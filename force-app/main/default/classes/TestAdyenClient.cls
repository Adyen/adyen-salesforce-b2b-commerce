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
    private static testMethod void testCaptureInterface() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        CaptureRequest req = Mocks.dummyCaptureRequest(mrch,'abcd1234');
        CaptureResponse resp = AdyenInterface.capturePayment('ApexTest', req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testAuthoriseInterface() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        AuthoriseRequest req = Mocks.dummyAuthoriseRequest(mrch);
        AuthoriseResponse resp = AdyenInterface.authorisePayment('ApexTest', req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testDisableSuccess() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        DisableRequest req = Mocks.dummyDisableRequest(mrch);
        DisableResponse resp = AdyenClient.disablePaymentMethod(mrch, req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testDisableError() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableErrorMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        DisableRequest req = Mocks.dummyDisableRequest(mrch);
        DisableResponse resp = AdyenClient.disablePaymentMethod(mrch, req);
        Test.stopTest();
        System.assertEquals(false, resp.success, 'Expected failure');
        System.assertEquals(422, resp.errorDetail.status, 'Expected 422 status');
    }
    private static testMethod void testDisableInterface() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        DisableRequest req = Mocks.dummyDisableRequest(mrch);
        DisableResponse resp = AdyenInterface.disablePaymentMethod('ApexTest', req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
    private static testMethod void testUpdateError() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenUpdateErrorMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        AuthoriseRequest req = Mocks.dummyUpdateRequest(mrch);
        AuthoriseResponse resp = AdyenClient.updatePaymentMethod(mrch, req);
        Test.stopTest();
        System.assertEquals(false, resp.success, 'Expected failure');
        System.assertEquals(400, resp.errorDetail.status, 'Expected 400 status');
    }
    private static testMethod void testUpdateInterface() {
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenUpdateSuccessMock());
        Merchant__mdt mrch = Util.getConfigByName('ApexTest');
        Test.startTest();
        AuthoriseRequest req = Mocks.dummyUpdateRequest(mrch);
        AuthoriseResponse resp = AdyenInterface.updatePaymentMethod('ApexTest', req);
        Test.stopTest();
        System.assertEquals(true, resp.success, 'Expected success');
    }
}