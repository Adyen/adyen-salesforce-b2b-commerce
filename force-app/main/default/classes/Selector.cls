public with sharing class Selector {
    /**
    * Return account details from user record for the current Id.
    */
    public static User getUserAndAccount(Id userId) {
        return [SELECT AccountId
                FROM User WHERE Id = :userId];
    }

    /**
    * Return stored payment details 
    */
    public static ccrz__E_StoredPayment__c getStoredPayment(String sotredPaymentId) {
        return [SELECT Id,
                ccrz__Account__c,
                ccrz__Token__c,
                ccrz__AccountType__c,
                ccrz__ExpYear__c,
                ccrz__ExpMonth__c,
                ccrz__StoreFront__c,
                ccrz__DisplayName__c,
                ccrz__Enabled__c
                FROM ccrz__E_StoredPayment__c WHERE Id = :sotredPaymentId];
    }
    
}