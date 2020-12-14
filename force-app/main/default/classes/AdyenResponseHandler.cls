public with sharing class AdyenResponseHandler {
    public static Map<String, Object> handleResponse(PaymentResponse paymentResponse) {
        PaymentResponse.ResultCodeEnum resultCode = paymentResponse.resultCode;
        switch on resultCode {
            when AUTHORISED, REFUSED, ERROR, CANCELLED {
                return new Map<String, Object>{
                        'isFinal' => true,
                        'resultCode' => resultCode
                };
            }
            when REDIRECTSHOPPER, IDENTIFYSHOPPER, CHALLENGESHOPPER, PRESENTTOSHOPPER, PENDING {
                return new Map<String, Object>{
                        'isFinal' => false,
                        'resultCode' => resultCode,
                        'action' => paymentResponse.action
                };
            }
            when RECEIVED {
                return new Map<String, Object>{
                        'isFinal' => false,
                        'resultCode' => resultCode,
                        'additionalData' => paymentResponse.additionalData
                };
            }
            when else {
                return new Map<String, Object>{
                        'isFinal' => true,
                        'resultCode' => resultCode
                };
            }
        }
    }
}