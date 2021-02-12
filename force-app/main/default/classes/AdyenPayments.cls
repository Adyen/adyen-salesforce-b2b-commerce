public with sharing class AdyenPayments {
    public static PaymentsRequest createPaymentsRequest(String stateData, String cartId, Merchant__mdt merchant, Boolean isZeroAuth) {
        PaymentsRequest paymentsRequest = createPaymentsRequestFromStateData(stateData);
        paymentsRequest.merchantAccount = merchant.Merchant_Account__c;
        paymentsRequest.applicationInfo = AdyenUtil.getApplicationInfo();
        paymentsRequest.additionalData = getAdditionalData();
        paymentsRequest.channel = 'web';

        String returnPage = '/apex/AdyenReturn?merchantReference=';
        if(isZeroAuth){
            paymentsRequest.amount = AdyenUtil.getAdyenAmount(UserInfo.getDefaultCurrency(), 0.00);
            paymentsRequest.shopperReference = AdyenUtil.getAccountIdFromUser(UserInfo.getUserId()).AccountId;
            paymentsRequest.reference = 'addStoredMethod-' + cartId;
            returnPage = '/ccrz__MyAccount?viewState=viewAccount&cartId=';
        }
        else {
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(cartId);
            paymentsRequest.reference = cartId;
            paymentsRequest.shopperReference = cart.ccrz__Account__c;
            paymentsRequest.amount = AdyenUtil.getAdyenAmount(cart.ccrz__CurrencyISOCode__c, cart.ccrz__TotalAmount__c);
        }

        //TODOBAS dynamic get host
        paymentsRequest.returnUrl = 'https://componentsdev0221-developer-edition.na150.force.com' + returnPage + cartId;

        return paymentsRequest;
    }

    private static PaymentsRequest createPaymentsRequestFromStateData(String stateData) {
        PaymentsRequest paymentRequest = new PaymentsRequest();
        Map<String, Object> stateDataObjects = (Map<String, Object>) JSON.deserializeUntyped(stateData);
        if (stateDataObjects.containsKey('riskData')) {
            Map<String, Object> riskData = (Map<String, Object>) stateDataObjects.get('riskData');
            String serializedRiskData = JSON.serialize(riskData, true);
            paymentRequest.riskData = (RiskData) JSON.deserialize(serializedRiskData, RiskData.class);
        }

        if (stateDataObjects.containsKey('browserInfo')) {
            Map<String, Object> browserInfo = (Map<String, Object>) stateDataObjects.get('browserInfo');
            String serializedBrowserInfo = JSON.serialize(browserInfo, true);
            paymentRequest.browserInfo = (BrowserInfo) JSON.deserialize(serializedBrowserInfo, BrowserInfo.class);
        }

        if (stateDataObjects.containsKey('origin')) {
            paymentRequest.origin = (String)stateDataObjects.get('origin');
        }

        if (stateDataObjects.containsKey('paymentMethod')) {
            Map<String, Object> paymentMethod = (Map<String, Object>) stateDataObjects.get('paymentMethod');
            paymentRequest.paymentMethod = getPaymentMethodDetails(paymentMethod);
        }

        return paymentRequest;
    }

    private static PaymentMethodDetails getPaymentMethodDetails(Map<String, Object> paymentMethod) {
        String paymentType = (String) paymentMethod.get('type');
        if (paymentType == 'scheme') {
            CardDetails cardDetails = new CardDetails();
            cardDetails.holderName = (String) paymentMethod.get('holderName');
            cardDetails.encryptedCardNumber = (String) paymentMethod.get('encryptedCardNumber');
            cardDetails.encryptedExpiryMonth = (String) paymentMethod.get('encryptedExpiryMonth');
            cardDetails.encryptedExpiryYear = (String) paymentMethod.get('encryptedExpiryYear');
            cardDetails.encryptedSecurityCode = (String) paymentMethod.get('encryptedSecurityCode');
            return cardDetails;
        } else if (paymentType == 'ach') {
            ACHDetails achDetails = new ACHDetails();
            achDetails.encryptedBankAccountNumber = (String) paymentMethod.get('encryptedBankAccountNumber');
            achDetails.encryptedBankLocationId = (String) paymentMethod.get('encryptedBankLocationId');
            achDetails.ownerName = (String) paymentMethod.get('ownerName');
            return achDetails;
        } else if (paymentType == 'sepadirectdebit') {
            SepaDirectDebitDetails sepaDirectDebitDetails = new SepaDirectDebitDetails();
            sepaDirectDebitDetails.ibanNumber = (String) paymentMethod.get('sepa.ibanNumber');
            sepaDirectDebitDetails.ownerName = (String) paymentMethod.get('sepa.ownerName');
            return sepaDirectDebitDetails;
        } else if (!String.isBlank((String) paymentMethod.get('issuer'))) {
            IssuerDetails issuerDetails = new IssuerDetails();
            issuerDetails.setType(paymentType);
            issuerDetails.issuer = (String) paymentMethod.get('issuer');
            return issuerDetails;
        } else {
            DefaultPaymentMethodDetails defaultPaymentMethodDetails = new DefaultPaymentMethodDetails();
            defaultPaymentMethodDetails.setType(paymentType);
            return defaultPaymentMethodDetails;
        }
    }

    private static Map<String,String> getAdditionalData(){
        return new Map<String, String> {
                'allow3DS2' => 'true'
        };
    }

    public static PaymentsResponse authorisePayment(Merchant__mdt merchant, PaymentsRequest request) {
        PaymentsResponse paymentsResponse = new PaymentsResponse();
        AdyenClient client = new AdyenClient(merchant.API_Key__c, merchant.Payment_Endpoint__c);
        String jsonString = JSON.serialize(request, true);
        jsonString = Util.makeAdyenCompatible(jsonString);
        HttpResponse httpResponse = client.request(client.config, jsonString);
        if (AdyenUtil.isHttpResponseOK(httpResponse.getStatusCode())) {
            paymentsResponse = (PaymentsResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResponse.getBody()), PaymentsResponse.class);
        } else {
            System.Debug('## Response code ' + httpResponse.getStatusCode() + 'from /payments call');
            System.Debug('## /payments raw response: ' + httpResponse.getBody());
        }

        return paymentsResponse;
    }
}