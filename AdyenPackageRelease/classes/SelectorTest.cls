@IsTest
private class SelectorTest {
	static testMethod void testGetUserAndAccount(){
        Account acc = AdyenTestDataFactory.createAccount('account');
        insert acc;
        
        Contact con = AdyenTestDataFactory.createContact(acc, 'contact');
        insert con;
        
        User u1 = AdyenTestDataFactory.createCommunityUser(con);
        insert u1;
        
        User u2 = Selector.getUserAndAccount(u1.Id);
        System.assert(u2.AccountId != null);
    }
    
    static testMethod void testGetStoredPayment(){
        Account acc = AdyenTestDataFactory.createAccount('account');
        insert acc;
        
        ccrz__E_StoredPayment__c sp1 = AdyenTestDataFactory.createCCStoredPayment(acc);
        insert sp1;
        
        ccrz__E_StoredPayment__c sp2 = Selector.getStoredPayment(sp1.Id);
        System.assertEquals(sp1.Id, sp2.Id);
    }
}