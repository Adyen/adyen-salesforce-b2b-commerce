public with sharing class AdyenResponseHandler {
    public static Map<String, Object> handleResponse(PaymentsResponse paymentsResponse) {
        PaymentsResponse.ResultCodeEnum resultCode = paymentsResponse.resultCode;
        switch on resultCode {
            when AUTHORISED, REFUSED, ERROR, CANCELLED {
                return new Map<String, Object>{
                        'isFinal' => true,
                        'resultCode' => resultCode,
                        'merchantReference' => paymentsResponse.merchantReference
                };
            }
            when REDIRECTSHOPPER, IDENTIFYSHOPPER, CHALLENGESHOPPER, PRESENTTOSHOPPER, PENDING {
                return new Map<String, Object>{
                        'isFinal' => false,
                        'resultCode' => resultCode,
                        'action' => paymentsResponse.action,
                        'paymentData' => paymentsResponse.paymentData
                };
            }
            when RECEIVED {
                return new Map<String, Object>{
                        'isFinal' => false,
                        'resultCode' => resultCode,
                        'additionalData' => paymentsResponse.additionalData
                };
            }
            when else {
                System.Debug('## Unknown resultCode: ' + resultCode);
                return new Map<String, Object>{
                        'isFinal' => true,
                        'resultCode' => resultCode
                };
            }
        }
    }

    public static Boolean isResponseSuccessful(PaymentsResponse.ResultCodeEnum resultCode){
        if(resultCode == PaymentsResponse.ResultCodeEnum.AUTHORISED){
            return true;
        }
        return false;
    }
}