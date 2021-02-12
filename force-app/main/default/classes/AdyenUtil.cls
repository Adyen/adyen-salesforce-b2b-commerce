public with sharing class AdyenUtil {
    public static Merchant__mdt getConfiguredMerchantAccount(ccrz__E_Cart__c cart) {
        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
        Map<String, String> mapConfigs = (Map<String, String>) mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
        //TODOBAS refactor
        return Util.getConfigByName('AdyenMerchantConfig');
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

    public static OASApplicationInfo getApplicationInfo() {
        OASApplicationInfo applicationInfo = new OASApplicationInfo();
        OASCommonField adyenPaymentSource = new OASCommonField();
        adyenPaymentSource.name = AdyenConstants.PACKAGE_NAME;
        adyenPaymentSource.version = AdyenConstants.PACKAGE_VERSION;
        applicationInfo.adyenPaymentSource = adyenPaymentSource;

        OASExternalPlatform externalPlatform = new OASExternalPlatform();
        externalPlatform.name = AdyenConstants.PLATFORM_NAME;
        externalPlatform.version = '';
        applicationInfo.externalPlatform = externalPlatform;
        return applicationInfo;
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