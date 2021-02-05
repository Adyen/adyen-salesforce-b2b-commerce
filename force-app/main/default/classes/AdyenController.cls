global with sharing class AdyenController {
    public static ccrz.cc_RemoteActionResult obtainPaymentMethods(ccrz.cc_RemoteActionContext ctx, Boolean isStoredPaymentMethod){
            ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
            System.debug('### getPaymentMethods initiated ctx= ' + ctx);
            try {
                ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);
                System.debug('### getPaymentMethods initiated cart= ' + cart);
                PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethods.getPaymentMethods(cart, isStoredPaymentMethod);
                System.debug('### paymentMethodsResponse = ' + paymentMethodsResponse);

                //Remove suffix and convert to string
                String jsonPaymentMethodsResponse = JSON.serialize(paymentMethodsResponse, true);
                String stringPaymentMethodsResponse = Util.makeAdyenCompatible(jsonPaymentMethodsResponse);

                res.data = stringPaymentMethodsResponse;
                res.success = true;
            } catch (Exception e) {
                ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
                System.Debug('## ERROR CATCH ' + e);
                res.success = false;
            } finally {
                ccrz.ccLog.close(res);
            }
            return res;
    }

    public static ccrz.cc_RemoteActionResult processPayment(ccrz.cc_RemoteActionContext ctx, String stateData){
         ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);

            Map<String, Object> inputParams = new Map<String, Object>();
            inputParams.put('accountType', 'adyencc');
            //Use token for stateData
            inputParams.put('token', stateData);

            Map<String, Object> paymentProcessorInput = new Map<String, Object>{
                    ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => JSON.serialize(inputParams), //stateData,
                    ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT,
                    ccrz.cc_hk_Payment.PARAM_CART => cart,
                    ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => 'adyencc'
            };

            Map<String, Object> processResult = paymentHook.processPayment(paymentProcessorInput);
            Map<String, Object> paymentResult = (Map<String, Object>) processResult.get('paymentResult');

            if (!(Boolean)paymentResult.get('isFinal')) {
                cart.AdyenPaymentData__c = (String)paymentResult.get('paymentData');
                update cart;
                paymentResult.put('cartId', cart.Id);
                res.data = paymentResult;
                return res;
            }

            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                //create order
                Map<String, Object> orderResult = AdyenController.placeOrder(processResult, cart.Id);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                //Return orderId for confirmation page
                res.data = orderIds.get('orderIdEnc');
                res.success = true;
                return res;
            }

            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message('Payment failed, result is ' + paymentResult);
            res.messages.add(m);

        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            //Exception handling here
            System.Debug('#### exception ' + e.getMessage() + e.getStackTraceString());
            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(e.getMessage());
            res.messages.add(m);
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    public static Map<String, Object> placeOrder(Map<String, Object> processResult, String cartId) {
            Map<String, Object> createOrderParams = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                    ccrz.ccApiCart.TRANSPAYMENTDATA =>
                            processResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA),
                    ccrz.ccApiCart.PAYMENTRESULT => processResult,
                    ccrz.ccApiCart.CART_ENCID => cartId
            };
            if (Test.isRunningTest()) {
                createOrderParams.put(ccrz.ccApiCart.SKIP_VALID_CHECK, true);
            }

            //Converts a cart to a corresponding order.
            Map<String, Object> placeResult = ccrz.ccApiCart.place(createOrderParams);
            return placeResult;
    }

     public static Map<String, String> validateOrderResult(Map<String, Object> placeResult) {
        String orderId = (String) placeResult.get('orderId');
        ccrz__E_Order__c[] placedOrder = getOrderById(orderId);
        Map<String, String> orderResult = new Map<String, String>();
        if (placedOrder <> null && placedOrder.size() == 1) {
            orderResult.put('orderId', orderId);
            orderResult.put('orderIdEnc', placedOrder[0].ccrz__EncryptedId__c);
            orderResult.put('cartId', placedOrder[0].ccrz__OriginatedCart__c);
        }
        return orderResult;
    }

    private static ccrz__E_Order__c[] getOrderById(String orderId){
        return  [
                SELECT Id, ccrz__EncryptedId__c, ccrz__OriginatedCart__c
                FROM ccrz__E_Order__c
                WHERE Id = :orderId
                LIMIT 1
        ];
    }
}