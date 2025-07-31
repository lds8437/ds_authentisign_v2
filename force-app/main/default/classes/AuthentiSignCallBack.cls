/**
@Apex Class Name    AuthentiSignCallBack
@Created Date       Jan 30, 2024
@description        A call back class to return the response when document is signed.
@author             FFD Developer
*/
@RestResource(urlMapping='/callback')
global with sharing class  AuthentiSignCallBack 
{  
    /**
    @description post call back method for authentisign to send data
    */
    @HttpPost
    global static void doPost() {
        
        /**
         * @description request context params
         * @return string
         */
        string params = JSON.serialize(RestContext.request.params);
        /**
         * @description request context body
         * @return string
         */
        string body = JSON.serialize(RestContext.request.requestBody);
        /**
         * @description request context headers
         * @return string
         */
        string headers = JSON.serialize(RestContext.request.headers);
        /**
         * @description request context requestURI
         * @return string
         */
        string requestURI = JSON.serialize(RestContext.request.requestURI);
        
        Callback_Response__c callback = new Callback_Response__c();
        callback.Params__c = params;
        callback.Headers__c = headers;
        callback.Body__c = body;
        callback.Uri__c = requestURI;
        
        if (Schema.sObjectType.Callback_Response__c.fields.Params__c.isAccessible() &&
            Schema.sObjectType.Callback_Response__c.fields.Headers__c.isAccessible() &&
            Schema.sObjectType.Callback_Response__c.fields.Body__c.isAccessible() &&
            Schema.sObjectType.Callback_Response__c.fields.Uri__c.isAccessible()
            ) {
            insert callback;
        }
    }
}