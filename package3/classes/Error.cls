//
// Represents an Adyen API error
/*{
  "status": 422,
  "errorCode": "167",
  "message": "Original pspReference required for this operation",
  "errorType": "validation"
}
 */
global class Error {
    global Integer status;
    global String errorCode;
    global String message;
    global String errorType;
}