public with sharing class AuthentisignDocumentHelper {

    public static Map<string,string> fillandSubmit(string requestString, string quoteId, string quoteName, string documentId, string documentName, string objectName)
    {
        List<SignersRequest> signersData = (list<SignersRequest>)JSON.deserialize(requestString, List<SignersRequest>.class);
        Map<string,string> result = fillandSubmit(signersData, quoteId, quoteName, documentId, documentName, objectName);
    	
        /*
        string resultStatus = result.get('status');
        if(resultStatus == 'error')
        {
            resultStatus = result.get('result');
        }*/
        
        return result;
    }
    
    public static Map<string,string> fillandSubmit(List<SignersRequest> signersData, string quoteId, string quoteName, string documentId, string documentName, string objectName)
    {
        Map<string,string> result = new Map<string,string>();
        if(signersData.size() > 0)
        {
            authentisign__Setting__c setting = Utility.getSetting();
            
            Map<string,string> requestParams = new Map<string,string>();
            
            string requestMethod = '/api/v2/signings/fill-and-send-documents';
            string finalEndpoint = setting.authentisign__Endpoint__c + requestMethod;
            
            requestParams.put('url', finalEndpoint);
            requestParams.put('externalId', setting.authentisign__Account_Id__c);
            requestParams.put('token', setting.authentisign__Bearer_Token__c);
            requestParams.put('objectName', objectName);
            requestParams.put('documentId', documentId);
            requestParams.put('documentName', documentName);
            requestParams.put('quoteName', quoteName);
            
            System.debug('requestParams: '+requestParams);

            string submitResponse = Utility.submitDocumentRequest(signersData, requestParams);
            string documentSigningId = '';
            if(!(submitResponse == null || submitResponse == ''))
            {
                Map<string,object> resultMap = (Map<string,object>)JSON.deserializeUntyped(submitResponse);
                documentSigningId = (string)resultMap.get('id');
                System.debug('signingId: '+ documentSigningId);
                if(documentSigningId != null)
                {
                    result.put('status','success');
                    result.put('result',documentSigningId);
                    
                    SObject qt = Schema.getGlobalDescribe().get(objectName).newSObject();
                    
                    qt.put('Id',quoteId);
                    qt.put('authentisign__Document_Signing_Id__c',documentSigningId);
                    qt.put('authentisign__Document_Id__c',documentId);
                    qt.put('authentisign__Authsign_Document_Status__c', 'sent');
                    
                    update qt;
                    
                    //Added 2 seconds delay
                    datetime start = System.Now();
                    while(System.Now() < start.addSeconds(2));
                    
                    System.enqueueJob(new QueueSavingAttachment(quoteId, documentSigningId, objectName, true));
                    
                }else{
                    result.put('status','error');
                    result.put('result', 'error: '+(string)resultMap.get('message') + (resultMap.get('details') ==null ? '' : ': '+ string.valueOf(resultMap.get('details')).replace(')','').replace('(','')));
                }
            }else{
                result.put('status','error');
                result.put('result', 'error: some unknown error occurred');
            }
        }else{
            result.put('status','error');
            result.put('result', 'error: no signers');
        }
        System.debug('result: '+ result);
        
        return result;
    }
}