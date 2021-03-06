public with sharing class AdyenUtil {
    public static AuthoriseRequest authoriseFromTransactionParams(Map<String, Object> inputData, Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
        request.amount = new Amount();
        request.paymentMethod = new PaymentMethod();
        request.applicationInfo = new ApplicationInfo();
        request.applicationInfo.adyenPaymentSource = new PaymentSource();
        request.applicationInfo.externalPlatform = new ExternalPlatform();
        
        request.applicationInfo.adyenPaymentSource.version = '1.0.0';
        request.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
        request.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
        request.applicationInfo.externalPlatform.integrator = '';
        request.applicationInfo.externalPlatform.version = '';
        
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c)inputData.get('cart');
        ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams)inputData.get('processedPaymentData');
        
        request.amount.currency_x = cart.ccrz__CurrencyISOCode__c;
        request.amount.value = (Long)cart.ccrz__TotalAmount__c * 100;
        
        request.paymentMethod.number_x = paymentParams.accountNumber;
        request.paymentMethod.expiryMonth = String.valueOf(paymentParams.expirationMonth);
        request.paymentMethod.expiryYear = String.valueOf(paymentParams.expirationYear);
        request.paymentMethod.cvc = paymentParams.verificationCode;
        request.paymentMethod.type = 'scheme';
        
        request.reference = cart.Id;
        request.merchantAccount = merchant.Name__c;
        request.storePaymentMethod = paymentParams.saveAsStoredPayment;
        request.shopperReference = cart.ccrz__Account__c;
        
        return request;
    }
    
    public static AuthoriseRequest authoriseFromNewPage(Map<String, Object> inputData, Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
        request.amount = new Amount();
        request.paymentMethod = new PaymentMethod();
        request.applicationInfo = new ApplicationInfo();
        request.applicationInfo.adyenPaymentSource = new PaymentSource();
        request.applicationInfo.externalPlatform = new ExternalPlatform();
        
        request.applicationInfo.adyenPaymentSource.version = '1.0.0';
        request.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
        request.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
        request.applicationInfo.externalPlatform.integrator = '';
        request.applicationInfo.externalPlatform.version = '';
        
        request.amount.currency_x = UserInfo.getDefaultCurrency();
        request.amount.value = 0;
        
        request.paymentMethod.number_x = String.valueOf(inputData.get('accountNumber'));
        request.paymentMethod.expiryMonth = String.valueOf(inputData.get('expirationMonth'));
        request.paymentMethod.expiryYear = String.valueOf(inputData.get('expirationYear'));
        request.paymentMethod.cvc = String.valueOf(inputData.get('verificationCode'));
        request.paymentMethod.type = 'scheme';
        
        request.reference = UserInfo.getUserId();
        request.merchantAccount = merchant.Name__c;
        request.storePaymentMethod = true;
        request.shopperReference = Selector.getUserAndAccount(UserInfo.getUserId()).AccountId;
        
        return request;
    }

    //using a stored payment method (SPM)
    public static AuthoriseRequest authoriseFromTransactionParamsSPM(Map<String, Object> inputData, Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
        request.amount = new Amount();
        request.paymentMethod = new PaymentMethod();
        request.applicationInfo = new ApplicationInfo();
        request.applicationInfo.adyenPaymentSource = new PaymentSource();
        request.applicationInfo.externalPlatform = new ExternalPlatform();
        
        request.applicationInfo.adyenPaymentSource.version = '1.0.0';
        request.applicationInfo.adyenPaymentSource.name = 'adyen-salesforce-b2b-commerce';
        request.applicationInfo.externalPlatform.name = 'SalesforceB2BCommerce';
        request.applicationInfo.externalPlatform.integrator = '';
        request.applicationInfo.externalPlatform.version = '';
        
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c)inputData.get('cart');
        ccrz.cc_hk_Payment.TransactionPaymentParams paymentParams = (ccrz.cc_hk_Payment.TransactionPaymentParams)inputData.get('processedPaymentData');
        
        request.amount.currency_x = cart.ccrz__CurrencyISOCode__c;
        request.amount.value = (Long)cart.ccrz__TotalAmount__c * 100;
        
        request.paymentMethod.recurringDetailReference = paymentParams.token;
        request.shopperInteraction = 'ContAuth';
        
        request.reference = cart.Id;
        request.merchantAccount = merchant.Name__c;
        request.shopperReference = cart.ccrz__Account__c;
        
        return request;
    }
    
    public static CaptureRequest captureFromTransPayment(ccrz__E_TransactionPayment__c tp, Merchant__mdt merchant)
    {
        CaptureRequest cr = new CaptureRequest();
        cr.modificationAmount = new Amount();
        cr.originalReference = tp.ccrz__TransactionCode__c;
        //
        // Amount
        cr.modificationAmount.currency_x = tp.ccrz__CurrencyISOCode__c;
        cr.modificationAmount.value = (Long)tp.ccrz__Amount__c * 100;
        //
        // root props
        cr.merchantAccount = merchant.Name__c;
        cr.reference = tp.Id;
        
        return cr;
    }

    public static DisableRequest disableStoredPayment(ccrz__E_StoredPayment__c storedPayment,  Merchant__mdt merchant)
    {
        DisableRequest dr = new DisableRequest();

        dr.merchantAccount = merchant.Name__c;
        dr.shopperReference = storedPayment.ccrz__Account__c;
        dr.recurringDetailReference = storedPayment.ccrz__Token__c;

        return dr;
    }
    
    public static AuthoriseRequest updateSoretPayment(ccrz__E_StoredPayment__c storedPayment,  Merchant__mdt merchant)
    {
        AuthoriseRequest request = new AuthoriseRequest();
        request.amount = new Amount();
        request.card = new PaymentMethod();
        request.recurring = new Recurring();
        
        request.amount.value = 0;
        request.amount.currency_x = UserInfo.getDefaultCurrency();
        
        request.card.expiryMonth = String.valueOf(storedPayment.ccrz__ExpMonth__c);
        request.card.expiryYear = String.valueOf(storedPayment.ccrz__ExpYear__c);
        
        request.reference = storedPayment.Id;
        request.shopperReference = storedPayment.ccrz__Account__c;
        request.shopperInteraction = 'ContAuth';
        request.selectedRecurringDetailReference = storedPayment.ccrz__Token__c;
        request.merchantAccount = merchant.Name__c;
        
        request.recurring.contract = 'RECURRING';
        
        return request;
    }
}