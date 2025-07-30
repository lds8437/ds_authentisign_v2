public with sharing class AuthentiSignMappingHelper {

    //Get Mapping Initial Data
    public static RecordsFields getAllData(string recordId, string objectName)
    {
        string quoteLineItem = '';
        string quoteIdinLineItem = '';
        if(objectName.toLowerCase() == 'quote')
        {
            quoteLineItem = 'QuoteLineItem';
            quoteIdinLineItem = 'QuoteId';
        }
        else if(objectName.toLowerCase() == 'sbqq__quote__c'){
            quoteLineItem = 'SBQQ__QuoteLine__c';
            quoteIdinLineItem = 'SBQQ__Quote__c';
        }
        
        RecordsFields wrapper = new RecordsFields();
        
        //Quote
        SObjectFieldPackage QuoteAllInfo =  Utility.getSObjectFields(objectName,'where Id = \''+recordId+'\' ','','');
        List<SObject> QuoteRecords = Database.query(QuoteAllInfo.Query);
        
        if(QuoteRecords.size()> 0)
        {
            wrapper.quote = QuoteRecords[0];
        }
        wrapper.quoteFieldProps = QuoteAllInfo.SObjectFieldsProperties;
        wrapper.participientFields = QuoteAllInfo.ParticipientList;
        wrapper.usercontactfieldmap = QuoteAllInfo.UserContactFieldMap;
        
        //Quote Line Items
        SObjectFieldPackage QuoteLineItemAllInfo = Utility.getSObjectFields(quoteLineItem,'where '+quoteIdinLineItem+' = \''+recordId+'\' ','','');
        List<SObject> QuoteLineItemRecords = Database.query(QuoteLineItemAllInfo.Query);
        
        if(QuoteLineItemRecords.size()> 0)
        {
            wrapper.quoteLineItems = QuoteLineItemRecords;
        }
        wrapper.quoteLineItemFieldProps = QuoteLineItemAllInfo.SObjectFieldsProperties;

        return wrapper;
    }
    
    public static string fillandSubmit(string requestString, string quoteId, string layoutId, string mappings, string objectName)
    {
        Map<string,string> submitResponse = new Map<string,string>();
        System.debug('requestString: '+requestString);
        System.debug('quoteId: '+quoteId);
        System.debug('layoutId: '+layoutId);
        System.debug('mappings: '+mappings);
        System.debug('objectName: '+objectName);
        
        string signingId = '';
        
        authentisign__Setting__c setting = Utility.getSetting();
        
        if(setting != null)
        {
            string requestBody = requestString.replace('##callbackurl##', setting.authentisign__Callback_Url__c);
            
            System.debug('requestBody: '+ requestBody);
            
            string token = setting.authentisign__Bearer_Token__c; //'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIyODNDRjIyNC0zRkJBLTQ1OUItQTdCMy0wOTk1OEUyMEY0MTciLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI0MEQxNEM3QS1GNjExLUVFMTEtQTlCQi0wMDBEM0ExMzZBQTciLCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJhdWQiOiJhdXRoZW50aXNpZ25fZXh0ZXJuYWwiLCJpc3MiOiJhdXRoZW50aXNpZ24iLCJleHAiOjE3MTYyMzkwMjIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3N5c3RlbSI6IkV4dGVybmFsIn0.TLKQR-WYnHYkf6nq2pxa2pb8m4rpU5hPf7vvgmi32M4';
            string ASAccountId = setting.authentisign__Account_Id__c;// '66767a4f-329b-4acb-89ad-5f7bb31af7fd';
            
            Map<string,string> headers = new Map<string,string>();
            
            //set final endpoint
            string requestMethod = '/api/v1/signings/fill-and-send';
            string endpoint = setting.authentisign__Endpoint__c + requestMethod;
            
            System.debug('endpoint: '+ endpoint);
            
            //set headers
            headers.put('Authorization','Bearer '+token);
            headers.put('Content-Type','application/json');
            headers.put('externalId',ASAccountId);
            
            System.debug('headers: '+ headers);
            
            string responseBody = Utility.sendHttpRequest('POST',endpoint, headers, token, requestBody);
            
            System.debug('responseBody: '+responseBody);
            SigningResponse sResponse = new SigningResponse();
            
            //if(!(responseBody == '' || responseBody == null))
            {
                try
                {
                    sResponse = (SigningResponse)JSON.deserialize(responseBody, SigningResponse.class);
                }
                catch(Exception ex)
                {
                    
                }
                
                System.debug('SigningId: '+sResponse.id);
                
                authentisign__Record_Signing__c record = new authentisign__Record_Signing__c();
                
                string attachmentId = '';
                if(sResponse.id != null)
                {
                    record.authentisign__Signing_Id__c = sResponse.id;
                    signingId = sResponse.id;
                    
                    submitResponse.put('signingId', signingId);
                }
                
                record.authentisign__Signing_Request__c = requestBody;
                record.authentisign__Signing_Response__c = responseBody;
                record.authentisign__Layout_Id__c = LayoutId;
                if(objectName.toLowerCase() == 'quote')
                {
                    record.Type__c = 'Standard';
                    record.authentisign__Quote_Id__c = quoteId;
                }
                else{
                    record.Type__c = 'CPQ';
                    record.authentisign__Quote_Id_CPQ__c = quoteId;
                }
                insert record;
                
                authentisign__Layout_Mapping__c layout = new authentisign__Layout_Mapping__c();
                layout.authentisign__Layout_Id__c = layoutId;
                layout.authentisign__Mapping__c = mappings;
                layout.authentisign__Object__c = objectName;
                layout.authentisign__Unique_Id__c = LayoutId + objectName.toLowerCase();
                Database.upsert(layout, authentisign__Layout_Mapping__c.authentisign__Unique_Id__c);
                
                if(signingId != '')
                {
                    SObject qt = Schema.getGlobalDescribe().get(objectName).newSObject();
                    
                    qt.put('Id',quoteId);
                    qt.put('authentisign__Signing_Id__c',signingId);
                    qt.put('authentisign__Layout_Id__c',LayoutId);
                    qt.put('authentisign__Authsign_Status__c','sent');
                    update qt;

                    //Added 2 seconds delay
                    datetime start = System.Now();
                    while(System.Now() < start.addSeconds(2));
                    
                    System.enqueueJob(new QueueSavingAttachment(quoteId, signingId, objectName, false));
                }
            }
        }
        
        //submitResponse
        return signingId;
    }
}