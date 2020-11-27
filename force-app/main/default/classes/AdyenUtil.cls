public with sharing class AdyenUtil {
    public static Merchant__mdt getConfiguredMerchantAccount(ccrz__E_Cart__c cart){
        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
        Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
        return Util.getConfigByName(mapConfigs.get('pmt_adyencc.config'));
    }

    public static String getConfiguredCaptureDelay(ccrz__E_Cart__c cart){
        Map<String, Object> mapAdyenParams = Util.getCCConfig('pmt_adyencc', cart.ccrz__Storefront__c, true, true);
        Map<String, String> mapConfigs = (Map<String,String>)mapAdyenParams.get(ccrz.ccAPIConfig.CONFIGURATIONS);
        Boolean immediateCapture = Boolean.valueOf(mapConfigs.get('pmt_adyencc.immediate_capture'));
        return immediateCapture ? AdyenConstants.IMMEDIATE_CAPTURE : AdyenConstants.MANUAL_CAPTURE;
    }

    public static ccrz__E_Cart__c getCartFromDatabase(String cartId){
        String query = 'SELECT ' + Util.allFieldsCommaSeparated(Util.getFieldList('ccrz__E_Cart__c')) +', Owner.Email FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartId LIMIT 1';
        return (ccrz__E_Cart__c) Database.query(query);
    }

    public static OASAmount getAdyenAmount(ccrz__E_Cart__c cart){
        Integer multiplier = getMultiplierMinorUnits(cart.ccrz__CurrencyISOCode__c);
        OASAmount amount = new OASAmount();
        amount.currency_x = cart.ccrz__CurrencyISOCode__c;
        amount.value = (Long)cart.ccrz__TotalAmount__c * multiplier;
        return amount;
    }

    public static OASApplicationInfo getApplicationInfo(){
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

    public static Boolean isHttpResponseOK(Integer responseCode){
        List<Integer> responseOK = new List<Integer> {200, 201, 202, 204};
        return responseOK.contains(responseCode);
    }
    
    public static AuthoriseRequest authoriseFromNewPage(Map<String, Object> inputData, Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
//        request.amount = new Amount();
//        request.paymentMethod = new PaymentMethod();
//        request.applicationInfo = new ApplicationInfo();
//        request.applicationInfo.adyenPaymentSource = new PaymentSource();
//        request.applicationInfo.externalPlatform = new ExternalPlatform();
//
//        request.applicationInfo.adyenPaymentSource.version = '1.0.0';
//        request.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
//        request.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
//        request.applicationInfo.externalPlatform.integrator = '';
//        request.applicationInfo.externalPlatform.version = '';
//
//        request.amount.currency_x = UserInfo.getDefaultCurrency();
//        request.amount.value = 0;
//
//        request.paymentMethod.number_x = String.valueOf(inputData.get('accountNumber'));
//        request.paymentMethod.expiryMonth = String.valueOf(inputData.get('expirationMonth'));
//        request.paymentMethod.expiryYear = String.valueOf(inputData.get('expirationYear'));
//        request.paymentMethod.cvc = String.valueOf(inputData.get('verificationCode'));
//        request.paymentMethod.type = 'scheme';
//
//        request.reference = UserInfo.getUserId();
//        request.merchantAccount = merchant.Name__c;
//        request.storePaymentMethod = true;
//        request.shopperReference = Selector.getUserAndAccount(UserInfo.getUserId()).AccountId;
        
        return request;
    }

    //using a stored payment method (SPM)
    public static AuthoriseRequest authoriseFromTransactionParamsSPM(Map<String, Object> inputData, Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
//        request.amount = new Amount();
//        request.paymentMethod = new PaymentMethod();
//        request.applicationInfo = new ApplicationInfo();
//        request.applicationInfo.adyenPaymentSource = new PaymentSource();
//        request.applicationInfo.externalPlatform = new ExternalPlatform();
//
//        request.applicationInfo.adyenPaymentSource.version = '1.0.0';
//        request.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
//        request.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
//        request.applicationInfo.externalPlatform.integrator = '';
//        request.applicationInfo.externalPlatform.version = '';
//
//        ccrz__E_Cart__c cart = (ccrz__E_Cart__c)inputData.get('cart');
//        ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams)inputData.get('processedPaymentData');
//
//        request.amount.currency_x = cart.ccrz__CurrencyISOCode__c;
//        request.amount.value = (Long)cart.ccrz__TotalAmount__c * 100;
//
//        request.paymentMethod.recurringDetailReference = paymentParams.token;
//        request.shopperInteraction = 'ContAuth';
//
//        request.reference = cart.Id;
//        request.merchantAccount = merchant.Name__c;
//        request.shopperReference = cart.ccrz__Account__c;
        
        return request;
    }

    public static Integer getMultiplierMinorUnits(String currencyCode){
        switch on currencyCode {
          when 'CVE','DJF', 'GNF','IDR','JPY','KMF','KRW', 'PYG','RWF','UGX','VND', 'VUV', 'XAF', 'XOF', 'XPF' {
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

//    public static CaptureRequest captureFromTransPayment(ccrz__E_TransactionPayment__c tp, Merchant__mdt merchant)
//    {
//        CaptureRequest cr = new CaptureRequest();
//        cr.modificationAmount = new Amount();
//        cr.originalReference = tp.ccrz__TransactionCode__c;
//        //
//        // Amount
//        cr.modificationAmount.currency_x = tp.ccrz__CurrencyISOCode__c;
//        cr.modificationAmount.value = (Long)tp.ccrz__Amount__c * 100;
//        //
//        // root props
//        cr.merchantAccount = merchant.Name__c;
//        cr.reference = tp.Id;
//
//        return cr;
//    }
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