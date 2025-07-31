/*
*********************************************************
@Apex Class Name    : SigningResponse
@Created Date       : Dec 12, 2023
@description        : Wrapper class for deserializing Authentisign API signing response
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added AuraEnabled annotations for UI compatibility. Added documentation for consistency with Opportunity-based codebase. Confirmed no CPQ dependencies.
*********************************************************
*/
public with sharing class SigningResponse {
    /*
    *********************************************************
    @description    : Unique identifier of the signing request
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String id { get; set; }
    
    /*
    *********************************************************
    @description    : Name of the signing request
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String name { get; set; }
    
    /*
    *********************************************************
    @description    : Authentisign account ID
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String accountId { get; set; }
    
    /*
    *********************************************************
    @description    : Status ID of the signing request
    @type           : Integer
    ********************************************************
    */
    @AuraEnabled
    public Integer statusId { get; set; }
    
    /*
    *********************************************************
    @description    : Indicates if signing order is enforced
    @type           : Boolean
    ********************************************************
    */
    @AuraEnabled
    public Boolean isOrdered { get; set; }
    
    /*
    *********************************************************
    @description    : Date and time the signing request was created
    @type           : DateTime
    ********************************************************
    */
    @AuraEnabled
    public DateTime dateCreated { get; set; }
    
    /*
    *********************************************************
    @description    : Date and time the signing request was last modified
    @type           : DateTime
    ********************************************************
    */
    @AuraEnabled
    public DateTime lastModified { get; set; }
    
    /*
    *********************************************************
    @description    : Expiration date of the signing request
    @type           : DateTime
    ********************************************************
    */
    @AuraEnabled
    public DateTime expirationDate { get; set; }
    
    /*
    *********************************************************
    @description    : Position ID in the signing process
    @type           : Integer
    ********************************************************
    */
    @AuraEnabled
    public Integer idPosition { get; set; }
    
    /*
    *********************************************************
    @description    : Day for sending reminders
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String reminderDay { get; set; }
    
    /*
    *********************************************************
    @description    : Hour for sending reminders
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String reminderHour { get; set; }
    
    /*
    *********************************************************
    @description    : Transaction ID for the signing request
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String transactionId { get; set; }
    
    /*
    *********************************************************
    @description    : Technology provider for the signing request
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String technologyProvider { get; set; }
    
    /*
    *********************************************************
    @description    : Callback URL for the signing request
    @type           : String
    ********************************************************
    */
    @AuraEnabled
    public String callbackUrl { get; set; }
}