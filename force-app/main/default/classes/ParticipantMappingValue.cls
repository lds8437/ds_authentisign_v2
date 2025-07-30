/*
*********************************************************
@Apex Class Name    : ParticipantMappingValue
@Created Date       : Dec 15, 2023
@description        : class to save mapped values of participant
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class ParticipantMappingValue {

    public string role {get;set;}
    public string lookupField {get;set;}
    public string lookupid {get;set;}
    public string objecttype {get;set;}
    public string name {get;set;}
    public string firstname {get;set;}
    public string lastname {get;set;}
    public string email {get;set;}
    public integer index {get;set;}
    
    public ParticipantMappingValue()
    {
        role = '';
        lookupfield = '';
        lookupid = '';
        objecttype  = '';
        name = '';
        email = '';
        index = 0;
    }
}