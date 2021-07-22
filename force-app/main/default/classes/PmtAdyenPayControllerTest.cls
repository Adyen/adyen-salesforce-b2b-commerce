@isTest
private class PmtAdyenPayControllerTest {
    @testSetup
    private static void testData(){

    String adyenNamespace = Util.getNamespacePrefix('cc_adyencc_ccPaymentProcessor');
    Map<String,Map<String,Object>> testSetupDataAdyen = new Map<String,Map<String,Object>>{
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
                                                                    };

        Map<String,Object> resData = ccrz.ccApiTestData.setupData(testSetupDataAdyen);

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

        Account acc = AdyenTestDataFactory.createAccount('account');
        insert acc;

        Contact con = AdyenTestDataFactory.createContact(acc, 'contact');
        insert con;

        User u1 = AdyenTestDataFactory.createCommunityUser(con);
        insert u1;

        ccrz__E_Product__c prd = AdyenTestDataFactory.createCCProduct('product test');
        insert prd;

        ccrz__E_Cart__c cart = AdyenTestDataFactory.createCCCart(u1, con, acc);
        insert cart;

        ccrz__E_CartItem__c cartItem = AdyenTestDataFactory.createCCCartItem(cart, prd);
        insert cartItem;
    }

    @isTest
    private static void testOrderSuccess(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c][0];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        string stateData = '{"riskData":{"clientData":"eyJ2ZXJzaW.."},"paymentMethod":{"type":"scheme","holderName":"Bas","encryptedCardNumber":"adyenjs_0_1_25$YtGy..","encryptedExpiryMonth":"adyenjs_0_1_25$gs6..","encryptedExpiryYear":"adyenjs_0_1_25$dLg..","encryptedSecurityCode":"adyenjs_0_1_25$Qo.."},"browserInfo":{}}';

        Test.setMock(HttpCalloutMock.class, new Mocks.AdyenPaymentsSuccessMock());
        Test.startTest();
        ccrz.cc_RemoteActionResult res = PmtAdyenPayController.placeOrderAdyen(ctx, stateData);
        Test.stopTest();
    }
}