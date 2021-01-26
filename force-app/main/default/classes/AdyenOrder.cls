global with sharing class AdyenOrder {
    public static Map<String, Object> placeOrder(Map<String, Object> processResult, String cartId) {
            Map<String, Object> createOrderParams = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => 9,
                    ccrz.ccApiCart.TRANSPAYMENTDATA =>
                            processResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA),
                    ccrz.ccApiCart.PAYMENTRESULT => processResult,
                    ccrz.ccApiCart.CART_ENCID => cartId
            };
            if (Test.isRunningTest()) {
                createOrderParams.put(ccrz.ccApiCart.SKIP_VALID_CHECK, true);
            }

            //Converts a cart to a corresponding order.
            Map<String, Object> placeResult = ccrz.ccApiCart.place(createOrderParams);
            return placeResult;
    }

     public static Map<String, String> validateOrderResult(Map<String, Object> placeResult) {
        String orderId = (String) placeResult.get('orderId');
        ccrz__E_Order__c[] placedOrder = getOrderById(orderId);
        Map<String, String> orderResult = new Map<String, String>();
        if (placedOrder <> null && placedOrder.size() == 1) {
            orderResult.put('orderId', orderId);
            orderResult.put('orderIdEnc', placedOrder[0].ccrz__EncryptedId__c);
            orderResult.put('cartId', placedOrder[0].ccrz__OriginatedCart__c);
        }

        return orderResult;
    }

     public static String updateOrderStatus(String cartId){
     System.debug('### cartId = ' + cartId);
        ccrz__E_Order__c[] authOrder = AdyenOrder.getOrderByCartId(cartId);
        System.debug('### UserInfo getProfileId = ' + UserInfo.getProfileId());
        System.debug('### UserInfo getUserName = ' + UserInfo.getUserName());
        System.debug('### UserInfo getUserRoleId()= ' + UserInfo.getUserRoleId());
        System.debug('### authOrder = ' + authOrder);
        if(authOrder <> null && authOrder.size() == 1) {
            //TODOBAS update Order Status authOrder[0]
            return authOrder[0].ccrz__EncryptedId__c;
        }

        return 'OrderInvalid';
    }

    public static ccrz__E_Order__c[] getOrderById(String orderId){
        return  [
                SELECT Id, ccrz__EncryptedId__c, ccrz__OriginatedCart__c
                FROM ccrz__E_Order__c
                WHERE Id = :orderId
                LIMIT 1
        ];
    }

    public static ccrz__E_Order__c[] getOrderByCartId(String cartId){
        return  [
                SELECT Id, ccrz__EncryptedId__c, ccrz__OriginatedCart__c
                FROM ccrz__E_Order__c
                WHERE ccrz__OriginatedCart__c = :cartId
                LIMIT 1
        ];
    }

}