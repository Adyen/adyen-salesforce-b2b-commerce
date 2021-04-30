global class cc_adyencc_hk_Payment extends ccrz.cc_hk_Payment {
    global override Map<String,Object> removeStoredPayment(Map<String,Object> inputData) {
        Map<String,Object> returnData = new Map<String,Object>();
        ccrz__E_StoredPayment__c storedPayment = AdyenUtil.getStoredPayment((String)inputData.get(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID));
        if(storedPayment.ccrz__AccountType__c == 'adyencc' && storedPayment.ccrz__User__c == UserInfo.getUserId())
        {
            DisableResponse disableResponse = AdyenDisable.disableStoredPayment(storedPayment);
            if(disableResponse.response == '[detail-successfully-disabled]')
            {
                returnData = super.removeStoredPayment(inputData);
            }
            else
            {
                returnData.put('result', false);
            }
        }
        else {
            returnData = super.removeStoredPayment(inputData);
        }

        return returnData;
    }

    global override Map<String,Object> fetchPaymentTypes(Map<String,Object> inputData) {
        PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethods.getPaymentMethods(ccrz.cc_CallContext.currCartId, false);
        //Remove suffix and convert to string
        String jsonPaymentMethodsResponse = JSON.serialize(paymentMethodsResponse, true);
        String stringPaymentMethodsResponse = Util.makeAdyenCompatible(jsonPaymentMethodsResponse);
        Map<String,Object> returnData =  super.fetchPaymentTypes(inputData);
        Map<String,Object> paymentTypes = (Map<String,Object>)returnData.get('paymentTypes');
        Map<String,Object> adyencc = (Map<String,Object>)paymentTypes.get('adyencc');
        adyencc.put('adyenPaymentMethods', stringPaymentMethodsResponse);
        adyencc.put('adyenClientKey', AdyenUtil.getClientKey());
        adyencc.put('adyenEnvironment', AdyenUtil.getAdyenEnvironment());
        return returnData;
    }

}