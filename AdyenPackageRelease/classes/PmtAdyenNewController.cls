global with sharing class PmtAdyenNewController {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addAdyenccStoredPayment(ccrz.cc_RemoteActionContext ctx, String inputData)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        Boolean success = true;
        
        try
        {
            Map<String, Object> mapInputData = (Map<String, Object>) JSON.deserializeUntyped(inputData);
            Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', res.inputContext.storeFront, true, true);
            Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
            Merchant__mdt merchant = Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));
            AuthoriseRequest request = AdyenUtil.authoriseFromNewPage(mapInputData, merchant);
            AuthoriseResponse response = AdyenInterface.authorisePayment(mapConfigs.get('pmt_adyencc.config'), request);
			
            success = response.success;
            
            if(!success)
            {
                ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(response.errorDetail.message); 
                res.messages.add(m);
            }
            else if(success && response.resultCode != 'Authorised')
            {
                success = false;
                ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(response.resultCode); 
                res.messages.add(m);
            }
            else
            {
                //get response and save sf record
                ccrz__E_StoredPayment__c storedPayment = new ccrz__E_StoredPayment__c();
                storedPayment.ccrz__Enabled__c = Boolean.valueOf(mapInputData.get('isEnabled'));
            	storedPayment.ccrz__ExpMonth__c = Decimal.valueOf((String)mapInputData.get('expirationMonth'));
            	storedPayment.ccrz__ExpYear__c = Decimal.valueOf((String)mapInputData.get('expirationYear'));
                storedPayment.ccrz__Token__c = response.additionalData.recurring_recurringDetailReference;
                storedPayment.ccrz__DisplayName__c = (String)mapInputData.get('displayName');
                storedPayment.ccrz__Account__c = Selector.getUserAndAccount(UserInfo.getUserId()).AccountId;
                storedPayment.ccrz__AccountNumber__c = response.additionalData.cardSummary;
                storedPayment.ccrz__User__c = UserInfo.getUserId();
                storedPayment.ccrz__Storefront__c = res.inputContext.storeFront;
                storedPayment.ccrz__AccountType__c = (String)mapInputData.get('accountType');
                
                insert storedPayment;
            }
            
            res.success = success;
        }
        catch(Exception ex)
        {
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(ex.getMessage()); 
            res.messages.add(m);
            res.success = false;
        }

        return res;
    }
}