global with sharing class PmtAdyenPayController {

    public Boolean isGuest {
        get {
            return UserInfo.getUserType() == 'Guest';
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult placeOrderAdyen(ccrz.cc_RemoteActionContext ctx, String stateData) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);
            Map<String, Object> adyenResult = AdyenController.callAdyenPaymentHook(ctx.currentCartId, stateData, 'payments');
            Map<String, Object> paymentResult = (Map<String, Object>) adyenResult.get('paymentResult');
            if (!(Boolean)paymentResult.get('isFinal')) {
                cart.AdyenPaymentData__c = (String)paymentResult.get('paymentData');
                update cart;
                paymentResult.put('cartId', cart.ccrz__EncryptedId__c);
                res.data = paymentResult;
                return res;
            }
            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                Map<String, String> additionalData = (Map<String, String>)paymentResult.get('additionalData');
                AdyenController.checkToStorePaymentMethod(additionalData, res.inputContext.storeFront);
                //create order
                Map<String, Object> orderResult = AdyenController.placeOrder(adyenResult, cart.ccrz__EncryptedId__c);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                //Return orderId for confirmation page
                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
                res.data = paymentResult;
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

    @RemoteAction
    global static String handleOnAdditionalDetails(ccrz.cc_RemoteActionContext ctx, String details){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String storefrontName = res.inputContext.storeFront;
        return AdyenController.handleOnAdditionalDetails(details, storefrontName);
    }
}