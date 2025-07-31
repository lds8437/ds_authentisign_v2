public with sharing class SetupController {
    public String accountId { get; set; }
    public String endpointUrl { get; set; }
    public String callbackUrl { get; set; }
    public String tokenBearer { get; set; }
    public String settingId {get;set;}
    public SetupController()
    {
        getSetupData();
    }
    
    public void getSetupData()
    {
        Setting__c[] settings = [SELECT Id, Name, Endpoint__c, Account_Id__c, Bearer_Token__c, Callback_Url__c FROM Setting__c];
        if(settings.size() > 0)
        {
            accountId = settings[0].Account_Id__c;
            endpointUrl = settings[0].Endpoint__c;
            callbackUrl = settings[0].Callback_Url__c;
            tokenBearer = settings[0].Bearer_Token__c;
            settingId = settings[0].Id; 
        }
    }
    
    public void saveConfig() {
        // Perform logic to save configuration, e.g., store in custom settings, custom metadata, etc.
        // You can add validation logic before saving.
        
        Setting__c setting = new Setting__c();
        setting.Account_Id__c = accountId;
        setting.Endpoint__c = endpointUrl;
        setting.Callback_Url__c = callbackUrl;
        setting.Bearer_Token__c = tokenBearer;
        
        Database.UpsertResult result =  Database.Upsert(setting, Setting__c.Account_Id__c);
        
        if(result.isSuccess())
        {
            // Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Configuration saved successfully.'));
        }
        else{
            // Display error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to save settings.'));
        }
    }
}