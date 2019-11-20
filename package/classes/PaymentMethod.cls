//
// Represents an Adyen PaymentMethod
/*
  "paymentMethod": {
    "type": "scheme",
    "number": "4111111111111111",
    "expiryMonth": "10",
    "expiryYear": "2020",
    "holderName": "John Smith",
    "cvc": "737"
  }
*/
public class PaymentMethod {
    public String number_x;
    public String expiryMonth;
    public String expiryYear;
    public String cvc;
    public String holderName;
    public String type;
}