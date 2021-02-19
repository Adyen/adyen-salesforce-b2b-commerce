@RestResource(urlMapping='/AdyenService/*')
global with sharing class AdyenService {
    @HttpPost
    global static String adyenPaymentsDetails(){
        String stateData = RestContext.request.requestBody.toString();
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(stateData);
        String cartId = (String)requestData.get('cartId');
        System.debug('### cartId = ' + cartId);
//        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestFromStateData(stateData);
//        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsDetailsResponse);
        ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
        Map<String, Object> paymentProcessorInput = AdyenController.createProcessorInput(cartId, stateData, 'paymentsDetails');
        System.debug('### AdyenService Before PaymentHook.ProcessPayment = ' + paymentProcessorInput);
        Map<String, Object> processResult = paymentHook.processPayment(paymentProcessorInput);
        System.debug('### AdyenService PaymentHook.ProcessPayment  processResult = ' + processResult);
        Boolean orderSuccess = false;
        Map<String, Object> paymentResult = (Map<String, Object>) processResult.get('paymentResult');
        if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                System.debug('### AUTHORISED');
                //Delete Payment Data from cart
//                cart.AdyenPaymentData__c = '';
//                update cart;
                //create order
                Map<String, Object> orderResult = AdyenController.placeOrder(processResult, cartId);
                System.debug('### AUTHORISED orderResult = ' + orderResult);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                System.debug('### AUTHORISED orderIds = ' + orderIds);
                //Return orderId for confirmation page
                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
                orderSuccess = true;
            }

////        if((Boolean)paymentResult.get('isFinal') && paymentsDetailsResponse.merchantReference == cartId){
////        System.debug('### merchant == cartId');
//            if (String.valueOf(paymentResult.get('resultCode')) == 'AUTHORISED') {
//            System.debug('### AUTHORISED');
//                //TODOBAS place order success=false
////                paymentProcessorInput.put('paymentResult', paymentResult);
////                paymentParams.transactionCode = (String)paymentResult.get('pspReference');
////                paymentProcessorInput.put(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA, paymentParams);
//
//                Map<String, Object> orderResult = AdyenController.placeOrder(paymentResult, cartId);
//                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
//                //Return orderId for confirmation page
//                paymentResult.put('orderIdEnc', orderIds.get('orderIdEnc'));
//                orderSuccess = true;
//            }
//        }

        paymentResult.put('orderSuccess', orderSuccess);
        return JSON.serialize(paymentResult, true);
    }
}