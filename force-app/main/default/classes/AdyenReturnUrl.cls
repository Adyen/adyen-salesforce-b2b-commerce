@RestResource(urlMapping='/AdyenReturnUrl/*')
global with sharing class AdyenReturnUrl {
    public PageReference pageReferenceMethod()
    {
        System.Debug('## ReturnURL');
        return new PageReference('/001');
    }
}