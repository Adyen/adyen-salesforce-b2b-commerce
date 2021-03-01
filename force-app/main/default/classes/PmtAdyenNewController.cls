global with sharing class PmtAdyenNewController {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        return AdyenController.obtainPaymentMethods(ctx, true);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addAdyenccStoredPayment(ccrz.cc_RemoteActionContext ctx, String stateData)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            //Handle the Zero Auth request
            Map<String, Object> handleResponse = AdyenController.handlePaymentsCall(ctx.currentCartId, stateData, true);
            Map<String, Object> paymentResult = (Map<String, Object>)handleResponse.get('paymentResult');
            if (!(Boolean)paymentResult.get('isFinal')) {
                res.data = paymentResult;
                return res;
            }

            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                Map<String, String> additionalData = (Map<String, String>)handleResponse.get('additionalData');
                String token = additionalData.get('recurring_recurringDetailReference');
                if(!String.isBlank(token)){
                    List<ccrz__E_StoredPayment__c> existingStoredPayments = AdyenUtil.getStoredPaymentByToken(token);
                    if(existingStoredPayments.isEmpty()){
                        AdyenController.createStoredPaymentMethod(additionalData, res);
                    }
                    else {
                        AdyenController.updateStoredPaymentMethod(existingStoredPayments, additionalData);
                    }
                }
                else {
                    System.Debug('#### No recurringDetailReference in Adyen response ');
                }

                res.success = true;
                return res;
            }

            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message('Payment failed, result is ' + paymentResult);
            res.messages.add(m);
        }
        catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            //Exception handling here
            System.Debug('#### exception ' + e.getMessage() + e.getStackTraceString());
            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(e.getMessage());
            res.messages.add(m);
        }
        return res;
    }
}