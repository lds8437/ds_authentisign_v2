@IsTest
private class CPQElectronicSignPluginTest {

    @IsTest
    private static void unittest()
    {
        List<SBQQ__QuoteDocument__c> docs = new List<SBQQ__QuoteDocument__c>();
         
        CPQElectronicSignPlugin plugin = new CPQElectronicSignPlugin();
        
        plugin.sendWithRedirect(docs);
        plugin.send(docs);
        plugin.updateStatus(docs);
        plugin.revoke(docs);
        plugin.getSendButtonLabel();
        plugin.isSendButtonEnabled();
    }
}