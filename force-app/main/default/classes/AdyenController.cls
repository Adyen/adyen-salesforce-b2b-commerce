global with sharing class AdyenController {
    public static ccrz.cc_RemoteActionResult obtainPaymentMethods(ccrz.cc_RemoteActionContext ctx, Boolean isStoredPaymentMethod){
            ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
            try {
                PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethods.getPaymentMethods(ctx.currentCartId, isStoredPaymentMethod);

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

    public static Map<String, Object> handlePaymentsCall(String cartId, String stateData, Boolean isZeroAuth){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        PaymentsRequest paymentsRequest = AdyenPayments.createPaymentsRequest(stateData, cartId, merchant, isZeroAuth);
        PaymentsResponse paymentsResponse = AdyenPayments.authorisePayment(merchant, paymentsRequest);
        return new Map<String, Object> {
            'paymentResult' => AdyenResponseHandler.handleResponse(paymentsResponse),
            'additionalData' => paymentsResponse.additionalData
        };
    }

    public static void createStoredPaymentMethod(Map<String, String> additionalData, ccrz.cc_RemoteActionResult res){
        ccrz__E_StoredPayment__c storedPayment = new ccrz__E_StoredPayment__c();
        storedPayment.ccrz__Enabled__c = true;
        storedPayment.ccrz__Token__c = additionalData.get('recurring_recurringDetailReference');
        storedPayment.ccrz__DisplayName__c = additionalData.get('cardHolderName');
        storedPayment.ccrz__Account__c = AdyenUtil.getAccountIdFromUser(UserInfo.getUserId()).AccountId;
        storedPayment.ccrz__AccountNumber__c = (String)additionalData.get('cardBin') + '******' + (String)additionalData.get('cardSummary');
        storedPayment.ccrz__User__c = UserInfo.getUserId();
        storedPayment.ccrz__Storefront__c = res.inputContext.storeFront;
        storedPayment.ccrz__AccountType__c = 'adyencc';

        insert storedPayment;
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