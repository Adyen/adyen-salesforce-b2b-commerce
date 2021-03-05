global inherited sharing class cc_adyencc_ccPaymentProcessor extends ccrz.ccPaymentProcessor {
    global override Map<String, Object> preProcess(Map<String, Object> paymentProcessorInput) {
        if (paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX) == ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT) {
            ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams) paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c) paymentProcessorInput.get('cart');
            //Zero Auth transaction does not have cart, also no capture delay needed
            if(!String.isBlank(cart.ccrz__EncryptedId__c)){
                paymentParams.transactionType = AdyenUtil.getConfiguredCaptureDelay(cart);
            }
            //Delete paymentData from cart
            if(!String.isBlank(cart.AdyenPaymentData__c)){
                cart.AdyenPaymentData__c = '';
                update cart;
            }
            String stateData = String.valueOf(paymentParams.token);
            String adyenCall = (String)paymentProcessorInput.get('adyenCall');
            Map<String, Object> paymentResult = AdyenController.handleCalloutAdyen(cart, stateData, adyenCall);
            paymentProcessorInput.put('paymentResult', paymentResult);
            paymentParams.transactionCode = (String)paymentResult.get('pspReference');
            //Remove the stateData from payment
            paymentParams.token = '';

            paymentProcessorInput.put(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA, paymentParams);
        }

        return paymentProcessorInput;
    }
}