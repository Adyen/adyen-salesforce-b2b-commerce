public with sharing class AdyenDisable {
    public static DisableResponse disableStoredPayment(ccrz__E_StoredPayment__c storedPayment) {
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        DisableRequest disableRequest = new DisableRequest();
        disableRequest.merchantAccount = merchant.Merchant_Account__c;
        disableRequest.shopperReference = storedPayment.ccrz__Account__c;
        disableRequest.recurringDetailReference = storedPayment.ccrz__Token__c;
        AdyenClient client = new AdyenClient('{!$Credential.Password}', 'callout:AdyenDisableAPI');
        String jsonString = JSON.serialize(disableRequest, true);
        jsonString = Util.makeAdyenCompatible(jsonString);
        HttpResponse httpResponse = client.request(client.config, jsonString);
        DisableResponse disableResponse = new DisableResponse();
        if (AdyenUtil.isHttpResponseOK(httpResponse.getStatusCode())) {
            disableResponse = (DisableResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResponse.getBody()), DisableResponse.class);
        } else {
            System.Debug('## Response code ' + httpResponse.getStatusCode() + ' from /disable call');
            System.Debug('## /disable raw response: ' + httpResponse.getBody());
        }
        return disableResponse;
    }
}