global inherited sharing class cc_adyencc_ccPaymentProcessor extends ccrz.ccPaymentProcessor {
    global override Map<String,Object> preProcess(Map<String,Object> paymentProcessorInput) {
        System.debug('preProcess');
        System.debug(paymentProcessorInput);
//        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'preProcess', paymentProcessorInput);
        //checkout flow
        System.Debug('#### 1 ' + paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX));
        System.Debug('#### 2 ' + ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT);
        if(paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX) == ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT)
        {
            ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams)paymentProcessorInput.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            String accountNumber = paymentParams.accountNumber;
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c)paymentProcessorInput.get('cart');
            Merchant__mdt merchant = AdyenUtil.getConfiguredMerchantAccount(cart);
            paymentParams.transactionType = AdyenUtil.getConfiguredCaptureDelay(cart);
            String stateData = String.valueOf(paymentParams.token);

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
                PaymentRequest paymentRequest = AdyenPaymentRequest.createPaymentRequest(stateData, cart, merchant);
                PaymentResponse paymentResponse = AdyenClient.authorisePayment(merchant, paymentRequest);

                System.Debug('#### paymentResponse ' + paymentResponse);
                System.Debug('#### paymentResponse resultCode ' + paymentResponse.resultCode);

               //TODOBAS compare resultCode enum
//                if(paymentResponse.resultCode == paymentsResponse.ResultCodeEnum.AUTHORISED) {
                    paymentParams.transactionCode = paymentResponse.pspReference;
                    paymentParams.token = '';
//                }

                //TODOBAS see results Payment Response
//                if(!paymentResponse.success || (paymentResponse.success && paymentResponse.resultCode != 'Authorised'))
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
//                else
//                {
//                    paymentParams.transactionCode = paymentResponse.pspReference;
//
//                    if(paymentParams.saveAsStoredPayment)
//                    {
////                        if(paymentResponse.additionalData.recurring_recurringDetailReference != null && paymentResponse.additionalData.recurring_recurringDetailReference != '')
////                        {
////                            paymentParams.token = paymentResponse.additionalData.recurring_recurringDetailReference;
////                        }
////                        else
////                        {
//                            paymentParams.saveAsStoredPayment = false;
////                        }
//                    }
//                }
//
//                paymentParams.accountNumber = paymentParams.accountNumber.right(4);
//                paymentParams.verificationCode = '';
//            }
//
            paymentProcessorInput.put(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA, paymentParams);
//            //System.debug(inputData);
        }

        return paymentProcessorInput;
    }
}