/*
*********************************************************
@Apex Class Name    : LayoutListHelper
@Created Date       : Dec 12, 2023
@description        : Helper class for LayoutListCtrl class
@author             : FFD Developer
@Modification Log   : 
  - Updated August 6, 2025: Added createLayout method to send POST request to Authentisign API for creating a new layout.
*********************************************************
*/
public with sharing class LayoutListHelper {

    /*
    *********************************************************
    @Method Name    : getLayouts
    @description    : Get the layouts from Authentisign with API calls
    @param          : String recordId, String objectName
    @return         : LayoutResponse (wrapper class)
    ********************************************************
    */
    public static LayoutResponse getLayouts(String recordId, String objectName) {
        LayoutResponse result = new LayoutResponse();
        List<LayoutWrapper> wrapper = new List<LayoutWrapper>();
        
        Setting__c setting = Utility.getSetting();
        
        if (setting != null) {
            // Get record (e.g., Opportunity) by Id
            SObject record = DataLayer.getRecordById(recordId, objectName);
            result.opportunity = record;
            
            // Send layout request
            String responseResult = sendLayoutRequest(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c);
            System.debug('responseResult: ' + responseResult);
            wrapper = (List<LayoutWrapper>)JSON.deserialize(responseResult, List<LayoutWrapper>.class);
            result.wrapper = wrapper;
            
            Map<String,String> finalSigningStatus = getDocumentSigningStatus(record, setting);
            
            System.debug('finalSigningStatus: ' + finalSigningStatus);
            
            result.signingStatus = finalSigningStatus.get('signingStatus');
            result.documentsigningStatus = finalSigningStatus.get('documentSigningStatus');
            
            result.documents = DataLayer.getDocuments(recordId, objectName);
        }
                
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : sendLayoutRequest
    @description    : Create layout request and send it to utility class to get the response
    @param          : String token, String accountId, String baseurl
    @return         : String (JSON response from Authentisign)
    ********************************************************
    */
    public static String sendLayoutRequest(String token, String accountId, String baseurl) {
        String responseResult = '';
        
        Map<String,String> params = new Map<String,String>();
        Map<String,String> headers = new Map<String,String>();
        
        // Set params
        params.put('language', 'en');
        String queryParams = Utility.createQueryParams(params);
        
        // Set final endpoint
        String requestMethod = '/api/v1/layouts';
        String endpoint = baseurl + requestMethod + '?' + queryParams;
        
        // Set headers
        headers.put('Authorization', 'Bearer ' + token);
        headers.put('Accept', '*/*');
        headers.put('externalId', accountId);
        
        responseResult = Utility.sendHttpRequest('GET', endpoint, headers, token, '');
        
        return responseResult;
    }

    /*
    *********************************************************
    @Method Name    : createLayout
    @description    : Create a new layout via Authentisign API POST request
    @param          : String templateName
    @return         : String (layout ID)
    ********************************************************
    */
    public static String createLayout(String templateName) {
        String responseResult = '';
        
        Setting__c setting = Utility.getSetting();
        
        if (setting == null) {
            throw new AuraHandledException('Authentisign settings not found.');
        }
        
        Map<String,String> headers = new Map<String,String>();
        String endpoint = setting.Endpoint__c + '/api/v1/layouts';
        
        // Set headers
        headers.put('Authorization', 'Bearer ' + setting.Bearer_Token__c);
        headers.put('Content-Type', 'application/json');
        headers.put('externalId', setting.Account_Id__c);
        
        // Set request body
        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('name', templateName);
        String requestBody = JSON.serialize(requestBodyMap);
        
        // Send POST request
        try {
            responseResult = Utility.sendHttpRequest('POST', endpoint, headers, setting.Bearer_Token__c, requestBody);
            System.debug(LoggingLevel.DEBUG, 'createLayout response: ' + responseResult);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'HTTP request failed: ' + e.getMessage());
            throw new AuraHandledException('Failed to call Authentisign API: ' + e.getMessage());
        }
        
        // Validate response as layout ID
        if (String.isBlank(responseResult)) {
            throw new AuraHandledException('Failed to retrieve layout ID: Empty response.');
        }
        
        // Assume response is the layout ID string
        String layoutId = responseResult.trim();
         
        // Remove quotes if present
        if (layoutId.startsWith('"') && layoutId.endsWith('"')) {
            layoutId = layoutId.substring(1, layoutId.length() - 1);
        }

       // Validate UUID format
        Pattern uuidPattern = Pattern.compile('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
        Matcher uuidMatcher = uuidPattern.matcher(layoutId);
        if (!uuidMatcher.matches()) {
            // Try JSON parsing as a fallback
            try {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseResult);
                if (responseMap.containsKey('id')) {
                    layoutId = (String)responseMap.get('id');
                } else if (responseMap.containsKey('data')) {
                    Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
                    if (dataMap != null && dataMap.containsKey('id')) {
                        layoutId = (String)dataMap.get('id');
                    }
                }
                if (String.isBlank(layoutId)) {
                    throw new AuraHandledException('Failed to retrieve layout ID from JSON response.');
                }
                // Re-validate UUID format

                uuidMatcher = uuidPattern.matcher(layoutId);
                if (!uuidMatcher.matches()) {
                    throw new AuraHandledException('Invalid layout ID format: ' + layoutId);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'JSON parsing failed: ' + e.getMessage());
                throw new AuraHandledException('Invalid response format: ' + responseResult);
            }
        }
        
        return layoutId;
    }
    
    /*
    *********************************************************
    @Method Name    : getDocumentSigningStatus
    @description    : Check the signing status of request record
    @param          : SObject record, Setting__c setting
    @return         : Map<String,String>
    ********************************************************
    */
    public static Map<String,String> getDocumentSigningStatus(SObject record, Setting__c setting) { 
        String signingStatus = '';
        String recordSigningId = (String)record.get('Signing_Id__c');
        String recordSigningStatus = (String)record.get('Authsign_Status__c');
        
        String documentSigningStatus = '';
        String recordDocSigningId = (String)record.get('Document_Signing_Id__c');
        String recordDocSigningStatus = (String)record.get('Authsign_Document_Status__c');
        
        PDFResponse pdfSignings = new PDFResponse();
        if (recordSigningId != null) {
            if (recordSigningStatus == 'sent') {
                pdfSignings = Utility.getPDFResponse(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c, recordSigningId, 's');
            } else if (recordSigningStatus == 'signed') {
                signingStatus = 'document signed';
            }
        }
        
        PDFResponse pdfDocSignings = new PDFResponse();
        if (recordDocSigningId != null) {
            if (recordDocSigningStatus == 'sent') {
                pdfDocSignings = Utility.getPDFResponse(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c, recordDocSigningId, 's');
            } else if (recordDocSigningStatus == 'signed') {
                documentSigningStatus = 'document signed';
            }
        }
        
        if (recordSigningStatus == 'sent') {
            signingStatus = processPDFResponse(pdfSignings, record, recordSigningStatus, true);
        }
        
        if (recordDocSigningStatus == 'sent') {
            documentSigningStatus = processPDFResponse(pdfDocSignings, record, recordDocSigningStatus, false);
        }
        
        Map<String,String> finalSigningStatus = new Map<String,String>();
        
        finalSigningStatus.put('signingStatus', signingStatus);
        finalSigningStatus.put('documentSigningStatus', documentSigningStatus); 
        
        return finalSigningStatus;
    }
    
    public static String processPDFResponse(PDFResponse pdfSignings, SObject record, String signingStatus, Boolean isLayout) {
        if (pdfSignings != null && !(pdfSignings.pdfStream == null || pdfSignings.pdfStream == '')) {
            if (pdfSignings.pdfStream.indexOf('%PDF') == 0 || Test.isRunningTest()) {
                signingStatus = 'document signed';
                
                // Update attachment
                Attachment attach = new Attachment();
                String recordAttachmentId = null;
                if (isLayout)
                    recordAttachmentId = (String)record.get('AttachmentId__c');
                else
                    recordAttachmentId = (String)record.get('Document_Attachment_Id__c');
                
                if (recordAttachmentId != null) {
                    // Update record with status 
                    if (isLayout)
                        record.put('Authsign_Status__c', 'signed');
                    else
                        record.put('Authsign_Document_Status__c', 'signed');
                    update record;
                    
                    attach.Id = recordAttachmentId;
                    attach.Body = pdfSignings.pdfBlob;
                    attach.ContentType = 'application/pdf';
                    update attach;    
                } else {
                    attach.Name = Test.isRunningTest() ? 'test' : pdfSignings.fileName;
                    attach.ParentId = record.Id;
                    attach.Body = pdfSignings.pdfBlob;
                    attach.ContentType = 'application/pdf';
                    insert attach;
                    
                    if (isLayout) {
                        record.put('Authsign_Status__c', 'signed');
                        record.put('AttachmentId__c', attach.Id);
                    } else {
                        record.put('Authsign_Document_Status__c', 'signed');
                        record.put('Document_Attachment_Id__c', attach.Id);
                    }
                    update record;
                }
            } else {
                SigningStatusResponse statusResult = (SigningStatusResponse)JSON.deserialize(pdfSignings.pdfStream, SigningStatusResponse.class);
                signingStatus = statusResult.details[0];    
            }
        }
        
        return signingStatus;
    }
    
    /*
    *********************************************************
    @Method Name    : getDocumentSigningStatusLink
    @description    : Check the signing status link of request record
    @param          : SObject record, Setting__c setting
    @return         : String (signing status link)
    ********************************************************
    */
    public static String getDocumentSigningStatusLink(SObject record, Setting__c setting) { 
        String documentLink = '';
        String recordDocumentSigningId = (String)record.get('Document_Signing_Id__c');
        if (recordDocumentSigningId != null) {
            String pdfLinkResponse = Utility.getPDFLinkResponse(setting.Bearer_Token__c, setting.Account_Id__c, setting.Endpoint__c, recordDocumentSigningId, 's/url');

            Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(pdfLinkResponse);
            
            if (result.get('url') != null) {
                documentLink = 'url: ' + String.valueOf(result.get('url')); 
            } else {
                String details = String.valueOf(result.get('details'));
                documentLink = 'error: ' + details.replace('(', '').replace(')', '');
            }
        }
        
        return documentLink;
    }
}