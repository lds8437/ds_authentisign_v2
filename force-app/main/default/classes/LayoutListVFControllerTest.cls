@Istest
private class LayoutListVFControllerTest {

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

        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country', Phone = '123456');
        insert objAccount;
        
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        
        
        insert objPBE;
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
        insert objOpp;
        
        
        for(Integer i=0; i< 1 ; i++)
        {
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, ExpirationDate=System.today(), Name = 'Test Quote' + i,   Status = 'Review Pending', Signing_Id__c = '123', Authsign_Status__c  = 'sent', Pricebook2Id =  Test.getStandardPricebookId()  ));
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, ExpirationDate=System.today(), Name = 'Test Quote' + i,   Status = 'Review Pending',   Pricebook2Id =  Test.getStandardPricebookId(), Document_Id__c = contentVersion_1.Id , Document_Signing_Id__c = '17353725-78ec-ee11-aaf0-00224826a11a' ));
        }
        insert lstQuote;
        
        QuoteLineItem item = new QuoteLineItem();
        item.QuoteId = lstQuote[0].Id;
        item.PricebookEntryId = objPBE.Id;
        item.Quantity = 10;
        item.UnitPrice  = 100;
        insert item;
        
        authentisign__Layout_Mapping__c mapping = new authentisign__Layout_Mapping__c();
        mapping.authentisign__Layout_Id__c = '58193357-8337-ee11-a3f1-000d3a1d5b2d';
        mapping.authentisign__Object__c = 'Quote';
        mapping.authentisign__Mapping__c = '{"rolesMap":{"Seller":null,"buyer":"OwnerId"},"fieldsMap":{"Test Field 1":{"lineItemId":"'+item.Id+'","object":"lineitem","field":"CreatedById"},"AgentNumber":{"lineItemId":"'+item.Id+'","object":"lineitem","field":"CreatedById"},"Product":{"object":"quote","field":"Id"}}}';
        mapping.authentisign__Unique_Id__c = '58193357-8337-ee11-a3f1-000d3a1d5b2dQuote';
        insert mapping;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = lstQuote[0].id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
    }
    
     
	@IsTest
    private static void unittestgetlayouts()
    {
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c from Quote where Signing_Id__c != null  limit 1];
        
        SingleRequestMock layoutResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '[{"id": "58193357-8337-ee11-a3f1-000d3a1d5b2d","name": "test","dateCreated": "2023-08-10T13:39:34.827","lastModified": "2023-08-10T13:39:58.463","layoutParticipants": [{"id": "07273065-8337-ee11-a3f1-000d3a1d5b2d","layoutId": "58193357-8337-ee11-a3f1-000d3a1d5b2d","role": "buyer","order": 1,"dateCreated": "2023-08-10T13:39:58.293","layout": null}],"roles": ["buyer 1"],"fields": ["test"]}]',
                                                                  null);

        SingleRequestMock SigningResp = new SingleRequestMock(400,
                                                  'Bad Request',
                                                  '{"code": 400,"message": "BadRequest","details": ["Signing has not been finalized."]}',
                                                   null);
        
        SingleRequestMock documentSigningResp = new SingleRequestMock(200,
                                                  'OK',
                                                  '{ "url" : "https://spa-api.pre.authentisign.com/api/v1/documents/s/1234567890"}',
                                                   null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/layouts?language=en',layoutResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/123/documents/s?language=en',SigningResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/17353725-78ec-ee11-aaf0-00224826a11a/documents/s/url?language=en',documentSigningResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',String.valueOf(quot.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);
        
        LayoutListVFController theController = new LayoutListVFController(sc);
        theController.selectedLayout = '58193357-8337-ee11-a3f1-000d3a1d5b2d';
        theController.GotoMappings();
        
        Test.stopTest();
    }
    
    @IsTest
    private static void unittestsigers()
    {
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c  from Quote where Document_Signing_Id__c != null limit 1];
        
        ContentVersion content = [Select Id,Title from ContentVersion limit 1];

        
        SingleRequestMock layoutResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '[{"id": "58193357-8337-ee11-a3f1-000d3a1d5b2d","name": "test","dateCreated": "2023-08-10T13:39:34.827","lastModified": "2023-08-10T13:39:58.463","layoutParticipants": [{"id": "07273065-8337-ee11-a3f1-000d3a1d5b2d","layoutId": "58193357-8337-ee11-a3f1-000d3a1d5b2d","role": "buyer","order": 1,"dateCreated": "2023-08-10T13:39:58.293","layout": null}],"roles": ["buyer 1"],"fields": ["test"]}]',
                                                                  null);

        SingleRequestMock SigningResp = new SingleRequestMock(400,
                                                  'Bad Request',
                                                  '{"code": 400,"message": "BadRequest","details": ["Signing has not been finalized."]}',
                                                   null);
        
        SingleRequestMock documentSigningResp = new SingleRequestMock(200,
                                                  'OK',
                                                  '{ "url" : "https://spa-api.pre.authentisign.com/api/v1/documents/s/1234567890"}',
                                                   null);
        
        SingleRequestMock fillSubmitResp = new SingleRequestMock(200,
                                                                 'Complete',
                                                                 '{"id":"eecaf271-3040-ee11-a3f1-000d3a1d5b2d","name":"Test Quote 1","accountId":"7a971144-5f32-ee11-a3f1-000d3a1d5b2d","statusId":0,"isOrdered":false,"dateCreated":"2023-08-21T14:38:51.94","lastModified":"2023-08-21T14:38:51.94","expirationDate":"2023-08-31T00:00:00Z","idPosition":0,"reminderDay":null,"reminderHour":null,"transactionId":null,"technologyProvider":null,"callbackUrl":"https://frozenfishdevelopment--ffd.sandbox.my.site.com/portal/services/apexrest/callback"}',
                                                                 null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
 
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/layouts?language=en',layoutResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/123/documents/s?language=en',SigningResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/17353725-78ec-ee11-aaf0-00224826a11a/documents/s/url?language=en',documentSigningResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v2/signings/fill-and-send-documents',fillSubmitResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',String.valueOf(quot.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);
        
        LayoutListVFController theController = new LayoutListVFController(sc);
        theController.selectedLayout = '58193357-8337-ee11-a3f1-000d3a1d5b2d';
        theController.GotoSignersLayout();
        theController.AddSigners();
        Apexpages.currentPage().getParameters().put('rowIndex','0');
        theController.DeleteSigner();
        
        
        theController.selectedDocument = content.Id;
        theController.participantMappingValues = new List<ParticipantMappingValue>();
        ParticipantMappingValue record = new ParticipantMappingValue();
        record.email = 'test@test.com';
        record.firstname = 'test';
        record.lastname = 'test';
        record.index = 0;
        record.role = 'buyer 1';
        theController.participantMappingValues.add(record);
        theController.submitSigners(); 
        
        Test.stopTest();
    }
    
    @IsTest
    private static void unittestsubmitrequest()
    {
        Quote quot = [Select Id,Name, authentisign__Layout_Id__c, authentisign__Signing_Id__c, authentisign__Authsign_Status__c, authentisign__AttachmentId__c from Quote limit 1];
        
        /*
        SingleRequestMock layoutResp = new SingleRequestMock(200,
                                                                  'Complete',
                                                                  '[{"id": "58193357-8337-ee11-a3f1-000d3a1d5b2d","name": "test","dateCreated": "2023-08-10T13:39:34.827","lastModified": "2023-08-10T13:39:58.463","layoutParticipants": [{"id": "07273065-8337-ee11-a3f1-000d3a1d5b2d","layoutId": "58193357-8337-ee11-a3f1-000d3a1d5b2d","role": "buyer","order": 1,"dateCreated": "2023-08-10T13:39:58.293","layout": null}],"roles": ["buyer 1"],"fields": ["test"]}]',
                                                                  null);

        SingleRequestMock SigningResp = new SingleRequestMock(400,
                                                  'Bad Request',
                                                  '{"code": 400,"message": "BadRequest","details": ["Signing has not been finalized."]}',
                                                   null);
		*/
        
        SingleRequestMock SigningResp = new SingleRequestMock(200,
                                                              'Complete',
                                                              '{"id":"b9e5703e-e4b3-ee11-bea1-00224826a9d3","name":"Test Quote Lonewolf 3","accountId":"7a971144-5f32-ee11-a3f1-000d3a1d5b2d","statusId":0,"isOrdered":false,"dateCreated":"2024-01-15T20:25:38.653","lastModified":"2024-01-15T20:25:38.653","expirationDate":"2023-09-30T00:00:00Z","idPosition":0,"reminderDay":null,"reminderHour":null,"transactionId":null,"technologyProvider":null,"callbackUrl":"https://lonewolf5-dev-ed.develop.my.salesforce-sites.com/services/apexrest/authentisign/callback"}',
                                                              null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        
        //endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/layouts?language=en',layoutResp);
        endpoint2TestResp.put('https://api.pre.authentisign.com/api/v1/signings/fill-and-send',SigningResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',String.valueOf(quot.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);
        
        LayoutListVFController theController = new LayoutListVFController();
        theController.selectedLayout = '58193357-8337-ee11-a3f1-000d3a1d5b2d';
        
        string strMappingValues = '[{"Value":"Test Account","ObjectName":"quote","LineItemIndex":"","LineItemId":"","IsLineItem":false,"Field":"Account","ASFieldName":"Product"},{"Value":"001Hn00001wn5VdIAI","ObjectName":"quote","LineItemIndex":"","LineItemId":"","IsLineItem":false,"Field":"AccountId","ASFieldName":"AgentNumber"},{"Value":"Jarrett Fisher","ObjectName":"lineitem","LineItemIndex":"0","LineItemId":"0QLHn000007DT0DOAW","IsLineItem":true,"Field":"CreatedBy","ASFieldName":"Test Field 1"}]';
        theController.MappingValues = (List<FieldMappingValue>)JSON.deserialize(strMappingValues, List<FieldMappingValue>.class);
        
        string strParticipantValues = '[{"role":"buyer","objecttype":" User","name":"Jarrett Fisher","lookupid":"005Hn00000IAVTQIA5","lookupField":"OwnerId","lastname":"Fisher","firstname":"Jarrett","email":"ffdall@frozenfishdev.com"},{"role":"Seller","objecttype":"Contact","name":"","lookupid":"","lookupField":"ContactId","lastname":"","firstname":"","email":""}]';
        theController.ParticipantMappingValues  = (List<ParticipantMappingValue>)JSON.deserialize(strParticipantValues, List<ParticipantMappingValue>.class);
        
        theController.allMappingData = AuthentiSignMappingHelper.getAllData(quot.Id, 'Quote');
        theController.Submit();
        theController.BackToLayout();
        
        Test.stopTest();
    }
	 
}