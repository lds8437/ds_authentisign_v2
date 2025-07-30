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
        authentisign__Setting__c[] settings = [SELECT Id, Name, authentisign__Endpoint__c, authentisign__Account_Id__c, authentisign__Bearer_Token__c, authentisign__Callback_Url__c FROM authentisign__Setting__c];
        if(settings.size() > 0)
        {
            accountId = settings[0].authentisign__Account_Id__c;
            endpointUrl = settings[0].authentisign__Endpoint__c;
            callbackUrl = settings[0].authentisign__Callback_Url__c;
            tokenBearer = settings[0].authentisign__Bearer_Token__c;
            settingId = settings[0].Id; 
        }
    }
    
    public void saveConfig() {
        // Perform logic to save configuration, e.g., store in custom settings, custom metadata, etc.
        // You can add validation logic before saving.
        
        authentisign__Setting__c setting = new authentisign__Setting__c();
        setting.authentisign__Account_Id__c = accountId;
        setting.authentisign__Endpoint__c = endpointUrl;
        setting.authentisign__Callback_Url__c = callbackUrl;
        setting.authentisign__Bearer_Token__c = tokenBearer;
        
        Database.UpsertResult result =  Database.Upsert(setting, authentisign__Setting__c.authentisign__Account_Id__c);
        
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