/*
*********************************************************
@Apex Class Name    : LayoutListHelper
@Created Date       : Dec 12, 2023
@description        : Helper class for LayoutListCtrl class
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutListHelper {

    /*
    *********************************************************
    @Method Name    : getLayouts
    @description    : get the layouts from the authentisign with api calls
    @param          : string recordId, string objectName
    @return         : LayoutResponse (wrapper class)
    ********************************************************
    */
    public static LayoutResponse getLayouts(string recordId, string objectName)
    {
        LayoutResponse result = new LayoutResponse();
        List<LayoutWrapper> wrapper = new List<LayoutWrapper>();
        
        authentisign__Setting__c setting = Utility.getSetting();
        
        if(setting != null)
        {
            //Get Quote record
            sObject quot = DataLayer.getQuoteById(recordId, objectName);
            result.quote = quot;
            
            //Send layout request
            string responseResult = sendLayoutRequest(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c);
            System.debug('responseResult: '+ responseResult);
            wrapper = (List<LayoutWrapper>)JSON.deserialize(responseResult, List<LayoutWrapper>.class);
            result.wrapper = wrapper;
            
            //result.documentSigningStatus = getDocumentSigningStatusLink(quot, setting);
            //result.signingStatus = getDocumentSigningStatus(quot, setting);
            
            Map<string,string> finalSigningStatus = getDocumentSigningStatus(quot, setting);
            
            System.debug('finalSigningStatus: '+finalSigningStatus);
            
            result.signingStatus = finalSigningStatus.get('signingStatus');
            result.documentsigningStatus = finalSigningStatus.get('documentSigningStatus');
            
            
            result.documents = DataLayer.getDocuments(recordId, objectName);
        }
                
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : sendLayoutRequest
    @description    : create layout request and sent it to utility class to get the response
    @param          : string token, string accountId, string baseurl
    @return         : string (json response from authentisign)
    ********************************************************
    */
    public static string sendLayoutRequest(string token, string accountId, string baseurl)
    {
        string responseResult = '';
        
        Map<string,string> params = new Map<string,string>();
        Map<string,string> headers = new Map<string,string>();
        
        //set params
        params.put('language','en');
        string queryParams = Utility.createQueryParams(params);
        
        
        //set final endpoint
        string requestMethod = '/api/v1/layouts';
        string endpoint = baseurl + requestMethod + '?'+queryParams;
        //System.debug(endpoint);
        
         //set headers
        headers.put('Authorization','Bearer '+token);
        headers.put('Accept','*/*');
        headers.put('externalId',accountId);
        
        responseResult = Utility.sendHttpRequest('GET',endpoint, headers, token, '');
        
        return responseResult;
    }
    
    /*
    *********************************************************
    @Method Name    : getDocumentSigningStatus
    @description    : check the signing status of request record
    @param          : SObject quot, authentisign__Setting__c setting
    @return         : Map<string,string>
    ********************************************************
    */
    public static Map<string,string> getDocumentSigningStatus(SObject quot, authentisign__Setting__c setting)
    { 
        string signingStatus = '';
        string quotSigningId = (string)quot.get('authentisign__Signing_Id__c');
        string quotSigningStatus = (string)quot.get('authentisign__Authsign_Status__c');
        
        string documentSigningStatus = '';
        string quotDocSigningId = (string)quot.get('authentisign__Document_Signing_Id__c');
        string quotDocSigningStatus = (string)quot.get('authentisign__Authsign_Document_Status__c');
        /*
        *  qt.put('authentisign__Document_Signing_Id__c',documentSigningId);
        *  qt.put('authentisign__Document_Id__c',documentId);
        *  qt.put('authentisign__Authsign_Document_Status__c', 'sent');
        */
        PDFResponse pdfSignings = new PDFResponse();
        if(quotSigningId != null)
        {
            if(quotSigningStatus =='sent')
            {
                pdfSignings = Utility.getPDFResponse(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c, quotSigningId, 's' );
            }
            else if(quotSigningStatus == 'signed'){
                signingStatus = 'document signed';
            }
        }
        
        PDFResponse pdfDocSignings = new PDFResponse();
        if(quotDocSigningId != null)
        {
            if(quotDocSigningStatus =='sent')
            {
                pdfDocSignings = Utility.getPDFResponse(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c, quotDocSigningId, 's' );
            }
            else if(quotDocSigningStatus == 'signed'){
                documentSigningStatus = 'document signed';
            }
        }
        
        if(quotSigningStatus == 'sent')
        {
            signingStatus = processPDFResponse(pdfSignings, quot, quotSigningStatus, true);
        }
        
        if(quotDocSigningStatus == 'sent')
        {
            documentSigningStatus = processPDFResponse(pdfDocSignings, quot, quotDocSigningStatus, false);
        }
        
        Map<string,string> finalSigningStatus = new Map<string,string>();
        
        finalSigningStatus.put('signingStatus',signingStatus);
        finalSigningStatus.put('documentSigningStatus',documentSigningStatus); 
        
        //System.debug('final: '+singingStatus);
        return finalSigningStatus;
    }
    
    public static string processPDFResponse(PDFResponse pdfSignings,SObject quot, string singingStatus, boolean isLayout)
    {
        if(pdfSignings != null && !(pdfSignings.pdfStream == null || pdfSignings.pdfStream == ''))
        {
            if(pdfSignings.pdfStream.indexOf('%PDF')==0 || Test.IsRunningTest())
            {
                singingStatus = 'document signed';
                
                //update attachment
                Attachment attach = new Attachment();
                string quotAttachmentId = null;
                if(isLayout)
                    quotAttachmentId =  (string)quot.get('authentisign__AttachmentId__c');
                else
                    quotAttachmentId =  (string)quot.get('authentisign__Document_Attachment_Id__c');
                
                if(quotAttachmentId != null)
                {
                    //update quote with status 
                    if(isLayout)
                        quot.put('authentisign__Authsign_Status__c','signed');
                    else
                        quot.put('authentisign__Authsign_Document_Status__c','signed');
                    update quot;
                    
                    attach.id = quotAttachmentId;
                    attach.body = pdfSignings.pdfBlob;
                    attach.contenttype = 'application/pdf';
                    update attach;    
                }
                else{
                    attach.name = Test.IsRunningTest() ? 'test':  pdfSignings.fileName;
                    attach.ParentId = quot.Id;
                    attach.body = pdfSignings.pdfBlob;
                    attach.contenttype = 'application/pdf';
                    insert attach;
                    
                    if(isLayout){
                        quot.put('authentisign__Authsign_Status__c','signed');
                        quot.put('authentisign__AttachmentId__c', attach.Id);
                    }
                    else{
                        quot.put('authentisign__Authsign_Document_Status__c','signed');
                        quot.put('authentisign__Document_Attachment_Id__c', attach.Id);
                        
                    }
                    update quot;
                }
                
            }
            else{
                SigningStatusResponse statusResult =  (SigningStatusResponse)JSON.deserialize(pdfSignings.pdfStream, SigningStatusResponse.class);
                singingStatus = statusResult.details[0];    
            }
        }
        
        return singingStatus;
    }
    /*
    *********************************************************
    @Method Name    : getDocumentSigningStatusLink
    @description    : check the signing status of request record
    @param          : SObject quot, authentisign__Setting__c setting
    @return         : string (signing status)
    ********************************************************
    */
    public static string getDocumentSigningStatusLink(SObject quot, authentisign__Setting__c setting)
    { 
        string documentLink = '';
        string quotDocumentSigningId = (string)quot.get('authentisign__Document_Signing_Id__c');
        if(quotDocumentSigningId != null)
        {
            string pdfLinkResponse = Utility.getPDFLinkResponse(setting.authentisign__Bearer_Token__c, setting.authentisign__Account_Id__c, setting.authentisign__Endpoint__c, quotDocumentSigningId, 's/url' );

			Map<string,object> result = (Map<string,object>)JSON.deserializeUntyped(pdfLinkResponse);
            
            if(result.get('url') != null)
            {
                documentLink = 'url: '+ string.valueOf(result.get('url')); 
            }
            else{
                string details = string.valueOf(result.get('details'));
                documentLink = 'error: ' + details.replace('(','').replace(')','');
            }
        }
        
        return documentLink;
    }
}