@IsTest
private class TransactionPaymentHandlerTest {

    @testSetup
    private static void testData(){
        Map<String,Object> resData = AdyenTestDataFactory.initiateTestData();

        Map<String,Object> accData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.ACCOUNT_DATA);
        List<Account> accList = (List<Account>)accData.get(ccrz.ccApiTestData.ACCOUNT_LIST);

        Map<String,Object> conData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.CONTACT_DATA);
        List<Contact> conList = (List<Contact>)conData.get(ccrz.ccApiTestData.CONTACT_LIST);

        List<User> userList = [SELECT Id, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];

        ccrz__E_Order__c order = AdyenTestDataFactory.createCCOrder(accList[0], userList[0], conList[0]);
        insert order;

        ccrz__E_OrderItem__c orderItem = AdyenTestDataFactory.createCCOrderItem(order);
        insert orderItem;

        order = database.query('SELECT '+Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Order__c'))+' FROM ccrz__E_Order__c WHERE Id = \''+order.Id+'\'');

        ccrz__E_TransactionPayment__c tp1 = AdyenTestDataFactory.createCCTransactionPayment(order, 'AUTH', 'adyencc');
        insert tp1;

    }

    @isTest
    private static void testCapturePayment(){

        ccrz__E_TransactionPayment__c tp1 = [SELECT Id FROM ccrz__E_TransactionPayment__c][0];

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureSuccessMock());

        Test.startTest();
        tp1.Capture_Payment__c = true;
        update tp1;
        Test.stopTest();

         List<ccrz__E_TransactionPayment__c> listTP = [SELECT Capture_Payment__c FROM ccrz__E_TransactionPayment__c];

        System.assertEquals(listTP.size(), 2);
    }
}