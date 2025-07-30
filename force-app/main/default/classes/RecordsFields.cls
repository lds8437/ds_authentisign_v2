/*
*********************************************************
@Apex Class Name    : RecordsFields
@Created Date       : Dec 13, 2023
@description        : Class to hold describe fields for quote and quote line item and their records
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class RecordsFields
{
    @AuraEnabled
    public SObject quote {get;set;}
    
    @AuraEnabled
    public List<SObject> quoteLineItems {get;set;}
    
    @AuraEnabled
    public Map<string, Map<string, string>> quoteFieldProps {get;set;}
    
    @AuraEnabled
    public Map<string, Map<string, string>> quoteLineItemFieldProps {get;set;}
    
    @AuraEnabled
    public Map<string,List<string>> participientFields {get; set;}
    
    @AuraEnabled
    public Map<string,string> usercontactfieldmap {get; set;}
}