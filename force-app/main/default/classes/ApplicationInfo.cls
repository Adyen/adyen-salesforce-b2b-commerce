//
// Represents and Adyen ApplicationInfo
/*
“applicationInfo”:{
    “adyenPaymentSource”:{
       “name”:“YOUR_PLUGIN”,
       “version”:“YOUR_PLUGIN_VERSION”
    },
    “externalPlatform”:{
       “name”:“PLATFORM_NAME”,
       “version”:“PLATFORM_VERSION”,
       “integrator”:“YOUR_SYSTEM_INTEGRATOR_NAME”
    }
*/

public class ApplicationInfo {
    public PaymentSource adyenPaymentSource = new PaymentSource();
    public PaymentSource merchantApplication = new MerchantApplication();
    public ExternalPlatform externalPlatform = new ExternalPlatform();

}