public with sharing class AdyenPayments {
    public static PaymentRequest createPaymentRequest(String stateData, ccrz__E_Cart__c cart, Merchant__mdt merchant) {
        PaymentRequest paymentRequest = createPaymentRequestFromStateData(stateData);
        paymentRequest.merchantAccount = merchant.Merchant_Account__c;
        paymentRequest.amount = AdyenUtil.getAdyenAmount(cart.ccrz__CurrencyISOCode__c, cart.ccrz__TotalAmount__c);
        paymentRequest.applicationInfo = AdyenUtil.getApplicationInfo();
        paymentRequest.reference = cart.Id;
        paymentRequest.returnUrl = 'https://b2b-scoping-0920-developer-edition.na139.force.com/services/apexrest/AdyenReturnUrl/*';
        paymentRequest.shopperReference = cart.ccrz__Account__c;
        paymentRequest.additionalData = getAdditionalData();
        paymentRequest.channel = 'web';
        return paymentRequest;
    }

    private static PaymentRequest createPaymentRequestFromStateData(String stateData) {
        PaymentRequest paymentRequest = new PaymentRequest();
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

    public static PaymentsResponse authorisePayment(Merchant__mdt merchant, PaymentRequest request) {
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