public with sharing class AdyenPaymentMethods {
    private static PaymentMethodsRequest createPaymentMethodsRequest(String cartId, Merchant__mdt merchant, Boolean isStoredPaymentMethod) {
        PaymentMethodsRequest paymentMethodsRequest = new PaymentMethodsRequest();
        paymentMethodsRequest.merchantAccount = merchant.Merchant_Account__c;
        paymentMethodsRequest.allowedPaymentMethods = new List<String>{'scheme'};
        if(isStoredPaymentMethod){
            //No cart through My Wallet
            paymentMethodsRequest.shopperReference = AdyenUtil.getAccountIdFromUser(UserInfo.getUserId()).AccountId;
        }
        else {
            ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(cartId);
            paymentMethodsRequest.amount = AdyenUtil.getAdyenAmount(cart.ccrz__CurrencyISOCode__c, cart.ccrz__TotalAmount__c);
            paymentMethodsRequest.shopperReference = cart.ccrz__Account__c;
            List<ccrz__E_ContactAddr__c> billingAddress = [Select ccrz__CountryISOCode__c from ccrz__E_ContactAddr__c Where Id = :cart.ccrz__BillTo__c];
            paymentMethodsRequest.countryCode = billingAddress[0].ccrz__CountryISOCode__c;
        }
        return paymentMethodsRequest;
    }

    public static PaymentMethodsResponse getPaymentMethods(String cartId, Boolean isStoredPaymentMethod) {
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        PaymentMethodsRequest paymentMethodsRequest = createPaymentMethodsRequest(cartId, merchant, isStoredPaymentMethod);
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