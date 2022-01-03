global with sharing class AdyenAsyncAdapter implements commercepayments.PaymentGatewayAsyncAdapter, commercepayments.PaymentGatewayAdapter {
    global AdyenAsyncAdapter() {}
    
    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        return null;
    }
    
    global commercepayments.GatewayNotificationResponse processNotification(commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext) {
        String apexName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        return AdyenPaymentHelper.handleAsyncNotificationCallback(gatewayNotificationContext, apexName); 
        /*commercepayments.GatewayNotificationResponse gatewayNotificationResponse = new commercepayments.GatewayNotificationResponse();
        String msg = '';
        msg += '[accepted] But not processed - wrong payment adapter or wrong instance';
        gatewayNotificationResponse.setResponseBody(Blob.valueOf( msg ));
        gatewayNotificationResponse.setStatusCode(200);
        System.debug('I was executed');
        return gatewayNotificationResponse; */
    }
}