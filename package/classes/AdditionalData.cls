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

public class AdditionalData {
    public String expiryDate;
    public String fraudResultType;
    public String cardHolderName;
    public String cardSummary;
    public String fraudManualReview;
    public String paymentMethod;
}