global with sharing class PmtAdyenPayController {

    //TODOBAS investigate isGuest
    public Boolean isGuest { get{ return UserInfo.getUserType() == 'Guest';} }

    //TODOBAS new method name
    @RemoteAction
    global static ccrz.cc_RemoteActionResult pressMeCcrz(ccrz.cc_RemoteActionContext ctx, String stateData) {
//        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
//        System.Debug('#### res '+ res);
//        System.Debug('#### inputData '+ stateData);
////        System.Debug('#### deserializeUntyped ' + JSON.deserializeUntyped(stateData));
//        PaymentRequest paymentRequest = AdyenPaymentRequest.paymentRequestBuilder(stateData);
////        StateData stateDataParsed = (StateData) JSON.deserialize(stateData, StateData.class);
//        System.Debug('#### paymentRequest '+ paymentRequest);
//        System.Debug('#### paymentRequest paymentMethod '+ paymentRequest.paymentMethod);
//        System.Debug('#### paymentRequest RiskData '+ paymentRequest.riskData);
//        System.Debug('#### paymentRequest BrowserInfo '+ paymentRequest.browserInfo);
//        System.Debug('#### paymentRequest BrowserInfo acceptHeader '+ paymentRequest.browserInfo.acceptHeader);
//        try{
//            List<String> inputValidations = validateInputs(inputData);
//
//            if(inputValidations.size() > 0)
//            {
//                res.success = false;
//                res.data = inputData;
//
//                for(String s : inputValidations)
//                {
//                    ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(s);
//                    res.messages.add(m);
//                }
//
//                return res;
//            }
//
//            Boolean savePayment = (Boolean.valueOf((String) inputData.get('saveAsStoredPayment').get('value')) == true);
//
            ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
            String cartId = ctx.currentCartId;
            String query = 'SELECT '+Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Cart__c'))+', Owner.Email FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartId LIMIT 1';
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c) Database.query(query);
//            Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
//            Map<String, Object> inputParams = new Map<String, Object>();
//            inputParams.put('accountNumber',inputData.get('accountNumber').get('value'));
//            inputParams.put('expirationMonth',inputData.get('expirationMonth').get('value'));
//            inputParams.put('expirationYear',inputData.get('expirationYear').get('value'));
//            inputParams.put('verificationCode',inputData.get('verificationCode').get('value'));
//            inputParams.put('displayName',inputData.get('accountName').get('value'));
//            inputParams.put('accountType', 'adyencc');
//            inputParams.put('saveAsStoredPayment', savePayment);
//
//            if(inputData.containsKey('storedPaymentId')){
//                inputParams.put('storedPaymentId',inputData.get('storedPaymentId').get('value'));
//            }
//
            Map<String,Object> createParams = new Map<String,Object> {
//                ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => JSON.serialize(inputParams),
                ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT,
                ccrz.cc_hk_Payment.PARAM_CART => cart,
                ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => 'adyencc'
            };
            System.Debug('#### create '+ createParams);
            //
//            // SOQL Cart and Serialize
            ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT = 'Checkout'
            Map<String,Object> processResult = paymentHook.processPayment(createParams, stateData);
            System.Debug('#### processResult '+processResult);
//
//            Map<String,Object> placeParams = new Map<String,Object>{
//                ccrz.ccApi.API_VERSION => 9,
//                    ccrz.ccApiCart.PAYMENTDATA => JSON.serialize(inputParams),
//                    ccrz.ccApiCart.TRANSPAYMENTDATA => processResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA),
//                    ccrz.ccApiCart.PAYMENTRESULT => processResult,
//                    ccrz.ccApiCart.CART_ENCID => cartId
//                    };
//                        if(Test.isRunningTest()){
//                            placeParams.put(ccrz.ccApiCart.SKIP_VALID_CHECK, true);
//                        }
//
//            Map<String,Object> placeResult = ccrz.ccApiCart.place(placeParams);
//            //
//            // Get order enc-id
//            Map<String, Map<String, String>> inputData2 = inputData.clone();
//            String orderId = (String)placeResult.get('orderId');
//            ccrz__E_Order__c[] ords = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Order__c WHERE Id=:orderId LIMIT 1];
//            if(ords<>null && ords.size()==1) {
//                Map<String, String> temp = new Map<String, String>();
//                temp.put('ordId',ords[0].ccrz__EncryptedId__c);
//                inputData2.put('orderInfo',temp);
//            }
//            res.success = true;
//            res.data = inputData2; // TRY WITH CLONE TO PREVENT COLLECTION IS READONLY ERROR
//            //
//            // FIGURE OUT::
//            // Confirmation Mail not sent currently
//        }
//        catch(Exception e){
//            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
//            //Exception handling here
//            //System.Debug('#### exception '+e.getMessage()+e.getStackTraceString());
//            res.success = false;
//            res.data = inputData;
//            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(e.getMessage());
//            res.messages.add(m);
//            return res;
//        }
//        finally{
//            ccrz.ccLog.close(res);
//        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
       ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
       try {
            ccrz__E_Cart__c cart = getCartById(ctx.currentCartId);

            Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
            Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
            Merchant__mdt merchant = Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));

            OASPaymentMethodsRequest paymentMethodsRequest = AdyenUtil.createPaymentMethodsRequest(cart, merchant);
            OASPaymentMethodsResponse paymentMethodsResponse = AdyenClient.getPaymentMethods(merchant, paymentMethodsRequest);

            //Remove suffix and convert to string
            String jsonPaymentMethodsResponse = JSON.serialize(paymentMethodsResponse, true);
            String stringPaymentMethodsResponse = Util.makeAdyenCompatible(jsonPaymentMethodsResponse);

            res.data = stringPaymentMethodsResponse;
            res.success = true;
        }
        catch(Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
            System.Debug('## ERROR CATCH ' + e);
            res.success = false;
        }
        finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    private static ccrz__E_Cart__c getCartById(String cartId){
        String query = 'SELECT '+Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Cart__c'))+', Owner.Email FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartId LIMIT 1';
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c) Database.query(query);
        return cart;
    }

// TODOBAS delete this method
//    public static List<String> validateInputs(Map<String, Map<String, String>> inputData)
//    {
//        List<String> listString = new List<String>();
//        Set<String> setRequiredFields = new Set<String>{'accountNumber', 'expirationMonth', 'expirationYear', 'verificationCode'};
//            Set<String> setLabels = new Set<String>();
//        Map<String,Object> mapLabels = new Map<String,Object>();
//        Map<String,String> errorLabelStringMap = new Map<String,String>();
//
//        for(String s : setRequiredFields)
//            setLabels.add('PMTAdyencc_'+s+'Req');
//
//        mapLabels = Util.getLabels(setLabels);
//        errorLabelStringMap = (Map<String,String>)mapLabels.get('pageLabels');
//
//        for(String field : setRequiredFields)
//        {
//            if(!inputData.containsKey(field) || inputData.get(field).get('value') == '')
//            {
//                listString.add(errorLabelStringMap.get('PMTAdyencc_'+field+'Req'));
//            }
//        }
//
//        return listString;
//    }
}