public with sharing class SObjectFieldPackage
{
    public string Query {get; set;}
    
    public List<string> SObjectFieldsList {get; set;}
    
    public Map<string,List<string>> ParticipientList {get; set;}
    
    public Map<string, Map<string, string>> SObjectFieldsProperties {get;set;}
    
    public Map<string,string> UserContactFieldMap {get; set;}
}