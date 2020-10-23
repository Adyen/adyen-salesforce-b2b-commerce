global class cc_adyencc_hk_Payment extends ccrz.cc_hk_Payment {

//    global override Map<String,Object> removeStoredPayment(Map<String,Object> inputData) {
//        Map<String,Object> returnData = new Map<String,Object>();
//
//        //query storedPayment and if it's adyencc type, call adyen service to delete
//        //if success, resul=true
//        //if not, result=false
//
////        ccrz__E_StoredPayment__c storedPayment = Selector.getStoredPayment((String)inputData.get(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID));
////        Boolean useCache = !Test.isRunningTest();
////        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', storedPayment.ccrz__Storefront__c, true, useCache);
////        Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
////        Merchant__mdt merchant = Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));
////
////        if(storedPayment.ccrz__AccountType__c == 'adyencc')
////        {
////            DisableRequest disableRequest = AdyenUtil.disableStoredPayment(storedPayment, merchant);
////            DisableResponse disableResponse = AdyenInterface.disablePaymentMethod(merchant.Name__c, disableRequest);
////
////            if(disableResponse.success)
////            {
////                returnData = super.removeStoredPayment(inputData);
////            }
////            else
////            {
////                returnData.put('result', false);
////            }
////        }
////        else {
////            returnData = super.removeStoredPayment(inputData);
////        }
//
//        return returnData;
//    }
}