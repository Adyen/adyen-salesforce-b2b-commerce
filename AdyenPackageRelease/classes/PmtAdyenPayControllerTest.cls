@isTest
private class PmtAdyenPayControllerTest {
    @testSetup
    private static void testData(){

        String adyenNamespace = Util.getNamespacePrefix('cc_adyencc_ccPaymentProcessor');

        Map<String,Object> resData =
            ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>>{
                ccrz.ccApiTestData.APPLICATION_SETTINGS => new Map<String,Object>{
                    'Anonymous_Account_Name__c' => 'CCAnonymous',
                        'Default_Storefront__c' => 'DefaultStore'
                        
                        },
                            ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object>{
                                'DefaultStore' => new Map<String,Object>()            
                                    },
                                        ccrz.ccApiTestData.HOOK_SETTINGS => new Map<String,Object>{
                                            'DefaultStore' => new Map<String,Object>{
                                                'cc_hk_Payment.HK_ID' => adyenNamespace+'.cc_adyencc_hk_Payment'
                                                    }
                                        },
                                            ccrz.ccApiTestData.CONFIG_SETTINGS => new Map<String,Object>{
                                                'pmt_adyencc.config' => 'ApexTest',
                                                    'pmt_adyencc.proc' => adyenNamespace+'.cc_adyencc_ccPaymentProcessor'
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
                                                            },
                                                                ccrz.ccApiTestData.BASE_PRICELISTS => new Map<String,Object>{
                                                                    'MyStore' => new Map<String,Object>{
                                                                        'USD' => 'EnterpriseUSD'
                                                                            }
                                                                },
                                                                    ccrz.ccApiTestData.PRICELIST_DATA => null
                                                                    });
        
        Map<String,Object> accData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.ACCOUNT_DATA);
        List<Account> accList = (List<sObject>)accData.get(ccrz.ccApiTestData.ACCOUNT_LIST);
        
        Map<String,Object> conData = (Map<String,Object>)resData.get(ccrz.ccApiTestData.CONTACT_DATA);
        List<Contact> conList = (List<sObject>)conData.get(ccrz.ccApiTestData.CONTACT_LIST);
        
        ccrz__E_ConfigurationModule__c cm = AdyenTestDataFactory.createCCConfigModule('pmt_adyencc', 'name');
        insert cm;
        
        ccrz__E_ConfigurationMeta__c cme = AdyenTestDataFactory.createCCConfigMeta(cm, 'config', 'name', 'desc');
        insert cme;
        
        ccrz__E_ConfigurationMeta__c cme2 = AdyenTestDataFactory.createCCConfigMeta(cm, 'proc', 'name', 'desc');
        insert cme2;
        
        ccrz__E_ConfigurationMeta__c cme3 = AdyenTestDataFactory.createCCConfigMeta(cm, 'immediate_capture', 'name', 'desc');
        insert cme3;
        
        ccrz__E_Configuration__c config = AdyenTestDataFactory.createCCConfig(cme, 'all', 'Global', 'ApexTest');
        config.Name = 'Global.all.pmt_adyencc.config';
        insert config;
        
        ccrz__E_Configuration__c config2 = AdyenTestDataFactory.createCCConfig(cme2, 'all', 'Global', adyenNamespace+'.cc_adyencc_ccPaymentProcessor');
        config2.Name = 'Global.all.pmt_adyencc.proc';
        insert config2;
        
        ccrz__E_Configuration__c config3 = AdyenTestDataFactory.createCCConfig(cme3, 'all', 'Global', 'false');
        config3.Name = 'Global.all.pmt_adyencc.immediate_capture';
        insert config3;
        
        ccrz__E_Product__c prd = AdyenTestDataFactory.createCCProduct('product test');
        insert prd;
        
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz__E_Cart__c cart = AdyenTestDataFactory.createCCCart(userList[0], conList[0], accList[0]);
        insert cart;
        
        ccrz__E_CartItem__c cartItem = AdyenTestDataFactory.createCCCartItem(cart, prd);
        insert cartItem;
        
        ccrz__E_StoredPayment__c sp = AdyenTestDataFactory.createCCStoredPayment(accList[0]);
        insert sp;
    }
    
    static testmethod void testMissingInputs(){
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '1111'}
        };
            
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testOrderSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        PmtAdyenPayController pmt = new PmtAdyenPayController();
        Boolean isGuest = pmt.isGuest;
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testOrderSaveStoredPaymentSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'},
                                        'saveAsStoredPayment' => new Map<String,String>{'value' => 'true'}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testOrderSaveUsingStoredPaymentSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'},
                                        'storedPaymentId' => new Map<String,String>{'value' => (String)sp.Id}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseSuccessMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, true);
    }
    
    static testMethod void testOrderSaveUsingStoredPaymentError(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'},
                                        'storedPaymentId' => new Map<String,String>{'value' => (String)sp.Id}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseErrorMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testOrderSaveUsingStoredPaymentRefused(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        ccrz__E_StoredPayment__c sp = [SELECT Id FROM ccrz__E_StoredPayment__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'},
                                        'storedPaymentId' => new Map<String,String>{'value' => (String)sp.Id}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseRefusedMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testOrderError(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseErrorMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
    
    static testMethod void testOrderRefused(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];
        
        //system.debug(cart);
        List<User> userList = [SELECT Id, FirstName, Email, ccrz__CC_CurrencyCode__c FROM User where id = :UserInfo.getUserId()];
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ctx.storefront = 'DefaultStore';
        ctx.userIsoCode = userList[0].ccrz__CC_CurrencyCode__c;
        
        Map<String, Map<String,String>> mapInputData = new Map<String, Map<String,String>>{
            'accountNumber' => new Map<String,String>{'value' => '4111111111111111'},
                'expirationMonth' => new Map<String,String>{'value' => '10'},
                    'expirationYear' => new Map<String,String>{'value' => '2020'},
                        'verificationCode' => new Map<String,String>{'value' => '737'},
                            'displayName' => new Map<String,String>{'value' => 'test'},
                                'saveAsStoredPayment' => new Map<String,String>{'value' => 'false'},
                                    'accountName' => new Map<String,String>{'value' => 'name'}
        };
            
            Test.setMock(HttpCalloutMock.class, new Mocks.AdyenAuthoriseRefusedMock());     
        
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.pressMeCcrz(ctx, mapInputData);
        Test.stopTest();
        
        System.assertEquals(res.success, false);
    }
}