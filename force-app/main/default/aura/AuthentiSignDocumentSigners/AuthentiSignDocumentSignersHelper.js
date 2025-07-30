({
    doInit : function(component, event) {
        
        component.set("v.spinner",true);
        
        var quoteId = component.get("v.quoteId");
        var documentId = component.get("v.documentId");
        var objectName = component.get("v.objectName");
        var documentName = component.get("v.documentName");
        
        var action = component.get("c.getAllData");
        action.setParams({ recordId : quoteId, objectName : objectName });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var allData = response.getReturnValue(); 
                component.set("v.allData",allData);
                
                //populate user contact fields drop down
                var usercontactfields = [];
                usercontactfields.push({"name":"--Select--","value":""});
                for(var fieldName  in allData.usercontactfieldmap)
                {
                    var rec = {"name": allData.quoteFieldProps[fieldName].label , "value" :fieldName , "lookupname" : allData.usercontactfieldmap[fieldName]}
                    usercontactfields.push(rec);
                }
                usercontactfields.sort((a, b) => (a.name > b.name) ? 1 : -1);
                component.set("v.usercontactfields",usercontactfields);
                
                this.addSignerByDefault(component, allData);
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
            
            setTimeout(function(){
                component.set("v.spinner",false);
            },100);
        });
        
        $A.enqueueAction(action);
        
    },
    addSignerByDefault : function(component, allData)
    {
        var signers = component.get("v.signers");
        var objSigner = {};
        objSigner.data = {};
        
        var objectName = component.get("v.objectName");
        var fieldName = "";
        if(objectName == "SBQQ__Quote__c")
        {
            fieldName = "SBQQ__PrimaryContact__c";
        }else{
            fieldName = "ContactId";
        }
        
        var lookupField  = allData.usercontactfieldmap[fieldName];
        var quoteRecord = allData.quote[lookupField];
        
        if(quoteRecord)
        {
            objSigner.data = quoteRecord;
            
            var participientFields = allData.participientFields[lookupField];
            var objectType = participientFields[participientFields.length -1];
            objectType = objectType.replace('(','').replace(')','');
            objectType = objectType.indexOf('User') >=0 ? "User": objectType;
            
            objSigner.data.Type = objectType;
        }
        objSigner.data.Role = "Signer 1";
        signers.push(objSigner);  
        component.set("v.signers", signers);
        
        setTimeout(function(){
            component.find("{!'ddlUserContact-'+index}").set("v.value", fieldName);
        },100)
    },
    
    handleUserContactddl : function(component, fieldName, nameAttr){
        var index = eval(nameAttr.split("-")[1]);
        
        var allData = component.get("v.allData");
        
        var lookupField  = allData.usercontactfieldmap[fieldName];
        console.log(lookupField);
        
        var quoteRecord = allData.quote[lookupField];
    	console.log(quoteRecord);

        var signers = component.get("v.signers");
        var signer = signers[index];
        if(quoteRecord)
        {
            signer.data = quoteRecord;
            
            var participientFields = allData.participientFields[lookupField];
            var objectType = participientFields[participientFields.length -1];
            objectType = objectType.replace('(','').replace(')','');
            objectType = objectType.indexOf('User') >=0 ? "User": objectType;
            
            signer.data.Type = objectType;
        }
        else{
            var objSigner = {};
            objSigner.data = {};
            //objSigner.data.Role = "";
            objSigner.data.Name = "";
            objSigner.data.Email = "";
            objSigner.data.FirstName = "";
            objSigner.data.Id = "";
            objSigner.data.LastName ="";
            objSigner.data.Type= "";

            signer.data = objSigner;
        }

        component.set("v.signers", signers);
    },
    
    addSigner : function(component, event){
        var signers = component.get("v.signers");
        var objSigner = {};
        objSigner.data = {};
        //objSigner.data.Role = "";
        objSigner.data.Name = "";
        objSigner.data.Email = "";
        objSigner.data.FirstName = "";
        objSigner.data.Id = "";
        objSigner.data.LastName ="";
        objSigner.data.Type = "";
        signers.push(objSigner);

        component.set("v.signers", signers);
    },
    
    deleteSigner : function(component, btnName, event){
        var index = eval(btnName.split("-")[1]);
        var signers = component.get("v.signers");
        var signer = signers[index];
        
        signers.splice(index, 1);
        component.set("v.signers", signers);
    },
    
    back: function(component, event){
        debugger;
        var quoteId = component.get("v.quoteId");
        this.navigateToRecord(component, quoteId);
    },
    
    navigateToRecord : function(component, recordId)
    {
        var navEvt = $A.get("e.force:navigateToSObject");
        if(navEvt)
        {
            navEvt.setParams({
                "recordId": recordId,
                "slideDevName": "related"
            });
            navEvt.fire();    
        }else{
            //window.location("/"+recordId);
            var msgForVf="Hi This message was pass from component to me and I am VF page displaying this message";
            var vfMethod=component.get("v.VfPageMethod");
            vfMethod(msgForVf,function()
                     {
                         
                         
                         
                     });
        }
    },
    
    createRequest : function(component, event){
        
        component.set("v.spinner",true);
        
        var signers = component.get("v.signers");
        var allData = component.get("v.allData");
        var requestString = JSON.stringify(signers);
        console.log(requestString);
        
        var errorMessage = "";
        if(signers.length == 0)
        {
            errorMessage = "No signer added, please add signers.";
        }
        else{
            for(var key in signers)
            {
                var signer = signers[key];
                console.log(signer);
                if(!signer.data.Id)
                {
                    errorMessage += "Please select valid User/Contact\r\n";
                }
                if(!signer.data.Role)
                {
                    errorMessage += "Please add the role of signer\r\n";
                }
                
                if(errorMessage != "")
                    break;
            }
        }
        
        if(errorMessage != "")
        {
            component.set("v.spinner",false);
            this.showToastMessage(component, errorMessage ,"error");
            
            return;
        }
        
        var action = component.get("c.submitDocumentRequest");
        action.setParams({
            			  requestString : requestString , 
                          quoteId : allData.quote.Id,
            			  quoteName : allData.quote.Name,
                          documentId: component.get("v.documentId"), 
                          documentName : component.get("v.documentName"),
                          objectName : component.get("v.objectName") 
                         });
        
        action.setCallback(this, function(response) {
            
            component.set("v.spinner",false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var data = response.getReturnValue(); 
                console.log(data);
                if(data)
                {
                    if(data.status == 'success')
                    {
                        
                        /*
                        setTimeout(function(){
                            
                            var innerAction = component.get("c.savePDFasAttachmentDocument");
                            innerAction.setParams({ quoteId : allData.quote.Id, signingId: data.result, objectName : component.get("v.objectName") });
                            innerAction.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    // Alert the user with the value returned 
                                    // from the server
                                    var attachmentId = response.getReturnValue(); 
                                    console.log(attachmentId);
                                    
                                    this.showToastMessage(component, "Signing submitted successfully.","success");
                                    
                                    this.navigateToRecord(component, allData.quote.Id);
                                }
                                
                                component.set("v.spinner",false);
                            });
                            $A.enqueueAction(innerAction);

                        },2000);*/
                        
                        this.showToastMessage(component, "Signing submitted successfully.","success");
                        
                        
                        this.navigateToRecord(component, allData.quote.Id);  
                        
                        
                    }
                    if(data.status.indexOf("error") == 0){
                        
                        this.showToastMessage(component, data.result.replace("{","").replace("}",""),"error");
                    }
                }
                else{
                     
                    this.showToastMessage(component, "Something went wrong, please contact System Adiminstrator.","error");
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
    },
    showToastMessage: function(component, message, type)
    {
        component.set("v.showMessage", false);
        if(type =='success')
        {
            var toastEvent = $A.get("e.force:showToast");
            
            if(toastEvent)
            {
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": message
                });
                toastEvent.fire(); 
            }
            else{
                component.set("v.showMessage", true);
                component.set("v.message", message);
                component.set("v.messageType", "confirm");
                component.set("v.messageTitle", "Success");
            }
        }
        else if(type =='error')
        {
            var toastEvent = $A.get("e.force:showToast");
            if(toastEvent)
            {
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": message
                });
                toastEvent.fire();
            }
            else{
                component.set("v.showMessage", true);
                component.set("v.message", message);
                component.set("v.messageType", "error");
                component.set("v.messageTitle", "Error");
            }
        }
    }
})