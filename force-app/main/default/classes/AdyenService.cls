@RestResource(urlMapping='/AdyenService/*')
global with sharing class AdyenService {
    @HttpPost
    global static String adyenPaymentsDetails(){
        //TODOBAS Retrieve OrderId
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        System.debug('### requestData = ' + requestData);
        String currentCartId = (String)requestData.get('cartId');

        PaymentsDetailsRequest paymentsDetailsRequest = (PaymentsDetailsRequest) JSON.deserialize(requestBody, PaymentsDetailsRequest.class);

        System.debug('### paymentsDetailsRequest req = ' + paymentsDetailsRequest);
        PaymentsResponse paymentsResponse = AdyenPaymentsDetailsRequest.callPaymentsDetails(paymentsDetailsRequest);
        System.debug('### paymentsResponse = ' + paymentsResponse);
        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsResponse);

        //TODOBAS check if merchantReference from paymentsResponse is same as OrderId
        if (String.valueOf(paymentResult.get('resultCode')) == 'AUTHORISED') {
            System.debug('### payment Authorised and start updating Order Status');
            //TODOBAS update Order Status to Order Submitted

        }
        System.debug('### paymentResult = ' + paymentResult);
        return JSON.serialize(paymentResult, true);
//        PaymentsDetailsRequest paymentsDetailsRequest = AdyenPaymentsDetailsRequest.createPaymentsDetailsRequest(stateData);
//        System.debug('### paymentsDetailsRequest = ' + paymentsDetailsRequest);
//        PaymentsResponse paymentsResponse = AdyenPaymentsDetailsRequest.callPaymentsDetails(paymentsDetailsRequest);
//        System.debug('### paymentsResponse = ' + paymentsResponse);
//        return JSON.serialize(paymentsResponse, true);

//        return 'AdyenService Success';
    }
}