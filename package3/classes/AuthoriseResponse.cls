//
// Represents the Adyen response to Authorise request
/*
{
  "additionalData": {
    "expiryDate": "10\/2020",
    "fraudResultType": "GREEN",
    "cardHolderName": "John Smith Apex",
    "cardSummary": "1111",
    "fraudManualReview": "false",
    "paymentMethod": "visa"
  },
  "fraudResult": {
    "accountScore": 50,
    "results": [
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 2,
          "name": "CardChunkUsage"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 3,
          "name": "PaymentDetailUsage"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 4,
          "name": "HolderNameUsage"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 1,
          "name": "PaymentDetailRefCheck"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 13,
          "name": "IssuerRefCheck"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 27,
          "name": "PmOwnerRefCheck"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 50,
          "checkId": 41,
          "name": "PaymentDetailNonFraudRefCheck"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 10,
          "name": "HolderNameContainsNumber"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 11,
          "name": "HolderNameIsOneWord"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 15,
          "name": "IssuingCountryReferral"
        }
      },
      {
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 25,
          "name": "CVCAuthResultCheck"
        }
      }
    ]
  },
  "pspReference": "853567420135695D",
  "resultCode": "Authorised",
  "merchantReference": "Appsolutely"
}
*/
global class AuthoriseResponse {
    global String pspReference;
    global String resultCode;
    global String merchantReference;
    global AdditionalData additionalData;
    global FraudResult fraudResult;
    //
    // Added by the client
    global Error errorDetail;
    global Boolean success;
}