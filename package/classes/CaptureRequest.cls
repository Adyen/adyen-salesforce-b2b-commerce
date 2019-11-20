//
// Represents an Adyen Capture Request

/*
{
  "originalReference": "COPY_PSP_REFERENCE_FROM_AUTHORISE_RESPONSE",
  "modificationAmount": {
    "value": 500,
    "currency": "EUR"
  },
  "reference": "YourModificationReference",
  "merchantAccount": "YOUR_MERCHANT_ACCOUNT"
}
*/
public class CaptureRequest {
    public String originalReference;
    public Amount modificationAmount;
    public String reference;
    public String merchantAccount;
}