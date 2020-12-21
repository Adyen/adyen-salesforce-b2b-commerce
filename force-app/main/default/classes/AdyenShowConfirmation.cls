public class AdyenShowConfirmation {
    public AdyenShowConfirmation(){
        renderPage();
    }

    public static PageReference renderPage(){
        PageReference pr = new PageReference('/apex/AdyenResult');
        pr.getParameters().put('key','value');
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.
        return pr;
    }
}