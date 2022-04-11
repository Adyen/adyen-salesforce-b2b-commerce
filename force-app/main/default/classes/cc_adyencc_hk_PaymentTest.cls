@isTest
private class cc_adyencc_hk_PaymentTest {
    @testSetup
    private static void testData(){
       AdyenTestDataFactory.initiateTestData();
    }

    @isTest
    private static void testRemoveStoredPayment() {
        Profile p = [select id, name from profile where UserType = 'PowerCustomerSuccess' OR UserType = 'PowerPartner'][0];
        User user = [SELECT Id FROM User WHERE profileid = :p.id][0];
        System.runAs(user){
            Account testAccount = AdyenTestDataFactory.createAccount('StoreFrontUserAccount');
            insert testAccount;
            ccrz__E_StoredPayment__c storedPayment = AdyenTestDataFactory.createCCStoredPayment(testAccount,user);
            insert storedPayment;
            Map<String,Object> inputData = new Map<String,Object>();
            inputData.put(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID, (String)storedPayment.Id);
            cc_adyencc_hk_Payment pmtHk = new cc_adyencc_hk_Payment();

            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableSuccessMock());
            Test.startTest();
            pmtHk.removeStoredPayment(inputData);
            Test.stopTest();
            List<ccrz__E_StoredPayment__c> listSP = [SELECT Id FROM ccrz__E_StoredPayment__c WHERE Id = :storedPayment.Id];
            System.assertEquals(listSP.size(), 0);
        }
    }

    @isTest
    private static void testFetchPaymentTypes() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(ccrz.cc_hk_Payment.PARAM_APPL_PAYMENT_TYPES, 'adyencc');
        inputData.put('paymentTypesContext', 'co');
        ccrz.cc_CallContext.currCartId = cart.ccrz__EncryptedId__c;
        cc_adyencc_hk_Payment pmtHk = new cc_adyencc_hk_Payment();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentMethodsMock());
        Test.startTest();
        pmtHk.fetchPaymentTypes(inputData);
        Test.stopTest();
    }

}