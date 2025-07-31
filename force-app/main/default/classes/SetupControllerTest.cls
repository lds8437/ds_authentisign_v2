@IsTest
private class SetupControllerTest {
    
    @IsTest
    private static void UnitTestGETCallBack() {
        
        Setting__c setting = new Setting__c();
        setting.Account_Id__c = '123';
        setting.Endpoint__c = 'test.test.com';
        setting.Callback_Url__c = 'test.test.com';
        setting.Bearer_Token__c = '12345';
        
        insert setting;
        
        SetupController controller = new SetupController();
        controller.accountId = '123';
        controller.endpointUrl = 'test.salesforce.com';
        controller.callbackUrl = 'test.salesforce.com';
        controller.tokenBearer = '12345';
        
        controller.saveConfig();
        
        Setting__c settingRecord =  [SELECT Id, Name, Endpoint__c, Account_Id__c, Bearer_Token__c, Callback_Url__c FROM Setting__c limit 1];
        
        
        System.assert(settingRecord.Endpoint__c == 'test.salesforce.com');
    }
}