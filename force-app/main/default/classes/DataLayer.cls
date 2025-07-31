/*
*********************************************************
@Apex Class Name    : DataLayer
@Created Date       : Dec 05, 2023
@description        : Class to get data with SOQL queries
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added try-catch with AuraHandledException for UI compatibility. Added field validation in getRecordById. Confirmed no CPQ dependencies; supports Opportunity.
*********************************************************
*/
public with sharing class DataLayer {

    /*
    *********************************************************
    @Method Name    : getSetting
    @description    : Get the Authentisign setting for API requests
    @param          : None
    @return         : Setting__c
    ********************************************************
    */
    public static Setting__c getSetting() {
        try {
            if (Schema.sObjectType.Setting__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Setting__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Setting__c.fields.Account_Id__c.isAccessible() &&
                Schema.sObjectType.Setting__c.fields.Bearer_Token__c.isAccessible() &&
                Schema.sObjectType.Setting__c.fields.Callback_Url__c.isAccessible() &&
                Schema.sObjectType.Setting__c.fields.Endpoint__c.isAccessible()) {
                Setting__c[] settings = [SELECT Id, Name, Account_Id__c, Bearer_Token__c, Callback_Url__c, Endpoint__c 
                                         FROM Setting__c LIMIT 1];
                return settings.isEmpty() ? null : settings[0];
            }
            throw new AuraHandledException('Insufficient permissions to access Setting__c fields.');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving Setting__c: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving settings: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getRecordById
    @description    : Get record by Id and object name
    @param          : String recordId, String sObjectName
    @return         : SObject
    ********************************************************
    */
    public static SObject getRecordById(String recordId, String sObjectName) {
        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
            if (fieldMap == null) {
                throw new AuraHandledException('Invalid SObject: ' + sObjectName);
            }

            List<String> fields = new List<String>{'Id', 'Name', 'Layout_Id__c', 'Signing_Id__c', 'Authsign_Status__c', 
                                                  'AttachmentId__c', 'Document_Attachment_Id__c', 'Authsign_Document_Status__c', 
                                                  'Document_Id__c', 'Document_Signing_Id__c'};
            List<String> accessibleFields = new List<String>();
            for (String field : fields) {
                if (fieldMap.containsKey(field.toLowerCase()) && fieldMap.get(field.toLowerCase()).getDescribe().isAccessible()) {
                    accessibleFields.add(field);
                }
            }

            if (accessibleFields.isEmpty()) {
                throw new AuraHandledException('No accessible fields for SObject: ' + sObjectName);
            }

            String query = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + String.escapeSingleQuotes(sObjectName) + 
                          ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1';
            return Database.query(query);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error querying record: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving record: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getLayoutMappings
    @description    : Get saved layout mappings for requested layout
    @param          : String layoutId, String objectName
    @return         : String (JSON mapping strings)
    ********************************************************
    */
    public static String getLayoutMappings(String layoutId, String objectName) {
        try {
            String jsonLayoutMappings = '';
            if (Schema.sObjectType.Layout_Mapping__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Layout_Mapping__c.fields.Layout_Id__c.isAccessible() &&
                Schema.sObjectType.Layout_Mapping__c.fields.Mapping__c.isAccessible() &&
                Schema.sObjectType.Layout_Mapping__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Layout_Mapping__c.fields.Unique_Id__c.isAccessible()) {
                Layout_Mapping__c[] layouts = [SELECT Id, Layout_Id__c, Mapping__c 
                                              FROM Layout_Mapping__c 
                                              WHERE Layout_Id__c = :layoutId AND Object__c = :objectName LIMIT 1];
                if (!layouts.isEmpty()) {
                    jsonLayoutMappings = layouts[0].Mapping__c;
                }
            }
            return jsonLayoutMappings;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving layout mappings: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving layout mappings: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getDocuments
    @description    : Get documents associated with a record
    @param          : String recordId, String objectName
    @return         : Map<String,String> (Document Title to Id)
    ********************************************************
    */
    public static Map<String,String> getDocuments(String recordId, String objectName) {
        try {
            Map<String,String> resultMap = new Map<String,String>();
            if (Schema.sObjectType.ContentDocumentLink.fields.Id.isAccessible() &&
                Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible() &&
                Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible() &&
                Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() &&
                Schema.sObjectType.ContentVersion.fields.Id.isAccessible() &&
                Schema.sObjectType.ContentVersion.fields.Title.isAccessible()) {
                List<Id> contentDocIds = new List<Id>();
                for (ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId = :recordId]) {
                    contentDocIds.add(cdLink.ContentDocumentId);
                }
                for (ContentVersion ver : [SELECT Id, Title 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId IN :contentDocIds]) {
                    resultMap.put(ver.Title, ver.Id);
                }
            }
            return resultMap;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving documents: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving documents: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getDocumentById
    @description    : Get document content by Id
    @param          : String documentId, String objectName
    @return         : Blob
    ********************************************************
    */
    public static Blob getDocumentById(String documentId, String objectName) {
        try {
            if (Schema.sObjectType.ContentVersion.fields.Id.isAccessible() &&
                Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible()) {
                ContentVersion[] versions = [SELECT Id, VersionData 
                                             FROM ContentVersion 
                                             WHERE Id = :documentId LIMIT 1];
                return versions.isEmpty() ? null : versions[0].VersionData;
            }
            throw new AuraHandledException('Insufficient permissions to access ContentVersion fields.');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving document: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving document: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getAttachmentId
    @description    : Get attachment Id from record
    @param          : String recordId, String sObjectName, Boolean isLayout
    @return         : String (Attachment Id)
    ********************************************************
    */
    public static String getAttachmentId(String recordId, String sObjectName, Boolean isLayout) {
        try {
            String attachmentId = '';
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
            if (fieldMap == null) {
                throw new AuraHandledException('Invalid SObject: ' + sObjectName);
            }

            List<String> fields = new List<String>{'Id', 'AttachmentId__c', 'Document_Attachment_Id__c'};
            List<String> accessibleFields = new List<String>();
            for (String field : fields) {
                if (fieldMap.containsKey(field.toLowerCase()) && fieldMap.get(field.toLowerCase()).getDescribe().isAccessible()) {
                    accessibleFields.add(field);
                }
            }

            if (accessibleFields.isEmpty()) {
                throw new AuraHandledException('No accessible fields for SObject: ' + sObjectName);
            }

            String query = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + String.escapeSingleQuotes(sObjectName) + 
                          ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1';
            SObject record = Database.query(query);
            attachmentId = isLayout ? (String)record.get('AttachmentId__c') : (String)record.get('Document_Attachment_Id__c');
            return attachmentId == null ? '' : attachmentId;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving attachment Id: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving attachment Id: ' + e.getMessage());
        }
    }
}