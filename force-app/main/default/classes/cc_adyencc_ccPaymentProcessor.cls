global inherited sharing class cc_adyencc_ccPaymentProcessor extends ccrz.ccPaymentProcessor {
    global override Map<String, Object> preProcess(Map<String, Object> paymentProcessorInput) {
        //checkout flow
        if (paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX) == ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT) {
            ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams) paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c) paymentProcessorInput.get('cart');
            paymentParams.transactionType = AdyenUtil.getConfiguredCaptureDelay(cart);
            String stateData = String.valueOf(paymentParams.token);

            Map<String, Object> handleResponse = AdyenController.handlePaymentsCall(cart.ccrz__EncryptedId__c, stateData, false);
            Map<String, Object> paymentResult = (Map<String, Object>)handleResponse.get('paymentResult');
            paymentProcessorInput.put('paymentResult', paymentResult);

            paymentParams.transactionCode = (String)paymentResult.get('pspReference');
            //Remove the stateData from payment
            paymentParams.token = '';

            paymentProcessorInput.put(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA, paymentParams);
        }

        return paymentProcessorInput;
    }
}