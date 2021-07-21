@isTest
private class PmtAdyenPayControllerTest {
    @isTest
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

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = '123123';
        string stateData = 'stateDataTest';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
    }
}