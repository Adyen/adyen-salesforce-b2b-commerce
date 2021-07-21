//
// Contains mock structures for testing the Adyen interface.
public class Mocks {
    public static String mockPaymentsResponse() {
        System.debug('Start Mock');
        String paymentsResponseAuthorised = '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa", }, "pspReference": "8826268577445660", "resultCode": "Authorised" }';
//        PaymentsResponse paymentsResponse = (PaymentsResponse) JSON.deserialize(Util.makeSalesforceCompatible(paymentsResponseAuthorised), PaymentsResponse.class);
//        System.debug('paymentsResponse = ' + paymentsResponse);
//        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsResponse);
//        System.debug('paymentResult = ' + paymentResult);
//        Map<String, Object> adyenResult = new Map<String, Object>();
//        adyenResult.put('paymentResult', paymentResult);
//        System.debug('adyenResult = ' + adyenResult);
        return paymentsResponseAuthorised;
    }

    public class AdyenPaymentsSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockPaymentsResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
}