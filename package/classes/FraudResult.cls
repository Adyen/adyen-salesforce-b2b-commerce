//
// Represents the fraudResult object from the Adyen API
/*
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

*/
public with sharing class FraudResult {
    public Integer accountScore;
    public List<ResultRow> results;
}