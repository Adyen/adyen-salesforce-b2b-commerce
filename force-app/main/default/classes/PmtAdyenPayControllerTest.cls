@isTest
private class PmtAdyenPayControllerTest {
    @testSetup
    private static void testData(){
        AdyenTestDataFactory.initiateTestData();
    }

    @isTest
    private static void creditCardSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"John Smith","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, true);
    }

    @isTest
    private static void creditCardFailed(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"John Smith","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsFailedMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, false);
    }

    @isTest
    private static void creditCardThreeDS2Challenge(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"John Smith","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsChallengeMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.data.toString().contains('CHALLENGESHOPPER'), true);
    }

    @isTest
    private static void creditCardError() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = 'wrongCartId';
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"John Smith","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.success, false);
    }

    @isTest
    private static void handleOnAdditionalDetailsSuccess() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string details = '{"details":{"threeds2.challengeResult":"eyJ0cm.."},"paymentData":"Ab02b4c..","cartId":"' + cart.ccrz__EncryptedId__c + '"}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        String result = PmtAdyenPayController.handleOnAdditionalDetails(ctx, details);
        Test.stopTest();
        System.assertEquals(result.contains('AUTHORISED'), true);
    }

    @isTest
    private static void handleOnAdditionalDetailsFailed() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string details = '{"details":{"threeds2.challengeResult":"eyJ0cm.."},"paymentData":"Ab02b4c..","cartId":"' + cart.ccrz__EncryptedId__c + '"}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsFailedMock());
        Test.startTest();
        String result = PmtAdyenPayController.handleOnAdditionalDetails(ctx, details);
        Test.stopTest();
        System.assertEquals(result.contains('REFUSED'), true);
    }

    @isTest
    private static void ThreeDS1RedirectTest(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"John Smith","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsRedirectMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
        System.assertEquals(res.data.toString().contains('REDIRECTSHOPPER'), true);
    }

    @isTest
    private static void ThreeDS1RedirectResultTest(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        PageReference pageRef = Page.adyenReturn;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('redirectResult', 'eyghjbvduyehjdvc');
        pageRef.getParameters().put('merchantReference', cart.ccrz__EncryptedId__c);

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        AdyenReturn testAR = new AdyenReturn();
        testAR.handleRedirectResponse();
        Test.stopTest();
    }
}