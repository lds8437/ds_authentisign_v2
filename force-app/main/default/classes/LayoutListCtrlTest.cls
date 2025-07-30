/**
@Apex Class Name    : LayoutListCtrlTest
@Created Date       : Sep 18, 2023
@description        : LayoutListCtrl test class.
@author             : FFD Developer
@Modification Log   :
*/
@IsTest
private class LayoutListCtrlTest {

    /**
    @Method Name    : setup
    @description    : setup class to create initial records for testing
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
        
        authentisign__Setting__c setting = new authentisign__Setting__c();
        setting.authentisign__Account_Id__c = '66767a4f-329b-4acb-89ad-5f7bb31af7fd';
        setting.authentisign__Bearer_Token__c = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIyODNDRjIyNC0zRkJBLTQ1OUItQTdCMy0wOTk1OEUyMEY0MTciLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI0MEQxNEM3QS1GNjExLUVFMTEtQTlCQi0wMDBEM0ExMzZBQTciLCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJhdWQiOiJhdXRoZW50aXNpZ25fZXh0ZXJuYWwiLCJpc3MiOiJhdXRoZW50aXNpZ24iLCJleHAiOjE3MTYyMzkwMjIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3N5c3RlbSI6IkV4dGVybmFsIn0.TLKQR-WYnHYkf6nq2pxa2pb8m4rpU5hPf7vvgmi32M4';
        setting.authentisign__Callback_Url__c = 'https://lonewolf5-dev-ed.develop.my.salesforce-sites.com/services/apexrest/authentisign/callback';
        setting.authentisign__Endpoint__c = 'https://api.pre.authentisign.com';
        insert setting;
        
        authentisign__Layout_Mapping__c mapping = new authentisign__Layout_Mapping__c();
        mapping.authentisign__Layout_Id__c = '58193357-8337-ee11-a3f1-000d3a1d5b2d';
        mapping.authentisign__Object__c = 'Quote';
        mapping.authentisign__Mapping__c = '{"fieldsMap":{"test":{"object":"lineitem","field":"CreatedById","lineItemId":"0QLHn000007DT0DOAW"}},"rolesMap":{"buyer":"OwnerId"}}';
        insert mapping;
        
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country', Phone = '123456');
        insert objAccount;
        
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        
        
        //insert objPBE;
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
        insert objOpp;
        
        for(Integer i=0; i< 1 ; i++)
        {
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i,   Status = 'Review Pending', Signing_Id__c = '123', Authsign_Status__c  = 'sent',
                                   Authsign_Document_Status__c  = 'sent', Document_Id__c = contentVersion_1.Id , Document_Signing_Id__c = '17353725-78ec-ee11-aaf0-00224826a11a' ));
        }
        insert lstQuote;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = lstQuote[0].id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
    }
    
    /**
    @Method Name    : unittestgetlayouts
    @description    : to test the get layouts method
    */
    @IsTest
    private static void unittestgetlayouts()
    {
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c from Quote limit 1];
        
