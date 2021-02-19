public with sharing class AdyenReturn {
    public PageReference handleRedirectResponse() {
        String redirectResult = ApexPages.currentPage().getParameters().get('redirectResult');
        String payload = ApexPages.currentPage().getParameters().get('payload');
        String merchantReference = ApexPages.currentPage().getParameters().get('merchantReference');
        System.debug('### handleRedirectResponse');
        //Get details from the querystring
        Map<String, String> details = getDetails(redirectResult, payload);
//        String cartEncryptedId = AdyenUtil.getCartEncryptedId(merchantReference);
        PaymentsResponse paymentsDetailsResponse = AdyenPaymentsDetails.requestAfterRedirect(details, merchantReference);
        System.debug('### paymentsDetailsResponse = ' + paymentsDetailsResponse);
        Map<String, Object> paymentResult = AdyenResponseHandler.handleResponse(paymentsDetailsResponse);


        if((String)paymentResult.get('merchantReference') == merchantReference){
            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED){
                //Place order
                Map<String, Object> orderResult = AdyenController.placeOrder(paymentResult, merchantReference);
                Map<String, String> orderIds = AdyenController.validateOrderResult(orderResult);
                String orderId = orderIds.get('orderIdEnc');
                //TODOBAS retrieve community URL
                PageReference pageRef = new PageReference(Site.getBaseSecureUrl() + '/ccrz__OrderConfirmation?o=' + orderId);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }

        //TODOBAS add Payment Failed error message
        PageReference pageReference = new PageReference(Site.getBaseSecureUrl() + '/ccrz__CheckoutNew?cartID=' + merchantReference);
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
