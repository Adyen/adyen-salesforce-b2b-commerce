global inherited sharing class AdyenController {
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

    public static Map<String, Object> handlePaymentsDetailsCall(String stateData){
        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestFromStateData(stateData);
        return new Map<String, Object> {
            'paymentResult' => AdyenResponseHandler.handleResponse(paymentsDetailsResponse),
            'additionalData' => paymentsDetailsResponse.additionalData
        };
    }

    public static Map<String, Object> handleCalloutAdyen(ccrz__E_Cart__c cart, String stateData, String adyenCall) {
       if(adyenCall == 'payments'){
            return handlePaymentsCall(cart.ccrz__EncryptedId__c, stateData, false);
       }
       return handlePaymentsDetailsCall(stateData);
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
        List<String> expiryDate = additionalData.get('expiryDate').split('/');
        storedPayment.ccrz__ExpMonth__c = Decimal.valueOf(expiryDate.get(0));
        storedPayment.ccrz__ExpYear__c = Decimal.valueOf(expiryDate.get(1));
        insert storedPayment;
    }

    public static Map<String, Object> createProcessorInput(String cartId, String stateData, String adyenCall){
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(cartId);
            Map<String, String> inputParams = new Map<String, String>{
                'accountType' => 'adyencc',
                'token' => stateData
            };

            Map<String, Object> paymentProcessorInput = new Map<String, Object>{
                    ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => JSON.serialize(inputParams), //stateData,
                    ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT,
                    ccrz.cc_hk_Payment.PARAM_CART => cart,
                    ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => 'adyencc',
                    'adyenCall' => adyenCall
            };
        return paymentProcessorInput;
    }

    public static void updateStoredPaymentMethod(List<ccrz__E_StoredPayment__c> existingStoredPayments, Map<String, String> additionalData){
        //There can only be one stored payment with recurringDetailReference as token
        ccrz__E_StoredPayment__c existingStoredPayment = existingStoredPayments.get(0);
        existingStoredPayment.ccrz__DisplayName__c = additionalData.get('cardHolderName');
        List<String> expiryDate = additionalData.get('expiryDate').split('/');
        existingStoredPayment.ccrz__ExpMonth__c = Decimal.valueOf(expiryDate.get(0));
        existingStoredPayment.ccrz__ExpYear__c = Decimal.valueOf(expiryDate.get(1));
        update existingStoredPayment;
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