/*
*********************************************************
@Apex Class Name    : DataLayer
@Created Date       : Dec 05, 2023
@description        : class to get the data with soql queries
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class DataLayer {

    /*
    *********************************************************
    @Method Name    : getSetting
    @description    : get the authentisign setting to request authentisign api
    @param          : N/A
    @return         : authentisign__Setting__c 
    ********************************************************
    */
    public static authentisign__Setting__c getSetting()
    {
        if (Schema.sObjectType.authentisign__Setting__c.fields.Id.isAccessible() &&
            Schema.sObjectType.authentisign__Setting__c.fields.Name.isAccessible() &&
            Schema.sObjectType.authentisign__Setting__c.fields.authentisign__Account_Id__c.isAccessible() &&
            Schema.sObjectType.authentisign__Setting__c.fields.authentisign__Bearer_Token__c.isAccessible() &&
            Schema.sObjectType.authentisign__Setting__c.fields.authentisign__Callback_Url__c.isAccessible() &&
            Schema.sObjectType.authentisign__Setting__c.fields.authentisign__Endpoint__c.isAccessible()
           ) 
        {
            authentisign__Setting__c[] settings = [Select Id, Name, authentisign__Account_Id__c, authentisign__Bearer_Token__c, authentisign__Callback_Url__c, authentisign__Endpoint__c from authentisign__Setting__c limit 1];
            if(settings.size() > 0)
            {
                return settings[0];
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }	
    
    /*
    *********************************************************
    @Method Name    : getQuoteById
    @description    : get Quote record by Id and Object name (Quote, CPQ Quote)
    @param          : string recordId, string sObjectName
    @return         : SObject
    ********************************************************
    */
    public static SObject getQuoteById(string recordId, string sObjectName)
    {
        Map<String, Schema.SObjectField> SOBjectFieldfMap = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().Fields.getMap();
        
        Schema.DescribeFieldResult idFD = SOBjectFieldfMap.get('Id').getDescribe();
        Schema.DescribeFieldResult nameFD = SOBjectFieldfMap.get('Name').getDescribe();
        Schema.DescribeFieldResult layoutIdFD = SOBjectFieldfMap.get('authentisign__Layout_Id__c').getDescribe();
        Schema.DescribeFieldResult signingIdFD = SOBjectFieldfMap.get('authentisign__Signing_Id__c').getDescribe();
        Schema.DescribeFieldResult statusFD = SOBjectFieldfMap.get('authentisign__Authsign_Status__c').getDescribe();
        Schema.DescribeFieldResult attachmentIdFD = SOBjectFieldfMap.get('authentisign__AttachmentId__c').getDescribe();
        Schema.DescribeFieldResult documentIdFD = SOBjectFieldfMap.get('authentisign__Document_Id__c').getDescribe();
        Schema.DescribeFieldResult documentSigningIdFD = SOBjectFieldfMap.get('authentisign__Document_Signing_Id__c').getDescribe();
        Schema.DescribeFieldResult documentAttachIdFD = SOBjectFieldfMap.get('authentisign__Document_Attachment_Id__c').getDescribe();
        Schema.DescribeFieldResult documentStatusFD = SOBjectFieldfMap.get('authentisign__Authsign_Document_Status__c').getDescribe();

        
        if(idFD.isAccessible() &&
           nameFD.isAccessible() &&
           layoutIdFD.isAccessible() &&
           signingIdFD.isAccessible() &&
           statusFD.isAccessible() &&
           attachmentIdFD.isAccessible() &&
           documentIdFD.isAccessible() &&
           documentSigningIdFD.isAccessible() &&
           documentAttachIdFD.isAccessible() &&
           documentStatusFD.isAccessible()
          )
        {
            sObject quoteObject =  Database.query('Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c,'+
                                                  ' authentisign__Document_Attachment_Id__c, authentisign__Authsign_Document_Status__c, authentisign__Document_Id__c, authentisign__Document_Signing_Id__c from ' + sObjectName + ' where Id = \''+recordId+'\' ');
            return quoteObject; 
        }else{
            return null;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getLayoutMappings
    @description    : get saved layout mappings for requested layout
    @param          : string layoutId, string objectName
    @return         : string (json mapping strings)
    ********************************************************
    */
    public static string getLayoutMappings(string layoutId, string objectName)
    {
        string jsonLayoutMappings = '';// '{"fieldsMap":{"Product":{"object":"lineitem","field":"CreatedById","lineItemId":"0QLHn000007DT0DOAW"},"AgentNumber":{"object":"quote","field":"AccountId"},"Test Field 1":{"object":"lineitem","field":"CreatedById","lineItemId":"0QLHn000007DT0EOAW"}},"rolesMap":{"buyer":"OwnerId","Seller":"ContactId"}}';
        
        if (Schema.sObjectType.authentisign__Layout_Mapping__c.fields.Id.isAccessible() &&
            Schema.sObjectType.authentisign__Layout_Mapping__c.fields.authentisign__Layout_Id__c.isAccessible() &&
            Schema.sObjectType.authentisign__Layout_Mapping__c.fields.authentisign__Mapping__c.isAccessible() &&
            Schema.sObjectType.authentisign__Layout_Mapping__c.fields.authentisign__Layout_Id__c.isAccessible() &&
            Schema.sObjectType.authentisign__Layout_Mapping__c.fields.authentisign__Object__c.isAccessible() &&
            Schema.sObjectType.authentisign__Layout_Mapping__c.fields.authentisign__Unique_Id__c.isAccessible()  
           ) 
        {
            authentisign__Layout_Mapping__c[] layouts = [Select Id, authentisign__Layout_Id__c, authentisign__Mapping__c from authentisign__Layout_Mapping__c
                                                         where authentisign__Layout_Id__c =: layoutId and authentisign__Object__c =: objectName];
            if(layouts.size() > 0)
            {
                jsonLayoutMappings = layouts[0].authentisign__Mapping__c;
            }
        }
        return jsonLayoutMappings;
    }
    
    public static Map<string,string> getDocuments(string recordId, string objectName)
    {
        Map<string,string> resultMap = new Map<string,string>();
        if(objectName == 'SBQQ__Quote__c')
        {
            if (Schema.sObjectType.SBQQ__QuoteDocument__c.fields.Id.isAccessible() &&
                Schema.sObjectType.SBQQ__QuoteDocument__c.fields.Name.isAccessible() &&
                Schema.sObjectType.SBQQ__QuoteDocument__c.fields.SBQQ__DocumentId__c.isAccessible() &&
                Schema.sObjectType.SBQQ__QuoteDocument__c.fields.SBQQ__Quote__c.isAccessible()
               ) 
            {
                for(SBQQ__QuoteDocument__c  doc : [Select Id,Name,SBQQ__DocumentId__c from SBQQ__QuoteDocument__c where SBQQ__Quote__c =: recordId])
                {
                    resultMap.put(doc.Name,doc.SBQQ__DocumentId__c);
                }
            }
        }
        else
        {
             if (Schema.sObjectType.ContentDocumentLink.fields.Id.isAccessible() &&
                 Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible() &&
                 Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible() &&
                 Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() &&
                 Schema.sObjectType.ContentVersion.fields.Id.isAccessible() &&
                 Schema.sObjectType.ContentVersion.fields.Title.isAccessible()
               ) 
             {
                 List<Id> contentDocIds = new List<Id>();
                 for(ContentDocumentLink cdlink : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: recordId])
                 {
                     contentDocIds.add(cdlink.ContentDocumentId);
                 }
                 for(ContentVersion ver : [SELECT Id, Title FROM ContentVersion where ContentDocumentId =: contentDocIds])
                 {
                     resultMap.put(ver.Title,ver.Id);
                 }
             }
        }
        return resultMap;
    }
    
    public static blob getDocumentById(string documentId, string objectName)
    {
        blob result = null;
        if(objectName == 'SBQQ__Quote__c')
        {
            if (Schema.sObjectType.Document.fields.Id.isAccessible() &&
                Schema.sObjectType.Document.fields.Body.isAccessible()
               ) 
            {
                 result = [SELECT Id,Body FROM Document where Id=:documentId limit 1].Body;
            }
        }
        else
        {
             if (Schema.sObjectType.ContentVersion.fields.Id.isAccessible() &&
                 Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible()
               ) 
             {
                 result = [SELECT Id, VersionData FROM ContentVersion where Id =: documentId limit 1].VersionData;
             }
        }
        return result;
    }
     
    
    public static string getAttachmentId(string recordId, string sObjectName, boolean isLayout)
    {
        string attachmentId = '';
        
        Map<String, Schema.SObjectField> SOBjectFieldfMap = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().Fields.getMap();
        Schema.DescribeFieldResult idFD = SOBjectFieldfMap.get('Id').getDescribe();
        Schema.DescribeFieldResult attachmentIdFD = SOBjectFieldfMap.get('authentisign__AttachmentId__c').getDescribe();
        Schema.DescribeFieldResult docAttachmentIdFD = SOBjectFieldfMap.get('authentisign__Document_Attachment_Id__c').getDescribe();
        
        
        if(idFD.isAccessible() && attachmentIdFD.isAccessible() && docAttachmentIdFD.isAccessible())
        {
            sObject quoteObject =  Database.query('Select Id, authentisign__AttachmentId__c, authentisign__Document_Attachment_Id__c  from ' + sObjectName + ' where Id = \''+recordId+'\' ');
            
            if(isLayout)
                attachmentId =  quoteObject.get('authentisign__AttachmentId__c') == null ? '' : (string)quoteObject.get('authentisign__AttachmentId__c') ;
            else
                attachmentId =  quoteObject.get('authentisign__Document_Attachment_Id__c') == null ? '' : (string)quoteObject.get('authentisign__Document_Attachment_Id__c') ;
        }
        
        
        return attachmentId;
    }
}