//
// Represents the additional data node of the Adyen API
/*
"additionalData": {
    "expiryDate": "10\/2020",
    "fraudResultType": "GREEN",
    "cardHolderName": "John Smith Apex",
    "cardSummary": "1111",
    "fraudManualReview": "false",
    "paymentMethod": "visa"
  } */

global class AdditionalData {
    global String expiryDate;
    global String fraudResultType;
    global String cardHolderName;
    global String cardSummary;
    global String fraudManualReview;
    global String paymentMethod;
    global String recurring_recurringDetailReference;
    global String recurringProcessingModel;
    global String merchantReference;
}