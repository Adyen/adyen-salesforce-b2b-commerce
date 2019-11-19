//
// Contains mock structures for testing the Adyen interface.
public class Mocks {
    public static AuthoriseRequest dummyAuthoriseRequest(Merchant__mdt config) {
        AuthoriseRequest ar = new AuthoriseRequest();
        ar.amount = new Amount();
        ar.applicationInfo = new ApplicationInfo();
        ar.paymentMethod = new PaymentMethod();

        //
        // Card
        ar.paymentMethod.cvc = '737';
        ar.paymentMethod.holderName = 'John Smith Apex';
        ar.paymentMethod.expiryMonth = '10';
        ar.paymentMethod.expiryYear = '2020';
        ar.paymentMethod.number_x = '4111111111111111';
        ar.paymentMethod.type = 'scheme';

        //
        // Amount
        ar.amount.currency_x = 'EUR';
        ar.amount.value = 10000;

        //
        // Application info
        ar.applicationInfo.adyenPaymentSource = new PaymentSource();
        ar.applicationInfo.externalPlatform = new ExternalPlatform();
        ar.applicationInfo.adyenPaymentSource.version = '0.1';
        ar.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
        ar.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
        ar.applicationInfo.externalPlatform.integrator = 'Appsolutely';
        ar.applicationInfo.externalPlatform.version = '40';

        //
        // root props
        ar.merchantAccount = config.Name__c;
        ar.reference = 'ref';

        return ar;
    }
    public static CaptureRequest dummyCaptureRequest(Merchant__mdt config, String origRef) {
        CaptureRequest cr = new CaptureRequest();
        cr.modificationAmount = new Amount();
        cr.originalReference = origRef;

        //
        // Amount
        cr.modificationAmount.currency_x = 'EUR';
        cr.modificationAmount.value = 10000;
        //
        // root props
        cr.merchantAccount = config.Name__c;
        cr.reference = 'ref';
        return cr;
    }
    public static AuthoriseResponse mockAuthoriseResponse() {
        AuthoriseResponse resp = new AuthoriseResponse();
        resp.additionalData = new AdditionalData();
        resp.additionalData.paymentMethod = 'visa';
        resp.additionalData.cardHolderName = 'John Smith';
        resp.additionalData.cardSummary = '1111';
        resp.additionalData.expiryDate = '10/2020';
        resp.additionalData.fraudManualReview = 'false';
        resp.additionalData.fraudResultType = 'GREEN';
        resp.merchantReference = 'dummy-mrchref';
        resp.pspReference = 'dummy-psp';
        resp.resultCode = 'Authorised';
        resp.fraudResult = new FraudResult();
        resp.fraudResult.results = new List<ResultRow>();
        for(Integer x = 0; x<10; x++) {
            ResultRow row = new ResultRow();
            FraudCheckResult fr = new FraudCheckResult();
            fr.name = 'FR'+x;
            fr.accountScore = 10;
            fr.checkId = x;
            row.FraudCheckResult = fr;
            resp.fraudResult.results.add(row);
        }
        return resp;
    }
    public static AuthoriseResponse mockAuthoriseResponseRefused() {
        AuthoriseResponse resp = new AuthoriseResponse();
        resp.additionalData = new AdditionalData();
        resp.additionalData.paymentMethod = 'visa';
        resp.additionalData.cardHolderName = 'John Smith';
        resp.additionalData.cardSummary = '1111';
        resp.additionalData.expiryDate = '10/2020';
        resp.additionalData.fraudManualReview = 'false';
        resp.additionalData.fraudResultType = 'GREEN';
        resp.merchantReference = 'dummy-mrchref';
        resp.pspReference = 'dummy-psp';
        resp.resultCode = 'Refused';
        resp.fraudResult = new FraudResult();
        resp.fraudResult.results = new List<ResultRow>();

        return resp;
    }
    public static CaptureResponse mockCaptureResponse() {
        CaptureResponse resp = new CaptureResponse();
        resp.pspReference = 'abcd1234';
        resp.response = '[capture-received]';
        return resp;
    }
    public static DisableRequest dummyDisableRequest(Merchant__mdt config) {
        DisableRequest dr = new DisableRequest();

        dr.shopperReference = 'test';
        dr.recurringDetailReference = 'reference';
        dr.merchantAccount = config.Name__c;

        return dr;
    }
    public static DisableResponse mockDisableResponse() {
        DisableResponse resp = new DisableResponse();
        resp.response = '[detail-successfully-disabled]';
        return resp;
    }
    public static AuthoriseRequest dummyUpdateRequest(Merchant__mdt config) {
        AuthoriseRequest ar = new AuthoriseRequest();
        ar.amount = new Amount();
        ar.applicationInfo = new ApplicationInfo();
        ar.card = new PaymentMethod();
        ar.recurring = new Recurring();

        ar.recurring.contract = 'RECURRING';

        //
        // Card
        ar.card.expiryMonth = '10';
        ar.card.expiryYear = '2020';

        //
        // Amount
        ar.amount.currency_x = 'EUR';
        ar.amount.value = 0;

        //
        // root props
        ar.merchantAccount = config.Name__c;
        ar.reference = 'ref';
        ar.shopperInteraction = 'ConAuth';
        ar.shopperReference = 'test';
        ar.selectedRecurringDetailReference = 'token';

        return ar;
    }
    public static AuthoriseResponse mockUpdateResponse() {
        AuthoriseResponse resp = new AuthoriseResponse();
        resp.additionalData = new AdditionalData();
        resp.additionalData.paymentMethod = 'visa';
        resp.additionalData.cardHolderName = 'John Smith';
        resp.additionalData.cardSummary = '1111';
        resp.additionalData.expiryDate = '10/2020';
        resp.additionalData.merchantReference = 'dummy-mrchref';
        resp.pspReference = 'dummy-psp';
        resp.resultCode = 'Authorised';
        return resp;
    }
    public static AuthoriseResponse mockUpdateResponseNotAuthorised() {
        AuthoriseResponse resp = new AuthoriseResponse();
        resp.additionalData = new AdditionalData();
        resp.additionalData.paymentMethod = 'visa';
        resp.additionalData.cardHolderName = 'John Smith';
        resp.additionalData.cardSummary = '1111';
        resp.additionalData.expiryDate = '10/2020';
        resp.additionalData.merchantReference = 'dummy-mrchref';
        resp.pspReference = 'dummy-psp';
        resp.resultCode = 'Refused';
        return resp;
    }
    public class AdyenAuthoriseSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockAuthoriseResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class AdyenAuthoriseRefusedMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockAuthoriseResponseRefused()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class AdyenAuthoriseErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            Error err = new Error();
            err.errorCode = '400';
            err.errorType = 'validation';
            err.message = 'Err';
            err.status = 400;
            res.setBody(JSON.serialize(err));
            res.setStatusCode(400);
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
    public class AdyenCaptureErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
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
    public class AdyenDisableSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockDisableResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class AdyenDisableErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            Error err = new Error();
            err.errorCode = '803';
            err.errorType = 'validation';
            err.message = 'PaymentDetail not found';
            err.status = 422;
            res.setBody(JSON.serialize(err));
            res.setStatusCode(400);
            return res;
        }
    }
    public class AdyenUpdateSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockUpdateResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class AdyenUpdateErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            Error err = new Error();
            err.errorCode = '400';
            err.errorType = 'validation';
            err.message = 'Err';
            err.status = 400;
            res.setBody(JSON.serialize(err));
            res.setStatusCode(400);
            return res;
        }
    }
    public class AdyenUpdateRefusedMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(mockUpdateResponseNotAuthorised()));
            res.setStatusCode(200);
            return res;
        }
    }
}