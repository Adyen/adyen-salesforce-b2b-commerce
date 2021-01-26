public with sharing class AdyenPaymentsDetailsRequest {
    //TODOBAS check where this is called and optimise /payments/details call
   public static PaymentsResponse adyenPaymentsDetails(String stateData){
        PaymentsDetailsRequest paymentsDetailsRequest = createPaymentsDetailsRequestFromStateData(stateData);
        PaymentsResponse paymentsDetailsResponse = callPaymentsDetails(paymentsDetailsRequest);
        return paymentsDetailsResponse;
    }

    public static PaymentsDetailsRequest createPaymentsDetailsRequestFromStateData(String stateData) {
        return (PaymentsDetailsRequest) JSON.deserialize(stateData, PaymentsDetailsRequest.class);
    }

    public static PaymentsResponse callPaymentsDetails(PaymentsDetailsRequest request){
        PaymentsResponse paymentsDetailsResponse = new PaymentsResponse();
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');

        AdyenClient client = new AdyenClient(merchant.API_Key__c, merchant.Payments_Details_Endpoint__c);
        String jsonString = JSON.serialize(request, true);
        jsonString = Util.makeAdyenCompatible(jsonString);
        HttpResponse httpResponse = client.request(client.config, jsonString);
        if (AdyenUtil.isHttpResponseOK(httpResponse.getStatusCode())) {
            paymentsDetailsResponse = (PaymentsResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResponse.getBody()), PaymentsResponse.class);
        } else {
            System.Debug('## Response code ' + httpResponse.getStatusCode() + 'from /payments/details call');
            System.Debug('## /payments/details raw response: ' + httpResponse.getBody());
        }

        return paymentsDetailsResponse;
    }
}