@isTest
public class AdyenTestDataFactory {
    public static List<ccrz__E_PageLabel__c> createCCPageLabel(Integer qty){
        List<ccrz__E_PageLabel__c> listLabels = new List<ccrz__E_PageLabel__c>();
        
        for(Integer i=1; i<=qty; i++){
            ccrz__E_PageLabel__c label = new ccrz__E_PageLabel__c();
            label.Name = 'label'+i;
            label.ccrz__PageName__c = 'All';
            label.ccrz__Storefront__c = 'Global';
            label.ccrz__ValueRT__c = 'value'+i;
            listLabels.add(label);
        }
        
        return listLabels;
    }
    
    public static ccrz__E_ConfigurationModule__c createCCConfigModule(String apiName, String name){
        ccrz__E_ConfigurationModule__c cm = new ccrz__E_ConfigurationModule__c();
        cm.Name = name;
        cm.ccrz__APIName__c = apiName;
        
        return cm;
    }
    
    public static ccrz__E_ConfigurationMeta__c createCCConfigMeta(ccrz__E_ConfigurationModule__c cm, String apiName, String name, String description){
        ccrz__E_ConfigurationMeta__c cme = new ccrz__E_ConfigurationMeta__c();
        cme.ccrz__APIName__c = apiName;
        cme.ccrz__Description__c = description;
        cme.Name = name;
        cme.ccrz__ConfigurationModule__c = cm.Id;
        cme.ccrz__ExternallySafe__c = true;
        
        return cme;
    }
    
    public static ccrz__E_Configuration__c createCCConfig(ccrz__E_ConfigurationMeta__c cme, String pageName, String storeFront, String textValue){
        ccrz__E_Configuration__c config = new ccrz__E_Configuration__c();
        config.ccrz__ConfigurationMeta__c = cme.Id;
        config.ccrz__PageName__c = pageName;
        config.ccrz__Storefront__c = storeFront;
        config.ccrz__TextValue__c = textValue;
        
        return config;
    }
    
    public static Account createAccount(String name){
        Account acc = new Account(
                Name = name
        );
        return acc;
    }
    
    public static Contact createContact(Account acc, String Name){
        Contact con = new Contact(
                AccountId = acc.Id,
                LastName = Name
        );
        return con;
    }
    
