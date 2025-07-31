/*
*********************************************************
@Apex Class Name    : Utility
@Created Date       : Jan 30, 2024
@description        : Helper class for Authentisign API calls, SObject field retrieval, and PDF attachment handling
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Removed CPQ dependencies, updated to support Opportunity. Added AuraEnabled annotations. Renamed ParticipientList to ParticipantList to match SObjectFieldPackage. Renamed quoteName to recordName in submitDocumentRequest. Fixed savePDFasAttachmentDocument to use ContentDocumentLink. Added consistent error handling and documentation.
*********************************************************
*/
public with sharing class Utility {

    /*
    *********************************************************
    @Method Name    : getSetting
    @description    : Retrieve Authentisign settings from Setting__c
    @param          : None
    @return         : Setting__c
    ********************************************************
    */
    public static Setting__c getSetting() {
        try {
            return DataLayer.getSetting();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving Setting__c: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving settings: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : createQueryParams
    @description    : Create query parameters for HTTP request
    @param          : Map<String,String> params
    @return         : String
    ********************************************************
    */
    public static String createQueryParams(Map<String,String> params) {
        try {
            String result = '';
            for (String key : params.keySet()) {
                if (result == '') {
                    result = key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
                } else {
                    result += '&' + key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
                }
            }
            return result;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error creating query params: ' + e.getMessage());
            throw new AuraHandledException('Error creating query params: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : sendHttpRequest
    @description    : Send HTTP request to Authentisign API
    @param          : String verb, String endpoint, Map<String,String> headers, String token, String requestBody
    @return         : String (response body)
    ********************************************************
    */
    public static String sendHttpRequest(String verb, String endpoint, Map<String,String> headers, String token, String requestBody) {
        try {
            Http h = new Http();
            HttpRequest r = new HttpRequest();
            r.setEndpoint(endpoint);
            r.setTimeout(120000); // Timeout set to 120s per original code
            r.setMethod(verb);

            if (headers != null && !headers.isEmpty()) {
                for (String key : headers.keySet()) {
                    r.setHeader(key, headers.get(key));
                }
            }

            if (String.isNotBlank(requestBody)) {
                r.setBody(requestBody);
            }

            System.debug('externalId: ' + r.getHeader('externalId'));
            System.debug('Authorization: ' + r.getHeader('Authorization'));

            HttpResponse resp = h.send(r);
            String body = resp.getBody();
            System.debug('response body: ' + body);

            if (resp.getStatusCode() != 200 && resp.getStatusCode() != 201) {
                throw new CalloutException('API call failed: ' + resp.getStatusCode() + ' ' + resp.getStatus());
            }

            return body;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendHttpRequest: ' + e.getMessage());
            throw new AuraHandledException('API call failed: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : sendHttpRequestBlob
    @description    : Send HTTP request to Authentisign and get PDF response
    @param          : String verb, String endpoint, Map<String,String> headers, String token, String requestBody
    @return         : PDFResponse
    ********************************************************
    */
    public static PDFResponse sendHttpRequestBlob(String verb, String endpoint, Map<String,String> headers, String token, String requestBody) {
        try {
            Http h = new Http();
            HttpRequest r = new HttpRequest();
            r.setEndpoint(endpoint);
            r.setTimeout(120000);
            r.setMethod(verb);

            if (headers != null && !headers.isEmpty()) {
                for (String key : headers.keySet()) {
                    r.setHeader(key, headers.get(key));
                }
            }

            if (String.isNotBlank(requestBody)) {
                r.setBody(requestBody);
            }

            System.debug('externalId: ' + r.getHeader('externalId'));
            System.debug('Authorization: ' + r.getHeader('Authorization'));

            HttpResponse resp = h.send(r);
            Blob blobBody = resp.getBodyAsBlob();
            System.debug('blobBody: ' + blobBody);

            String stream = resp.getBody();
            PDFResponse finalResult = new PDFResponse();
            finalResult.pdfBlob = blobBody;
            finalResult.pdfStream = stream;
            finalResult.fileName = '';

            String contentDisposition = resp.getHeader('Content-Disposition');
            if (String.isNotBlank(contentDisposition)) {
                Integer startIndex = contentDisposition.indexOf('filename=');
                if (startIndex >= 0) {
                    finalResult.fileName = contentDisposition.substring(startIndex + 'filename='.length());
                    finalResult.fileName = EncodingUtil.urlDecode(finalResult.fileName, 'UTF-8');
                }
            }
            System.debug('fileName: ' + finalResult.fileName);

            return finalResult;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendHttpRequestBlob: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving PDF: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getPDFResponse
    @description    : Create request and call sendHttpRequestBlob to get PDF response
    @param          : String token, String accountId, String baseurl, String signingId, String signingMethod
    @return         : PDFResponse
    ********************************************************
    */
    public static PDFResponse getPDFResponse(String token, String accountId, String baseurl, String signingId, String signingMethod) {
        try {
            Map<String,String> params = new Map<String,String>();
            params.put('language', 'en');
            String queryParams = createQueryParams(params);

            String requestMethod = '/api/v1/signings/' + signingId + '/documents/' + signingMethod;
            String endpoint = baseurl + requestMethod + '?' + queryParams;
            System.debug('endpoint: ' + endpoint);

            Map<String,String> headers = new Map<String,String>();
            headers.put('Authorization', 'Bearer ' + token);
            headers.put('Accept', '*/*');
            headers.put('externalId', accountId);

            return sendHttpRequestBlob('GET', endpoint, headers, token, '');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getPDFResponse: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving PDF response: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getPDFLinkResponse
    @description    : Create request and call sendHttpRequest to get PDF link response
    @param          : String token, String accountId, String baseurl, String signingId, String signingMethod
    @return         : String
    ********************************************************
    */
    public static String getPDFLinkResponse(String token, String accountId, String baseurl, String signingId, String signingMethod) {
        try {
            Map<String,String> params = new Map<String,String>();
            params.put('language', 'en');
            String queryParams = createQueryParams(params);

            String requestMethod = '/api/v1/signings/' + signingId + '/documents/' + signingMethod;
            String endpoint = baseurl + requestMethod + '?' + queryParams;

            Map<String,String> headers = new Map<String,String>();
            headers.put('Authorization', 'Bearer ' + token);
            headers.put('Accept', '*/*');
            headers.put('externalId', accountId);

            return sendHttpRequest('GET', endpoint, headers, token, '');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getPDFLinkResponse: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving PDF link: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : savePDFasAttachment
    @description    : Save PDF as an Attachment to the record
    @param          : String recordId, String signingId, String pdfMethod, String objectName
    @return         : String (Attachment Id)
    ********************************************************
    */
    @AuraEnabled
    public static String savePDFasAttachment(String recordId, String signingId, String pdfMethod, String objectName) {
        try {
            Setting__c setting = getSetting();
            if (setting == null) {
                throw new AuraHandledException('Authentisign settings not found.');
            }

            PDFResponse pdfResponseObj = getPDFResponse(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c, signingId, pdfMethod);
            System.debug('pdfResponseObj: ' + pdfResponseObj.fileName);

            Attachment attach = new Attachment();
            attach.Name = pdfResponseObj.fileName;
            attach.ParentId = recordId;
            attach.Body = pdfResponseObj.pdfBlob;
            attach.ContentType = 'application/pdf';
            insert attach;

            SObject obj = Schema.getGlobalDescribe().get(objectName).newSObject();
            obj.put('Id', recordId);
            obj.put('AttachmentId__c', attach.Id);
            update obj;

            return attach.Id;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in savePDFasAttachment: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            throw new AuraHandledException('Error saving PDF as attachment: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : savePDFasAttachmentDocument
    @description    : Save PDF as a ContentDocument linked to the record
    @param          : String recordId, String signingId, String pdfMethod, String objectName
    @return         : String (ContentDocument Id)
    ********************************************************
    */
    @AuraEnabled
    public static String savePDFasAttachmentDocument(String recordId, String signingId, String pdfMethod, String objectName) {
        try {
            Setting__c setting = getSetting();
            if (setting == null) {
                throw new AuraHandledException('Authentisign settings not found.');
            }

            PDFResponse pdfResponseObj = getPDFResponse(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c, signingId, pdfMethod);
            System.debug('pdfResponseObj: ' + pdfResponseObj.fileName);

            ContentVersion cv = new ContentVersion(
                Title = pdfResponseObj.fileName,
                PathOnClient = pdfResponseObj.fileName,
                VersionData = pdfResponseObj.pdfBlob,
                ContentLocation = 'S'
            );
            insert cv;

            ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = recordId,
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
                ShareType = 'V'
            );
            insert cdl;

            SObject obj = Schema.getGlobalDescribe().get(objectName).newSObject();
            obj.put('Id', recordId);
            obj.put('Document_Attachment_Id__c', cdl.ContentDocumentId);
            update obj;

            return cdl.ContentDocumentId;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in savePDFasAttachmentDocument: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            throw new AuraHandledException('Error saving PDF as document: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getSObjectFields
    @description    : Get fields schema information for SObject and related items
    @param          : String objectName, String whereClause, String orderBy, String recordLimit
    @return         : SObjectFieldPackage
    ********************************************************
    */
    public static SObjectFieldPackage getSObjectFields(String objectName, String whereClause, String orderBy, String recordLimit) {
        try {
            SObjectFieldPackage wrapper = new SObjectFieldPackage();
            wrapper.SObjectFieldsList = new List<String>();
            wrapper.SObjectFieldsProperties = new Map<String, Map<String, String>>();
            wrapper.ParticipantList = new Map<String, List<String>>();
            wrapper.UserContactFieldMap = new Map<String, String>();

            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
            if (fieldMap == null) {
                throw new IllegalArgumentException('Invalid SObject: ' + objectName);
            }

            for (String key : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(key);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                Map<String, String> fieldMapProps = new Map<String, String>();

                String fieldName = fieldDescribe.getName();
                if (fieldDescribe.isAccessible()) {
                    fieldMapProps.put('custom', String.valueOf(fieldDescribe.isCustom()));
                    fieldMapProps.put('label', String.valueOf(fieldDescribe.getLabel()));
                    fieldMapProps.put('length', String.valueOf(fieldDescribe.getLength()));
                    fieldMapProps.put('localName', String.valueOf(fieldDescribe.getLocalName()));
                    fieldMapProps.put('name', String.valueOf(fieldName));

                    String referenceTo = String.valueOf(fieldDescribe.getReferenceTo());
                    fieldMapProps.put('referenceTo', referenceTo);
                    fieldMapProps.put('type', String.valueOf(fieldDescribe.getType()));

                    wrapper.SObjectFieldsProperties.put(fieldName, fieldMapProps);
                    wrapper.SObjectFieldsList.add(fieldName);

                    if (fieldDescribe.getReferenceTo().size() > 0) {
                        List<String> referenceFields = new List<String>();
                        String lookupFieldName = '';
                        if (fieldDescribe.isCustom()) {
                            lookupFieldName = fieldName.replace('__c', '__r');
                        } else {
                            lookupFieldName = fieldName.replace('Id', '').replace('id', '');
                        }

                        if (String.isNotBlank(lookupFieldName)) {
                            if ((referenceTo.toLowerCase().contains('contact') || referenceTo.toLowerCase().contains('user')) &&
                                !(key.equalsIgnoreCase('createdbyid') || key.equalsIgnoreCase('lastmodifiedbyid'))) {
                                referenceFields.add('Id');
                                referenceFields.add('Name');
                                wrapper.SObjectFieldsList.add(lookupFieldName + '.Name');
                                referenceFields.add('FirstName');
                                wrapper.SObjectFieldsList.add(lookupFieldName + '.FirstName');
                                referenceFields.add('LastName');
                                wrapper.SObjectFieldsList.add(lookupFieldName + '.LastName');
                                referenceFields.add('Email');
                                wrapper.SObjectFieldsList.add(lookupFieldName + '.Email');
                                referenceFields.add('Phone');
                                wrapper.SObjectFieldsList.add(lookupFieldName + '.Phone');
                                referenceFields.add(referenceTo);

                                wrapper.ParticipantList.put(lookupFieldName, referenceFields);
                                wrapper.UserContactFieldMap.put(fieldName, lookupFieldName);
                            } else {
                                String referenceObjectName = String.valueOf(fieldDescribe.getReferenceTo()[0]);
                                Boolean hasNameField = Schema.getGlobalDescribe().get(referenceObjectName.toLowerCase()).getDescribe().fields.getMap().containsKey('Name');
                                if (hasNameField) {
                                    wrapper.SObjectFieldsList.add(lookupFieldName + '.Name');
                                }
                            }
                        }
                    }
                }
            }

            String sObjectQuery = 'SELECT ' + String.join(wrapper.SObjectFieldsList, ',') + ' FROM ' + objectName + ' ' + 
                                 whereClause + ' ' + orderBy + ' ' + recordLimit;
            wrapper.Query = sObjectQuery;

            return wrapper;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getSObjectFields: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving SObject fields: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : submitDocumentRequest
    @description    : Submit document signing request to Authentisign
    @param          : List<SignersRequest> signers, Map<String,String> requestParams
    @return         : String (response body)
    ********************************************************
    */
    public static String submitDocumentRequest(List<SignersRequest> signers, Map<String,String> requestParams) {
        try {
            String objectName = requestParams.get('objectName');
            String documentId = requestParams.get('documentId');
            String documentName = requestParams.get('documentName');
            String recordName = requestParams.get('recordName');
            String url = requestParams.get('url');
            String token = requestParams.get('token');
            String externalId = requestParams.get('externalId');

            System.debug('url: ' + url);
            System.debug('signers: ' + signers);

            Blob fileBlob = DataLayer.getDocumentById(documentId, objectName);
            if (fileBlob == null) {
                throw new AuraHandledException('Document not found for ID: ' + documentId);
            }

            String fileName = documentName + '.pdf';
            HttpHexFormBuilder builder = HttpHexFormBuilder.build()
                .writeParam('Name', recordName + ' - ' + documentName);

            for (Integer x = 0; x < signers.size(); x++) {
                builder.writeParam('Participants[' + String.valueOf(x) + '].ParticipantRole', signers[x].data.Role)
                    .writeParam('Participants[' + String.valueOf(x) + '].Email', signers[x].data.Email)
                    .writeParam('Participants[' + String.valueOf(x) + '].FirstName', signers[x].data.FirstName)
                    .writeParam('Participants[' + String.valueOf(x) + '].LastName', signers[x].data.LastName)
                    .writeParam('Participants[' + String.valueOf(x) + '].StaticSignatureEnabled', 'true')
                    .writeParam('Participants[' + String.valueOf(x) + '].ScriptedSignatureEnabled', 'true')
                    .writeParam('Participants[' + String.valueOf(x) + '].ImageSignatureEnabled', 'true');
            }

            builder.writeFile('Files', fileName, EncodingUtil.base64Encode(fileBlob));
            Blob formData = builder.getFormAsBlob();

            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setBodyAsBlob(formData);
            httpRequest.setEndpoint(url);
            httpRequest.setHeader('Connection', 'keep-alive');
            httpRequest.setHeader('Content-Length', String.valueOf(formData.size()));
            httpRequest.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
            httpRequest.setHeader('Authorization', 'Bearer ' + token);
            httpRequest.setHeader('externalId', externalId);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);

            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            String responseBody = response.getBody();
            System.debug('response: ' + response);

            responseBody = responseBody.replace('\r', '').replace('\n', '');
            System.debug('responseBody: ' + responseBody);

            if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                throw new CalloutException('API call failed: ' + response.getStatusCode() + ' ' + response.getStatus());
            }

            return responseBody;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in submitDocumentRequest: ' + e.getMessage());
            throw new AuraHandledException('Error submitting document request: ' + e.getMessage());
        }
    }
}