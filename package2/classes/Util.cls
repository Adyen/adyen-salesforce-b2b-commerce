//
// Utility methods
public class Util {
    //
    // Strip off the _x's needed to avoid protected keywords
    public static String stripX(String input) {
        String output = input;
        if(output <> null) {
            output = output.replace('_x','');
        }
        return output;
    }
    public static Merchant__mdt getConfigByName(String configName) {
        Merchant__mdt[] configs = [SELECT API_Key__c, Capture_Endpoint__c, Authorise_Endpoint__c, Name__c, Reference__c, QualifiedApiName FROM Merchant__mdt WHERE QualifiedApiName=:configName LIMIT 1];
        if(configs <> null && configs.size()==1) {
            return configs[0];
        } else {
            return null;
        }
    }
}