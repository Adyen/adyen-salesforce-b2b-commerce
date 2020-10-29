global inherited sharing class cc_adyencc_ccPaymentProcessor extends ccrz.ccPaymentProcessor{
    global override Map<String,Object> preProcess(Map<String,Object> inputData) {
        //System.debug('preProcess');
        //system.debug(inputData);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'preProcess', inputData );
        //checkout flow
        if(inputData.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX) == ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT)
        {
            ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams)inputData.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            String accountNumber = paymentParams.accountNumber;
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c)inputData.get('cart');
            Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
            Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
            Merchant__mdt merchant = Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));
            Boolean immediateCapture = Boolean.valueOf(mapConfigs.get('pmt_adyencc.immediate_capture'));

            paymentParams.transactionType = immediateCapture ? 'AUTH+CAPTURE' : 'AUTH';
            //need to check if it's a stored payment method
            //if it is a stored pay method, get the token and call adyen
            //if not, call adyen with cc number, get the token back and update it on paymentParams to store token in pay method record (only if saveAsStoredPayment = true) and get only 4 last digits of the cc
//            if(paymentParams.storedPaymentId != null)
//            {
//                //throw new MyException('test');
//                //use token from paymentParams to call Adyen
//                //System.debug(paymentParams);
//                AuthoriseRequest authRequest = AdyenUtil.authoriseFromTransactionParamsSPM(inputData, merchant);
//                AuthoriseResponse authResponse = AdyenClient.authorisePayment(merchant, authRequest);
//
//                if(!authResponse.success || (authResponse.success && authResponse.resultCode != 'Authorised'))
//                {
//                    //return appropriate error message to user, if applicable. Waiting for a SF response on how to do that.
//
//                    Map<String,Object> errorLabelMap = Util.getLabels(new Set<String>{'Checkout_OrderPlaceError_Adyen'});
//                    Map<String,String> errorLabelStringMap = (Map<String,String>)errorLabelMap.get('pageLabels');
//                    String errorMsg = 'Callout failed or Unauthorised transaction';
//
//
//                    if(Boolean.valueOf(errorLabelMap.get('success')) && errorLabelStringMap.containskey('Checkout_OrderPlaceError_Adyen'))
//                    {
//                        errorMsg = errorLabelStringMap.get('Checkout_OrderPlaceError_Adyen');
//                    }
//
//                    throw new AdyenException(errorMsg);
//                }
//                else{
//                    paymentParams.transactionCode = authResponse.PSPReference;
//                }
//            }
//            else
//            {
                //call adyen to payment
                
                OASPaymentRequest authRequest = AdyenUtil.authoriseFromTransactionParams(inputData, merchant);
                AuthoriseResponse authResponse = AdyenClient.authorisePayment(merchant, authRequest);
                
                //System.debug(authResponse);

                if(!authResponse.success || (authResponse.success && authResponse.resultCode != 'Authorised'))
                {
                    //return appropriate error message to user, if applicable. Waiting for a SF response on how to do that.

                    Map<String,Object> errorLabelMap = Util.getLabels(new Set<String>{'Checkout_OrderPlaceError_Adyen'});
                    Map<String,String> errorLabelStringMap = (Map<String,String>)errorLabelMap.get('pageLabels');
                    String errorMsg = 'Callout failed or Unauthorised transaction';
                    

                    if(Boolean.valueOf(errorLabelMap.get('success')) && errorLabelStringMap.containskey('Checkout_OrderPlaceError_Adyen'))
                    {
                        errorMsg = errorLabelStringMap.get('Checkout_OrderPlaceError_Adyen');
                    }

                    throw new AdyenException(errorMsg);
                }
                else
                {
                    paymentParams.transactionCode = authResponse.PSPReference;
                    
                    if(paymentParams.saveAsStoredPayment)
                    {
//                        if(authResponse.additionalData.recurring_recurringDetailReference != null && authResponse.additionalData.recurring_recurringDetailReference != '')
//                        {
//                            paymentParams.token = authResponse.additionalData.recurring_recurringDetailReference;
//                        }
//                        else
//                        {
                            paymentParams.saveAsStoredPayment = false;
//                        }
                    }
//                }
                
                paymentParams.accountNumber = paymentParams.accountNumber.right(4);
                paymentParams.verificationCode = '';
            }
            
            inputData.put(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA, paymentParams);
            //System.debug(inputData);
        }

        return inputData;
    }
}