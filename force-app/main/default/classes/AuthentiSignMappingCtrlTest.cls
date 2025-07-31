/*
*********************************************************
@Apex Class Name    : AuthentiSignMappingCtrlTest
@Created Date       : Jan 30, 2024
@description        : AuthentiSignMappingCtrl test class.
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
@IsTest
private class AuthentiSignMappingCtrlTest {

    /*
    *********************************************************
    @Method Name    : setup
    @description    : setup class to create initial records for testing
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @testsetup static void setup()
    {
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        Setting__c setting = new Setting__c();
        setting.Account_Id__c = '66767a4f-329b-4acb-89ad-5f7bb31af7fd';
        setting.Bearer_Token__c = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIyODNDRjIyNC0zRkJBLTQ1OUItQTdCMy0wOTk1OEUyMEY0MTciLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI0MEQxNEM3QS1GNjExLUVFMTEtQTlCQi0wMDBEM0ExMzZBQTciLCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJhdWQiOiJhdXRoZW50aXNpZ25fZXh0ZXJuYWwiLCJpc3MiOiJhdXRoZW50aXNpZ24iLCJleHAiOjE3MTYyMzkwMjIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3N5c3RlbSI6IkV4dGVybmFsIn0.TLKQR-WYnHYkf6nq2pxa2pb8m4rpU5hPf7vvgmi32M4';
        setting.Callback_Url__c = 'https://lonewolf5-dev-ed.develop.my.salesforce-sites.com/services/apexrest/authentisign/callback';
        setting.Endpoint__c = 'https://api.pre.authentisign.com';
        insert setting;
        
        List<Quote> lstQuote = new List<Quote>();

        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                                                    BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                                                    BillingCountry = 'Test Country', Phone = '123456');
        insert objAccount;
        
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        insert objProduct;
       
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
        insert objOpp;
        
        for(Integer i=0; i< 1 ; i++)
		{
			lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i,   Status = 'Review Pending', Signing_Id__c = '123', Authsign_Status__c  = 'sent'));
		}
        insert lstQuote;
    }
    
    /*
    *********************************************************
    @Method Name    : getAllDataTest
    @description    : test class for AuthentiSignMappingCtrl class getAllData method
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void getAllDataTest()
    {
        
        Quote quot = [Select Id,Name, Layout_Id__c, Signing_Id__c, Authsign_Status__c, AttachmentId__c from Quote limit 1];
        
        Test.startTest();
        
        RecordsFields obj = AuthentiSignMappingCtrl.getAllData(quot.Id, 'Quote');
        
        System.assert(obj.participientFields.size() >0);
        System.assert(obj.quoteFieldProps.size() >0);
        System.assert(obj.quoteLineItemFieldProps.size() >0);
        System.assert(obj.usercontactfieldmap.size() >0);
        
        Test.stopTest();
    }

    /*
    *********************************************************
    @Method Name    : fillandsubmitTest
    @description    : test class for AuthentiSignMappingCtrl class fillandSubmit method
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void fillandsubmitTest()
    {
        Quote quot = [Select Id,Name, Layout_Id__c, Signing_Id__c, Authsign_Status__c, AttachmentId__c from Quote limit 1];
        
        string requestString = '{"name":"Test Quote 1","isOrdered":false,"expirationDate":"2023-08-31T00:00:00.000Z","callbackUrl":"https://frozenfishdevelopment--ffd.sandbox.my.site.com/portal/services/apexrest/callback","layoutId":"e1e1aa76-5f32-ee11-a3f1-000d3a1d5b2d","fields":{"Product":"0Q0DC000000AUY30AO","AgentNumber":"005Dn000007gsa9IAA","Test Field 1":"Aamir Hussain"},"participants":[{"firstname":"Aamir","middlename":"","lastname":"Hussain","email":"aamir@frozenfishdev.com","type":0,"participantRole":"buyer","staticSignatureEnabled":true,"scriptedSignatureEnabled":true,"imageSignatureEnabled":true},{"firstname":"Jarrett","middlename":"","lastname":"Fisher","email":"jarrett@frozenfishdev.com","type":0,"participantRole":"Seller","staticSignatureEnabled":true,"scriptedSignatureEnabled":true,"imageSignatureEnabled":true}]}';
        string layoutId = 'e1e1aa76-5f32-ee11-a3f1-000d3a1d5b2d';
            
        SingleRequestMock fillSubmitResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '{"id":"eecaf271-3040-ee11-a3f1-000d3a1d5b2d","name":"Test Quote 1","accountId":"7a971144-5f32-ee11-a3f1-000d3a1d5b2d","statusId":0,"isOrdered":false,"dateCreated":"2023-08-21T14:38:51.94","lastModified":"2023-08-21T14:38:51.94","expirationDate":"2023-08-31T00:00:00Z","idPosition":0,"reminderDay":null,"reminderHour":null,"transactionId":null,"technologyProvider":null,"callbackUrl":"https://frozenfishdevelopment--ffd.sandbox.my.site.com/portal/services/apexrest/callback"}',
                                                                  null);
 
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/fill-and-send',fillSubmitResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        string SigningId = AuthentiSignMappingCtrl.FillandSubmit(requestString, quot.Id, LayoutId, '', 'Quote');
         
        System.Assert(SigningId != null);
        System.debug('SigningId test: '+ SigningId);
        System.assertEquals(SigningId,  'eecaf271-3040-ee11-a3f1-000d3a1d5b2d');
        
        Test.stopTest();
        
    }
    
    /*
    *********************************************************
    @Method Name    : fillandsubmitDocumentTest
    @description    : test class for AuthentiSignMappingCtrl class submitDocumentRequest method
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void fillandsubmitDocumentTest()
    {
        Quote quot = [Select Id,Name, Layout_Id__c, Signing_Id__c, Authsign_Status__c, AttachmentId__c from Quote limit 1];
        
        ContentVersion content = [Select Id,Title from ContentVersion limit 1];
        
        string requestString = '[{"data":{"Name":"Jarrett Fisher","FirstName":"Jarrett","LastName":"Fisher","Email":"ffdall@frozenfishdev.com","Id":"005Hn00000IAVTQIA5","Type":"User","Role":"buyer 1"}}]';
        string documentSigningId = 'e1e1aa76-5f32-ee11-a3f1-000d3a1d5b2d';
            
        SingleRequestMock fillSubmitResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '{"id":"eecaf271-3040-ee11-a3f1-000d3a1d5b2d","name":"Test Quote 1","accountId":"7a971144-5f32-ee11-a3f1-000d3a1d5b2d","statusId":0,"isOrdered":false,"dateCreated":"2023-08-21T14:38:51.94","lastModified":"2023-08-21T14:38:51.94","expirationDate":"2023-08-31T00:00:00Z","idPosition":0,"reminderDay":null,"reminderHour":null,"transactionId":null,"technologyProvider":null,"callbackUrl":"https://frozenfishdevelopment--ffd.sandbox.my.site.com/portal/services/apexrest/callback"}',
                                                                  null);
 
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v2/signings/fill-and-send-documents',fillSubmitResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        Map<string,string> documentSigningIdResponseMap = AuthentiSignMappingCtrl.submitDocumentRequest(requestString, quot.Id, quot.Name, content.Id , content.Title, 'Quote');
         
        System.Assert(documentSigningIdResponseMap != null);
        System.debug('SigningId test: '+ documentSigningIdResponseMap);
        System.assertEquals(documentSigningIdResponseMap.get('status'),  'success');
        
        Test.stopTest();
        
    }
    
    /*
    *********************************************************
    @Method Name    : getAllDataTest
    @description    : test class for AuthentiSignMappingCtrl class savePDFAttachment method
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void savePDFAttachmentTest()
    {
        Quote quot = [Select Id,Name, Layout_Id__c, Signing_Id__c, Authsign_Status__c, AttachmentId__c from Quote limit 1];
        string signingId = 'e1e1aa76-5f32-ee11-a3f1-000d3a1d5b2d';
            
        Map<string,string> headers = new Map<string,string>();
        headers.put('Content-Disposition','inline; filename=123.pdf');
        
        SingleRequestMock pdfResponse = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '123456789',
                                                                  headers);
 
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/e1e1aa76-5f32-ee11-a3f1-000d3a1d5b2d/documents/ls?language=en',pdfResponse);
       
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        string AttachmentId = AuthentiSignMappingCtrl.savePDFasAttachment(quot.Id, signingId, 'Quote');
        
        System.Assert(AttachmentId != null);
        
        Test.stopTest();
        
    }
}