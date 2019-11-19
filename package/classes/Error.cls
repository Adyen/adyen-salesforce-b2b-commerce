//
// Represents an Adyen API error
/*{
  "status": 422,
  "errorCode": "167",
  "message": "Original pspReference required for this operation",
  "errorType": "validation"
}
 */
public class Error {
    public Integer status;
    public String errorCode;
    public String message;
    public String errorType;
}