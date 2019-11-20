@IsTest
private class TestSetupController {

    static testMethod void testInit() {
        Test.startTest();
        SetupController setupController = new SetupController();
        List<Merchant__mdt> merchants = setupController.settings;
        System.assert(merchants.size()>0,'Expected a minimum of 1 Merchant record');
        System.assertEquals(false, setupController.needsRefresh,'Expected needsRefresh false');
        Test.stopTest();

    }

    static testMethod void testNewRow() {
        Test.startTest();
        SetupController setupController = new SetupController();
        setupController.newRow();
        Test.stopTest();
        System.assert(setupController.editingRow<>null,'Expected empty Merchant row');
        System.assertEquals('',setupController.editingRow.MasterLabel,'Expected empty Merchant MasterLabel');
    }

    @isTest
    static void testCancel() {
        Test.startTest();
        SetupController setupController = new SetupController();
        setupController.cancel();
        System.assertEquals(null, setupController.editingRow, 'Expected no row in edit mode anymore after cancel');
        Test.stopTest();
    }
    @isTest
    static void testEditRow() {
        Test.startTest();
        SetupController setupController = new SetupController();
        setupController.editId = 'ApexTest';
        System.assertEquals(Page.EditSetupRecord.getUrl(),setupController.editRow().getUrl(),'Expected to be in edit page');
        System.assertEquals('ApexTest',setupController.editingRow.QualifiedApiName,'Expected ApexTest in edit mode');

        Test.stopTest();
    }
    @isTest
    static void testSaveRow() {
        Test.startTest();
        SetupController setupController = new SetupController();
        setupController.newRow();
        setupController.editingRow.MasterLabel = 'X X';
        setupController.editingRow.Name__c = 'X X';
        setupController.editingRow.Authorise_Endpoint__c = 'http://test.org';
        setupController.editingRow.Capture_Endpoint__c = 'http://test.org';
        setupController.editingRow.API_Key__c = 'TOKEN';
        setupController.saveRow();
        System.assertEquals(true, setupController.needsRefresh,'Expected needsRefresh true');
        System.assertEquals('X_X',setupController.editingRow.QualifiedApiName,'Expected underscored spaces');
        System.assertEquals('APEX',setupController.jobId,'Expected "APEX" jobid');
        setupController.jobReady();
        System.assertEquals(null,setupController.jobId,'Expected null jobid');
        Test.stopTest();
    }


}