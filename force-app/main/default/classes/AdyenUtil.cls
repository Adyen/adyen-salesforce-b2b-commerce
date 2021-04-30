public inherited sharing class AdyenUtil {
    public static String getClientKey(){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        return merchant.Client_Key__c;
    }

    public static String getAdyenEnvironment(){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        if(merchant.PaymentMethods_Endpoint__c.contains('checkout-live')
        && merchant.Payment_Endpoint__c.contains('checkout-live')
        && merchant.Payments_Details_Endpoint__c.contains('checkout-live')){
            return 'live';
        }
        return 'test';
    }

    public static String getConfiguredCaptureDelay(ccrz__E_Cart__c cart) {
        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
        Map<String, String> mapConfigs = (Map<String, String>) mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
        Boolean immediateCapture = Boolean.valueOf(mapConfigs.get('pmt_adyencc.immediate_capture'));
        return immediateCapture ? AdyenConstants.IMMEDIATE_CAPTURE : AdyenConstants.MANUAL_CAPTURE;
    }

    public static ccrz__E_Cart__c getCartByEncryptedId(String cartId) {
        String query = 'SELECT ' + Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Cart__c')) + ', Owner.Email FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartId LIMIT 1';
        return (ccrz__E_Cart__c) Database.query(query);
    }

    public static String getCartEncryptedId(String cartId) {
        String query = 'SELECT ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE Id = :cartId LIMIT 1';
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c) Database.query(query);
        return (String) cart.ccrz__EncryptedId__c;
    }

    public static User getAccountIdFromUser(Id userId) {
        return [SELECT AccountId
                FROM User WHERE Id = :userId];
    }

    public static ccrz__E_StoredPayment__c getStoredPayment(String storedPaymentId) {
        return [SELECT Id,
                ccrz__Account__c,
                ccrz__Token__c,
                ccrz__AccountType__c,
                ccrz__ExpYear__c,
                ccrz__ExpMonth__c,
                ccrz__StoreFront__c,
                ccrz__DisplayName__c,
                ccrz__Enabled__c,
                ccrz__User__c
                FROM ccrz__E_StoredPayment__c WHERE Id = :storedPaymentId AND ccrz__User__c = :UserInfo.getUserId()];
    }

    public static List<ccrz__E_StoredPayment__c> getStoredPaymentByToken(String token) {
        return [SELECT Id,
                ccrz__Account__c,
                ccrz__Token__c,
                ccrz__AccountType__c,
                ccrz__ExpYear__c,
                ccrz__ExpMonth__c,
                ccrz__StoreFront__c,
                ccrz__DisplayName__c,
                ccrz__Enabled__c,
                ccrz__User__c
                FROM ccrz__E_StoredPayment__c WHERE ccrz__Token__c = :token AND ccrz__User__c = :UserInfo.getUserId()];
    }

    public static Amount getAdyenAmount(String currencyCode, Decimal amount) {
        Integer multiplier = getMultiplierMinorUnits(currencyCode);
        Amount adyenAmount = new Amount();
        adyenAmount.currency_x = currencyCode;
        adyenAmount.value = (Long) amount * multiplier;
        return adyenAmount;
    }

    public static Integer getMultiplierMinorUnits(String currencyCode) {
        switch on currencyCode {
            when 'CVE', 'DJF', 'GNF', 'IDR', 'JPY', 'KMF', 'KRW', 'PYG', 'RWF', 'UGX', 'VND', 'VUV', 'XAF', 'XOF', 'XPF' {
                return 1;
            }
            when 'BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND' {
                return 1000;
            }
            when else {
                return 100;
            }
        }
    }

    public static ApplicationInfo getApplicationInfo() {
        ApplicationInfo applicationInfo = new ApplicationInfo();
        CommonField adyenPaymentSource = new CommonField();
        adyenPaymentSource.name = AdyenConstants.PACKAGE_NAME;
        adyenPaymentSource.version = AdyenConstants.PACKAGE_VERSION;
        applicationInfo.adyenPaymentSource = adyenPaymentSource;

        ExternalPlatform externalPlatform = new ExternalPlatform();
        externalPlatform.name = AdyenConstants.PLATFORM_NAME;
        externalPlatform.version = '';
        externalPlatform.integrator = getAppInfoSI();
        applicationInfo.externalPlatform = externalPlatform;
        return applicationInfo;
    }

    public static String getAppInfoSI(){
        Merchant__mdt merchant = Util.getConfigByName('AdyenMerchantConfig');
        return merchant.ApplicationInfo_SI__c;
    }

    public static Boolean isHttpResponseOK(Integer responseCode) {
        List<Integer> responseOK = new List<Integer>{
                200, 201, 202, 204
        } ;
        return responseOK.contains(responseCode);
    }

//
//    public static DisableRequest disableStoredPayment(ccrz__E_StoredPayment__c storedPayment,  Merchant__mdt merchant)
//    {
//        DisableRequest dr = new DisableRequest();
//
//        dr.merchantAccount = merchant.Name__c;
//        dr.shopperReference = storedPayment.ccrz__Account__c;
//        dr.recurringDetailReference = storedPayment.ccrz__Token__c;
//
//        return dr;
//    }
//
//    public static AuthoriseRequest updateSoretPayment(ccrz__E_StoredPayment__c storedPayment,  Merchant__mdt merchant)
//    {
//        AuthoriseRequest request = new AuthoriseRequest();
//        request.amount = new Amount();
//        request.card = new PaymentMethod();
//        request.recurring = new Recurring();
//
//        request.amount.value = 0;
//        request.amount.currency_x = UserInfo.getDefaultCurrency();
//
//        request.card.expiryMonth = String.valueOf(storedPayment.ccrz__ExpMonth__c);
//        request.card.expiryYear = String.valueOf(storedPayment.ccrz__ExpYear__c);
//
//        request.reference = storedPayment.Id;
//        request.shopperReference = storedPayment.ccrz__Account__c;
//        request.shopperInteraction = 'ContAuth';
//        request.selectedRecurringDetailReference = storedPayment.ccrz__Token__c;
//        request.merchantAccount = merchant.Name__c;
//
//        request.recurring.contract = 'RECURRING';
//
//        return request;
//    }
}