@RestResource(urlMapping='/AdyenService/*')
global with sharing class AdyenService {
    @HttpPost
    global static String adyenPaymentsDetails(){
        String stateData = RestContext.request.requestBody.toString();
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(stateData);

        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestFromStateData(stateData);
        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsDetailsResponse);

        Boolean orderSuccess = false;
        String cartId = (String)requestData.get('cartId');

        if((Boolean)paymentResult.get('isFinal') && paymentsDetailsResponse.merchantReference == cartId){
            if (String.valueOf(paymentResult.get('resultCode')) == 'AUTHORISED') {
                //TODOBAS place order success=false
                Map<String, Object> orderResult = AdyenController.placeOrder(paymentResult, cartId);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                //Return orderId for confirmation page
                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
                orderSuccess = true;
            }
        }

        paymentResult.put('orderSuccess', orderSuccess);
        return JSON.serialize(paymentResult, true);
    }
}