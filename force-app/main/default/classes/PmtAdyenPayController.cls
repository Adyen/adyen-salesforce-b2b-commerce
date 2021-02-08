global with sharing class PmtAdyenPayController {

    public Boolean isGuest {
        get {
            return UserInfo.getUserType() == 'Guest';
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        return AdyenController.obtainPaymentMethods(ctx, false);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult placeOrderAdyen(ccrz.cc_RemoteActionContext ctx, String stateData) {
        return AdyenController.processPayment(ctx, stateData);
    }

}