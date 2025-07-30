public class QueueSavingAttachment implements Queueable, Database.AllowsCallouts {

    private string quoteId {get;set;}
    private string signingId {get;set;}
    private string objectName {get;set;}
    private boolean isDocument {get;set;}
    
    public QueueSavingAttachment(string quoteId, string signingId, string objectName, boolean isDocument)
    {
        this.quoteId = quoteId;
        this.signingId = signingId;
        this.objectName = objectName;
        this.isDocument = isDocument;
    }
    public void execute(QueueableContext context) {
        System.debug('quoteId: '+quoteId);
        System.debug('signingId: '+signingId);
        System.debug('objectName: '+objectName);

        //Added 2 more seconds delay
        datetime start = System.Now();
        while(System.Now() < start.addSeconds(2));
        
        if(this.isDocument == true)
        {
            if(!Test.IsRunningTest())
                Utility.savePDFasAttachmentDocument(quoteId, signingId, 'ls', objectName);
        }
        else{
            if(!Test.IsRunningTest())
                Utility.savePDFasAttachment(quoteId, signingId, 'ls', objectName);
        }
            
    }
}