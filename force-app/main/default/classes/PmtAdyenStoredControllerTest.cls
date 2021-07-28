@isTest
private class PmtAdyenStoredControllerTest {
    @testSetup
    private static void testData(){
        AdyenTestDataFactory.initiateTestData();
    }

    @isTest
    private static void storedCreditCardSuccess() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod": { "type": "scheme", "holderName": "John Smith", "storedPaymentMethodId": "8xxxxxxxx", "brand": "mc" },"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenStoredController.placeOrderByStoredPaymentAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, true);
    }

    @isTest
    private static void storedCreditCardFailed() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod": { "type": "scheme", "holderName": "John Smith", "storedPaymentMethodId": "8xxxxxxxx", "brand": "mc" },"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsFailedMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenStoredController.placeOrderByStoredPaymentAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, false);
    }

    @isTest
    private static void storedCreditCardThreeDS2Challenge(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod": { "type": "scheme", "holderName": "John Smith", "storedPaymentMethodId": "8xxxxxxxx", "brand": "mc" },"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsChallengeMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenStoredController.placeOrderByStoredPaymentAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.data.toString().contains('CHALLENGESHOPPER'), true);
    }

    @isTest
    private static void storedCreditCardError() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = 'WrongCartId';
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod": { "type": "scheme", "holderName": "John Smith", "storedPaymentMethodId": "8xxxxxxxx", "brand": "mc" },"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsFailedMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenStoredController.placeOrderByStoredPaymentAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, false);
    }

}