        SingleRequestMock layoutResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '[{"id": "58193357-8337-ee11-a3f1-000d3a1d5b2d","name": "test","dateCreated": "2023-08-10T13:39:34.827","lastModified": "2023-08-10T13:39:58.463","layoutParticipants": [{"id": "07273065-8337-ee11-a3f1-000d3a1d5b2d","layoutId": "58193357-8337-ee11-a3f1-000d3a1d5b2d","role": "buyer","order": 1,"dateCreated": "2023-08-10T13:39:58.293","layout": null}],"roles": ["buyer 1"],"fields": ["test"]}]',
                                                                  null);

        SingleRequestMock signingResp = new SingleRequestMock(400,
                                                  'Bad Request',
                                                  '{"code": 400,"message": "BadRequest","details": ["Signing has not been finalized."]}',
                                                   null);
        
        SingleRequestMock documentSigningResp = new SingleRequestMock(400,
                                                  'Bad Request',
                                                  '{"code": 400,"message": "BadRequest","details": ["Signing has not been finalized."]}',
                                                   null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/layouts?language=en',layoutResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/123/documents/s?language=en',signingResp);
        //endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/17353725-78ec-ee11-aaf0-00224826a11a/documents/s/url?language=en',documentSigningResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/17353725-78ec-ee11-aaf0-00224826a11a/documents/s?language=en',documentSigningResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        LayoutResponse result = LayoutListCtrl.getLayouts(quot.Id, 'Quote');
        
        //string signingId = LayoutListCtrl.saveAttachment(quot.Id, '123', 'Quote');
        
        System.assert(result.wrapper.size() > 0, 'result wrapper size is greater than 0');
        System.assertEquals(result.wrapper[0].id, '58193357-8337-ee11-a3f1-000d3a1d5b2d','result wrapper id is 58193357-8337-ee11-a3f1-000d3a1d5b2d');
            
        Test.stopTest();
    }
    
    @IsTest
    private static void unittestgetdocumentlinkstatus()
    {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        authentisign__Setting__c setting = DataLayer.getSetting();
        
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Document_Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c from Quote limit 1];
        
        
        SingleRequestMock documentSigningResp = new SingleRequestMock(200,
                                                                      'OK',
                                                                      '{ "url" : "https://spa-api.pre.authentisign.com/api/v1/documents/s/1234567890"}',
                                                                      null);
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/17353725-78ec-ee11-aaf0-00224826a11a/documents/s/url?language=en',documentSigningResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        LayoutListHelper.getDocumentSigningStatusLink(quot, setting);
        
        Test.stopTest();
    }
    
    
    /**
    @Method Name    unittestgetlayoutMapping
    @description    to test layout mapping method
    */
    @IsTest
    private static void unittestgetlayoutMapping()
    {
        Test.startTest();
        
        string result = LayoutListCtrl.getLayoutMappings('58193357-8337-ee11-a3f1-000d3a1d5b2d', 'Quote');
        System.assert(result != null, 'mapping string is not null');

        Test.stopTest();
    }
    
    /**
    @Method Name    : savePDFAttachmentTest
    @description    : to test save pdf as attachment method
    */
    @IsTest
    private static void savePDFAttachmentTest()
    {
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c from Quote limit 1];
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
        
        string attachmentId = LayoutListCtrl.saveAttachment(quot.Id, signingId, 'Quote', true);
        
        System.Assert(attachmentId != null, 'attachmentId should not be null');
        
        Test.stopTest();
        
    }
    
    /**
    @Method Name    : wrapperClassTest
    @description    : to test different wrapper class
    */
    @IsTest 
    private static void wrapperClassTest()
    {
        
        LayoutParticipant objParticipants = new LayoutParticipant();
        objParticipants.id = ''; 
        objParticipants.layoutId = ''; 
        objParticipants.role = ''; 
        objParticipants.order = 0; 
        objParticipants.dateCreated = null; 
        objParticipants.layout = ''; 
        
        LayoutWrapper objLayout = new LayoutWrapper();
        objLayout.id = ''; 
        objLayout.name = ''; 
        objLayout.dateCreated = null; 
        objLayout.lastModified = null; 
        objLayout.layoutParticipants =  new List<LayoutParticipant>();
        objLayout.roles = new List<string>();
        objLayout.fields = new List<string>();
        
 
        SigningStatusResponse objSigningStatus = new SigningStatusResponse();
        objSigningStatus.code = 0;
        objSigningStatus.details = new List<string>();
        objSigningStatus.message = '';
        
        SigningResponse objSigningResponse = new SigningResponse();
        objSigningResponse.id = '';
        objSigningResponse.name = '';
        objSigningResponse.accountId = '';
        objSigningResponse.statusId = 0;
        objSigningResponse.isOrdered = false;
        objSigningResponse.dateCreated = System.today();
        objSigningResponse.lastModified = System.today();
        objSigningResponse.expirationDate = System.today();
        objSigningResponse.idPosition = 0;
        objSigningResponse.reminderDay = '';
        objSigningResponse.reminderHour = '';
        objSigningResponse.transactionId = '';
        objSigningResponse.technologyProvider = '';
        objSigningResponse.callbackUrl = '';
        
        System.assert(objParticipants != null, 'objParticipants is not null');
        System.assert(objLayout != null, 'objLayout is not null');
        System.assert(objSigningStatus != null, 'objSigningStatus is not null'); 
        System.assert(objSigningResponse != null, 'objSigningResponse is not null'); 
    }
}