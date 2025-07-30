/**
@Apex Class Name    : LayoutListCtrl
@Created Date       : Sep 18, 2023
@description        : Apex class contains methods to display the list of layouts fetched from Authentisign.
@author             : FFD Developer
@Modification Log   : 
*/
public with sharing class LayoutListCtrl {

    /**
    @methodname     LayoutResponse
    @description    calls helper class method to get the layouts
    @param          recordId 
    @param          objectName
    @return         LayoutResponse
    */
    @AuraEnabled
    public static LayoutResponse getLayouts(string recordId, string objectName)
    {
        return LayoutListHelper.getLayouts(recordId, objectName);
    }
    
    /**
    @methodname     saveAttachment
    @description    calls utility class method to save PDF as attachment
    @param          quoteId
    @param          signingId
    @param          objectName
    @return         string (AttachmentId)
    */
    @AuraEnabled
    public static string saveAttachment(string quoteId, string signingId, string objectName, boolean isLayout)
    {
        string attachmentId = DataLayer.getAttachmentId(quoteId, objectName, isLayout);
        if(attachmentId == '')
        {
            if(isLayout)
                attachmentId = Utility.savePDFasAttachment(quoteId, signingId, 'ls', objectName);
            else
                attachmentId = Utility.savePDFasAttachmentDocument(quoteId, signingId, 'ls', objectName);
        }
        return attachmentId;
    }
    
    /**
    @methodname     getLayoutMappings
    @description    calls data layer class method to get the saved mappings
    @param          layoutId
    @param          objectName
    @return         string (json string mappings)
    */
    @AuraEnabled
    public static string getLayoutMappings(string layoutId, string objectName)
    {
        return DataLayer.getLayoutMappings(layoutId, objectName);
    }

}