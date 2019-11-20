global class AdyenInterface {
    global static AuthoriseResponse authorisePayment(String merchantRecord, AuthoriseRequest request) {
        Merchant__mdt merchant = Util.getConfigByName(merchantRecord);
        return AdyenClient.authorisePayment(merchant, request);
    }
    global static CaptureResponse capturePayment(String merchantRecord, CaptureRequest request) {
        Merchant__mdt merchant = Util.getConfigByName(merchantRecord);
        return AdyenClient.capturePayment(merchant, request);
    }
}