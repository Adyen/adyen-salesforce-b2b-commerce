@IsTest
private class PmtAdyenEditControllerTest {
    
    @testSetup
    private static void testData(){
         Map<String,Object> resData =
            ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>>{
                ccrz.ccApiTestData.APPLICATION_SETTINGS => new Map<String,Object>{
                    'Anonymous_Account_Name__c' => 'CCAnonymous',
                        'Default_Storefront__c' => 'DefaultStore'
                        
                        },
                            ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object>{
                                'DefaultStore' => new Map<String,Object>()            
                                    },
                                        ccrz.ccApiTestData.CONFIG_SETTINGS => new Map<String,Object>{
                                            'pmt_adyencc.config' => 'ApexTest'
                                                },
                                                    ccrz.ccApiTestData.ACCOUNT_DATA => new Map<String,Object>{
                                                        ccrz.ccApiTestData.ACCOUNT_LIST => new List<Map<String,Object>>{
                                                            new Map<String,Object>{
                                                                'name' => 'testAccount1',
                                                                    'ccrz__dataId__c' => 'testAccount1'
                                                                    }
                                                        }
                                                    }
            });
        
        ccrz__E_ConfigurationModule__c cm = AdyenTestDataFactory.createCCConfigModule('pmt_adyencc', 'name');
        insert cm;
        
        ccrz__E_ConfigurationMeta__c cme = AdyenTestDataFactory.createCCConfigMeta(cm, 'config', 'name', 'desc');
        insert cme;
        
        ccrz__E_Configuration__c config = AdyenTestDataFactory.createCCConfig(cme, 'all', 'Global', 'ApexTest');
        config.Name = 'Global.all.pmt_adyencc.config';
        insert config;
        
        Map<String,Object> accData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.ACCOUNT_DATA);
        List<Account> accList = (List<Account>)accData.get(ccrz.ccApiTestData.ACCOUNT_LIST);
        
        ccrz__E_StoredPayment__c sp = AdyenTestDataFactory.createCCStoredPayment(accList[0]);
        insert sp;
    }
    
    static testMethod void testPmtAdyenEditController(){
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1];
        apexpages.currentpage().getparameters().put('pid', sp.Id);
        
        Test.startTest();
        PmtAdyenEditController editController = new PmtAdyenEditController();
        Test.stopTest();
        
        System.assertEquals(sp.Id, editController.storedPayment.Id);
    }
    
    static testMethod void testUpdateAdyenccStoredPayment(){
        ccrz__E_StoredPayment__c sp = Selector.getStoredPayment([SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1].Id);
        
        Map<String,Object> mapInputData = new Map<String,Object>();
        mapInputData.put('storedPaymentId', (String)sp.Id);
        mapInputData.put('displayName', (String)sp.ccrz__DisplayName__c);
        mapInputData.put('isEnabled', String.valueOf(sp.ccrz__Enabled__c));
        mapInputData.put('expirationMonth', String.valueOf(sp.ccrz__ExpMonth__c));
        mapInputData.put('expirationYear', String.valueOf(sp.ccrz__ExpYear__c));
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testUpdateAdyenccStoredPaymentCallout(){
        ccrz__E_StoredPayment__c sp = Selector.getStoredPayment([SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1].Id);
        
        Map<String,Object> mapInputData = new Map<String,Object>();
        mapInputData.put('storedPaymentId', (String)sp.Id);
        mapInputData.put('displayName', (String)sp.ccrz__DisplayName__c);
        mapInputData.put('isEnabled', String.valueOf(sp.ccrz__Enabled__c));
        mapInputData.put('expirationMonth', String.valueOf(sp.ccrz__ExpMonth__c+1));
        mapInputData.put('expirationYear', String.valueOf(sp.ccrz__ExpYear__c+1));
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenUpdateSuccessMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testUpdateAdyenccStoredPaymentCalloutError(){
        ccrz__E_StoredPayment__c sp = Selector.getStoredPayment([SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1].Id);
        
        Map<String,Object> mapInputData = new Map<String,Object>();
        mapInputData.put('storedPaymentId', (String)sp.Id);
        mapInputData.put('displayName', (String)sp.ccrz__DisplayName__c);
        mapInputData.put('isEnabled', String.valueOf(sp.ccrz__Enabled__c));
        mapInputData.put('expirationMonth', String.valueOf(sp.ccrz__ExpMonth__c+1));
        mapInputData.put('expirationYear', String.valueOf(sp.ccrz__ExpYear__c+1));
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenUpdateErrorMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testUpdateAdyenccStoredPaymentCalloutResufed(){
        ccrz__E_StoredPayment__c sp = Selector.getStoredPayment([SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1].Id);
        
        Map<String,Object> mapInputData = new Map<String,Object>();
        mapInputData.put('storedPaymentId', (String)sp.Id);
        mapInputData.put('displayName', (String)sp.ccrz__DisplayName__c);
        mapInputData.put('isEnabled', String.valueOf(sp.ccrz__Enabled__c));
        mapInputData.put('expirationMonth', String.valueOf(sp.ccrz__ExpMonth__c+1));
        mapInputData.put('expirationYear', String.valueOf(sp.ccrz__ExpYear__c+1));
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenUpdateRefusedMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenEditController.updateAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
}