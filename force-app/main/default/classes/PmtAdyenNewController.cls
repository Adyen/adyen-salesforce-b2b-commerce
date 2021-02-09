global with sharing class PmtAdyenNewController {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        return AdyenController.obtainPaymentMethods(ctx, true);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addAdyenccStoredPayment(ccrz.cc_RemoteActionContext ctx, String stateData)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(ctx.currentCartId);
        //Handle the Zero Auth request
        Map<String, Object> paymentResult = AdyenController.handlePaymentsCall(cart, stateData, true);
        //TODOBAS handle payments response
        return res;
    }
}