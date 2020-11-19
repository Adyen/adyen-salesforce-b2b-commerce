public with sharing class AdyenPaymentRequest {
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

       public static PaymentMethodDetails getPaymentMethodDetails(Map<String, Object> paymentMethod){
            String paymentType = (String)paymentMethod.get('type');
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
}