global with sharing class PmtAdyenNewController {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getMyWalletConfig(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
            try {
                PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethods.getPaymentMethods(ctx.currentCartId, true);

                //Remove suffix and convert to string
                String jsonPaymentMethodsResponse = JSON.serialize(paymentMethodsResponse, true);
                String stringPaymentMethodsResponse = Util.makeAdyenCompatible(jsonPaymentMethodsResponse);
                Map<String, Object> myWalletConfig = new Map<String, Object> {
                    'adyenPaymentMethods' => stringPaymentMethodsResponse,
                    'adyenClientKey' => AdyenUtil.getClientKey(),
                    'adyenEnvironment' => AdyenUtil.getAdyenEnvironment()
                };
                res.data = myWalletConfig;
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
    global static String handleOnAdditionalDetails(ccrz.cc_RemoteActionContext ctx, String details){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String storefrontName = res.inputContext.storeFront;
        return AdyenController.handleOnAdditionalDetails(details, storefrontName);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addAdyenccStoredPayment(ccrz.cc_RemoteActionContext ctx, String stateData)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            //Handle the Zero Auth request
            Map<String, Object> paymentResult = AdyenController.handlePaymentsCall(ctx.currentCartId, stateData, true);
            if (!(Boolean)paymentResult.get('isFinal')) {
                res.data = paymentResult;
                return res;
            }

            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                Map<String, String> additionalData = (Map<String, String>)paymentResult.get('additionalData');
                AdyenController.checkToStorePaymentMethod(additionalData, res.inputContext.storeFront);
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