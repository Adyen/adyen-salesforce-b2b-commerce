@RestResource(urlMapping='/AdyenService/*')
global without sharing class AdyenService {
    @HttpPost
    global static String adyenPaymentsDetails(){
        String stateData = RestContext.request.requestBody.toString();
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(stateData);
        String cartId = (String)requestData.get('cartId');
        ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
        Map<String, Object> paymentProcessorInput = AdyenController.createProcessorInput(cartId, stateData, 'paymentsDetails');
        Map<String, Object> processResult = paymentHook.processPayment(paymentProcessorInput);
        Boolean zeroAuthSuccess = false;
        Map<String, Object> paymentResult = (Map<String, Object>) processResult.get('paymentResult');
        if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
            String merchantReference = (String)paymentResult.get('merchantReference');
            if(merchantReference == cartId){
                //create order
                Map<String, Object> orderResult = AdyenController.placeOrder(processResult, cartId);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                //Return orderId for confirmation page
                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
            }
            else if(merchantReference.contains('addStoredMethod')){
                zeroAuthSuccess = true;
            }
            else {
                System.debug('Invalid merchantReference: ' + merchantReference);
            }
        }
        paymentResult.put('zeroAuthSuccess', zeroAuthSuccess);
        return JSON.serialize(paymentResult, true);
    }
}