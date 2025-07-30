@IsTest
private class SetupControllerTest {
    
    @IsTest
    private static void UnitTestGETCallBack() {
        
        authentisign__Setting__c setting = new authentisign__Setting__c();
        setting.authentisign__Account_Id__c = '123';
        setting.authentisign__Endpoint__c = 'test.test.com';
        setting.authentisign__Callback_Url__c = 'test.test.com';
        setting.authentisign__Bearer_Token__c = '12345';
        
        insert setting;
        
        SetupController controller = new SetupController();
        controller.accountId = '123';
        controller.endpointUrl = 'test.salesforce.com';
        controller.callbackUrl = 'test.salesforce.com';
        controller.tokenBearer = '12345';
        
        controller.saveConfig();
        
        authentisign__Setting__c settingRecord =  [SELECT Id, Name, authentisign__Endpoint__c, authentisign__Account_Id__c, authentisign__Bearer_Token__c, authentisign__Callback_Url__c FROM authentisign__Setting__c limit 1];
        
        
        System.assert(settingRecord.authentisign__Endpoint__c == 'test.salesforce.com');
    }
}