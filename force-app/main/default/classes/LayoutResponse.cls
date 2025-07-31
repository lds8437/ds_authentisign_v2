/*
*********************************************************
@Apex Class Name    : LayoutResponse
@Created Date       : Dec 12, 2023
@description        : Main wrapper class for layout response from API
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutResponse {
    @AuraEnabled
    public List<LayoutWrapper> wrapper { get; set; }
    
    @AuraEnabled
    public SObject quote { get; set; }
    
    @AuraEnabled
    public String signingStatus { get; set; }
    
    @AuraEnabled
    public Map<String,String> documents { get; set; }
    
    @AuraEnabled
    public String documentSigningStatus { get; set; }
    // No changes needed; SObject quote supports Opportunity
}