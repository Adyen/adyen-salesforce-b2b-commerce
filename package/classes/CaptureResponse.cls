/*
Represents the capture response object of the Adyen API
  {"pspReference":"883567596365413G","response":"[capture-received]"}
 */

public class CaptureResponse {
    public String pspReference;
    public String response;
    //
    // Added by the client
    public Error errorDetail;
    public Boolean success;
}