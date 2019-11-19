//
// Contains the callouts to the Adyen API
public class AdyenClient {
    public static AuthoriseResponse authorisePayment(Merchant__mdt merchantRecord, AuthoriseRequest request) {
        AuthoriseResponse output = new AuthoriseResponse();
        try {
            Http httpClient = new Http();
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(merchantRecord.Authorise_Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setHeader('X-API-KEY', merchantRecord.API_Key__c);
            httpReq.setHeader('Content-Type', 'application/json');
            String jsonString = JSON.serialize(request);
            jsonString = Util.stripX(jsonString);
            httpReq.setBody(jsonString);
            HttpResponse httpResp = httpClient.send(httpReq);
            System.Debug('## Raw response '+httpResp.getBody());
            if(httpResp.getStatusCode() == 200) {
                output = (AuthoriseResponse) JSON.deserialize(httpResp.getBody(), AuthoriseResponse.class);
                output.success = true;
            } else {
                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
                if(output.errorDetail.status==null) {
                    output.errorDetail.status = httpResp.getStatusCode();
                }
                output.success = false;
            }
        }
        catch(Exception e) {
            output.errorDetail = new Error();
            output.errorDetail.message = 'Adyen callout failed: '+e.getMessage();
            output.success = false;
        }
        return output;
    }
    public static CaptureResponse capturePayment(Merchant__mdt merchantRecord, CaptureRequest request) {
        CaptureResponse output = new CaptureResponse();
        try {
            Http httpClient = new Http();
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(merchantRecord.Capture_Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setHeader('X-API-KEY',merchantRecord.API_Key__c);
            httpReq.setHeader('Content-Type','application/json');
            String jsonString = JSON.serialize(request);
            jsonString = Util.stripX(jsonString);
            httpReq.setBody(jsonString);
            HttpResponse httpResp = httpClient.send(httpReq);
            System.Debug('## Raw response '+httpResp.getBody());
            if(httpResp.getStatusCode() == 200) {
                output = (CaptureResponse) JSON.deserialize(httpResp.getBody(), CaptureResponse.class);
                output.success = true;
            } else {
                output.errorDetail =  (Error) JSON.deserialize(httpResp.getBody(), Error.class);
                output.success = false;
                if(output.errorDetail.status==null) {
                    output.errorDetail.status = httpResp.getStatusCode();
                }
            }
        }
        catch(Exception e) {
            output.errorDetail = new Error();
            output.errorDetail.message = 'Adyen capture failed: '+e.getMessage();
            output.success = false;
        }

        return output;
    }
}