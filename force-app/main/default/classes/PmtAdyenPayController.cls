global with sharing class PmtAdyenPayController {

    public Boolean isGuest {
        get {
            return UserInfo.getUserType() == 'Guest';
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);
            Merchant__mdt merchant = AdyenUtil.getConfiguredMerchantAccount(cart);

            PaymentMethodsRequest paymentMethodsRequest = AdyenPaymentMethodsRequest.createPaymentMethodsRequest(cart, merchant);
            PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethodsRequest.getPaymentMethods(merchant, paymentMethodsRequest);

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

    @RemoteAction
    global static ccrz.cc_RemoteActionResult placeOrderAdyen(ccrz.cc_RemoteActionContext ctx, String stateData) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);

            Map<String, Object> inputParams = new Map<String, Object>();
            inputParams.put('accountType', 'adyencc');
            //Use token for stateData ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA
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

//                if(paymentResult.get('paymentData') !== null){
                    //TODOBAS save PaymentData to cart
                    cart.AdyenPaymentData__c = (String)paymentResult.get('paymentData');
                    update cart;
//                }
                paymentResult.put('cartId', cart.Id);
                res.data = paymentResult;
                return res;
            }

            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                //TODOBAS update order status to Submitted
                //create order
                Map<String, Object> orderResult = AdyenOrder.placeOrder(processResult, cart.Id);
                Map<String, String> orderIds = AdyenOrder.validateOrderResult(orderResult);
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

}