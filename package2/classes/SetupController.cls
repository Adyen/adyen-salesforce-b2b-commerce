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
                settings = [SELECT Id, Name__c, API_Key__c, Authorise_Endpoint__c, Capture_Endpoint__c, Reference__c, DeveloperName, MasterLabel, QualifiedApiName  FROM Merchant__mdt WHERE QualifiedApiName<>'ApexTest'];
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
            this.editingRow = [SELECT Id,Name__c,  API_Key__c, Authorise_Endpoint__c, Capture_Endpoint__c, Reference__c, DeveloperName, MasterLabel, QualifiedApiName FROM Merchant__mdt WHERE QualifiedApiName=:this.editId LIMIT 1];

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
            Merchant__mdt newConf = (Merchant__mdt) Merchant__mdt.sObjectType.newSObject();
            newConf.API_Key__c = '';
            newConf.Authorise_Endpoint__c = '';
            newConf.Capture_Endpoint__c = '';
            newConf.Reference__c = '';
            newConf.QualifiedApiName = '';
            newConf.MasterLabel = '';
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
            String recordDevName = 'New_Adyen_Merchant';
            if(String.isNotEmpty(this.editingRow.MasterLabel)) {
                recordDevName = this.editingRow.MasterLabel.trim().replaceAll('\\s+', '_');
                System.debug('### recordDevName '+recordDevName);
                this.editingRow.QualifiedApiName = recordDevName;
            }
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Merchant__mdt.'+ recordDevName;
            customMetadata.label = this.editingRow.MasterLabel;

            // Add all the field values
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'API_Key__c';
            customField.value = this.editingRow.API_Key__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Name__c';
            customField.value = this.editingRow.Name__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Authorise_Endpoint__c';
            customField.value = this.editingRow.Authorise_Endpoint__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Capture_Endpoint__c';
            customField.value = this.editingRow.Capture_Endpoint__c;
            customMetadata.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Reference__c';
            customField.value = this.editingRow.Reference__c;
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
            System.debug('## Deployment result '+result);
            System.debug('## Deployment context '+context);

        }
    }
}