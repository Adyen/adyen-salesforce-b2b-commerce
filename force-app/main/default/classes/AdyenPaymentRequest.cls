public with sharing class AdyenPaymentRequest {
//    public static PaymentRequest createPaymentRequest(Map<String, Object> inputData, Merchant__mdt merchant){
//        ccrz__E_Cart__c cart = (ccrz__E_Cart__c)inputData.get('cart');
//        PaymentRequest paymentRequest = new PaymentRequest();
//        OASAmount amount = new OASAmount();
//        amount.currency_x = cart.ccrz__CurrencyISOCode__c;
//        amount.value = (Long)cart.ccrz__TotalAmount__c * 100;
//        paymentRequest.amount = amount;
//
//        paymentRequest.reference = cart.Id;
//        paymentRequest.merchantAccount = merchant.Name__c;
//        paymentRequest.shopperReference = cart.ccrz__Account__c;
//        return paymentRequest;
//    }

   public static PaymentRequest createPaymentRequestFromStateData(String stateData){
        PaymentRequest paymentRequest = new PaymentRequest();
        Map<String, Object> stateDataObjects = (Map<String, Object>) JSON.deserializeUntyped(stateData);
        if(stateDataObjects.containsKey('riskData')){
            Map<String, Object> riskData = (Map<String, Object>) stateDataObjects.get('riskData');
            String serializedRiskData = JSON.serialize(riskData, true);
            paymentRequest.riskData = (RiskData)JSON.deserialize(serializedRiskData, RiskData.class);
        }

        if(stateDataObjects.containsKey('browserInfo')){
            Map<String, Object> browserInfo = (Map<String, Object>) stateDataObjects.get('browserInfo');
            String serializedBrowserInfo = JSON.serialize(browserInfo, true);
            paymentRequest.browserInfo = (BrowserInfo)JSON.deserialize(serializedBrowserInfo, BrowserInfo.class);
        }

        if(stateDataObjects.containsKey('paymentMethod')){
            Map<String, Object> paymentMethod = (Map<String, Object>) stateDataObjects.get('paymentMethod');
            paymentRequest.paymentMethod = getPaymentMethodDetails(paymentMethod);
        }

        return paymentRequest;
   }

    //TODOBAS remove this method
    public static PaymentMethodDetails setPaymentDetails(ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams){
        CardDetails card = new CardDetails();
        card.number_x = paymentParams.accountNumber;
        card.expiryMonth = String.valueOf(paymentParams.expirationMonth);
        card.expiryYear = String.valueOf(paymentParams.expirationYear);
        card.cvc = paymentParams.verificationCode;
        return card;
    }

    public static OASApplicationInfo updateApplicationInfo(OASApplicationInfo applicationInfo){
        OASCommonField adyenPaymentSource = new OASCommonField();
        adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
        adyenPaymentSource.version = '2.0.0';
        applicationInfo.adyenPaymentSource = adyenPaymentSource;

        OASExternalPlatform externalPlatform = new OASExternalPlatform();
        externalPlatform.name = 'SalesforceB2BCommerce';
        externalPlatform.version = '';
        applicationInfo.externalPlatform = externalPlatform;
        return applicationInfo;
    }

   public static PaymentMethodDetails getPaymentMethodDetails(Map<String, Object> paymentMethod){
        String paymentType = (String)paymentMethod.get('type');
        System.Debug('#### paymentType = ' + paymentType);
        if(paymentType == 'scheme'){
            CardDetails cardDetails = new CardDetails();
            cardDetails.holderName = (String)paymentMethod.get('holderName');
            cardDetails.encryptedCardNumber = (String)paymentMethod.get('encryptedCardNumber');
            cardDetails.encryptedExpiryMonth = (String)paymentMethod.get('encryptedExpiryMonth');
            cardDetails.encryptedExpiryYear = (String)paymentMethod.get('encryptedExpiryYear');
            cardDetails.encryptedSecurityCode = (String)paymentMethod.get('encryptedSecurityCode');
            return cardDetails;
        }
        else if(paymentType == 'ach'){
            ACHDetails achDetails = new ACHDetails();
            achDetails.encryptedBankAccountNumber = (String)paymentMethod.get('encryptedBankAccountNumber');
            achDetails.encryptedBankLocationId = (String)paymentMethod.get('encryptedBankLocationId');
            achDetails.ownerName = (String)paymentMethod.get('ownerName');
            return achDetails;
        }
        else if(paymentType == 'sepadirectdebit'){
            SepaDirectDebitDetails sepaDirectDebitDetails = new SepaDirectDebitDetails();
            sepaDirectDebitDetails.ibanNumber = (String)paymentMethod.get('sepa.ibanNumber');
            sepaDirectDebitDetails.ownerName = (String)paymentMethod.get('sepa.ownerName');
            return sepaDirectDebitDetails;
        }
        else {
            DefaultPaymentMethodDetails defaultPaymentMethodDetails = new DefaultPaymentMethodDetails();
            defaultPaymentMethodDetails.setType(paymentType);
            return defaultPaymentMethodDetails;
        }

   }

   public static Amount addAmount(){
        OASAmount amount = new OASAmount();
        amount.currency_x = cart.ccrz__CurrencyISOCode__c;
        amount.value = (Long)cart.ccrz__TotalAmount__c * 100;
        return amount;
   }
}