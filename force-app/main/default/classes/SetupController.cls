public with sharing class SetupController {
    public String editId { get; set; }
    public String jobId  { get; set; }
    public Boolean needsRefresh {
        get {
            if(jobId <> null) {
                return true;
            } else {
                return false;
            }
        }
    }

    public SetupController() {
    }
    public List<Merchant__mdt> settings {
        get {
            if(settings==null) {
                settings = [SELECT Id, Merchant_Account__c, API_Key__c, Authorise_Endpoint__c, Capture_Endpoint__c, Disable_Endpoint__c, Payment_Endpoint__c, DeveloperName, MasterLabel, QualifiedApiName  FROM Merchant__mdt WHERE DeveloperName<>'ApexTest'];
            }
            return settings;
        }
        set;
    }
    public Merchant__mdt editingRow {
        get; set;
    }
    public PageReference editRow() {
        try {
            this.editingRow = [SELECT Id,Merchant_Account__c,  API_Key__c, Authorise_Endpoint__c, Capture_Endpoint__c, Disable_Endpoint__c, Payment_Endpoint__c, DeveloperName, MasterLabel, QualifiedApiName FROM Merchant__mdt WHERE DeveloperName=:this.editId LIMIT 1];

            return Page.EditSetupRecord;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference jobReady() {
        try {
            //
            // Temporary solution, needs fetching info about the status
            // For now just stick to 1 page refresh
            this.jobId = null;
            this.settings = null;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference newRow() {
        try {

            Merchant__mdt confReference = [SELECT Id, Merchant_Account__c, API_Key__c, Authorise_Endpoint__c, Capture_Endpoint__c, Disable_Endpoint__c, Payment_Endpoint__c, DeveloperName, MasterLabel, QualifiedApiName  FROM Merchant__mdt WHERE DeveloperName = 'ApexTest' LIMIT 1];

            Merchant__mdt newConf = (Merchant__mdt) Merchant__mdt.sObjectType.newSObject();
            newConf.API_Key__c = '';
            newConf.Authorise_Endpoint__c = confReference.Authorise_Endpoint__c;
            newConf.Capture_Endpoint__c = confReference.Capture_Endpoint__c;
            newConf.Merchant_Account__c = '';
            newConf.QualifiedApiName = '';
            newConf.MasterLabel = '';
            newConf.Disable_Endpoint__c = confReference.Disable_Endpoint__c;
            newConf.Payment_Endpoint__c = confReference.Payment_Endpoint__c;
            //
            // Brings user to the edit component
            this.editingRow = newConf;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        //return null;
        return Page.EditSetupRecord;
    }
    public PageReference cancel() {
        try{
            //
            // Brings user back to the list
            this.editingRow = null;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return Page.Setup;
    }
    public PageReference saveRow() {
        try {
            String adyenNamespace = Util.getNamespacePrefix('cc_adyencc_ccPaymentProcessor');
            String recordDevName = 'New_Adyen_Merchant';
            if(String.isNotEmpty(this.editingRow.MasterLabel)) {
                recordDevName = this.editingRow.MasterLabel.trim().replaceAll('\\s+', '_');
                this.editingRow.QualifiedApiName = recordDevName;
            }

            this.editingRow.MasterLabel = this.editingRow.Merchant_Account__c;

            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = adyenNamespace+'__Merchant__mdt.'+ recordDevName;
            customMetadata.label = this.editingRow.MasterLabel;

            // Add all the field values
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__API_Key__c';
            customField.value = this.editingRow.API_Key__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__Merchant_Account__c';
            customField.value = this.editingRow.Merchant_Account__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__Authorise_Endpoint__c';
            customField.value = this.editingRow.Authorise_Endpoint__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__Capture_Endpoint__c';
            customField.value = this.editingRow.Capture_Endpoint__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__Disable_Endpoint__c';
            customField.value = this.editingRow.Disable_Endpoint__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = adyenNamespace+'__Payment_Endpoint__c';
            customField.value = this.editingRow.Payment_Endpoint__c;
            customMetadata.values.add(customField);

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);

            // Setup deploy callback, MyDeployCallback implements
            // the Metadata.DeployCallback interface
            CustomMetadataCallback callback = new CustomMetadataCallback();

            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            if(!Test.isRunningTest()) {
                this.jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.Merchant_Queued_Message));

                //
                // Brings user back to the list
                this.editingRow = null;
            } else {
                this.jobId = 'APEX';
            }
            //
            // Init rows
            this.settings = null;

        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }

        return Page.Setup;

    }

    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                Metadata.DeployCallbackContext context) {

        }
    }
}