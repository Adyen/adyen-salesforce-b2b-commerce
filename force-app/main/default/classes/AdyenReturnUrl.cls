@RestResource(urlMapping='/AdyenReturnUrl/*')
global with sharing class AdyenReturnUrl {

    @HttpGet
    global static void pageReferenceMethod()
    {
        System.Debug('## ReturnURL');
//        return new PageReference('/001');
//        return 'Test';
        PageReference pr = new PageReference('https://www.google.com');
        pr.setRedirect(true);
        System.Debug('## ReturnURL = ' + pr);
    }

    public PageReference renderPage(){
        PageReference pr = new PageReference('/apex/yourVFPageName');
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