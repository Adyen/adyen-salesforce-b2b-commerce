public without sharing class InstallInitialData implements PostInstallScript.InstallAction{
    public void execute(InstallContext context) {
        Set<String> setConfigNames = new Set<String>{'ccrz_E_Configuration_c', 'ccrz_E_ConfigurationMeta_c', 'ccrz_E_ConfigurationModule_c', 'ccrz_E_PageLabel_c'};
        Map<String, Record__mdt> mapStrMdt = getConfigByName(setConfigNames);
        List<ccrz__E_ConfigurationModule__c> listCM = new List<ccrz__E_ConfigurationModule__c>();
        List<ccrz__E_ConfigurationMeta__c> listCMeta = new List<ccrz__E_ConfigurationMeta__c>();
        List<ccrz__E_Configuration__c> listConfs = new List<ccrz__E_Configuration__c>();
        List<ccrz__E_PageLabel__c> listPageLabels = new List<ccrz__E_PageLabel__c>();

        for(String c : mapStrMdt.keySet()){
            switch on c {
                when 'ccrz__E_ConfigurationModule__c' {
                    listCM = (List<ccrz__E_ConfigurationModule__c>)JSON.deserialize(mapStrMdt.get(c).JSON__c, List<ccrz__E_ConfigurationModule__c>.Class);
                }	
                when 'ccrz__E_ConfigurationMeta__c' {
                    listCMeta = (List<ccrz__E_ConfigurationMeta__c>)JSON.deserialize(mapStrMdt.get(c).JSON__c, List<ccrz__E_ConfigurationMeta__c>.Class);
                }
                when 'ccrz__E_Configuration__c' {
                    listConfs = (List<ccrz__E_Configuration__c>)JSON.deserialize(mapStrMdt.get(c).JSON__c, List<ccrz__E_Configuration__c>.Class);
                }
                when 'ccrz__E_PageLabel__c' {
                    listPageLabels = (List<ccrz__E_PageLabel__c>)JSON.deserialize(mapStrMdt.get(c).JSON__c, List<ccrz__E_PageLabel__c>.Class);
                }
            }
        }

        insert listCM;
        insert listCMeta;
        insert listConfs;
        insert listPageLabels;
    }

    public Map<String, Record__mdt> getConfigByName(Set<String> configLNames) {
        Map<String, Record__mdt> mapStrMdt = new Map<String, Record__mdt>();

        for(Record__mdt config : [SELECT DeveloperName, JSON__c, MasterLabel FROM Record__mdt WHERE DeveloperName=:configLNames]){
            mapStrMdt.put(config.MasterLabel, config);
        }
        
        return mapStrMdt;
    }
}