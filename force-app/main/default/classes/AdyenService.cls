//
// Contains the callouts to the Adyen API
@RestResource(urlMapping='/adyenGetPaymentMethods/*')
global with sharing class AdyenService {

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
//        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
//        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];

        return 'resultAdyenPaymentMethods';
    }
}