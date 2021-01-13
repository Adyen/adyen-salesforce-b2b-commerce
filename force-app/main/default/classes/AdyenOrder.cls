public with sharing class AdyenOrder {
    public static Map<String, Object> createOrder(Map<String, Object> processResult, ccrz__E_Cart__c cart) {
            Map<String, Object> createOrderParams = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => 9,
                    ccrz.ccApiCart.TRANSPAYMENTDATA =>
                            processResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA),
                    ccrz.ccApiCart.PAYMENTRESULT => processResult,
                    ccrz.ccApiCart.CART_ENCID => cart.Id,
                    ccrz.ccApiOrder.PARAM_ORDER_STATUS => 'Open'
            };
            if (Test.isRunningTest()) {
                createOrderParams.put(ccrz.ccApiCart.SKIP_VALID_CHECK, true);
            }

            //Converts a cart to a corresponding order.
            Map<String, Object> placeResult = ccrz.ccApiCart.place(createOrderParams);
            System.Debug('#### order created ' + placeResult);
            return placeResult;
    }


}