public with sharing class AdyenPaymentMethodsRequest {
     public static PaymentMethodsRequest createPaymentMethodsRequest(ccrz__E_Cart__c cart, Merchant__mdt merchant){
            PaymentMethodsRequest paymentMethodsRequest = new PaymentMethodsRequest();
            paymentMethodsRequest.merchantAccount = merchant.Name__c;
            paymentMethodsRequest.amount = AdyenUtil.getAdyenAmount(cart);
            paymentMethodsRequest.shopperReference = cart.ccrz__Account__c;
            paymentMethodsRequest.allowedPaymentMethods = new List<String> {'card', 'ideal'};
            paymentMethodsRequest.countryCode = 'US';
            return paymentMethodsRequest;
     }
}