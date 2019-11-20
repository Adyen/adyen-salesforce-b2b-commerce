@IsTest
private class BatchCapturePaymentTest {
    
    @testSetup
    private static void testData() {
		Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name='Customer Community User' LIMIT 1];
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
                                                    },
                                                        ccrz.ccApiTestData.CONTACT_DATA => new Map<String,Object>{
                                                            ccrz.ccApiTestData.CONTACT_LIST => new List<Map<String,Object>>{
                                                                new Map<String,Object>{
                                                                    'ccrz__dataId__c' => 'testContact1',
                                                                        'account' => new Account(ccrz__dataId__c = 'testAccount1'),
                                                                        'email' => 'testcontact1.ccrz@cloudcraze.com',
                                                                        'lastName' => 'User1',
                                                                        'firstName' => 'Test1'
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
        
        Map<String,Object> conData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.CONTACT_DATA);
        List<Contact> conList = (List<Contact>)conData.get(ccrz.ccApiTestData.CONTACT_LIST);
        
        List<User> userList = [SELECT Id, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
            
        ccrz__E_Order__c order = AdyenTestDataFactory.createCCOrder(accList[0], userList[0], conList[0]);
        insert order;
        
        ccrz__E_OrderItem__c orderItem = AdyenTestDataFactory.createCCOrderItem(order);
        insert orderItem;
        
        order = database.query('SELECT '+Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Order__c'))+' FROM ccrz__E_Order__c WHERE Id = \''+order.Id+'\'');
        
        ccrz__E_TransactionPayment__c tp1 = AdyenTestDataFactory.createCCTransactionPayment(order, 'AUTH', 'adyencc');
        insert tp1;
	}
    
    static testMethod void testCapturePayment(){
        
		ccrz__E_TransactionPayment__c tp1 = [SELECT Id FROM ccrz__E_TransactionPayment__c][0];        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureSuccessMock());
        Database.executeBatch(new BatchCapturePayment(new Set<Id>{tp1.Id}));
        Test.stopTest();
        
        List<ccrz__E_TransactionPayment__c> listTP = [SELECT Capture_Payment__c FROM ccrz__E_TransactionPayment__c];
        
        System.assertEquals(listTP.size(), 2);
    }
    
    static testMethod void testCapturePaymentError(){
        
		ccrz__E_TransactionPayment__c tp1 = [SELECT Id FROM ccrz__E_TransactionPayment__c][0];        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenCaptureErrorMock());
        Database.executeBatch(new BatchCapturePayment(new Set<Id>{tp1.Id}));
        Test.stopTest();
        
        List<ccrz__E_TransactionPayment__c> listTP = [SELECT Capture_Payment__c FROM ccrz__E_TransactionPayment__c];
        
        System.assertEquals(listTP.size(), 1);
    }
}