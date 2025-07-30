/*
*********************************************************
@Apex Class Name    : LayoutListHelper
@Created Date       : Jan 30, 2024
@description        : Helper class for LayoutListCtrl class
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class Utility {
    
    /*
    *********************************************************
    @Method Name    : getSetting
    @description    : calls Data Layer class to get the setting record
    @param          : N/A
    @return         : authentisign__Setting__c 
    ********************************************************
    */
    public static authentisign__Setting__c getSetting()
    {
        return DataLayer.getSetting();
    }	
    
    /*
    *********************************************************
    @Method Name    : createQueryParams
    @description    : create query parameter for http request
    @param          : Map<string,string> params
    @return         : string  
    ********************************************************
    */
    public static string createQueryParams(Map<string,string> params)
    {
        string result = '';
        for(string key : params.keySet())
        {
            if(result == '')
            {
                result = key +'=' + params.get(key);
            }
            else{
                result += '&'+key +'=' + params.get(key);
            }
        }
        
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : sendHttpRequest
    @description    : send http request to authentisign and get the response
    @param          : string verb, string endpoint, map<string,string> headers, string token, string requestBody
    @return         : string (response return from authentisign) 
    ********************************************************
    */
    public static string sendHttpRequest(string verb, string endpoint, map<string,string> headers, string token, string requestBody)
    {
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        
        r.setEndpoint(endpoint);
        r.settimeout(120000); /*Revert back if taking too long. Change made on MAY 09 2025 Due to Layouts callout taking more than 10 sec*/
        
        String authorizationHeader = 'Bearer ' + token;
        
        if(headers != null && headers.size() > 0)
        {
            for(string key : headers.keySet())
            {
                r.setHeader(key, headers.get(key));
            }
        }
        r.setMethod(verb);
        
        if(!(requestBody == null || requestBody ==''))
        {
            r.setBody(requestBody);
        }
        
        System.debug('externalId: '+r.getHeader('externalId'));
        System.debug('Authorization: '+r.getHeader('Authorization'));
        
        HTTPResponse resp = h.send(r);
        String body = resp.getBody();
        System.debug('response body: '+ body);
        
        
        return body;
    }
    
    /*
    *********************************************************
    @Method Name    : sendHttpRequestBlob
    @description    : send http request to authentisign and get the pdf response
    @param          : string verb, string endpoint, map<string,string> headers, string token, string requestBody
    @return         : PDFResponse (wrapper class) 
    ********************************************************
    */
    public static PDFResponse sendHttpRequestBlob(string verb, string endpoint, map<string,string> headers, string token, string requestBody)
    {
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        
        r.setEndpoint(endpoint);
        
        String authorizationHeader = 'Bearer ' + token;
        
        if(headers != null && headers.size() > 0)
        {
            for(string key : headers.keySet())
            {
                r.setHeader(key, headers.get(key));
            }
        }
        r.setMethod(verb);
        
        if(!(requestBody == null || requestBody ==''))
        {
            r.setBody(requestBody);
        }
        
        System.debug('externalId: '+r.getHeader('externalId'));
        System.debug('Authorization: '+r.getHeader('Authorization'));
        
        HTTPResponse resp = h.send(r);
        
        blob blobBody = resp.getBodyAsBlob();
        System.debug('blobBody: '+blobBody);
        
        string stream = resp.getBody();
        // System.debug('stream: '+stream);
        
        PDFResponse finalResult = new PDFResponse();
        finalResult.pdfBlob = blobBody;
        finalResult.pdfStream = stream;
        
        finalResult.fileName = '';
        string contentDisposition = resp.getHeader('Content-Disposition');
        
        if(!(contentDisposition == null || contentDisposition == ''))
        {
            integer startIndex = contentDisposition.indexOf('filename=');
            if(startIndex >= 0)
            {
                finalResult.fileName = contentDisposition.substring(startIndex + 'filename='.length(), contentDisposition.length());    
                finalResult.fileName = EncodingUtil.urlDecode(finalResult.fileName,'UTF-8' );
            }
        }
        System.debug('fileName: '+ finalResult.fileName );
        
        return finalResult;
    }
    
    /*
    *********************************************************
    @Method Name    : getPDFResponse
    @description    : create the request and calls sendHttpRequestblob to get pdf response
    @param          : string token, string accountId, string baseurl, string signingId, string siningmethod
    @return         : PDFResponse (wrapper class) 
    ********************************************************
    */
    public static PDFResponse getPDFResponse(string token, string accountId, string baseurl, string signingId, string siningmethod)
    {        
        Map<string,string> params = new Map<string,string>();
        Map<string,string> headers = new Map<string,string>();
        
        //set params
        params.put('language','en');
        string queryParams = createQueryParams(params);
        
        
        //set final endpoint
        string requestMethod = '/api/v1/signings/'+signingId+'/documents/'+siningmethod;
        string endpoint = baseurl + requestMethod + '?'+queryParams;
        System.debug(endpoint);
        
         //set headers
        headers.put('Authorization','Bearer '+token);
        headers.put('Accept','*/*');
        headers.put('externalId',accountId);
        
        PDFResponse responseResult = sendHttpRequestblob('GET',endpoint, headers, token, '');
        
        return responseResult;
    }
    
    /*
    *********************************************************
    @Method Name    : getPDFLinkResponse
    @description    : create the request and calls sendHttpRequest to get pdf link response
    @param          : string token, string accountId, string baseurl, string signingId, string siningmethod
    @return         : PDFResponse (wrapper class) 
    ********************************************************
    */
    public static string getPDFLinkResponse(string token, string accountId, string baseurl, string signingId, string siningmethod)
    {        
        Map<string,string> params = new Map<string,string>();
        Map<string,string> headers = new Map<string,string>();
        
        //set params
        params.put('language','en');
        string queryParams = createQueryParams(params);
        
        
        //set final endpoint
        string requestMethod = '/api/v1/signings/'+signingId+'/documents/'+siningmethod;
        string endpoint = baseurl + requestMethod + '?'+queryParams;
        //System.debug(endpoint);
        
         //set headers
        headers.put('Authorization','Bearer '+token);
        headers.put('Accept','*/*');
        headers.put('externalId',accountId);
        
        string responseResult = sendHttpRequest('GET',endpoint, headers, token, '');
        
        return responseResult;
    }
    
    /*
    *********************************************************
    @Method Name    : savePDFasAttachment
    @description    : save the retrived pdf response as an attachment to requested record
    @param          : string quoteId, string signingId, string pdfmethod, string objectName
    @return         : string (Attachment Id) 
    ********************************************************
    */
    public static string savePDFasAttachment(string quoteId, string signingId, string pdfmethod, string objectName)
    {
        string attachmentId = '';
        System.debug('savePDFasAttachment: ');
        authentisign__Setting__c setting = getSetting();
        
        if(setting != null)
        {
            try{
                PDFResponse  pdfResponseObj = getPDFResponse(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c, signingId, pdfmethod);
                
                System.debug('pdfResponseObj: '+ pdfResponseObj.fileName);
                System.debug('pdfResponseObj: '+ pdfResponseObj);
                
                Attachment attach = new Attachment();
                attach.name = pdfResponseObj.fileName;
                attach.ParentId = quoteId;
                attach.body = pdfResponseObj.pdfBlob;
                attach.contenttype = 'application/pdf';
                insert attach;
                
                attachmentId = attach.Id;
                SObject qt = Schema.getGlobalDescribe().get(objectName).newSObject();
                qt.put('Id',quoteId);
                qt.put('authentisign__AttachmentId__c',attach.Id);
                update qt;
            }
            catch(Exception ex)
            {
                System.debug('error savePDFasAttachment: '+ ex.getMessage() +' , line: '+ex.getLineNumber());
                attachmentId  = '';
            }
        }
        
        return attachmentId;
    }
    
    /*
    *********************************************************
    @Method Name    : savePDFasAttachmentDocument
    @description    : save the retrived pdf response as an document attachment to requested record
    @param          : string quoteId, string signingId, string pdfmethod, string objectName
    @return         : string (Attachment Id) 
    ********************************************************
    */
    public static string savePDFasAttachmentDocument(string quoteId, string signingId, string pdfmethod, string objectName)
    {
        string attachmentId = '';
        
        authentisign__Setting__c setting = getSetting();
        
        if(setting != null)
        {
            try{
                PDFResponse  pdfResponseObj = getPDFResponse(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c, signingId, pdfmethod);
                
                Attachment attach = new Attachment();
                attach.name = pdfResponseObj.fileName;
                attach.ParentId = quoteId;
                attach.body = pdfResponseObj.pdfBlob;
                attach.contenttype = 'application/pdf';
                insert attach;
                
                attachmentId = attach.Id;
                SObject qt = Schema.getGlobalDescribe().get(objectName).newSObject();
                qt.put('Id',quoteId);
                qt.put('authentisign__Document_Attachment_Id__c',attach.Id);
                update qt;
            }
            catch(Exception ex)
            {
                //System.debug('error savePDFasAttachment: '+ ex.getMessage() +' , line: '+ex.getLineNumber());
                attachmentId  = '';
            }
        }
        
        return attachmentId;
    }
       
    /*
    *********************************************************
    @Method Name    : getSObjectFields
    @description    : get fields schema information for quote and quote line items 
    @param          : string objectName,string whereClause, string orderBy, string recordlimit
    @return         : SObjectFieldPackage (Fields information) 
    ********************************************************
    */
    public static SObjectFieldPackage getSObjectFields(string objectName,string whereClause, string orderBy, string recordlimit)
    {
        
        SObjectFieldPackage wrapper = new SObjectFieldPackage();
        
        //string objectName = 'Quote';
        Map<String, Schema.SObjectField> SOBjectFieldfMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        
        //SObject Describe Fields in the form of maps
        Map<string, Map<string, string>> FieldProperties = new Map<string, map<string, string>>();
        
        //List of SObject Fields to be used in dyanamic query
        List<string> SObjectQueryFieldsList = new List<string>();
        
        //List of Participents for Contact and User lookup Fields 
        Map<string,List<string>> Participients = new Map<string,List<string>>();
        
        //Field Api Name Map of User and Contact on Quote Field
        Map<string,string> UserContactFieldMap = new Map<string, string>();
        
        for(string key : SOBjectFieldfMap.keySet())
        {
            Schema.SObjectField field = SOBjectFieldfMap.get(key);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            map<string, string> fieldMap = new Map<string,string>();
            
            string fieldName = fieldDescribe.getName();
            if(fieldDescribe.isAccessible())
            {
                fieldMap.put('custom', string.valueOf(fieldDescribe.isCustom()) );
                fieldMap.put('label',string.valueOf(fieldDescribe.getLabel()));
                fieldMap.put('length',string.valueOf(fieldDescribe.getLength()));
                fieldMap.put('localName',string.valueOf(fieldDescribe.getLocalName()));
                fieldMap.put('name',string.valueOf(fieldName));
                
                string referenceTo = string.valueOf(fieldDescribe.getReferenceTo());
                fieldMap.put('referenceTo', referenceTo);
                
                fieldMap.put('type',string.valueOf(fieldDescribe.getType()));
                
                FieldProperties.put(fieldName,fieldMap);
                
                SObjectQueryFieldsList.add(fieldName);
                
                if(fieldDescribe.getReferenceTo().size() > 0)
                {
                    //System.debug('fieldName: '+ fieldName + ' referenceTo: '+ (fieldDescribe.getReferenceTo().size() == 0));
                    List<string> referenceFields = new List<string>();
                    string lookupFieldName = '';
                    if(fieldDescribe.isCustom() == true)
                    {
                        lookupFieldName = fieldName.replace('__c', '__r');
                    }
                    else{
                        lookupFieldName = fieldName.replace('Id', '').replace('id', '');
                    }
                    
                    if(lookupFieldName != '' )
                    {
                        if((referenceTo.toLowerCase().indexOf('contact') >= 0 || referenceTo.toLowerCase().indexOf('user') >= 0)  && !(key == 'createdbyid' || key == 'lastmodifiedbyid'))
                        {
                            //Add Id
                            referenceFields.add('Id');
                            
                            //Add Name
                            referenceFields.add('Name');
                            SObjectQueryFieldsList.add(lookupFieldName+'.Name');
                            
                            //Add First Name
                            referenceFields.add('FirstName');
                            SObjectQueryFieldsList.add(lookupFieldName+'.FirstName');
                            
                            //Add Last Name
                            referenceFields.add('LastName');
                            SObjectQueryFieldsList.add(lookupFieldName+'.LastName');
                            
                            //Add Email
                            referenceFields.add('Email');
                            SObjectQueryFieldsList.add(lookupFieldName+'.Email');
                            
                            //Add Phone
                            referenceFields.add('Phone');
                            SObjectQueryFieldsList.add(lookupFieldName+'.Phone');
                            
                            //Add Object
                            referenceFields.add(referenceTo);
                            
                            //Add Fax
                            //referenceFields.add(lookupFieldName+'.Fax');
                            //SObjectQueryFieldsList.add(lookupFieldName+'.Fax');
                            
                            Participients.put(lookupFieldName, referenceFields);
                            UserContactFieldMap.put(fieldName, lookupFieldName);
                        }
                        else{
                            
                            string referenceObjectName = string.valueOf(fieldDescribe.getReferenceTo()[0]);
                            //System.debug('referenceObjectName: '+referenceObjectName);
                            //check name field if exist in the reference object
                            boolean hasNameField = Schema.getGlobalDescribe().get(referenceObjectName.toLowerCase()).getDescribe().Fields.getMap().containsKey('Name');
                            
                            
                            //System.debug('hasNameField: '+hasNameField);
                            //System.debug('lookupFieldName: '+lookupFieldName+'.Name');
                            
                            Schema.SObjectField nameField = Schema.getGlobalDescribe().get(referenceObjectName.toLowerCase()).getDescribe().Fields.getMap().get('Name');
                            //System.debug('nameField: '+nameField);
                            Schema.DescribeFieldResult fieldDescribeRef = nameField.getDescribe();
                            //System.debug('fieldDescribeRef: '+fieldDescribeRef);
                            if(hasNameField)
                            {
                                //Add Name field for other lookup fields
                                SObjectQueryFieldsList.add(lookupFieldName+'.Name');    
                            }
                        }
                    }
                    
                }
            }
        }
        
        //System.debug('FieldProperties: '+ JSON.serialize(FieldProperties) );
        wrapper.SObjectFieldsProperties = FieldProperties;
        
        //System.debug('SObjectQueryFieldsList: '+ SObjectQueryFieldsList);
        wrapper.SObjectFieldsList = SObjectQueryFieldsList;
        
        string sObjectQuery = 'Select '+ string.join(SObjectQueryFieldsList, ',') + ' from ' + objectname + ' ' + whereClause + ' ' + orderBy +' '+ recordLimit;
        //System.debug('SObject Query: '+ sObjectQuery);
        wrapper.Query = sObjectQuery; 
        
        //System.debug('Participents: '+ Participients);
        wrapper.ParticipientList = Participients;
        
        //System.debug('UserContactFieldMap: '+ UserContactFieldMap);
        wrapper.UserContactFieldMap = UserContactFieldMap;
        
        return wrapper;
    }
     
    public static string submitDocumentRequest(List<SignersRequest> signers, map<string,string> requestParams)
    {
        string objectName = requestParams.get('objectName');
        string documentId = requestParams.get('documentId');
        string documentName = requestParams.get('documentName');
        string quoteName = requestParams.get('quoteName');
        string url = requestParams.get('url');
        string token = requestParams.get('token');
        string externalId = requestParams.get('externalId');
        string fileMimeType= 'application/pdf';
         
        System.debug('url: '+ url);
        System.debug('signers: '+ signers);
        
        blob fileBlob =  DataLayer.getDocumentById(documentId, objectName);
        string fileName = documentName+'.pdf';
        string contentType = vNHttpFormBuilder.GetContentType();
        
        //  Compose the form
        HttpHexFormBuilder builder = HttpHexFormBuilder.build()
            .writeParam( 'Name', quoteName +' - '+documentName);

        for(integer x=0;x<= signers.size() -1; x++)
        { 
            builder.writeParam( 'Participants['+string.valueOf(x)+'].ParticipantRole', signers[0].data.Role )
                .writeParam( 'Participants['+string.valueOf(x)+'].Email', signers[0].data.Email )
                .writeParam( 'Participants['+string.valueOf(x)+'].FirstName',  signers[0].data.FirstName )
                .writeParam( 'Participants['+string.valueOf(x)+'].LastName', signers[0].data.LastName )  
                .writeParam( 'Participants['+string.valueOf(x)+'].StaticSignatureEnabled', 'true')      
                .writeParam( 'Participants['+string.valueOf(x)+'].ScriptedSignatureEnabled', 'true')   
                .writeParam( 'Participants['+string.valueOf(x)+'].ImageSignatureEnabled', 'true');
        }
        
        builder.writeFile( 'Files', fileName, EncodingUtil.base64Encode(fileBlob));
        Blob formData  = builder.getFormAsBlob();
        
        /*
        HttpHexFormBuilder builder = HttpHexFormBuilder.build()
            .writeParam( 'Name', 'Q-00000-20240319-1638' );

        builder.writeParam( 'Participants[0].ParticipantRole', 'Signer 1' )
            .writeParam( 'Participants[0].Email', 'aamir@frozenfishdev.com' )
            .writeParam( 'Participants[0].FirstName', 'Aamir' )
            .writeParam( 'Participants[0].LastName', 'Hussain' )  
            .writeParam( 'Participants[0].StaticSignatureEnabled', 'true')      
            .writeParam( 'Participants[0].ScriptedSignatureEnabled', 'true')   
            .writeParam( 'Participants[0].ImageSignatureEnabled', 'true');   
            
        builder.writeFile( 'Files', fileName, EncodingUtil.base64Encode(fileBlob));
        */
        
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBodyAsBlob(formData);
        httpRequest.setEndpoint(url);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', String.valueOf(formData.size()) );
        httpRequest.setHeader('Content-Type', HttpHexFormBuilder.GetContentType() );
        httpRequest.setHeader('Authorization','Bearer ' + token);
        httpRequest.setHeader('externalId',externalId);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        
        /**/
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        string responseBody = response.getBody();
        System.debug(response);
        
        responseBody = responseBody.replace('\r','').replace('\n','');
        System.debug(responseBody);
        
        return  responseBody;
        
    }
}