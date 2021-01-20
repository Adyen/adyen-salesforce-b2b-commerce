public with sharing class AdyenCaptureRequest {
    public static CaptureRequest createCaptureRequest(ccrz__E_TransactionPayment__c tp, Merchant__mdt merchant) {
        CaptureRequest captureRequest = new CaptureRequest();
        captureRequest.merchantAccount = merchant.Merchant_Account__c;
        captureRequest.originalReference = tp.ccrz__TransactionCode__c;
        captureRequest.modificationAmount = AdyenUtil.getAdyenAmount(tp.ccrz__CurrencyISOCode__c, tp.ccrz__Amount__c);
        captureRequest.reference = tp.Id;
        return captureRequest;
    }

    public static CaptureResponse sendCaptureRequest(Merchant__mdt merchant, CaptureRequest request) {
        CaptureResponse captureResponse = new CaptureResponse();
        AdyenClient client = new AdyenClient(merchant.API_Key__c, merchant.Capture_Endpoint__c);
        String jsonString = JSON.serialize(request, true);
        jsonString = Util.makeAdyenCompatible(jsonString);
        HttpResponse httpResponse = client.request(client.config, jsonString);

        if (AdyenUtil.isHttpResponseOK(httpResponse.getStatusCode())) {
            captureResponse = (CaptureResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResponse.getBody()), CaptureResponse.class);
        } else {
            System.Debug('## Response code ' + httpResponse.getStatusCode() + 'from /capture call');
            System.Debug('## /capture raw response: ' + httpResponse.getBody());
        }

        return captureResponse;
    }

}