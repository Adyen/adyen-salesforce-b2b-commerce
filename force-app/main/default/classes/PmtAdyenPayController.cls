global with sharing class PmtAdyenPayController {

    public Boolean isGuest {
        get {
            return UserInfo.getUserType() == 'Guest';
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPaymentMethods(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_Cart__c cart = AdyenUtil.getCartFromDatabase(ctx.currentCartId);
            Merchant__mdt merchant = AdyenUtil.getConfiguredMerchantAccount(cart);

            PaymentMethodsRequest paymentMethodsRequest = AdyenPaymentMethodsRequest.createPaymentMethodsRequest(cart, merchant);
            PaymentMethodsResponse paymentMethodsResponse = AdyenPaymentMethodsRequest.getPaymentMethods(merchant, paymentMethodsRequest);

            //Remove suffix and convert to string
            String jsonPaymentMethodsResponse = JSON.serialize(paymentMethodsResponse, true);
            String stringPaymentMethodsResponse = Util.makeAdyenCompatible(jsonPaymentMethodsResponse);

            res.data = stringPaymentMethodsResponse;
            res.success = true;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            System.Debug('## ERROR CATCH ' + e);
            res.success = false;
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult placeOrderAdyen(ccrz.cc_RemoteActionContext ctx, String stateData) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
            ccrz__E_Cart__c cart = AdyenUtil.getCartFromDatabase(ctx.currentCartId);

            Map<String, Object> inputParams = new Map<String, Object>();
            inputParams.put('accountType', 'adyencc');
            //Use token for stateData
            inputParams.put('token', stateData);

            Map<String, Object> paymentProcessorInput = new Map<String, Object>{
                    ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => JSON.serialize(inputParams), //stateData,
                    ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PAYMENT_CTX_CHECKOUT,
                    ccrz.cc_hk_Payment.PARAM_CART => cart,
                    ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => 'adyencc'
            };

            Map<String, Object> processResult = paymentHook.processPayment(paymentProcessorInput);
            Map<String, Object> paymentResult = (Map<String, Object>) processResult.get('paymentResult');

            //create order (status is Open)
            Map<String, Object> orderResult = AdyenOrder.createOrder(processResult, cart);
            System.Debug('#### order created ' + orderResult);

            if (!(Boolean)paymentResult.get('isFinal')) {
                //TODOBAS add orderId into paymentResult
                res.data = paymentResult;
                return res;
            }

            if (paymentResult.get('resultCode') == PaymentsResponse.ResultCodeEnum.AUTHORISED) {
                //TODOBAS update order status to Submitted
                //Return orderId for confirmation page
                Map<String, String> orderId = AdyenUtil.validateOrderResult(orderResult);
                System.Debug('#### order orderId ' + orderId);
                res.data = orderId;
                res.success = true;
                return res;
            }

            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message('Payment failed, result is ' + paymentResult);
            res.messages.add(m);

        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            //Exception handling here
            System.Debug('#### exception ' + e.getMessage() + e.getStackTraceString());
            res.success = false;
            ccrz.cc_bean_Message m = new ccrz.cc_bean_Message(e.getMessage());
            res.messages.add(m);
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

}