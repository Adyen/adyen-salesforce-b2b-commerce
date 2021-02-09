global with sharing class AdyenController {
    public static ccrz.cc_RemoteActionResult obtainPaymentMethods(ccrz.cc_RemoteActionContext ctx, Boolean isStoredPaymentMethod){
            ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
            try {
                //TODOBAS what if no cart --> Stored payment method
                ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);
                PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethods.getPaymentMethods(cart, isStoredPaymentMethod);

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

    public static Map<String, Object> handlePaymentsCall(ccrz__E_Cart__c cart, String stateData, Boolean isZeroAuth){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        PaymentsRequest paymentsRequest = AdyenPayments.createPaymentsRequest(stateData, cart, merchant, true);
        PaymentsResponse paymentsResponse = AdyenPayments.authorisePayment(merchant, paymentsRequest);
        return AdyenResponseHandler.handleResponse(paymentsResponse);
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