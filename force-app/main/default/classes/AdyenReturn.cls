public with sharing class AdyenReturn {
    public PageReference handleRedirectResponse() {
        String redirectResult = ApexPages.currentPage().getParameters().get('redirectResult');
        String payload = ApexPages.currentPage().getParameters().get('payload');
        String merchantReference = ApexPages.currentPage().getParameters().get('merchantReference');
        System.debug('### Adyen Return HandleRedirectResponse');
        System.debug('### Adyen details = ' + redirectResult);
        System.debug('### Adyen merchantReference = ' + merchantReference);
        System.debug('### Adyen payload = ' + payload);

        System.debug('### Adyen getCurrentSiteUrl = ' + Site.getBaseUrl());

        //Get details from the querystring
        Map<String, String> details = getDetails(redirectResult, payload);

        String cartEncryptedId = AdyenUtil.getCartEncryptedId(merchantReference);
        Map<String, Object> paymentResult = callPaymentDetails(details, cartEncryptedId);
        System.debug('### Adyen paymentResult = ' + paymentResult);
        //TODOBAS check paymentResult, compare references
        if((String)paymentResult.get('merchantReference') == merchantReference){
            System.debug('### Adyen merchantReferences match');
            if (String.valueOf(paymentResult.get('resultCode')) == 'AUTHORISED'){
            System.debug('### Adyen AUTHORISED');
                //Place order
                Map<String, Object> orderResult = AdyenOrder.placeOrder(paymentResult, merchantReference);
                Map<String, String> orderIds = AdyenOrder.validateOrderResult(orderResult);
                String orderId = orderIds.get('orderIdEnc');
//                return new PageReference('http://www.google.nl/' + orderId);
                return new PageReference('https://b2b-scoping-0920-developer-edition.na139.force.com/ccrz__OrderConfirmation?o=' + orderId);
            }
            return new PageReference('https://b2b-scoping-0920-developer-edition.na139.force.com/ccrz__CheckoutNew?cartID=' + cartEncryptedId);
        }

        return new PageReference('http://www.google.com');
    }

    private Map<String, String> getDetails(String redirectResult, String payload){
        if(!String.isBlank(redirectResult)){
            return new Map<String, String> {
                    'redirectResult' => redirectResult
            };
        } else {
            return new Map<String, String> {
                    'payload' => payload
            };
        }
    }

    private Map<String, Object> callPaymentDetails(Map<String, String> details, String cartEncryptedId){
        ccrz__E_Cart__c cart = AdyenUtil.getCartByEncryptedId(cartEncryptedId);
        System.debug('### Adyen cart = ' + cart);
        PaymentsDetailsRequest paymentsDetailsRequest = new PaymentsDetailsRequest();
        paymentsDetailsRequest.details = details;
        //Get saved payment data from cart
        paymentsDetailsRequest.paymentData = cart.AdyenPaymentData__c;
        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetailsRequest.callPaymentsDetails(paymentsDetailsRequest);
        return AdyenResponseHandler.handleResponse(paymentsDetailsResponse);
    }
}
