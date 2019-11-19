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
global class PaymentMethod {
    global String number_x;
    global String expiryMonth;
    global String expiryYear;
    global String cvc;
    global String holderName;
    global String type;
    global String recurringDetailReference;
}