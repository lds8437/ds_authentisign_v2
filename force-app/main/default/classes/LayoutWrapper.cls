/*
*********************************************************
@Apex Class Name    : LayoutWrapper
@Created Date       : Dec 12, 2023
@description        : Wrapper class for layout reponse from api
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutWrapper
{
    @AuraEnabled
    public string id { get; set; }
    @AuraEnabled
    public string name { get; set; }
    @AuraEnabled
    public DateTime dateCreated { get; set; }
    @AuraEnabled
    public DateTime lastModified { get; set; }
    @AuraEnabled
    public List<LayoutParticipant> layoutParticipants { get; set; }
    @AuraEnabled
    public List<string> roles { get; set; }
    @AuraEnabled
    public List<string> fields { get; set; }
}