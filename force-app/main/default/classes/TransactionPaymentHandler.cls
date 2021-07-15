public with sharing class TransactionPaymentHandler {
    public static void capturePayments(List<ccrz__E_TransactionPayment__c> listNew, Map<Id,ccrz__E_TransactionPayment__c> mapOld){
        Set<Id> setIds = new Set<Id>();

        for(ccrz__E_TransactionPayment__c tp : listNew){
            if(tp.Capture_Payment__c && !mapOld.get(tp.Id).Capture_Payment__c){
                setIds.add(tp.Id);
            }
        }

        if(setIds.size()>0){
            //number of callouts per transaction is 100
            Database.executeBatch(new BatchCapturePayment(setIds), 10);
        }
    }
}
