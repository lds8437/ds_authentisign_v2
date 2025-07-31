/*
*********************************************************
@Apex Class Name    : RecordsFields
@Created Date       : Dec 13, 2023
@description        : Wrapper class to hold describe fields and records for parent SObject (e.g., Opportunity) and related line items (e.g., OpportunityLineItem)
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Renamed quote-related properties to record and lineItems for clarity (now refers to Opportunity and OpportunityLineItem). Renamed participientFields to participantFields. Updated documentation for consistency with Opportunity-based codebase.
  - Updated July 31, 2025: Added null checks for properties to prevent NullPointerException in UI components.
*********************************************************
*/
public with sharing class RecordsFields {
    /*
    *********************************************************
    @description    : Parent SObject record (e.g., Opportunity)
    @type           : SObject
    ********************************************************
    */
    @AuraEnabled
    public SObject record { get; set; }

    /*
    *********************************************************
    @description    : Related line item records (e.g., OpportunityLineItem)
    @type           : List<SObject>
    ********************************************************
    */
    @AuraEnabled
    public List<SObject> lineItems {
        get { return lineItems != null ? lineItems : new List<SObject>(); }
        set { lineItems = value; }
    }

    /*
    *********************************************************
    @description    : Field properties for the parent SObject
    @type           : Map<String, Map<String, String>>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, Map<String, String>> recordFieldProps {
        get { return recordFieldProps != null ? recordFieldProps : new Map<String, Map<String, String>>(); }
        set { recordFieldProps = value; }
    }

    /*
    *********************************************************
    @description    : Field properties for related line items
    @type           : Map<String, Map<String, String>>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, Map<String, String>> lineItemFieldProps {
        get { return lineItemFieldProps != null ? lineItemFieldProps : new Map<String, Map<String, String>>(); }
        set { lineItemFieldProps = value; }
    }

    /*
    *********************************************************
    @description    : Map of participant roles to their fields
    @type           : Map<String, List<String>>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, List<String>> participantFields {
        get { return participantFields != null ? participantFields : new Map<String, List<String>>(); }
        set { participantFields = value; }
    }

    /*
    *********************************************************
    @description    : Map of user/contact fields for mapping
    @type           : Map<String, String>
    ********************************************************
    */
    @AuraEnabled
    public Map<String, String> usercontactfieldmap {
        get { return usercontactfieldmap != null ? usercontactfieldmap : new Map<String, String>(); }
        set { usercontactfieldmap = value; }
    }
}