    public static User createCommunityUser(Contact con){
        Profile p = [select id from profile where UserType = 'PowerCustomerSuccess' OR UserType = 'PowerPartner'][0];
        Integer rand = Integer.valueof((Math.random() * 100));
        User user = new User(alias = 'c.user' + rand, email='community.user@example.org' + rand,
                emailencodingkey='UTF-8', lastname='Community', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive = true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com' + rand);
        
        return user;
    }
    
    public static ccrz__E_StoredPayment__c createCCStoredPayment(Account acc){
        ccrz__E_StoredPayment__c sp = new ccrz__E_StoredPayment__c();
        sp.ccrz__Account__c = acc.Id;
        sp.ccrz__AccountType__c = 'adyencc';
        sp.ccrz__Token__c = 'token';
        sp.ccrz__ExpYear__c = System.today().year()+2;
        sp.ccrz__ExpMonth__c = System.today().month()+2;
        sp.ccrz__Storefront__c = 'DefaultStore';
        sp.ccrz__AccountNumber__c = '1111';
        sp.ccrz__DisplayName__c = 'test';
        return sp;
    }
    
    public static ccrz__E_Order__c createCCOrder(Account acc, User u, Contact con){
        ccrz__E_Order__c o = new ccrz__E_Order__c();
        o.ccrz__Account__c = acc.Id;
		o.ccrz__BuyerEmail__c = u.Email;
        o.ccrz__Contact__c = con.Id;
        o.ccrz__CurrencyISOCode__c = u.ccrz__CC_CurrencyCode__c;
        o.ccrz__OrderDate__c = system.today();
        o.ccrz__Storefront__c = 'DefaultStore';
        o.ccrz__User__c = u.Id;
        return o;
    }
    
    public static ccrz__E_OrderItem__c createCCOrderItem(ccrz__E_Order__c order){
        ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c();
        oi.ccrz__Order__c = order.Id;
        oi.ccrz__OriginalItemPrice__c = 10;
        oi.ccrz__OriginalQuantity__c = 1;
        oi.ccrz__Price__c = 10;
        oi.ccrz__RequestDate__c = System.today();
        oi.ccrz__StoreId__c = 'DefaultStore';
        oi.ccrz__SubAmount__c = 10;
        oi.ccrz__Quantity__c = 1;
        return oi;
    }
    
    public static ccrz__E_TransactionPayment__c createCCTransactionPayment(ccrz__E_Order__c order, String transactionType, String accountType){
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
        tp.ccrz__Account__c = order.ccrz__Account__c;
        tp.ccrz__AccountType__c = accountType;
        tp.ccrz__TransactionType__c = transactionType;
        tp.ccrz__CCOrder__c = order.Id;
        tp.ccrz__Contact__c = order.ccrz__Contact__c;
        tp.ccrz__CurrencyISOCode__c = order.ccrz__CurrencyISOCode__c;
        tp.ccrz__ExpirationMonth__c = System.today().month();
        tp.ccrz__ExpirationYear__c = System.today().year();
        tp.ccrz__SoldTo__c = order.ccrz__Account__c;
        tp.ccrz__Storefront__c = 'DefaultStore';
        tp.ccrz__TransactionCode__c = String.valueOf(System.currentTimeMillis());
        tp.ccrz__User__c = order.ccrz__User__c;
        tp.ccrz__Amount__c = order.ccrz__TotalAmount__c;
        return tp;
    }
    
    public static ccrz__E_Product__c createCCProduct(String productName){
        ccrz__E_Product__c p = new ccrz__E_Product__c();
        p.ccrz__LongDescRT__c = p.ccrz__ShortDescRT__c = p.ccrz__SEODescription__c = 'desc';
        p.ccrz__InventoryType__c = 'STANDARD';
        P.ccrz__ProductStatus__c = 'Released';
        p.ccrz__ProductType__c = 'Product';
        p.ccrz__UnitOfMeasure__c = 'Each';
        p.ccrz__Storefront__c = 'DefaultStore';
        p.ccrz__ProductIndexStatus__c = 'Current';
        p.Name = productName;
        p.ccrz__SKU__c = productName;
        //p.ccrz__ProductId__c = '';
        p.ccrz__ShippingWeight__c = 3;
        p.ccrz__EndDate__c = System.today()+365;
        p.ccrz__StartDate__c = System.today()-1;
        p.ccrz__LeadTime__c = 1;
        p.ccrz__Quantityperunit__c = 1;
        return p;
    }
    
    public static ccrz__E_Cart__c createCCCart(User u, Contact con, Account acc){
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CurrencyISOCode__c = 'USD';
        cart.ccrz__Name__c = 'New Cart';
        cart.ccrz__BuyerEmail__c = u.Email;
        cart.ccrz__BuyerFirstName__c = u.FirstName;
        cart.ccrz__ActiveCart__c = false;
        cart.ccrz__Storefront__c = 'DefaultStore';
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__CartType__c = 'Cart';
        cart.ccrz__EncryptedId__c = '123123'; // String.valueOf(System.currentTimeMillis());
        cart.ccrz__Contact__c = con.Id;
        cart.ccrz__Account__c = acc.Id;
        return cart;
    }

    public static ccrz__E_CartItem__c createCCCartItem(ccrz__E_Cart__c cart, ccrz__E_Product__c prd){
        ccrz__E_CartItem__c ci = new ccrz__E_CartItem__c();
        ci.ccrz__ProductType__c = 'Product';
        ci.ccrz__cartItemType__c = 'Major';
        ci.ccrz__Is_Subscription_Selected__c = false;
        ci.ccrz__UnitOfMeasure__c = 'Each';
        ci.ccrz__StoreID__c = 'DefaultStore';
        ci.ccrz__ItemStatus__c = 'Available';
        ci.ccrz__PricingType__c = 'auto';
        ci.ccrz__Product__c = prd.Id;
        ci.ccrz__Cart__c = cart.Id;
        ci.ccrz__RequestDate__c = System.today();
        ci.ccrz__OriginalItemPrice__c = 10;
        ci.ccrz__Price__c = 10;
        ci.ccrz__SubAmount__c = 10;
        ci.ccrz__OriginalQuantity__c = 1;
        ci.ccrz__Quantity__c = 1;
        return ci;
    }
}