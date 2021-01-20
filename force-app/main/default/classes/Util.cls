//
// Utility methods
public inherited sharing class Util {

    public static Merchant__mdt getConfigByName(String configName) {
        Merchant__mdt[] configs = [
                SELECT API_Key__c, Capture_Endpoint__c, Authorise_Endpoint__c, Disable_Endpoint__c, Payment_Endpoint__c, PaymentMethods_Endpoint__c, Payments_Details_Endpoint__c, Merchant_Account__c, QualifiedApiName
                FROM Merchant__mdt
                WHERE DeveloperName = :configName
                LIMIT 1
        ];
        if (configs <> null && configs.size() == 1) {
            return configs[0];
        } else {
            return null;
        }
    }

    // Delete the suffix from Reserved Keywords
    public static String makeAdyenCompatible(String input) {
        String output = input;
        Map<String, String> mapKeyToReplace = new Map<String, String>();
        mapKeyToReplace.put('currency_x', 'currency');
        mapKeyToReplace.put('number_x', 'number');
        mapKeyToReplace.put('group_x', 'group');
        for (String key : mapKeyToReplace.keySet()) {
            output = output.replace(key, mapKeyToReplace.get(key));
        }

        return output;
    }

    //Add suffix to avoid Reserved Keywords
    public static String makeSalesforceCompatible(String input) {
        String output = input;
        Map<String, String> mapKeyToReplace = new Map<String, String>();
        mapKeyToReplace.put('recurring.recurringDetailReference', 'recurring_recurringDetailReference');
        mapKeyToReplace.put('currency', 'currency_x');
        mapKeyToReplace.put('number', 'number_x');
        mapKeyToReplace.put('group', 'group_x');
        for (String key : mapKeyToReplace.keySet()) {
            output = output.replace(key, mapKeyToReplace.get(key));
        }

        return output;
    }

    public static Map<String, Object> getCCConfig(String configModule, String storeName, Boolean safe, Boolean cache) {
        Map<String, Object> fetchMap = new Map<String, Object>();
        fetchMap.put(ccrz.ccApi.API_VERSION, ccrz.ccAPI.CURRENT_VERSION);
        fetchMap.put(ccrz.ccAPIConfig.CONFIG_MODULE, configModule);
        fetchMap.put(ccrz.ccAPIConfig.STORE_NAME, storeName);
        fetchMap.put(ccrz.ccAPIConfig.EXTERNALLY_SAFE, safe);
        fetchMap.put(ccrz.ccAPIConfig.USE_CACHE, cache);

        return (ccrz.ccAPIConfig.fetch(fetchMap));
    }

    public static Map<String, Object> getLabels(Set<String> labelNames) {
        Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(ccrz.ccApi.API_VERSION, ccrz.ccAPI.CURRENT_VERSION);
        inputData.put(ccrz.ccApiI18N.PAGE_LABEL_NAMES, labelNames);

        return ccrz.ccApiI18N.fetchPageLabels(inputData);
    }

    public static Set<String> getFieldList(String objectName) {
        Map<String, Schema.SObjectType> allObj = Schema.getGlobalDescribe();
        Set<String> setFields = new Set<String>();
        if (allObj.containsKey(objectName)) {
            Schema.SObjectType sot = allObj.get(objectName);
            for (Schema.SObjectField s : sot.getDescribe().fields.getMap().values()) {
                if (s.getDescribe().getName() != 'CloneSourceId') {
                    setFields.add(s.getDescribe().getName());
                }
            }
        }
        return setFields;
    }

    public static String allFieldsCommaSeparated(Set<String> fields) {
        String output = '';
        for (String fieldName : fields) {
            if (fieldName.toLowerCase() == 'id') {
                continue; // Adding Id at the end; saves the comma hassle
            }
            output += fieldName + ', ';
        }
        output += 'Id';
        return output;
    }

    public static String getNamespacePrefix(String className) {
        String namespacePrefix;
        Type t = Type.forName(className);
        String[] classNameParts = String.valueOf(t).split('\\.', 2);
        namespacePrefix = classNameParts.size() == 2 ? classNameParts[0] : 'c';
        return namespacePrefix;
    }
}