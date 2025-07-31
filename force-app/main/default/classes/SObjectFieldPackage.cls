/*
*********************************************************
@Apex Class Name    : SObjectFieldPackage
@Created Date       : Dec 12, 2023
@description        : Wrapper class to hold SObject query and field metadata
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added AuraEnabled annotations for UI compatibility. Renamed ParticipientList to ParticipantList for clarity. Added documentation for consistency with Opportunity-based codebase. Confirmed no CPQ dependencies.
*********************************************************
*/
public with sharing class SObjectFieldPackage {
    /*
    *********************************************************
    @description    : SOQL query string for the SObject
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String Query { get; set; }
    
    /*
    *********************************************************
    @description    : List of SObject field API names
    @type           : List<String>
    ********************************************************
    */
    @AuraEnabled
    public List<String> SObjectFieldsList { get; set; }
    
    /*
    *********************************************************
    @description    : Map of participant roles to their fields
    @type           : Map<String, List<String>>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, List<String>> ParticipantList { get; set; }
    
    /*
    *********************************************************
    @description    : Map of SObject fields to their properties (e.g., label, type)
    @type           : Map<String, Map<String, String>>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, Map<String, String>> SObjectFieldsProperties { get; set; }
    
    /*
    *********************************************************
    @description    : Map of user/contact fields for mapping
    @type           : Map<String, String>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, String> UserContactFieldMap { get; set; }
}