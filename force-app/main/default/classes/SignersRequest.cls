/*
*********************************************************
@Apex Class Name    : SignersRequest
@Created Date       : Dec 12, 2023
@description        : Wrapper class for deserializing signer data in Authentisign document signing requests
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added AuraEnabled annotations for UI compatibility. Renamed inner Data class to SignerData for clarity. Added documentation for consistency with Opportunity-based codebase. Confirmed no CPQ dependencies.
*********************************************************
*/
public with sharing class SignersRequest {

    /*
    *********************************************************
    @description    : Signer data for the Authentisign request
    @type           : SignerData
    ********************************************************
    */
    @AuraEnabled
    public SignerData data { get; set; }
    
    /*
    *********************************************************
    @Class Name     : SignerData
    @description    : Inner class to hold individual signer details
    ********************************************************
    */
    public with sharing class SignerData {
        /*
        *********************************************************
        @description    : Full name of the signer
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String Name { get; set; }
        
        /*
        *********************************************************
        @description    : First name of the signer
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String FirstName { get; set; }
        
        /*
        *********************************************************
        @description    : Last name of the signer
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String LastName { get; set; }
        
        /*
        *********************************************************
        @description    : Email address of the signer
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String Email { get; set; }
        
        /*
        *********************************************************
        @description    : Unique identifier for the signer (usage TBD)
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String Id { get; set; }
        
        /*
        *********************************************************
        @description    : Type of signer (usage TBD)
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String Type { get; set; }
        
        /*
        *********************************************************
        @description    : Role of the signer in the signing process
        @type           : String
        ********************************************************
        */
        @AuraEnabled
        public String Role { get; set; }
    }
}