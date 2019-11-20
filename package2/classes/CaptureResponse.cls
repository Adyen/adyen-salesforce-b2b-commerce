/*
Represents the capture response object of the Adyen API
  {"pspReference":"883567596365413G","response":"[capture-received]"}
 */

global class CaptureResponse {
    global String pspReference;
    global String response;
    //
    // Added by the client
    global Error errorDetail;
    global Boolean success;
}