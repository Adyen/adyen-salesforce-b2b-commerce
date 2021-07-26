//
// Contains mock structures for testing the Adyen endpoints.
public class Mocks {
    public static String mockPaymentsResponseSuccess() {
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        return '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Authorised", "merchantReference": "' + cart.ccrz__EncryptedId__c + '" }';
    }

    public static String mockPaymentsResponseFailed() {
        return '{ "additionalData": { "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Refused" }';
    }

    public static String mockPaymentsResponseChallenge() {
        return '{"resultCode":"ChallengeShopper","action":{"paymentData":"Ab02b4","paymentMethodType":"scheme","token":"eyJhY3NS","type":"threeDS2Challenge"},"authentication":{"threeds2.challengeToken":"eyJhY3NS"},"details":[{"key":"threeds2.challengeResult","type":"text"}],"paymentData":"Ab02b4"}';
    }

       public class AdyenPaymentsSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseSuccess());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenPaymentsFailedMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseFailed());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenPaymentsChallengeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseChallenge());
            res.setStatusCode(200);
            return res;
        }
    }
}