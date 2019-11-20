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
global class CaptureRequest {
    global String originalReference;
    global Amount modificationAmount;
    global String reference;
    global String merchantAccount;
}