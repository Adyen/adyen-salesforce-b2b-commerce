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

    public static String mockPaymentMethodsResponse() {
        return '{"groups":[{"name":"Credit Card","types":["mc","visa"]}],"paymentMethods":[{"brands":["mc","visa"],"details":[{"key":"number","type":"text"},{"key":"expiryMonth","type":"text"},{"key":"expiryYear","type":"text"},{"key":"cvc","type":"text"},{"key":"holderName","optional":true,"type":"text"}],"name":"Credit Card","supportsRecurring":true,"type":"scheme"}]}';
    }

    public static String mockZeroAuthResponseSuccess() {
        return '{ "additionalData": { "recurring.recurringDetailReference": "8xxxxxxxxx", "cardSummary": "1111", "expiryDate": "3/2030", "cardHolderName": "John Smith", "paymentMethod": "visa" }, "pspReference": "8xxxxxxxxx", "resultCode": "Authorised", "merchantReference": "addStoredMethod" }';
    }

    public static String mockDisableResponse() {
        return '{ "response": "[detail-successfully-disabled]" }';
    }

    public static String mockPaymentsResponseRedirect() {
        return '{ "resultCode": "RedirectShopper", "action": { "paymentData": "Ab02b4c0..", "paymentMethodType": "scheme", "url": "https://test.adyen.com/hpp/3d/validate.shtml", "data": { "MD": "WVllVjg..", "PaReq": "eNpVUtt..", "TermUrl": "https://www.adyen.com" }, "method": "POST", "type": "redirect" }, "details": [{ "key": "MD", "type": "text" }, { "key": "PaRes", "type": "text" } ], "paymentData": "Ab02b4c..", "redirect": { "data": { "PaReq": "eNpVUtt..", "TermUrl": "https://www.adyen.com", "MD": "WVllVjg.." }, "method": "POST", "url": "https://test.adyen.com/hpp/3d/validate.shtml" } }';
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

    public class AdyenZeroAuthSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockZeroAuthResponseSuccess());
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

    public class AdyenPaymentMethodsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentMethodsResponse());
            res.setStatusCode(200);
            return res;
        }
    }

     public class AdyenDisableSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockDisableResponse());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenPaymentsRedirectMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(mockPaymentsResponseRedirect());
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenCaptureSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockCaptureResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdyenCaptureErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            Error err = new Error();
            err.errorCode = '400';
            err.errorType = 'validation';
            err.message = 'Original pspReference required for this operation';
            err.status = 400;
            res.setBody(JSON.serialize(err));

            res.setStatusCode(400);
            return res;
        }
    }

    public static CaptureResponse mockCaptureResponse() {
        CaptureResponse resp = new CaptureResponse();
        resp.pspReference = 'abcd1234';
        resp.response = '[capture-received]';
        return resp;
    }
}