({
	init : function(component, event) {
        
        component.set("v.radioOptions", [
            { label: "Document", value: "document" },
            { label: "Layout", value: "layout" }
        ]);
        
        var action = component.get("c.getLayouts");
        action.setParams({ recordId : component.get("v.recordId") , objectName : component.get("v.sObjectName") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                
                var result = response.getReturnValue();
                console.log(result);
                
                component.set("v.data", result.wrapper);
                
                var ddlData = [];
                for(var x in result.wrapper)
                {
                    if(x==0)
                    {
                        ddlData.push({"name":"Select Layout","id":""});
                    }
                    ddlData.push(result.wrapper[x]);                  
                }
                
                component.set("v.layouts", ddlData);
                console.log(ddlData);
            
            	component.set("v.selectedRecord", result.quote.Layout_Id__c);
                component.set("v.savedLayoutId", result.quote.Layout_Id__c);
                console.log(result.quote.Layout_Id__c);
                
                component.set("v.signingStatus", result.signingStatus);
                component.set("v.documentSigningStatus", result.documentSigningStatus);
                
                component.set("v.attachmentId", result.quote.AttachmentId__c);
                component.set("v.documentAttachmentId", result.quote.Document_Attachment_Id__c);
                component.set("v.quote", result.quote);
                
               
                /*
                if(result.documentSigningStatus)
                {
                    if(result.documentSigningStatus.indexOf("error") == 0)
                    {
                        component.set("v.documentSigningStatus" , "error");
                        component.set("v.documentSigningStatusMessage" , result.documentSigningStatus.replace("error:","") );

                    }
                    else if(result.documentSigningStatus.indexOf("url") == 0)
                    {
                        component.set("v.documentSigningStatus" , "success");
                        component.set("v.documentSigningStatusMessage" , "Signing Completed");
                        component.set("v.documentSigningUrl" , result.documentSigningStatus.replace("url:","")  );
                    }
                }
                */
                this.populateDocuments(component, result.documents, result.quote.Document_Id__c, result.quote.Document_Signing_Id__c);
                //component.find("ddlLayout").set("v.value", result.quote.Layout_Id__c);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    populateDocuments:function(component, documents, docId, docSigningId){
        
        var docs = [];
        var count = 0;
        for(var key in documents)
        {
            if(count==0)
            {
                docs.push({"name":"Select Document","value":""});
            }
            var obj = {};
            obj.name = key;
            obj.value = documents[key];
            docs.push(obj);
            count ++;
        }
        component.set("v.documents", docs);
        
        setTimeout(function(){
            component.set("v.selectedDocument" , docId );
            component.set("v.documentSigningId" , docSigningId );
            
        },100)
    }, 
    handleLayoutChange: function(component, event){
        var layoutId = event.getSource().get("v.value");
        console.log('layoutId: '+layoutId);
        
        var selectedRecord = component.get("v.selectedRecord");
        console.log('selectedRecord: '+selectedRecord);
        
        var btnStart = component.find("btnStart");
        if(layoutId == "")
        {
            $A.util.addClass(btnStart, 'slds-hide');
            $A.util.removeClass(btnStart, 'slds-show');
        }
        else{
            $A.util.addClass(btnStart, 'slds-show');
            $A.util.removeClass(btnStart, 'slds-hide');
        }
    }, 
    handleChangeDocument: function(component, event){
         
        var documentId = component.get("v.selectedDocument");

        var selectedDocumentName = "";
        var record = component.get("v.documents").find(x=>x.value == documentId);
        if(record)
        {
            selectedDocumentName = record.name
        }
        component.set("v.selectedDocumentName", selectedDocumentName);
        
        var btnStartDoc = component.find("btnStartDocument");
        if(documentId == "")
        {
            $A.util.addClass(btnStartDoc, 'slds-hide');
            $A.util.removeClass(btnStartDoc, 'slds-show');
        }
        else{
            $A.util.addClass(btnStartDoc, 'slds-show');
            $A.util.removeClass(btnStartDoc, 'slds-hide');
        }
    },
    
    navigateToMappings: function(component, event){
        
        var action = component.get("c.getLayoutMappings");
        action.setParams({ layoutId : component.get("v.selectedRecord"), objectName : component.get("v.sObjectName") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                
                var mappings = response.getReturnValue();
                console.log(mappings);
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:AuthentiSignMappingLayout",
                    componentAttributes: {
                        layouts : component.get("v.data"),
                        quoteId : component.get("v.recordId"),
                        layoutId : component.get("v.selectedRecord"),
                        mappings : mappings,
                        objectName : component.get("v.sObjectName")
                    }
                });
                evt.fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    
    navigateToSigners: function(component, event){
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AuthentiSignDocumentSigners",
            componentAttributes: {
                quoteId : component.get("v.recordId"),
                documentId : component.get("v.selectedDocument"),
                documentName : component.get("v.selectedDocumentName"),
                objectName : component.get("v.sObjectName")
            }
        });
        evt.fire();
        
    },
    
    displaypdf: function(component, event){
        
        var  attachmentId = component.get("v.attachmentId");
        if(attachmentId != null)
            window.open("/servlet/servlet.FileDownload?file="+attachmentId,"_blank");
        else{
            
            component.set("v.spinner", true);
            
            var  quote = component.get("v.quote");
            console.log(quote);
            
            var params = { quoteId : quote.Id, signingId : quote.Signing_Id__c, objectName : component.get("v.sObjectName"), isLayout : true };
            console.log(params);
            
            var action = component.get("c.saveAttachment");
            action.setParams(params);
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.spinner", false);
                if (state === "SUCCESS") {
                    // Alert the user with the value returned 
                    // from the server
                    var attachmentId = response.getReturnValue(); 
                    if(attachmentId)
                    {
                        component.set("v.attachmentId", attachmentId);
                        $A.get('e.force:refreshView').fire();
                        window.open("/servlet/servlet.FileDownload?file="+attachmentId,"_blank");
                    }
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    displaypdfdocument: function(component, event){
        
        var  attachmentId = component.get("v.documentAttachmentId");
        if(attachmentId != null)
            window.open("/servlet/servlet.FileDownload?file="+attachmentId,"_blank");
        else{
            
            component.set("v.spinner", true);
            
            var  quote = component.get("v.quote");
            console.log(quote);
            
            var params = { quoteId : quote.Id, signingId : quote.Document_Signing_Id__c, objectName : component.get("v.sObjectName"), isLayout : false };
            console.log(params);
            
            var action = component.get("c.saveAttachment");
            action.setParams(params);
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.spinner", false);
                if (state === "SUCCESS") {
                    // Alert the user with the value returned 
                    // from the server
                    var attachmentId = response.getReturnValue(); 
                    if(attachmentId)
                    {
                        component.set("v.documentAttachmentId", attachmentId);
                        $A.get('e.force:refreshView').fire();
                        window.open("/servlet/servlet.FileDownload?file="+attachmentId,"_blank");
                    }
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
    },
})