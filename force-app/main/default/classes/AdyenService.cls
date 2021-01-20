@RestResource(urlMapping='/AdyenService/*')
global with sharing class AdyenService {
    @HttpPost
    global static String adyenPaymentsDetails(){
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(requestBody);

        PaymentsDetailsRequest paymentsDetailsRequest = (PaymentsDetailsRequest) JSON.deserialize(requestBody, PaymentsDetailsRequest.class);
        PaymentsResponse paymentsResponse = AdyenPaymentsDetailsRequest.callPaymentsDetails(paymentsDetailsRequest);
        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsResponse);

        if(!(Boolean)paymentResult.get('isFinal')){
            return JSON.serialize(paymentResult, true);
        }

        String cartId = (String)requestData.get('cartId');
        if(!(paymentsResponse.merchantReference == cartId)){
            //TODOBAS restore cart
            return 'Invalid order';
        }

        if (String.valueOf(paymentResult.get('resultCode')) == 'AUTHORISED') {
            return AdyenOrder.updateOrderStatus(cartId);
        }

        return JSON.serialize(paymentResult, true);

    }
}