global with sharing

class PmtAdyenPayController {

    public Boolean isGuest

    {
        get {
        return UserInfo.getUserType() == 'Guest';
    }
    }

    @RemoteAction
    global

    static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_Cart__c cart = AdyenUtil.getCartFromDatabase(ctx.currentCartId);
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
    global

    static ccrz.cc_RemoteActionResult placeOrderAdyen(ccrz.cc_RemoteActionContext ctx, String stateData) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
            ccrz__E_Cart__c cart = AdyenUtil.getCartFromDatabase(ctx.currentCartId);

            Map<String, Object> inputParams = new Map<String, Object>();
            inputParams.put('accountType', 'adyencc');
            //Use token for stateData
            inputParams.put('token', stateData);

            Map<String, Object> paymentProcessorInput = new Map<String, Object> {
                ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA =>JSON.serialize(inputParams), //stateData,
                        ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX =>ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT,
                        ccrz.cc_hk_Payment.PARAM_CART =>cart,
                        ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE =>'adyencc'
            } ;

            Map<String, Object> processResult = paymentHook.processPayment(paymentProcessorInput);
            //TODOBAS return paymentResponse if not isFinal

            //Here starts the Place Order
            Map<String, Object> placeParams = new Map<String, Object> {
                ccrz.ccApi.API_VERSION =>9,
                        ccrz.ccApiCart.TRANSPAYMENTDATA =>
                processResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA),
                        ccrz.ccApiCart.PAYMENTRESULT =>processResult,
                        ccrz.ccApiCart.CART_ENCID =>cart.Id
            } ;
            if (Test.isRunningTest()) {
                placeParams.put(ccrz.ccApiCart.SKIP_VALID_CHECK, true);
            }

            Map<String, Object> placeResult = ccrz.ccApiCart.place(placeParams);
            res = validatePlaceResult(placeResult, res);

        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            //Exception handling here
            System.Debug('#### exception ' + e.getMessage() + e.getStackTraceString());
            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(e.getMessage());
            res.messages.add(m);
            return res;
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    private static ccrz.cc_RemoteActionResult validatePlaceResult(Map<String, Object> placeResult, ccrz.cc_RemoteActionResult res) {
//        if(!placeResult.SUCCESS){
//           //TODOBAS Fail the order
//        }
        String orderId = (String) placeResult.get('orderId');
        ccrz__E_Order__c[] placedOrder = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Order__c WHERE Id =:orderId LIMIT
        1];
        Map<String, String> orderResult = new Map<String, String>();
        if (placedOrder <>null && placedOrder.size() == 1){
            orderResult.put('ordId', placedOrder[0].ccrz__EncryptedId__c);
        }
        res.success = true;
        res.data = orderResult;
        return res;
    }
}