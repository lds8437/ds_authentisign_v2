public with sharing class AuthentiSignMappingCtrl {

    @AuraEnabled
    public static RecordsFields getAllData(string recordId, string objectName)
    {
        return AuthentiSignMappingHelper.getAllData(recordId, objectName);
    }
    
    @AuraEnabled
    public static string fillandSubmit(string requestString, string quoteId, string layoutId, string mappings, string objectName)
    {
        return AuthentiSignMappingHelper.fillandSubmit(requestString, quoteId, layoutId, mappings, objectName);
    }
    
    @AuraEnabled
    public static string savePDFasAttachment(string quoteId, string signingId, string objectName)
    {
        System.debug('savePDFasAttachment');
        return Utility.savePDFasAttachment(quoteId, signingId, 'ls', objectName);
    }
    
    @AuraEnabled
    public static string savePDFasAttachmentDocument(string quoteId, string signingId, string objectName)
    {
        System.debug('savePDFasAttachmentDocument');
        return Utility.savePDFasAttachmentDocument(quoteId, signingId, 'ls', objectName);
    }
    
    @AuraEnabled
    public static Map<string,string> submitDocumentRequest(string requestString, string quoteId, string quoteName, string documentId, string documentName, string objectName)
    {
        return AuthentisignDocumentHelper.fillandSubmit(requestString, quoteId, quoteName, documentId, documentName, objectName);
    }
    
    
}