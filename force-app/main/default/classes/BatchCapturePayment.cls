global with sharing class BatchCapturePayment implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private String query;
    private Map<String, Merchant__mdt> mapStoreNameMerchant;
    private Set<Id> setIds;
    private Set<Id> remainingSetIds;

    public BatchCapturePayment(Set<Id> setIds) {
        this.setIds = setIds;
        this.remainingSetIds = new Set<Id>();
        this.query = 'SELECT ' + Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_TransactionPayment__c')) + ' FROM ccrz__E_TransactionPayment__c WHERE Id IN :setIds';
        this.mapStoreNameMerchant = new Map<String, Merchant__mdt>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ccrz__E_TransactionPayment__c> scope) {
        List<ccrz__E_TransactionPayment__c> listToUpsert = new List<ccrz__E_TransactionPayment__c>();
        //check for limits
        //# callouts
        //cumulative timeout callout
        for (ccrz__E_TransactionPayment__c tp : scope) {
            if (Limits.getCallouts() < Limits.getLimitCallouts()) {
                try {
                    Merchant__mdt merchant;

                    if (mapStoreNameMerchant.containsKey(tp.ccrz__Storefront__c)) {
                        merchant = mapStoreNameMerchant.get(tp.ccrz__Storefront__c);
                    } else {
                        Boolean useCache = !Test.isRunningTest();
                        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', tp.ccrz__Storefront__c, true, useCache);
                        Map<String, String> mapConfigs = (Map<String, String>) mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
                        merchant = Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));
                        mapStoreNameMerchant.put(tp.ccrz__Storefront__c, merchant);
                    }

                    CaptureRequest request = AdyenCaptureRequest.createCaptureRequest(tp, merchant);
                    CaptureResponse response = AdyenCaptureRequest.sendCaptureRequest(merchant, request);

                    if (!String.isBlank(response.pspReference)) {
                        //to-do: add field to write message on the record
                        ccrz__E_TransactionPayment__c newTp = tp.clone(false, true);
                        newTp.ccrz__SourceTransactionPayment__c = tp.Id;
                        newTp.ccrz__TransactionCode__c = response.pspReference;
                        newTp.ccrz__TransactionType__c = 'CAPTURE';
                        newTp.Capture_Payment__c = false;

                        listToUpsert.add(newTp);
                    } else {
                        tp.Capture_Payment__c = false;
                        //tp.Integration_Messages__c = response.errorDetail.message;
                        listToUpsert.add(tp);
                    }
                } catch (Exception ex) {
                    tp.Capture_Payment__c = false;
                    tp.Integration_Messages__c = ex.getMessage();
                    listToUpsert.add(tp);
                }
            } else {
                remainingSetIds.add(tp.Id);
            }
        }

        if (listToUpsert.size() > 0) {
            upsert listToUpsert;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (remainingSetIds.size() > 0) {
            Database.executeBatch(new BatchCapturePayment(remainingSetIds), 100);
        }
    }
}