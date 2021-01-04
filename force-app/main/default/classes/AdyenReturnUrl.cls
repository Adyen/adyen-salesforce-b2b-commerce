@RestResource(urlMapping='/AdyenReturnUrl/*')
global with sharing class AdyenReturnUrl {

    @HttpGet
    global static void returnUrl()
    {
//        System.Debug('## ReturnURL');
////        return new PageReference('/001');
////        return 'Test';
//        PageReference pr = new PageReference('https://www.google.com');
//        pr.setRedirect(true);
        System.Debug('## ReturnURL');
        PageReference pr = new PageReference('/apex/AdyenReturnUrl');
        System.Debug('## ReturnURL = ' + pr);
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.
        RestContext.response.responseBody = pr.getContent();
        RestContext.response.headers.put('Content-Type', 'text/html');
        RestContext.response.headers.put('Content-Length', RestContext.response.responseBody.size() + '');
    }

    public PageReference renderPage(){
        PageReference pr = new PageReference('/apex/AdyenReturnUrl');
//        pr.getParameters().put('key','value');
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.
        return pr;
    }

    public static PageReference redirect(string url)
    {
        System.debug('inside redirect');
        PageReference newFloodOnlyUrl = new PageReference(url);
        newFloodOnlyUrl.setRedirect(true);
        System.debug('newFloodOnlyUrl : ' + newFloodOnlyUrl );
        return newFloodOnlyUrl ;

    }
}