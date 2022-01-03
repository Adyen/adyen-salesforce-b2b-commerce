@isTest
public class AdyenAsyncAdapterTest {

    public class MyException extends Exception{}
    
    class EchoHttpMock implements HttpCalloutMock {
            HttpResponse res;
            EchoHttpMock(HttpResponse r) {
                res = r;
            }
            // This is the HttpCalloutMock interface method
            public HttpResponse respond(HttpRequest req) {
                    System.debug('--->Entering EchoHttpMock.respond');
                    if(req.getBody().contains('420')){
                            System.debug('--->Exiting EchoHttpMock.respond, throwing exception');
                            throw new MyException('network exception');
                    } else{
                            System.debug('--->Exiting EchoHttpMock.respond, returning response=' + res);
                            return res;
                    }
            }
    }
           
   /**
    *
    */
    @IsTest
    static void testUnsupported_Inbound_Notification() {

        //Build an object that will be coming back from adyen and serialize it as mock response json.
        AdyenService.AdyenNotification mockNotification = new AdyenService.AdyenNotification();
        mockNotification.live = 'false';
        mockNotification.notificationItems = new List<AdyenService.NotificationItems>();
        AdyenService.NotificationRequestItem notificationRequestItem = new AdyenService.NotificationRequestItem();
        AdyenService.Amount amount = new AdyenService.Amount();
        amount.value = 100;
        amount.currency_x = 'USD';
        notificationRequestItem.amount = amount;
        notificationRequestItem.eventCode = 'NOTCAP_NOTREF_IE_UNSUPPORTED';
        notificationRequestItem.pspReference = 'pspref';
        notificationRequestItem.success = 'true';
        notificationRequestItem.merchantAccountCode = 'merchant_account_code';

        AdyenService.NotificationItems notificationItems = new AdyenService.NotificationItems();
        notificationItems.NotificationRequestItem = notificationRequestItem;
        mockNotification.notificationItems.add(notificationItems);

        String mockPostResponse = JSON.serialize(mockNotification);


        HttpResponse res = new HttpResponse();
        res.setBody(mockPostResponse);
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));

        Test.startTest();

        Double amt = 500;
        String authId = 'testauthId123';
        Map<String,String> mHeaders = new Map<String,String>{'Content-Type' => 'application/json'};

        CommercePayments.PaymentGatewayNotificationRequest paymentGatewayNotificationRequest = new CommercePayments.PaymentGatewayNotificationRequest(mHeaders,mockPostResponse);
        CommercePayments.PaymentGatewayNotificationContext paymentGatewayNotificationContext = new CommercePayments.PaymentGatewayNotificationContext(paymentGatewayNotificationRequest);


        AdyenAsyncAdapter adyenAdapter = new AdyenAsyncAdapter();
        CommercePayments.GatewayNotificationResponse gatewayNotificationResponse = adyenAdapter.processNotification(paymentGatewayNotificationContext);

        Test.stopTest();

        // CommercePayments.GatewayNotificationResponse does not expose any getter methods
        System.Assert(gatewayNotificationResponse.toString().contains('GatewayNotificationResponse'));
    }
    
}