//
// Represents and Adyen AuthoriseRequest
/*
{
  "amount": {
    "currency": "USD",
    "value": 1000
  },
  "reference": "Your order number",
  "paymentMethod": {
    "type": "scheme",
    "number": "4111111111111111",
    "expiryMonth": "10",
    "expiryYear": "2020",
    "holderName": "John Smith",
    "cvc": "737"
  },
  "returnUrl": "https://your-company.com/...",
  "merchantAccount": "YOUR_MERCHANT_ACCOUNT"

“applicationInfo”:{
    “adyenPaymentSource”:{
       “name”:“YOUR_PLUGIN”,
       “version”:“YOUR_PLUGIN_VERSION”
    },
    “externalPlatform”:{
       “name”:“PLATFORM_NAME”,
       “version”:“PLATFORM_VERSION”,
       “integrator”:“YOUR_SYSTEM_INTEGRATOR_NAME”
    }
 }
*/

public class AuthoriseRequest {
    public Amount amount;
    public PaymentMethod paymentMethod;
    public ApplicationInfo applicationInfo;
    public String reference;
    public String merchantAccount;
    public String returnUrl;
}