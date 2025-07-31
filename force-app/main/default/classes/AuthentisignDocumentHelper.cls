/*
*********************************************************
@Apex Class Name    : AuthentisignDocumentHelper
@Created Date       : Dec 12, 2023
@description        : Helper class to handle document signing requests for Authentisign
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Renamed quoteId to recordId and quoteName to recordName for clarity (now refers to Opportunity). Added try-catch blocks for Aura compatibility. Improved error handling and documentation. Added warnings for SignersRequest and QueueSavingAttachment dependencies.
*********************************************************
*/
public with sharing class AuthentisignDocumentHelper {

    /*
    *********************************************************
    @Method Name    : fillandSubmit
    @description    : Deserialize signers data and submit document signing request
    @param          : String requestString, String recordId, String recordName, String documentId, String documentName, String objectName
    @return         : Map<String,String>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,String> fillandSubmit(String requestString, String recordId, String recordName, String documentId, String documentName, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        try {
            // WARNING: Verify SignersRequest class has no CPQ dependencies
            List<SignersRequest> signersData = (List<SignersRequest>)JSON.deserialize(requestString, List<SignersRequest>.class);
            Map<String,String> result = fillandSubmit(signersData, recordId, recordName, documentId, documentName, objectName);
            
            String resultStatus = result.get('status');
            if (resultStatus == 'error') {
                throw new AuraHandledException(result.get('result'));
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing document signing request: ' + e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : fillandSubmit
    @description    : Submit document signing request and update record
    @param          : List<SignersRequest> signersData, String recordId, String recordName, String documentId, String documentName, String objectName
    @return         : Map<String,String>
    ********************************************************
    */
    public static Map<String,String> fillandSubmit(List<SignersRequest> signersData, String recordId, String recordName, String documentId, String documentName, String objectName) {
        Map<String,String> result = new Map<String,String>();
        
        if (signersData.isEmpty()) {
            result.put('status', 'error');
            result.put('result', 'error: no signers');
            return result;
        }
        
        try {
            Setting__c setting = Utility.getSetting();
            if (setting == null) {
                throw new AuraHandledException('Authentisign settings not found.');
            }
            
            Map<String,String> requestParams = new Map<String,String>();
            String requestMethod = '/api/v2/signings/fill-and-send-documents';
            String finalEndpoint = setting.Endpoint__c + requestMethod;
            
            requestParams.put('url', finalEndpoint);
            requestParams.put('externalId', setting.Account_Id__c);
            requestParams.put('token', setting.Bearer_Token__c);
            requestParams.put('objectName', objectName);
            requestParams.put('documentId', documentId);
            requestParams.put('documentName', documentName);
            requestParams.put('recordName', recordName);
            
            System.debug('requestParams: ' + requestParams);
            
            String submitResponse = Utility.submitDocumentRequest(signersData, requestParams);
            String documentSigningId = '';
            
            if (String.isNotBlank(submitResponse)) {
                Map<String,Object> resultMap = (Map<String,Object>)JSON.deserializeUntyped(submitResponse);
                documentSigningId = (String)resultMap.get('id');
                System.debug('signingId: ' + documentSigningId);
                
                if (String.isNotBlank(documentSigningId)) {
                    result.put('status', 'success');
                    result.put('result', documentSigningId);
                    
                    // Update Opportunity with signing details
                    SObject record = Schema.getGlobalDescribe().get(objectName).newSObject();
                    record.put('Id', recordId);
                    record.put('Document_Signing_Id__c', documentSigningId);
                    record.put('Document_Id__c', documentId);
                    record.put('Authsign_Document_Status__c', 'sent');
                    
                    // Verify required fields exist
                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
                    if (!fieldMap.containsKey('Document_Signing_Id__c') || !fieldMap.containsKey('Document_Id__c') || !fieldMap.containsKey('Authsign_Document_Status__c')) {
                        throw new AuraHandledException('Required fields missing on ' + objectName + ': Document_Signing_Id__c, Document_Id__c, or Authsign_Document_Status__c');
                    }
                    
                    update record;
                    
                    // Add 2 seconds delay for async processing
                    Datetime start = System.now();
                    while (System.now() < start.addSeconds(2));
                    
                    // WARNING: Verify QueueSavingAttachment is refactored to support Opportunity
                    System.enqueueJob(new QueueSavingAttachment(recordId, documentSigningId, objectName, true));
                } else {
                    result.put('status', 'error');
                    result.put('result', 'error: ' + (String)resultMap.get('message') + (resultMap.get('details') == null ? '' : ': ' + String.valueOf(resultMap.get('details')).replace(')', '').replace('(', '')));
                }
            } else {
                result.put('status', 'error');
                result.put('result', 'error: some unknown error occurred');
            }
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('result', 'error: ' + e.getMessage());
        }
        
        System.debug('result: ' + result);
        return result;
    }
}