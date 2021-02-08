public with sharing class AdyenPaymentMethods {
    private static PaymentMethodsRequest createPaymentMethodsRequest(ccrz__E_Cart__c cart, Merchant__mdt merchant) {
        PaymentMethodsRequest paymentMethodsRequest = new PaymentMethodsRequest();
        paymentMethodsRequest.merchantAccount = merchant.Merchant_Account__c;
        paymentMethodsRequest.amount = AdyenUtil.getAdyenAmount(cart.ccrz__CurrencyISOCode__c, cart.ccrz__TotalAmount__c);
        paymentMethodsRequest.shopperReference = cart.ccrz__Account__c;

        //TODOBAS countryCode from address
        paymentMethodsRequest.countryCode = 'US';
        return paymentMethodsRequest;
    }

    public static PaymentMethodsResponse getPaymentMethods(ccrz__E_Cart__c cart) {
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        PaymentMethodsRequest paymentMethodsRequest = createPaymentMethodsRequest(cart, merchant);
        AdyenClient client = new AdyenClient(merchant.API_Key__c, merchant.PaymentMethods_Endpoint__c);
        String jsonString = JSON.serialize(paymentMethodsRequest, true);
        jsonString = Util.makeAdyenCompatible(jsonString);
        HttpResponse httpResponse = client.request(client.config, jsonString);

        PaymentMethodsResponse paymentMethods = new PaymentMethodsResponse();
        if (AdyenUtil.isHttpResponseOK(httpResponse.getStatusCode())) {
            paymentMethods = (PaymentMethodsResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResponse.getBody()), PaymentMethodsResponse.class);
        } else {
            System.Debug('## Response code ' + httpResponse.getStatusCode() + 'from /paymentMethods call');
            System.Debug('## /paymentMethods raw response: ' + httpResponse.getBody());
        }
        return paymentMethods;
    }
}