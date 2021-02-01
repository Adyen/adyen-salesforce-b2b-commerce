public with sharing class AdyenPaymentsDetails {
    public static PaymentsResponse requestFromStateData(string stateData){
        PaymentsDetailsRequest paymentsDetailsRequest = (PaymentsDetailsRequest) JSON.deserialize(stateData, PaymentsDetailsRequest.class);
        return callPaymentsDetails(paymentsDetailsRequest);
    }

    public static PaymentsResponse requestAfterRedirect(Map<String, String> details, String cartEncryptedId){
        ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(cartEncryptedId);
        PaymentsDetailsRequest paymentsDetailsRequest = new PaymentsDetailsRequest();
        paymentsDetailsRequest.details = details;
        //Get saved payment data from cart
        paymentsDetailsRequest.paymentData = cart.AdyenPaymentData__c;
        return callPaymentsDetails(paymentsDetailsRequest);
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