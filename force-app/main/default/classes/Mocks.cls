//
// Contains mock structures for testing the Adyen endpoints.
public class Mocks {
    //mock response for capture success - may need change as per the updated Adyen Capture method
      public static CaptureResponse mockCaptureResponse() {
         CaptureResponse resp = new CaptureResponse();
         resp.pspReference = 'abcd1234';
         resp.response = '[capture-received]';
         return resp;
    }

    public static String mockPaymentsResponseSuccess() {
        return '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Authorised" }';
    }

    public static String mockPaymentsResponseFailed() {
        return '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Refused" }';
    }

    public class AdyenPaymentsSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseSuccess());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenPaymentsFailedMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseFailed());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenCaptureSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockCaptureResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
}