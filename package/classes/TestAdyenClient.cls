@isTest
private class TestAdyenClient {

    private static testMethod void testAuthoriseSuccess() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        AuthoriseRequest req = Mocks.dummyAuthoriseRequest(mrch);
        AuthoriseResponse resp = AdyenClient.authorisePayment(mrch, req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testAuthoriseError() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseErrorMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        AuthoriseRequest req = Mocks.dummyAuthoriseRequest(mrch);
        AuthoriseResponse resp = AdyenClient.authorisePayment(mrch, req);
        Test.stopTest();
        System.assertEquals(false, resp.success, 'Expected failure');
        System.assertEquals(400, resp.errorDetail.status, 'Expected 400 status');
    }

    private static testMethod void testCaptureSuccess() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        CaptureRequest req = Mocks.dummyCaptureRequest(mrch,'abcd1234');
        CaptureResponse resp = AdyenClient.capturePayment(mrch, req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testCaptureError() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureErrorMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        CaptureRequest req = Mocks.dummyCaptureRequest(mrch,'abcd1234');
        CaptureResponse resp = AdyenClient.capturePayment(mrch, req);
        Test.stopTest();
        System.assertEquals(false, resp.success, 'Expected failure');
        System.assertEquals(400, resp.errorDetail.status, 'Expected 400 status');
    }
}