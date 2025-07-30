global class CPQElectronicSignPlugin implements SBQQ.ElectronicSignaturePlugin3 {

    global string sendWithRedirect(List<SBQQ__QuoteDocument__c> docs) {
        System.debug('sendWithRedirect: '+JSON.serializePretty(docs));
        
        string returnUrl = '';
        if(docs.size() > 0)
        {
            SBQQ__QuoteDocument__c qutoeDocument  = [Select Id,Name, SBQQ__Quote__c, SBQQ__DocumentId__c from SBQQ__QuoteDocument__c where Id =: docs[0].Id limit 1];
            returnUrl = '/apex/authentisign__sendtoauthentisign?documentid='+qutoeDocument.SBQQ__DocumentId__c+'&quoteid='+ EncodingUtil.UrlEncode(qutoeDocument.SBQQ__Quote__c, 'UTF-8') +'&documentname='+ EncodingUtil.UrlEncode(qutoeDocument.Name, 'UTF-8') +'&objectname='+ EncodingUtil.UrlEncode('SBQQ__Quote__c','UTF-8');
        }
        //'/apex/sendtoauthentisign?documentid='+docs[0].Id+'&quoteid=&documentname=&objectname='+ EncodingUtil.UrlEncode('SBQQ__Quote__c','UTF-8');
        return  returnUrl;
    }
    
    global void send(List<SBQQ__QuoteDocument__c> docs) {
        System.debug('send: '+JSON.serializePretty(docs));       
    }

    global void updateStatus(List<SBQQ__QuoteDocument__c> docs) {
        System.debug('updateStatus: '+ JSON.serializePretty(docs));
    }

    global void revoke(List<SBQQ__QuoteDocument__c> docs) {
        System.debug('revoke: '+JSON.serializePretty(docs));
    }

    global String getSendButtonLabel() {
        return 'Send to Authentisign';
    }

    global Boolean isSendButtonEnabled() {
        return true;
    }
}