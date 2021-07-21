@isTest
private class PmtAdyenPayControllerTest {
    @testSetup
    private static void testData(){

        Account acc = AdyenTestDataFactory.createAccount('account');
        insert acc;

        Contact con = AdyenTestDataFactory.createContact(acc, 'contact');
        insert con;

        User u1 = AdyenTestDataFactory.createCommunityUser(con);
        insert u1;

        ccrz__E_Product__c prd = AdyenTestDataFactory.createCCProduct('product test');
        insert prd;

        ccrz__E_Cart__c cart = AdyenTestDataFactory.createCCCart(u1, con, acc);
        insert cart;

        ccrz__E_CartItem__c cartItem = AdyenTestDataFactory.createCCCartItem(cart, prd);
        insert cartItem;

    }

    @isTest
    private static void testOrderSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"Bas","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{"acceptHeader":"*\/*","colorDepth":24,"language":"en-GB","javaEnabled":false,"screenHeight":900,"screenWidth":1440,"userAgent":"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/92.0.4515.107 Safari\/537.36","timeZoneOffset":-120}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
    }
}