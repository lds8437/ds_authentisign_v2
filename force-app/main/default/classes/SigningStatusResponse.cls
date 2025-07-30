public with sharing class SigningStatusResponse
{
    @AuraEnabled
    public integer code {get;set;} 
    
    @AuraEnabled
    public string message {get;set;}
    
    @AuraEnabled
    public List<string> details {get;set;}
}