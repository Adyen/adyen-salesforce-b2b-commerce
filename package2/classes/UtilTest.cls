@IsTest
private class UtilTest {
	static testMethod void testStripX() {
        String str1 = 'a_xbc';
        String str2 = Util.stripX(str1);
        System.assertEquals(str2, 'abc');
    }
    
    static testMethod void testReplaceDots() {
        String str1 = 'recurring.recurringDetailReference';
        String str2 = Util.replaceDots(str1);
        System.assertEquals(str2, 'recurring_recurringDetailReference');
    }
    
    static testMethod void testGetFieldList() {
        Set<String> setFields = Util.getFieldList('Account');
        System.assert(setFields.size() > 0);
    }
    
    static testMethod void testAllFieldsCommaSeparated() {
        Set<String> setFields = Util.getFieldList('Account');
        Decimal fLength1 = setFields.size();
        String str = Util.allFieldsCommaSeparated(setFields);
        Decimal fLength2 = str.split(',').size();
        System.assertEquals(fLength1, fLength2);
    }
    
    static testMethod void testGetLabels(){
        List<ccrz__E_PageLabel__c> listPL = AdyenTestDataFactory.createCCPageLabel(5);
        insert listPL;
        Map<String,Object> mapLabels1 = Util.getLabels(new Set<String>{'label1', 'label2'});
        System.assertEquals((Boolean)mapLabels1.get('success'), true);
        Map<String,String> mapLabels2 = (Map<String,String>)mapLabels1.get('pageLabels');
        System.assertEquals(mapLabels2.size(), 2);
    }
    
    static testMethod void testGetCCConfig(){
        ccrz__E_ConfigurationModule__c cm = AdyenTestDataFactory.createCCConfigModule('apiName', 'name');
        insert cm;
        
        ccrz__E_ConfigurationMeta__c cme = AdyenTestDataFactory.createCCConfigMeta(cm, 'apiName', 'name', 'desc');
        insert cme;
        
        ccrz__E_Configuration__c config = AdyenTestDataFactory.createCCConfig(cme, 'pageName', 'Global', 'textValue');
        insert config;
        
        Map<String,Object> mapConfig = Util.getCCConfig('apiName', 'Global', false, false);
        System.assertEquals((Boolean)mapConfig.get('success'), true);
        Map<String,String> mapConfigResult = (Map<String,String>)mapConfig.get('configurations');
        System.assertEquals(mapConfigResult.size(), 1);
    }
}