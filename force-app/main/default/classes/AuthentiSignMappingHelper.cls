/*
*********************************************************
@Apex Class Name    : AuthentiSignMappingHelper
@Created Date       : Dec 12, 2023
@description        : Helper class for AuthentiSignMappingCtrl to handle data retrieval and signing request submission
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Renamed quoteId to recordId in fillandSubmit for clarity. Added error handling for missing Opportunity_Id__c. Added warning about QueueSavingAttachment dependency. Updated RecordsFields property names (quote to record, quoteLineItems to lineItems, etc.) and ParticipientList to ParticipantList.
*********************************************************
*/
public with sharing class AuthentiSignMappingHelper {

    /*
    *********************************************************
    @Method Name    : getAllData
    @description    : Get initial data for mapping
    @param          : String recordId, String objectName
    @return         : RecordsFields
    ********************************************************
    */
    public static RecordsFields getAllData(String recordId, String objectName) {
        String lineItemObject = '';
        String lineItemParentField = '';
        
        // Determine related line item object based on parent object
        if (objectName.toLowerCase() == 'opportunity') {
            lineItemObject = 'OpportunityLineItem';
            lineItemParentField = 'OpportunityId';
        } else {
            // TODO: For generic SObject support, consider using custom metadata for object mappings
            throw new IllegalArgumentException('Unsupported object: ' + objectName);
        }
        
        RecordsFields wrapper = new RecordsFields();
        
        // Get parent record (e.g., Opportunity)
        try {
            SObjectFieldPackage recordInfo = Utility.getSObjectFields(objectName, 'WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'', '', '');
            List<SObject> records = Database.query(recordInfo.Query);
            
            if (!records.isEmpty()) {
                wrapper.record = records[0];
            }
            wrapper.recordFieldProps = recordInfo.SObjectFieldsProperties;
            wrapper.participantFields = recordInfo.ParticipantList;
            wrapper.usercontactfieldmap = recordInfo.UserContactFieldMap;
            
            // Get related line items (e.g., OpportunityLineItem)
            if (String.isNotBlank(lineItemObject)) {
                SObjectFieldPackage lineItemInfo = Utility.getSObjectFields(lineItemObject, 
                                                                           'WHERE ' + lineItemParentField + ' = \'' + String.escapeSingleQuotes(recordId) + '\'', '', '');
                List<SObject> lineItemRecords = Database.query(lineItemInfo.Query);
                
                if (!lineItemRecords.isEmpty()) {
                    wrapper.lineItems = lineItemRecords;
                }
                wrapper.lineItemFieldProps = lineItemInfo.SObjectFieldsProperties;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving data for mapping: ' + e.getMessage());
        }

        return wrapper;
    }
    
    /*
    *********************************************************
    @Method Name    : fillandSubmit
    @description    : Submit signing request and save mappings
    @param          : String requestString, String recordId, String layoutId, String mappings, String objectName
    @return         : String (Signing Id)
    ********************************************************
    */
    public static String fillandSubmit(String requestString, String recordId, String layoutId, String mappings, String objectName) {
        String signingId = '';
        
        Setting__c setting = Utility.getSetting();
        
        if (setting == null) {
            throw new AuraHandledException('Authentisign settings not found.');
        }
        
        try {
            String requestBody = requestString.replace('##callbackurl##', setting.Callback_Url__c);
            
            String token = setting.Bearer_Token__c;
            String accountId = setting.Account_Id__c;
            
            Map<String,String> headers = new Map<String,String>();
            headers.put('Authorization', 'Bearer ' + token);
            headers.put('Content-Type', 'application/json');
            headers.put('externalId', accountId);
            
            String endpoint = setting.Endpoint__c + '/api/v1/signings/fill-and-send';
            
            String responseBody = Utility.sendHttpRequest('POST', endpoint, headers, token, requestBody);
            
            SigningResponse sResponse = new SigningResponse();
            try {
                sResponse = (SigningResponse)JSON.deserialize(responseBody, SigningResponse.class);
            } catch (Exception ex) {
                System.debug('Error deserializing response: ' + ex.getMessage());
            }
            
            if (sResponse.id != null) {
                signingId = sResponse.id;
            }
            
            Record_Signing__c record = new Record_Signing__c();
            record.Signing_Id__c = sResponse.id;
            record.Signing_Request__c = requestBody;
            record.Signing_Response__c = responseBody;
            record.Layout_Id__c = layoutId;
            record.Type__c = objectName.toLowerCase() == 'opportunity' ? 'Opportunity' : 'Custom';
            if (objectName.toLowerCase() == 'opportunity') {
                // Verify Opportunity_Id__c field exists
                if (Schema.sObjectType.Record_Signing__c.fields.Opportunity_Id__c == null) {
                    throw new AuraHandledException('Opportunity_Id__c field not found on Record_Signing__c.');
                }
                record.Opportunity_Id__c = recordId;
            }
            insert record;
            
            Layout_Mapping__c layout = new Layout_Mapping__c();
            layout.Layout_Id__c = layoutId;
            layout.Mapping__c = mappings;
            layout.Object__c = objectName;
            layout.Unique_Id__c = layoutId + objectName.toLowerCase();
            Database.upsert(layout, Layout_Mapping__c.Unique_Id__c);
            
            if (String.isNotBlank(signingId)) {
                SObject obj = Schema.getGlobalDescribe().get(objectName).newSObject();
                obj.put('Id', recordId);
                obj.put('Signing_Id__c', signingId);
                obj.put('Layout_Id__c', layoutId);
                obj.put('Authsign_Status__c', 'sent');
                update obj;

                // Add delay for async processing
                Datetime start = System.now();
                while (System.now() < start.addSeconds(2));
                
                // WARNING: Verify QueueSavingAttachment is refactored to support Opportunity
                System.enqueueJob(new QueueSavingAttachment(recordId, signingId, objectName, false));
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error submitting signing request: ' + e.getMessage());
        }
        
        return signingId;
    }
}