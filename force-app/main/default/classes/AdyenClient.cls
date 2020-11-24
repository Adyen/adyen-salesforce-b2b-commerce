//
// Contains the callouts to the Adyen API
public class AdyenClient {
    public static PaymentResponse authorisePayment(Merchant__mdt merchantRecord, PaymentRequest request) {
        PaymentResponse paymentResponse = new PaymentResponse();
        try {
            Http httpClient = new Http();
            String jsonString = JSON.serialize(request, true);
            HttpRequest httpReq = createHttpRequest(merchantRecord.API_Key__c, merchantRecord.Payment_Endpoint__c, jsonString);
            System.Debug('## Raw request '+ httpReq);
            HttpResponse httpResp = httpClient.send(httpReq);
            System.Debug('## Raw response '+ httpResp.getBody());

            if(AdyenUtil.isHttpResponseOK(httpResp.getStatusCode())) {
                paymentResponse = (PaymentResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResp.getBody()), PaymentResponse.class);
//                output.success = true;
            } else {
//                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
//                if(output.errorDetail.status==null) {
//                    output.errorDetail.status = httpResp.getStatusCode();
//                }
//                output.success = false;
            }
        }
        catch(Exception e) {
//            output.errorDetail = new Error();
//            output.errorDetail.message = 'Adyen callout failed: '+e.getMessage();
//            output.success = false;
        }
        return paymentResponse;
    }

    public static PaymentMethodsResponse getPaymentMethods(Merchant__mdt merchantRecord, PaymentMethodsRequest request){
        PaymentMethodsResponse paymentMethods = new PaymentMethodsResponse();
        try {
            Http httpClient = new Http();
            String jsonString = JSON.serialize(request, true);
            HttpRequest httpReq = createHttpRequest(merchantRecord.API_Key__c, merchantRecord.PaymentMethods_Endpoint__c, jsonString);
            HttpResponse httpResp = httpClient.send(httpReq);

            if(AdyenUtil.isHttpResponseOK(httpResp.getStatusCode())) {
                paymentMethods = (PaymentMethodsResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResp.getBody()), PaymentMethodsResponse.class);
            } else {
                System.Debug('## Raw response invalid /paymentMethods request');
            }
        }
        catch(Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }
        return paymentMethods;
    }

    public static HttpRequest createHttpRequest(String apiKey, String endpoint, String request){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('X-API-KEY', apiKey);
        httpReq.setHeader('Content-Type', 'application/json');
        request = Util.makeAdyenCompatible(request);
        httpReq.setBody(request);
        return httpReq;
    }

//    public static CaptureResponse capturePayment(Merchant__mdt merchantRecord, CaptureRequest request) {
//        CaptureResponse output = new CaptureResponse();
//        try {
//            Http httpClient = new Http();
//            HttpRequest httpReq = new HttpRequest();
//            httpReq.setEndpoint(merchantRecord.Capture_Endpoint__c);
//            httpReq.setMethod('POST');
//            httpReq.setHeader('X-API-KEY',merchantRecord.API_Key__c);
//            httpReq.setHeader('Content-Type','application/json');
//            String jsonString = JSON.serialize(request);
//            jsonString = Util.stripX(jsonString);
//            httpReq.setBody(jsonString);
//            HttpResponse httpResp = httpClient.send(httpReq);
//            //System.Debug('## Raw response '+httpResp.getBody());
//            if(httpResp.getStatusCode() == 200) {
//                output = (CaptureResponse) JSON.deserialize(httpResp.getBody(), CaptureResponse.class);
//                output.success = true;
//            } else {
//                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
//                output.success = false;
//                if(output.errorDetail.status==null) {
//                    output.errorDetail.status = httpResp.getStatusCode();
//                }
//            }
//        }
//        catch(Exception e) {
//            output.errorDetail = new Error();
//            output.errorDetail.message = 'Adyen capture failed: '+e.getMessage();
//            output.success = false;
//        }
//
//        return output;
//    }
//    public static DisableResponse disablePaymentMethod(Merchant__mdt merchantRecord, DisableRequest request) {
//        DisableResponse output = new DisableResponse();
//        try {
//            Http httpClient = new Http();
//            HttpRequest httpReq = new HttpRequest();
//            httpReq.setEndpoint(merchantRecord.Disable_Endpoint__c);
//            httpReq.setMethod('POST');
//            httpReq.setHeader('X-API-KEY',merchantRecord.API_Key__c);
//            httpReq.setHeader('Content-Type','application/json');
//            String jsonString = JSON.serialize(request);
//            jsonString = Util.stripX(jsonString);
//            httpReq.setBody(jsonString);
//            HttpResponse httpResp = httpClient.send(httpReq);
//            //System.Debug('## Raw response '+httpResp.getBody());
//            if(httpResp.getStatusCode() == 200) {
//                output = (DisableResponse) JSON.deserialize(httpResp.getBody(), DisableResponse.class);
//                output.success = true;
//            } else {
//                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
//                output.success = false;
//                if(output.errorDetail.status==null) {
//                    output.errorDetail.status = httpResp.getStatusCode();
//                }
//            }
//        }
//        catch(Exception e) {
//            output.errorDetail = new Error();
//            output.errorDetail.message = 'Adyen disable failed: '+e.getMessage();
//            output.success = false;
//        }
//
//        return output;
//    }
//    public static AuthoriseResponse updatePaymentMethod(Merchant__mdt merchantRecord, AuthoriseRequest request) {
//        AuthoriseResponse output = new AuthoriseResponse();
//        try {
//            Http httpClient = new Http();
//            HttpRequest httpReq = new HttpRequest();
//            httpReq.setEndpoint(merchantRecord.Authorise_Endpoint__c);
//            httpReq.setMethod('POST');
//            httpReq.setHeader('X-API-KEY', merchantRecord.API_Key__c);
//            httpReq.setHeader('Content-Type', 'application/json');
//            String jsonString = JSON.serialize(request, true);
//            jsonString = Util.stripX(jsonString);
//            //System.Debug('## Raw request '+jsonString);
//            httpReq.setBody(jsonString);
//            HttpResponse httpResp = httpClient.send(httpReq);
//            //System.Debug('## Raw response '+httpResp.getBody());
//            if(httpResp.getStatusCode() == 200) {
//                output = (AuthoriseResponse) JSON.deserialize(Util.makeSalesforceCompatible(httpResp.getBody()), AuthoriseResponse.class);
//                output.success = true;
//            } else {
//                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
//                if(output.errorDetail.status==null) {
//                    output.errorDetail.status = httpResp.getStatusCode();
//                }
//                output.success = false;
//            }
//        }
//        catch(Exception e) {
//            output.errorDetail = new Error();
//            output.errorDetail.message = 'Adyen callout failed: '+e.getMessage();
//            output.success = false;
//        }
//        return output;
//    }
}