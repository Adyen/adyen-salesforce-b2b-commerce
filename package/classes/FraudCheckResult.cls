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

public with sharing class FraudCheckResult {
    public Integer accountScore;
    public Integer checkId;
    public String name;
}