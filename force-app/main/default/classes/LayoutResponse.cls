/*
*********************************************************
@Apex Class Name    : LayoutResponse
@Created Date       : Dec 12, 2023
@description        : Main wrapper class for layout reponse from api
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutResponse
{
    @AuraEnabled
    public List<LayoutWrapper> wrapper {get;set;}
    
    @AuraEnabled
    public SObject quote {get;set;}
    
    @AuraEnabled
    public string signingStatus {get;set;}
    
    @AuraEnabled
    public Map<string,string> documents {get;set;}
    
    @AuraEnabled
    public string documentSigningStatus {get;set;}
}