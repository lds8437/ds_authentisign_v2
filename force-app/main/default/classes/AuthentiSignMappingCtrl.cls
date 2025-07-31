/*
*********************************************************
@Apex Class Name    : AuthentiSignMappingCtrl
@Created Date       : Dec 15, 2023
@description        : Controller class for Authentisign mapping functionality in Lightning components
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Renamed quoteId to recordId and quoteName to recordName for clarity (now refers to Opportunity). Added warning about AuthentisignDocumentHelper dependency.
*********************************************************
*/
public with sharing class AuthentiSignMappingCtrl {

    /*
    *********************************************************
    @Method Name    : getAllData
    @description    : Retrieve record and related data for mapping
    @param          : String recordId, String objectName
    @return         : RecordsFields
    ********************************************************
    */
    @AuraEnabled
    public static RecordsFields getAllData(String recordId, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        try {
            return AuthentiSignMappingHelper.getAllData(recordId, objectName);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving data: ' + e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : fillandSubmit
    @description    : Submit signing request and save mappings
    @param          : String requestString, String recordId, String layoutId, String mappings, String objectName
    @return         : String (Signing Id)
    ********************************************************
    */
    @AuraEnabled
    public static String fillandSubmit(String requestString, String recordId, String layoutId, String mappings, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        try {
            return AuthentiSignMappingHelper.fillandSubmit(requestString, recordId, layoutId, mappings, objectName);
        } catch (Exception e) {
            throw new AuraHandledException('Error submitting signing request: ' + e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : savePDFasAttachment
    @description    : Save PDF as attachment to the record
    @param          : String recordId, String signingId, String objectName
    @return         : String (Attachment Id)
    ********************************************************
    */
    @AuraEnabled
    public static String savePDFasAttachment(String recordId, String signingId, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        System.debug('savePDFasAttachment');
        try {
            return Utility.savePDFasAttachment(recordId, signingId, 'ls', objectName);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving PDF as attachment: ' + e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : savePDFasAttachmentDocument
    @description    : Save PDF as document attachment to the record
    @param          : String recordId, String signingId, String objectName
    @return         : String (Attachment Id)
    ********************************************************
    */
    @AuraEnabled
    public static String savePDFasAttachmentDocument(String recordId, String signingId, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        System.debug('savePDFasAttachmentDocument');
        try {
            return Utility.savePDFasAttachmentDocument(recordId, signingId, 'ls', objectName);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving PDF as document attachment: ' + e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : submitDocumentRequest
    @description    : Submit document signing request
    @param          : String requestString, String recordId, String recordName, String documentId, String documentName, String objectName
    @return         : Map<String,String>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,String> submitDocumentRequest(String requestString, String recordId, String recordName, String documentId, String documentName, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        // WARNING: AuthentisignDocumentHelper.fillandSubmit must be refactored to remove CPQ dependencies and support Opportunity
        try {
            return AuthentisignDocumentHelper.fillandSubmit(requestString, recordId, recordName, documentId, documentName, objectName);
        } catch (Exception e) {
            throw new AuraHandledException('Error submitting document request: ' + e.getMessage());
        }
    }
}