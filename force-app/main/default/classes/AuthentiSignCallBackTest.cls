/*
*********************************************************
@Apex Class Name    : AuthentiSignCallBackTest
@Created Date       : Jan 30, 2024
@description        : AuthentiSignCallBack test class.
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
@IsTest
private class AuthentiSignCallBackTest {

    /*
    *********************************************************
    @Method Name    : unitTestGETCallBack
    @description    : authentisign call back GET method test class
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void unitTestGETCallBack() {
        
        RestRequest req = getRestRequest('callback','GET'); 
        RestContext.request = req;
        
        test.startTest();
        AuthentiSignCallBack.doPost();
        List<Callback_Response__c> callbackresponse = [Select Id from Callback_Response__c]; 
        System.assert(callbackresponse.size() > 0);
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : unitTestPOSTCallBack
    @description    : authentisign call back POST method test class
    @param          : N/A
    @return         : void
    ********************************************************
    */
    @IsTest
    private static void unitTestPOSTCallBack() {
        
        RestRequest req = getRestRequest('callback','POST'); 
        RestContext.request = req;
        
        test.startTest();
        AuthentiSignCallBack.doPost();
        List<Callback_Response__c> callbackresponse = [Select Id from Callback_Response__c]; 
        System.assert(callbackresponse.size() > 0);
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : getRestRequest
    @description    : utility method to get the RestRequest object
    @param          : string requestMethod, string verb
    @return         : RestRequest
    ********************************************************
    */
    static RestRequest getRestRequest(string requestMethod, string verb){
        RestRequest req = new RestRequest(); 
        
        req.requestURI = '/services/apexrest/'+requestMethod;
        req.httpMethod = verb;
        
        return req;
    }
    
}