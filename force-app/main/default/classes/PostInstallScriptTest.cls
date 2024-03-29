@IsTest
private class PostInstallScriptTest {

    @isTest
    private static void testInstallInitialData() {
        Test.startTest();
        Test.testInstall(new PostInstallScript(), null);
        Test.stopTest();

        List<ccrz__E_ConfigurationModule__c> listCM = [SELECT Id FROM ccrz__E_ConfigurationModule__c];

        System.assertEquals(listCM.size(), 1);
    }
}