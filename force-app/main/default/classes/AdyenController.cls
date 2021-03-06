global inherited sharing class AdyenController {
    public static Map<String, Object> handlePaymentsCall(String cartId, String stateData, Boolean isZeroAuth){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        PaymentsRequest paymentsRequest = AdyenPayments.createPaymentsRequest(stateData, cartId, merchant, isZeroAuth);
        PaymentsResponse paymentsResponse = AdyenPayments.authorisePayment(merchant, paymentsRequest);
        return AdyenResponseHandler.handleResponse(paymentsResponse);
    }

    public static Map<String, Object> handlePaymentsDetailsCall(String stateData){
        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestFromStateData(stateData);
        return AdyenResponseHandler.handleResponse(paymentsDetailsResponse);
    }

    public static Map<String, Object> handleCalloutAdyen(ccrz__E_Cart__c cart, String stateData, String adyenCall) {
       if(adyenCall == 'payments'){
            return handlePaymentsCall(cart.ccrz__EncryptedId__c, stateData, false);
       }
       return handlePaymentsDetailsCall(stateData);
    }

    public static String handleOnAdditionalDetails(String stateData, String storefrontName){
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(stateData);
        String cartId = (String)requestData.get('cartId');

        Map<String, Object> adyenResult = callAdyenPaymentHook(cartId, stateData, 'paymentsDetails');

        Boolean zeroAuthSuccess = false;
        Map<String, Object> paymentResult = (Map<String, Object>) adyenResult.get('paymentResult');
        Map<String, String> additionalData = (Map<String, String>)paymentResult.get('additionalData');
        String merchantReference = (String)paymentResult.get('merchantReference');
        if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED && (merchantReference == cartId || merchantReference.contains('addStoredMethod'))) {
            if(merchantReference.contains('addStoredMethod')){
                zeroAuthSuccess = true;
            }
            else {
                //create order
                Map<String, Object> orderResult = AdyenController.placeOrder(adyenResult, cartId);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                //Return orderId for confirmation page
                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
            }
            AdyenController.checkToStorePaymentMethod(additionalData, storefrontName);
        }
        else {
            System.debug('Payment failed or invalid merchantReference: ' + merchantReference);
        }
        paymentResult.put('zeroAuthSuccess', zeroAuthSuccess);
        return JSON.serialize(paymentResult, true);
    }

    public static Map<String, Object> callAdyenPaymentHook(String cartId, String stateData, String adyenEndpoint){
        ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
        Map<String, Object> paymentProcessorInput = AdyenController.createProcessorInput(cartId, stateData, adyenEndpoint);
        return paymentHook.processPayment(paymentProcessorInput);
    }

    public static void checkToStorePaymentMethod(Map<String, String> additionalData, string storefrontName){
        String token = additionalData.get('recurring_recurringDetailReference');
        if(!String.isBlank(token)){
            List<ccrz__E_StoredPayment__c> existingStoredPayments = AdyenUtil.getStoredPaymentByToken(token);
            if(existingStoredPayments.isEmpty()){
                createStoredPaymentMethod(additionalData, storefrontName);
            }
            else {
                updateStoredPaymentMethod(existingStoredPayments, additionalData);
            }
        }
        else {
            System.Debug('#### No recurringDetailReference in Adyen response ');
        }
    }

    private static void createStoredPaymentMethod(Map<String, String> additionalData, String storefrontName){
        ccrz__E_StoredPayment__c storedPayment = setStoredPaymentMethodDetails(new ccrz__E_StoredPayment__c(), additionalData);
        storedPayment.ccrz__Token__c = additionalData.get('recurring_recurringDetailReference');
        storedPayment.ccrz__Account__c = AdyenUtil.getAccountIdFromUser(UserInfo.getUserId()).AccountId;
        storedPayment.ccrz__AccountNumber__c = (String)additionalData.get('cardBin') + '******' + (String)additionalData.get('cardSummary');
        storedPayment.ccrz__User__c = UserInfo.getUserId();
        storedPayment.ccrz__Storefront__c = storefrontName;
        storedPayment.ccrz__AccountType__c = 'adyencc';
        insert storedPayment;
    }

     private static void updateStoredPaymentMethod(List<ccrz__E_StoredPayment__c> existingStoredPayments, Map<String, String> additionalData){
        //There can only be one stored payment with recurringDetailReference as token
        ccrz__E_StoredPayment__c existingStoredPayment = setStoredPaymentMethodDetails(existingStoredPayments.get(0), additionalData);
        update existingStoredPayment;
    }

    public static ccrz__E_StoredPayment__c setStoredPaymentMethodDetails(ccrz__E_StoredPayment__c storedPaymentMethod, Map<String, String> additionalData){
        storedPaymentMethod.ccrz__DisplayName__c = additionalData.get('cardHolderName');
        storedPaymentMethod.ccrz__Enabled__c = true;
        List<String> expiryDate = additionalData.get('expiryDate').split('/');
        storedPaymentMethod.ccrz__ExpMonth__c = Decimal.valueOf(expiryDate.get(0));
        storedPaymentMethod.ccrz__ExpYear__c = Decimal.valueOf(expiryDate.get(1));
        return storedPaymentMethod;
    }

    public static Map<String, Object> createProcessorInput(String cartId, String stateData, String adyenCall){
            Boolean isZeroAuth = String.isBlank(cartId);
            ccrz__E_Cart__c cart = !isZeroAuth ? AdyenUtil.getCartByEncryptedId(cartId) : new ccrz__E_Cart__c();
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

    public static Map<String, Object> placeOrder(Map<String, Object> processResult, String cartId) {
            Map<String, Object> createOrderParams = new Map<String, Object>{
                    ccrz.ccApiCart.PAYMENTDATA => JSON.serialize((Map<String, Object>) processResult.get('paymentResult')),
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