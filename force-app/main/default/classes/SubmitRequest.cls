public with sharing class SubmitRequest {

    public string name {get;set;}
    public boolean isOrdered {get;set;}
    public string expirationDate {get;set;}
    public string callbackUrl {get;set;}
    public string layoutId {get;set;}
    public Map<string,string> fields {get;set;}
    public List<Map<string,object>> participants {get;set;}
}