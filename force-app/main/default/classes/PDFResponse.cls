/*
*********************************************************
@Apex Class Name    : PDFResponse
@Created Date       : Dec 12, 2023
@description        : Wrapper class for PDF response from Authentisign API
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added AuraEnabled annotations and documentation for consistency with refactored Authentisign app. No functional changes needed; compatible with Opportunity and generic SObjects.
*********************************************************
*/
public with sharing class PDFResponse {
    /**
     * @description The raw PDF stream as a string from the Authentisign API response
     * @type String
     */
    @AuraEnabled
    public String pdfStream { get; set; }
    
    /**
     * @description The PDF content as a binary Blob for attachment creation
     * @type Blob
     */
    @AuraEnabled
    public Blob pdfBlob { get; set; }
    
    /**
     * @description The file name of the PDF extracted from the API response
     * @type String
     */
    @AuraEnabled
    public String fileName { get; set; }
}