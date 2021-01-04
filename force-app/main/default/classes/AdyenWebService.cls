global class AdyenWebService {
    webservice static String adyenPaymentsDetails(String stateData){
        System.debug('### paymentsDetailsRequest stateData = ' + stateData);
        PaymentsDetailsRequest paymentsDetailsRequest = AdyenPaymentsDetailsRequest.createPaymentsDetailsRequest(stateData);
        System.debug('### paymentsDetailsRequest = ' + paymentsDetailsRequest);
        PaymentsResponse paymentsResponse = AdyenPaymentsDetailsRequest.callPaymentsDetails(paymentsDetailsRequest);
        System.debug('### paymentsResponse = ' + paymentsResponse);
        return JSON.serialize(paymentsResponse, true);
    }
}