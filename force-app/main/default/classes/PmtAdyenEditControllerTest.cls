@isTest
private class PmtAdyenEditControllerTest {
    @testSetup
    private static void testData(){
        AdyenTestDataFactory.initiateTestData();
    }

    @isTest
    private static void constructorTest(){
        PageReference pageRef = new PageReference('www.adyentest.com');
        Profile p = [select id, name from profile where UserType = 'PowerCustomerSuccess' OR UserType = 'PowerPartner'][0];
        User user = [SELECT Id FROM User WHERE profileid = :p.id][0];
        System.runAs(user){
            Account testAccount = AdyenTestDataFactory.createAccount('StoreFrontUserAccount');
            insert testAccount;
            ccrz__E_StoredPayment__c storedPayment = AdyenTestDataFactory.createCCStoredPayment(testAccount,user);
            insert storedPayment;
            pageRef.getParameters().put('pid', storedPayment.id);
			Test.setCurrentPage(pageRef);
            Test.startTest();
            PmtAdyenEditController editController = new PmtAdyenEditController();
            Test.stopTest();
        }
    }


    @isTest
    private static void updateStoredPaymentSuccess(){
        Profile p = [select id, name from profile where UserType = 'PowerCustomerSuccess' OR UserType = 'PowerPartner'][0];
        User user = [SELECT Id FROM User WHERE profileid = :p.id][0];
        System.runAs(user){
            Account testAccount = AdyenTestDataFactory.createAccount('StoreFrontUserAccount');
            insert testAccount;
            ccrz__E_StoredPayment__c storedPayment = AdyenTestDataFactory.createCCStoredPayment(testAccount,user);
            insert storedPayment;
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            String inputData = '{"displayName":"John Smith","accountNumber":"545454******5454","expirationMonth":"3","expirationYear":"2030","isEnabled":true,"storedPaymentId":"' + storedPayment.Id + '"}';

            Test.startTest();
            ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenStoredPayment(ctx, inputData);
            Test.stopTest();
            System.assertEquals(res.success, true);
        }
    }

    @isTest
    private static void updateStoredPaymentError(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        String inputData = '{"displayName":"John Smith","accountNumber":"545454******5454","expirationMonth":"3","expirationYear":"2030","isEnabled":true,"storedPaymentId":"WrongStoredPaymentId"}';
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenStoredPayment(ctx, inputData);
        Test.stopTest();
        System.assertEquals(res.success, false);
    }
}