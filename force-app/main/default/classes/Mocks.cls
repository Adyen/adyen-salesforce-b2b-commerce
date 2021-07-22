//
// Contains mock structures for testing the Adyen endpoints.
public class Mocks {
    public static String mockPaymentsResponseSuccess() {
        return '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Authorised" }';
    }

    public class AdyenPaymentsSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockPaymentsResponseSuccess()));
            res.setStatusCode(200);
            return res;
        }
    }
}