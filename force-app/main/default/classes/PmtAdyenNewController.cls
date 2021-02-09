global with sharing class PmtAdyenNewController {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        return AdyenController.obtainPaymentMethods(ctx, true);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addAdyenccStoredPayment(ccrz.cc_RemoteActionContext ctx, String stateData)
    {
        return AdyenController.processPayment(ctx, stateData);
    }
}