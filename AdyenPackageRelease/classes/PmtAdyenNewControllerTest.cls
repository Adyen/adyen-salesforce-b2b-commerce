@IsTest
private class PmtAdyenNewControllerTest {
    
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
    
    static testMethod void testAddAdyenccStoredPayment(){
        Map<String,Object> mapInputData = new Map<String,Object>();

        mapInputData.put('displayName', 'test display name');
        mapInputData.put('isEnabled', 'true');
        mapInputData.put('expirationMonth', String.valueOf(System.today().month()));
        mapInputData.put('expirationYear', String.valueOf(System.today().year()));
        mapInputData.put('accountType', 'adyencc');
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenNewController.addAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testAddAdyenccStoredPaymentError(){
        Map<String,Object> mapInputData = new Map<String,Object>();

        mapInputData.put('displayName', 'test display name');
        mapInputData.put('isEnabled', 'true');
        mapInputData.put('expirationMonth', String.valueOf(System.today().month()));
        mapInputData.put('expirationYear', String.valueOf(System.today().year()));
        mapInputData.put('accountType', 'adyencc');
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseErrorMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenNewController.addAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testAddAdyenccStoredPaymentRefused(){
        Map<String,Object> mapInputData = new Map<String,Object>();

        mapInputData.put('displayName', 'test display name');
        mapInputData.put('isEnabled', 'true');
        mapInputData.put('expirationMonth', String.valueOf(System.today().month()));
        mapInputData.put('expirationYear', String.valueOf(System.today().year()));
        mapInputData.put('accountType', 'adyencc');
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseRefusedMock());
        ccrz.cc_RemoteActionResult res = PmtAdyenNewController.addAdyenccStoredPayment(ctx, JSON.serialize(mapInputData));
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
}