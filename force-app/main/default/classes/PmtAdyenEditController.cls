global with sharing class PmtAdyenEditController {
    
    public ccrz__E_StoredPayment__c storedPayment {public get; private set;}
    public String recordId {public get; private set;}
    public String displayName {public get; private set;}
    public String accountNumber {public get; private set;}
    public Boolean isEnabled {public get; private set;}
    public Decimal expirationMonth {public get; private set;}
    public Decimal expirationYear {public get; private set;}

    public PmtAdyenEditController()
    {   
        storedPayment = new ccrz__E_StoredPayment__c();
        String spId = apexpages.currentpage().getparameters().get('pid');
        String query = 'SELECT '+Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_StoredPayment__c'))+' FROM ccrz__E_StoredPayment__c WHERE Id=:spId LIMIT 1';
        storedPayment = (ccrz__E_StoredPayment__c) Database.query(query);
        recordId = storedPayment.Id;
        displayName = storedPayment.ccrz__DisplayName__c;
        accountNumber = storedPayment.ccrz__AccountNumber__c;
        isEnabled = storedPayment.ccrz__Enabled__c;
        expirationYear = storedpayment.ccrz__ExpYear__c;
        expirationMonth = storedPayment.ccrz__ExpMonth__c;
        
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateAdyenStoredPayment(ccrz.cc_RemoteActionContext ctx, String inputData)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try
        {
            Map<String, Object> mapInputData = (Map<String, Object>) JSON.deserializeUntyped(inputData);
            String storedPaymentId = (String)mapInputData.get('storedPaymentId');
            ccrz__E_StoredPayment__c storedPayment = AdyenUtil.getStoredPayment(storedPaymentId);
            storedpayment.ccrz__DisplayName__c = (String)mapInputData.get('displayName');
            storedpayment.ccrz__Enabled__c = Boolean.valueOf(mapInputData.get('isEnabled'));
            update storedPayment;
            res.success = true;
        }
        catch(Exception ex)
        {
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(ex.getMessage()+ex.getStackTraceString());
            res.messages.add(m);
            res.success = false;
        }

        return res;
    }
}