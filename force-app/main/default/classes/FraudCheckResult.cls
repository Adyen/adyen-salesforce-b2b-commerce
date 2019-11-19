//
// Represents a FraudCheckResult element in the Adyen API
/*
{
        "FraudCheckResult": {
          "accountScore": 0,
          "checkId": 2,
          "name": "CardChunkUsage"
        }
*/

global class FraudCheckResult {
    global Integer accountScore;
    global Integer checkId;
    global String name;
}