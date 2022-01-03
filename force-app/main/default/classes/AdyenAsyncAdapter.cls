global with sharing class AdyenAsyncAdapter implements commercepayments.PaymentGatewayAsyncAdapter, commercepayments.PaymentGatewayAdapter {
    global AdyenAsyncAdapter() {}
    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        return null;
    }
    
    global commercepayments.GatewayNotificationResponse processNotification(commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext) {
        String apexName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        return AdyenPaymentHelper.handleAsyncNotificationCallback(gatewayNotificationContext, apexName); 
    }
}