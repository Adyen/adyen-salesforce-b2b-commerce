public with sharing class AdyenReturn {
    public PageReference handleRedirectResponse() {
        String redirectResult = ApexPages.currentPage().getParameters().get('redirectResult');
        String payload = ApexPages.currentPage().getParameters().get('payload');
        String merchantReference = ApexPages.currentPage().getParameters().get('merchantReference');
        //Get details from the querystring
        Map<String, String> details = getDetails(redirectResult, payload);
        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestAfterRedirect(details, merchantReference);
        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsDetailsResponse);
        Map<String, String> additionalData = (Map<String, String>)paymentResult.get('additionalData');
        String responseMerchantReference = !String.isBlank((String)additionalData.get('merchantReference')) ? (String)additionalData.get('merchantReference') : (String)paymentResult.get('merchantReference');
        Boolean isMyWallet = responseMerchantReference.contains('addStoredMethod');
        PageReference pageReference = isMyWallet ? new PageReference(Site.getBaseSecureUrl() + '/ccrz__StoredPaymentDetail?pt=adyencc&mode=new&AuthorisationFailed=true&cartId=') : new PageReference(Site.getBaseSecureUrl() + '/ccrz__CheckoutNew?AuthorisationFailed=true?cartID=' + merchantReference);
        if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
            if(merchantReference == responseMerchantReference || isMyWallet){
                pageReference = new PageReference(Site.getBaseSecureUrl() + '/ccrz__MyAccount?viewState=myWallet');
                if(!isMyWallet){
                    //create order
                    Map<String, Object> orderResult = AdyenController.placeOrder(paymentResult, merchantReference);
                    Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                    String orderId = orderIds.get('orderIdEnc');
                    pageReference = new PageReference(Site.getBaseSecureUrl() + '/ccrz__OrderConfirmation?o=' + orderId);
                }
                AdyenController.checkToStorePaymentMethod(additionalData, ccrz.cc_CallContext.storefront);
            }
            else {
                System.debug('Invalid merchantReference: ' + merchantReference);
            }
        }

        pageReference.setRedirect(true);
        return pageReference;
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
}
