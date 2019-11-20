@isTest
private class cc_adyencc_hk_PaymentTest {
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
    
    private static testMethod void testRemoveStoredPayment() {
       
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1];
            
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID, (String)sp.Id);
        
        cc_adyencc_hk_Payment pmtHk = new cc_adyencc_hk_Payment();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableSuccessMock());
        pmtHk.removeStoredPayment(inputData);
        Test.stopTest();
        
        List<ccrz__E_StoredPayment__c> listSP = [SELECT Id FROM ccrz__E_StoredPayment__c];
        
        System.assertEquals(listSP.size(), 0);
    }
    
    private static testMethod void testRemoveStoredPaymentError() {
       
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1];
            
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID, (String)sp.Id);
        
        cc_adyencc_hk_Payment pmtHk = new cc_adyencc_hk_Payment();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenDisableErrorMock());
        pmtHk.removeStoredPayment(inputData);
        Test.stopTest();
        
        List<ccrz__E_StoredPayment__c> listSP = [SELECT Id FROM ccrz__E_StoredPayment__c];
        
        System.assertEquals(listSP.size(), 1);
    }
    
    private static testMethod void testRemoveStoredPaymentPO() {
       
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c LIMIT 1];
        sp.ccrz__AccountType__c = 'po';
        update sp;
        
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENT_ID, (String)sp.Id);
        
        cc_adyencc_hk_Payment pmtHk = new cc_adyencc_hk_Payment();

        Test.startTest();
        pmtHk.removeStoredPayment(inputData);
        Test.stopTest();
        
        List<ccrz__E_StoredPayment__c> listSP = [SELECT Id FROM ccrz__E_StoredPayment__c];
        
        System.assertEquals(listSP.size(), 0);
    }
}