public class AdyenPaymentUtility {

    public static final Set<String> threeDecimalCurrencies = new Set<String> {'BHD','IQD','JOD','KWD','LWD','OMR','TND'};
    public static final Set<String> zeroDecimalCurrencies = new Set<String>{
       'CVE', 'DJF', 'GNF', 'IDR', 'JPY', 'KMF', 'KRW',
       'PYG', 'RWF', 'UGX', 'VND', 'VUV', 'XAF', 'XOF', 'XPF'
    };    

  /**
   * Retrieve apex adapter id from the gateway reference number.
   *
   * @param gatewayRefNumber original payment gatewayrefnumber as recieved in the notification
   * @return apexclass id for the payment gateway adapter.
   */
  public static String retrieveApexAdapterId(String gatewayRefNumber) {
    String apexAdapterId = null;

    // Prioritize the payment authorization record if it exists
    for (PaymentAuthorization paymentAuthorization: [
        SELECT
        PaymentGateway.PaymentGatewayProvider.ApexAdapter.Id
        FROM
        PaymentAuthorization
        WHERE
        GatewayRefNumber =: gatewayRefNumber
      ]) {
      if (null != paymentAuthorization.PaymentGateway && null != paymentAuthorization.PaymentGateway.PaymentGatewayProvider && null != paymentAuthorization.PaymentGateway.PaymentGatewayProvider.ApexAdapter) {
        apexAdapterId = paymentAuthorization.PaymentGateway.PaymentGatewayProvider.ApexAdapter.Id;
      }
    }

    // Fall back to a payment record for pre-captured transactions
    if (null == apexAdapterId) {
      for (Payment payment: [
          SELECT
          PaymentGateway.PaymentGatewayProvider.ApexAdapter.Id
          FROM
          Payment
          WHERE
          GatewayRefNumber =: gatewayRefNumber
        ]) {
        if (null != payment.PaymentGateway && null != payment.PaymentGateway.PaymentGatewayProvider && null != payment.PaymentGateway.PaymentGatewayProvider.ApexAdapter) {
          apexAdapterId = payment.PaymentGateway.PaymentGatewayProvider.ApexAdapter.Id;
        }
      }
    }

    return apexAdapterId;
  }

  /**
   * Retrieve apex id from the class name and namespaceprefix.
   *
   * @param className The Class Name
   * @param namespace Namespace of the current class
   * @return apexclass id.
   */
  public static String retrieveApexClassId(String className, String namespace) {
    ApexClass apexClass = null;
    String apexAdapterId = null;
    String soql = 'SELECT Id FROM ApexClass WHERE Name = :className AND NamespacePrefix = :namespace';
    List < ApexClass > apexClasses = Database.query(soql);
    if (!apexClasses.isEmpty()) {
      apexClass = apexClasses[0];
      if (null != apexClass) {
        apexAdapterId = apexClass.Id;
      }
    }
    return apexAdapterId;
  }

  public static Integer getAmountMultiplier(String currencyCode) {
    if (threeDecimalCurrencies.contains(currencyCode))
      return 1000;
    else if (zeroDecimalCurrencies.contains(currencyCode))
      return 1;
    else
      return 100;
  }

}