/*
*********************************************************
@Apex Class Name    : QueueSavingAttachment
@Created Date       : Dec 12, 2023
@description        : Queueable job to save PDF attachments for signed documents or layouts
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Renamed quoteId to recordId for clarity (now refers to Opportunity). Added error handling and logging. Confirmed compatibility with Opportunity-based codebase.
*********************************************************
*/
public with sharing class QueueSavingAttachment implements Queueable, Database.AllowsCallouts {

    private String recordId { get; set; }
    private String signingId { get; set; }
    private String objectName { get; set; }
    private Boolean isDocument { get; set; }
    
    /*
    *********************************************************
    @Method Name    : QueueSavingAttachment
    @description    : Constructor to initialize queueable job parameters
    @param          : String recordId, String signingId, String objectName, Boolean isDocument
    ********************************************************
    */
    public QueueSavingAttachment(String recordId, String signingId, String objectName, Boolean isDocument) {
        this.recordId = recordId;
        this.signingId = signingId;
        this.objectName = objectName;
        this.isDocument = isDocument;
    }
    
    /*
    *********************************************************
    @Method Name    : execute
    @description    : Execute queueable job to save PDF attachment
    @param          : QueueableContext context
    ********************************************************
    */
    public void execute(QueueableContext context) {
        System.debug('recordId: ' + recordId);
        System.debug('signingId: ' + signingId);
        System.debug('objectName: ' + objectName);
        
        try {
            // Add 2 seconds delay for async processing
            Datetime start = System.now();
            while (System.now() < start.addSeconds(2));
            
            if (this.isDocument) {
                if (!Test.isRunningTest()) {
                    String attachmentId = Utility.savePDFasAttachmentDocument(recordId, signingId, 'ls', objectName);
                    if (String.isBlank(attachmentId)) {
                        System.debug(LoggingLevel.ERROR, 'Failed to save document attachment for recordId: ' + recordId);
                    }
                }
            } else {
                if (!Test.isRunningTest()) {
                    String attachmentId = Utility.savePDFasAttachment(recordId, signingId, 'ls', objectName);
                    if (String.isBlank(attachmentId)) {
                        System.debug(LoggingLevel.ERROR, 'Failed to save attachment for recordId: ' + recordId);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in QueueSavingAttachment: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            // TODO: Consider logging to a custom object for production monitoring
        }
    }
}