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
    @description    Calls helper class method to get the layouts
    @param          recordId 
    @param          objectName
    @return         LayoutResponse
    */
    @AuraEnabled
    public static LayoutResponse getLayouts(String recordId, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        return LayoutListHelper.getLayouts(recordId, objectName);
    }
    
    /**
    @methodname     saveAttachment
    @description    Calls utility class method to save PDF as attachment
    @param          quoteId
    @param          signingId
    @param          objectName
    @return         String (AttachmentId)
    */
    @AuraEnabled
    public static String saveAttachment(String quoteId, String signingId, String objectName, Boolean isLayout) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        String attachmentId = DataLayer.getAttachmentId(quoteId, objectName, isLayout);
        if (attachmentId == '') {
            if (isLayout)
                attachmentId = Utility.savePDFasAttachment(quoteId, signingId, 'ls', objectName);
            else
                attachmentId = Utility.savePDFasAttachmentDocument(quoteId, signingId, 'ls', objectName);
        }
        return attachmentId;
    }
    
    /**
    @methodname     getLayoutMappings
    @description    Calls data layer class method to get the saved mappings
    @param          layoutId
    @param          objectName
    @return         String (JSON string mappings)
    */
    @AuraEnabled
    public static String getLayoutMappings(String layoutId, String objectName) {
        // Note: Set objectName to 'Opportunity' for use with Opportunity records
        return DataLayer.getLayoutMappings(layoutId, objectName);
    }
}