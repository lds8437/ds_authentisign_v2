/**
@Apex Class Name    : LayoutListCtrl
@Created Date       : Sep 18, 2023
@description        : Apex class contains methods to display the list of layouts fetched from Authentisign.
@author             : FFD Developer
@Modification Log   : 
  - Updated August 6, 2025: Added createLayout method to handle POST request for creating a new layout.
*/
public with sharing class LayoutListCtrl {

    /**
    @methodname     getLayouts
    @description    Calls helper class method to get the layouts
    @param          recordId 
    @param          objectName
    @return         LayoutResponse
    */
    @AuraEnabled(cacheable=true)
    public static LayoutResponse getLayouts(String recordId, String objectName) {
        try {
            // Note: Set objectName to 'Opportunity' for use with Opportunity records
            return LayoutListHelper.getLayouts(recordId, objectName);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getLayouts: ' + e.getMessage());
            throw new AuraHandledException('Failed to retrieve layouts: ' + e.getMessage());
        }
    }
    
    /**
    @methodname     saveAttachment
    @description    Calls utility class method to save PDF as attachment
    @param          quoteId
    @param          signingId
    @param          objectName
    @param          isLayout
    @return         String (AttachmentId)
    */
    @AuraEnabled
    public static String saveAttachment(String quoteId, String signingId, String objectName, Boolean isLayout) {
        try {
            // Note: Set objectName to 'Opportunity' for use with Opportunity records
            String attachmentId = DataLayer.getAttachmentId(quoteId, objectName, isLayout);
            if (String.isBlank(attachmentId)) {
                if (isLayout)
                    attachmentId = Utility.savePDFasAttachment(quoteId, signingId, 'ls', objectName);
                else
                    attachmentId = Utility.savePDFasAttachmentDocument(quoteId, signingId, 'ls', objectName);
            }
            return attachmentId;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in saveAttachment: ' + e.getMessage());
            throw new AuraHandledException('Failed to save attachment: ' + e.getMessage());
        }
    }
    
    /**
    @methodname     getLayoutMappings
    @description    Calls data layer class method to get the saved mappings
    @param          layoutId
    @param          objectName
    @return         String (JSON string mappings)
    */
    @AuraEnabled(cacheable=true)
    public static String getLayoutMappings(String layoutId, String objectName) {
        try {
            // Note: Set objectName to 'Opportunity' for use with Opportunity records
            return DataLayer.getLayoutMappings(layoutId, objectName);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getLayoutMappings: ' + e.getMessage());
            throw new AuraHandledException('Failed to retrieve layout mappings: ' + e.getMessage());
        }
    }
    
    /**
    @methodname     createLayout
    @description    Calls helper class method to create a new layout via Authentisign API
    @param          templateName
    @return         String (layout ID)
    */
    @AuraEnabled
    public static String createLayout(String templateName) {
        try {
            return LayoutListHelper.createLayout(templateName);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in createLayout: ' + e.getMessage());
            throw new AuraHandledException('Failed to create layout: ' + e.getMessage());
        }
    }
}