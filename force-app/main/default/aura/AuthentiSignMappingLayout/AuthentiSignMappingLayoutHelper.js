({
    doInit : function(component, event) {
         
        component.set("v.spinner",true);
        var quoteId = component.get("v.quoteId");
        var layouts = component.get("v.layouts");
        var layoutId = component.get("v.layoutId");
        var mappings = component.get("v.mappings");
        var objectName = component.get("v.objectName");
        console.log(layoutId);
        console.log(layouts);
        console.log(mappings);
        
        var selectedLayout = layouts.find(x=>x.id == layoutId);
        console.log(selectedLayout);
        console.log(selectedLayout.fields);
        if(selectedLayout)
        {
            component.set("v.fields",selectedLayout.fields);   
            component.set("v.selectedLayout",selectedLayout);
            
            var roles = [];
        	for(var index in selectedLayout.layoutParticipants)
            {
                var recLayoutParticipient = selectedLayout.layoutParticipants[index];
                roles.push({"name" : recLayoutParticipient.role , "value" : recLayoutParticipient.role});
            }
            console.log(roles);
            component.set("v.roles", roles);
        }

        var action = component.get("c.getAllData");
        action.setParams({ recordId : quoteId, objectName : objectName });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var allData = response.getReturnValue(); 
                console.log(allData);
                component.set("v.allData",allData);
                
                
                //populate Quote Field Dropdown
                var quoteFields = [];
                quoteFields.push({"name":"--Select--","value":""});
                for(var fieldName in allData.quoteFieldProps)
                {
                    //console.log(fieldName);
                    var fieldProps = allData.quoteFieldProps[fieldName];
                    //fieldProps
                    var rec = {"name":fieldProps.label, "value" :fieldName}
                    quoteFields.push(rec);
                    
                    if(fieldProps.type.indexOf('REFERENCE') >=0)
                    {
                        var lookupFieldName = '';
                        
                        if(fieldProps.custom == "true")
                        {
                            lookupFieldName = fieldName.replace('__c', '__r');
                        }
                        else
                        {
                            lookupFieldName = fieldName.replace('Id', '').replace('Id', '');
                        }
                        
                        var recRefernece = {"name":fieldProps.label + " > Name", "value" :lookupFieldName, "data": null };
                        quoteFields.push(recRefernece);
                    }
                }
                quoteFields.sort((a, b) => (a.name > b.name) ? 1 : -1);
                component.set("v.quoteFields",quoteFields);
                
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
                
                
                //populate Quote Line Items Field Dropdown
                var quoteLineItemFields = [];
                quoteLineItemFields.push({"name":"--Select--","value":""});
                for(var fieldName in allData.quoteLineItemFieldProps)
                {
                    //console.log(fieldName);
                    //fieldProps
                    var fieldProps = allData.quoteLineItemFieldProps[fieldName];
                    
                    var rec = {"name":fieldProps.label, "value" :fieldName}
                    quoteLineItemFields.push(rec);   
                    
                    if(fieldProps.type.indexOf('REFERENCE') >=0)
                    {
                        var lookupFieldName = '';
                        
                        if(fieldProps.custom == "true")
                        {
                            lookupFieldName = fieldName.replace('__c', '__r');
                        }
                        else
                        {
                            lookupFieldName = fieldName.replace('Id', '').replace('Id', '');
                        }
                        
                        var recRefernece = {"name":fieldProps.label + " > Name", "value" :lookupFieldName};
                        quoteLineItemFields.push(recRefernece);
                    }
                }
                quoteLineItemFields.sort((a, b) => (a.name > b.name) ? 1 : -1);
                component.set("v.quoteLineItemFields",quoteLineItemFields);
                
                //populating quote line items dropdown
                var lineItemRecords = [];
                lineItemRecords.push({"name":"--Select--","value":""});
                for(var index in allData.quoteLineItems)
                {
                    //console.log(fieldName);
                    var lineItemRecord = allData.quoteLineItems[index];
                    
                    var productName = '';
                    //fieldProps
                    if(objectName.toLowerCase() == 'quote')
                    {
                        productName = lineItemRecord.Product2.Name;
                    }else{
                        productName = lineItemRecord.SBQQ__Product__r.Name;
                    }
                    var rec = {"name": productName, "value" :lineItemRecord.Id}
                    lineItemRecords.push(rec);
                }
                lineItemRecords.sort((a, b) => (a.name > b.name) ? 1 : -1);
                component.set("v.lineItemRecords",lineItemRecords);
                
                //Set Expiration Date Field
                var expirationDate = "";
                if(objectName.toLowerCase() == 'quote'){
                    expirationDate = allData.quote.ExpirationDate;
                }
                else{
                    expirationDate = allData.quote.SBQQ__ExpirationDate__c;
                }
                component.set("v.expirationDate",expirationDate);
                
                //participients
                var participients = [];
                for(var key in allData.participientFields)
                {
                    var participientFields =  allData.participientFields[key];
                    
                    //console.log(participients);
                    
                    var referenceField = allData.quote[key];
                    if(referenceField)
                    {
                        var obj = {};
                        for(var index in participientFields)
                        {
                            var fieldName = participientFields[index];
                        	//console.log(fieldName);
                        	if(fieldName.indexOf('(')==0)
                            {
                                var fieldValue = fieldName.replace('(','').replace(')','');
                                fieldValue = fieldValue.indexOf('User') >=0 ? "User": fieldValue;
                            	obj["Object"] = fieldValue;
                            }
                            else{
                                var fieldValue = referenceField[fieldName];
                                //console.log(fieldValue);
                                obj[fieldName] = fieldValue;    
                            }
                        }
                        participients.push(obj);
                    }
                }
                component.set("v.participients",participients);
                console.log(JSON.stringify(participients) );
                
                if(mappings)
                {
                    setTimeout(function(helper){
                        helper.populateFieldsValue(component, mappings);
                        
                    },500, this);
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
            setTimeout(function(){
                component.set("v.spinner",false);
            },100);
        });
        
        $A.enqueueAction(action);
         
    },
    
	populateFieldsValue : function(component, mappings) {
		
        if(mappings)
        {
            
            var liCheckboxes = component.find("chkQuoteLI");
            var ddlQuoteFields = component.find("ddlQuoteFields");
            var ddlLineItems = component.find("ddlLineItems");
            var ddlQuoteLineItemFields = component.find("ddlQuoteLineItemFields");
            var objMappings = JSON.parse(mappings);
            
            if(liCheckboxes.length > 0)
            {
                for(var index in liCheckboxes)
                {
                    var liChkBox = liCheckboxes[index];
                    var ddlQuote = ddlQuoteFields[index];
                    var ddlLineItem = ddlLineItems[index];
                    var ddlQuoteLineItemField = ddlQuoteLineItemFields[index];
                     
                    var forWhich = liChkBox.get("v.title");
                    var mapping = objMappings.fieldsMap[forWhich];
                    if(mapping)
                    {
                        if(mapping.object == "lineitem")
                        {
                            liChkBox.set("v.checked", true);
                            ddlLineItem.set("v.value", mapping.lineItemId);
                            ddlQuoteLineItemField.set("v.value", mapping.field);
                            
                            this.isChecked(true, ddlQuote, ddlLineItem, ddlQuoteLineItemField);
                            
                            component.set("v.lineItemField", mapping.field);
                            this.handleChangeQuoteLineItemddl(component, mapping.lineItemId, ddlLineItem.get("v.name"));
                            
                        }else{
                            ddlQuote.set("v.value", mapping.field);
                            
                            this.isChecked(false , ddlQuote, ddlLineItem, ddlQuoteLineItemField);
                            this.handleChangeQuoteddl(component, mapping.field , ddlQuote.get("v.name"));
                        }
                    }
                }
            }else{
                var liChkBox = liCheckboxes;
                var ddlQuote = ddlQuoteFields;
                var ddlLineItem = ddlLineItems;
                var ddlQuoteLineItemField = ddlQuoteLineItemFields;
                
                var forWhich = liChkBox.get("v.title");
                var mapping = objMappings.fieldsMap[forWhich];
                if(mapping)
                {
                    if(mapping.object == "lineitem")
                    {
                        liChkBox.set("v.checked", true);
                        ddlLineItem.set("v.value", mapping.lineItemId);
                        ddlQuoteLineItemField.set("v.value", mapping.field);
                        
                        this.isChecked(true, ddlQuote, ddlLineItem, ddlQuoteLineItemField);
                        
                        component.set("v.lineItemField", mapping.field);
                        this.handleChangeQuoteLineItemddl(component, mapping.lineItemId, ddlLineItem.get("v.name"));
                        
                    }else{
                        ddlQuote.set("v.value", mapping.field);
                        
                        this.isChecked(false , ddlQuote, ddlLineItem, ddlQuoteLineItemField);
                        this.handleChangeQuoteddl(component, mapping.field , ddlQuote.get("v.name"));
                    }
                }
            }
            
            var ddlUserContacts = component.find("ddlUserContact");
            
            for(var key in objMappings.rolesMap)
            {
                console.log(objMappings.rolesMap[key])
                for(var index in ddlUserContacts)
                {
                    var ddlUserContact = ddlUserContacts[index] == undefined ? ddlUserContacts : ddlUserContacts[index];
                    var title = ddlUserContact.get("v.title");
                    if(title == key)
                    {
                        ddlUserContact.set("v.value",objMappings.rolesMap[key]);
                        this.handleUserContactddl(component, objMappings.rolesMap[key], ddlUserContact.get("v.name"));   
                        break;
                    }
                }
            }
        }        
	},
    
    isChecked: function(isChecked, ddlQuotesCtrl, ddlQuoteLineItemsCtrl, ddlLineItemsCtrl){
        if(isChecked)
        {
            //Hide Quote
            $A.util.addClass(ddlQuotesCtrl, 'slds-hide');
            $A.util.removeClass(ddlQuotesCtrl, 'slds-show');
            
            //Show Quote Lineitems
            $A.util.addClass(ddlQuoteLineItemsCtrl, 'slds-show');
            $A.util.removeClass(ddlQuoteLineItemsCtrl, 'slds-hide');
            
            $A.util.addClass(ddlLineItemsCtrl, 'slds-show');
            $A.util.removeClass(ddlLineItemsCtrl, 'slds-hide');
            
        }
        else
        {
            //Show Quote
            $A.util.addClass(ddlQuotesCtrl, 'slds-show');
            $A.util.removeClass(ddlQuotesCtrl, 'slds-hide');
            
            //Hide Quote Lineitems
            $A.util.addClass(ddlQuoteLineItemsCtrl, 'slds-hide');
            $A.util.removeClass(ddlQuoteLineItemsCtrl, 'slds-show');
            
            $A.util.addClass(ddlLineItemsCtrl, 'slds-hide');
            $A.util.removeClass(ddlLineItemsCtrl, 'slds-show');
        }
    },
    
    handleChangeQuoteddl: function(component, value, name){
         
        var nameSplit = name.split("-");
        
        //get the list of control
        var txtCtrls = component.find('txtquotefieldvalue');
        //console.log(txtCtrls);
    	 
        //get the actual control by index
        var txtControl = txtCtrls[nameSplit[1]] == undefined ? txtCtrls : txtCtrls[nameSplit[1]] ;
        //console.log(txtControl);
         
        var allData = component.get("v.allData");
        
        //console.log(allData.quote[value]);
        var txtControlValue = allData.quote[value];
        //console.log(typeof(allData.quote[value]));
        
        if(typeof(txtControlValue) == "object")
        {
            txtControlValue = txtControlValue.Name == undefined ? "" : txtControlValue.Name; 
        }
        
        //setting the value of textbox
        txtControl.set("v.value",txtControlValue);
        //console.log(txtControlValue);
    },
    
    handleChangeQuoteLineItemddl: function(component, selection, name){
        
        var index = name.split("-")[1];
        console.log(index);
        
        
        //get the list of control
        var txtCtrls = component.find('txtquotefieldvalue');
        console.log(txtCtrls);
        
        var allData = component.get("v.allData");
        console.log(allData);
        
        //get the actual control by index
        var txtControl = txtCtrls.length == undefined ? txtCtrls : txtCtrls[index];
        console.log(txtControl);
        
        if(name.indexOf("ddlLineItems") >= 0)
        {
            var lineItemId = selection;
            component.set("v.lineItemId", lineItemId);
            var lineItemField = component.get("v.lineItemField");

            console.log(lineItemId);
            console.log(lineItemField);
            
            if(lineItemField != "" && lineItemId != "")
            {
                var lineItemRecord = allData.quoteLineItems.find(x=>x.Id == lineItemId);
                console.log(lineItemRecord);
                
                var txtControlValue = lineItemRecord[lineItemField];
        
                if(typeof(txtControlValue) == "object")
                {
                    txtControlValue = txtControlValue.Name == undefined ? "" : txtControlValue.Name; 
                }
            	txtControl.set("v.value", txtControlValue);
            }
            else
            {
                txtControl.set("v.value", "");
            }
        }
        else if(name.indexOf("ddlSFQuoteLineItemField") >= 0)
        {
            var lineItemField = selection;
            component.set("v.lineItemField", lineItemField);
            var lineItemId = component.get("v.lineItemId");
            
            console.log(lineItemId);
            console.log(lineItemField);

            if(lineItemField != "" && lineItemId != "")
            {
                var lineItemRecord = allData.quoteLineItems.find(x=>x.Id == lineItemId);
                console.log(lineItemRecord);
                
            	var txtControlValue = lineItemRecord[lineItemField];
        
                if(typeof(txtControlValue) == "object")
                {
                    txtControlValue = txtControlValue.Name == undefined ? "" : txtControlValue.Name; 
                }
                
            	txtControl.set("v.value", txtControlValue);
                
                
            }else{
                txtControl.set("v.value", "");
            }
        }
    },
    
    handleUserContactddl: function(component, fieldName, nameAttr){
        var index = eval(nameAttr.split("-")[1]);
        
        var allData = component.get("v.allData");
        
        var lookupField  = allData.usercontactfieldmap[fieldName];
        console.log(lookupField);
        
        var quoteRecord = allData.quote[lookupField];
    	console.log(quoteRecord);

        var roles = component.get("v.roles");
        var role = roles[index];
        if(quoteRecord)
        {
            role.data = quoteRecord;
            
            var participientFields = allData.participientFields[lookupField];
            var objectType = participientFields[participientFields.length -1];
            objectType = objectType.replace('(','').replace(')','');
            objectType = objectType.indexOf('User') >=0 ? "User": objectType;
            
            role.data.Type = objectType;
        }
        else{
            var objRole = {};
            objRole.Name = "";
            objRole.Email = "";
            objRole.FirstName = "";
            objRole.Id = "";
            objRole.LastName ="";
            objRole.Type= "";

            role.data = objRole;
        }

        component.set("v.roles", roles);
    },
    
    chkQuoteLIChange: function(component, event){
        var isChecked = event.getSource().get("v.checked");
        console.log(isChecked);
        
        var name = event.getSource().get("v.name");
        console.log(name);
        var nameSplit = name.split("-");
        var index = nameSplit[1];
        
        var ddlQuotes = component.find("ddlQuoteFields");
        var ddlQuoteLineItems = component.find("ddlQuoteLineItemFields");
        var ddlLineItems = component.find("ddlLineItems");
        var txtCtrls = component.find('txtquotefieldvalue');
        
        var ddlQuotesCtrl = ddlQuotes.length == undefined ? ddlQuotes :ddlQuotes[index];
        var ddlQuoteLineItemsCtrl = ddlQuoteLineItems.length == undefined ? ddlQuoteLineItems : ddlQuoteLineItems[index];
        var ddlLineItemsCtrl = ddlLineItems.length == undefined ? ddlLineItems  : ddlLineItems[index];
        var txtCtrlsCtrl = txtCtrls.length == undefined ? txtCtrls : txtCtrls[index];
        
        //resetting all values
        ddlQuotesCtrl.set("v.value","");
        ddlQuoteLineItemsCtrl.set("v.value","");
        ddlLineItemsCtrl.set("v.value","");
        txtCtrlsCtrl.set("v.value","");
        component.set("v.lineItemField","");
        component.set("v.lineItemId","");
        
        this.isChecked(isChecked, ddlQuotesCtrl, ddlQuoteLineItemsCtrl, ddlLineItemsCtrl);
    },
    
    back: function(component, event){
        var quoteId = component.get("v.quoteId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": quoteId,
            "slideDevName": "related"
        });
        navEvt.fire(); 
    },
    
    submitRequest : function(component, event){

        component.set("v.spinner",true);        
        var allData = component.get("v.allData");
        
        var liCheckboxes = component.find("chkQuoteLI");
        var ddlQuoteFields = component.find("ddlQuoteFields");
        var ddlLineItems = component.find("ddlLineItems");
        var ddlQuoteLineItemFields = component.find("ddlQuoteLineItemFields");
        var objectName = component.get("v.objectName");
        
        var listErrors = [];
        
        //Check for expiration date
        var expirationDate = "";
        if(objectName.toLowerCase() == 'quote'){
            expirationDate = allData.quote.ExpirationDate;
        }
        else{
            expirationDate = allData.quote.SBQQ__ExpirationDate__c;
        }
        
        if(!expirationDate){
            listErrors.push("* Expiration date is not provided");
        }
        
        var ddlUserContacts = component.find("ddlUserContact");
        var hasUserContactValue = false;
        for(var index in ddlUserContacts)
        {
            var ddlUserContact = ddlUserContacts.length == undefined ? ddlUserContacts : ddlUserContacts[index];
            if(ddlUserContact.get("v.value"))
            {
                hasUserContactValue = true;
                break;
            }
            
            try {
                var indexNumber = parseInt(index);
                if(isNaN(indexNumber)  || typeof(indexNumber) != "number")
                    break;
            }
            catch(err) {
                console.log(err);
                break;
            }
                
        }
        if(hasUserContactValue == false)
        {
            var parti = listErrors.indexOf("* Please select user/contact value in participants");
            if(parti == -1)
                listErrors.push("* Please select user/contact value in participants");
        }
        
        if(listErrors.length > 0)
        {
            component.set("v.spinner",false);
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Fix error(s)!",
                "message": listErrors.join("\n")
            });
            toastEvent.fire();
        	return;
        }
        
        
        var layoutId = component.get("v.layoutId");
        
        var ddlQuotes = component.find("ddlQuoteFields");
        //console.log(ddlQuotes);
        
        var fields = component.get("v.fields");
        //console.log(fields);
        var txtCtrls = component.find('txtquotefieldvalue');
        //console.log(txtCtrls);
        
        var objFields = {};
        var objFieldsMap = {};
        for(var key in fields)
        {
            objFields[fields[key]] = txtCtrls[key] == undefined ? txtCtrls.get("v.value") :  txtCtrls[key].get("v.value");
            var isLineItem = false;
            var liCheckBox = liCheckboxes[key] == undefined ? liCheckboxes : liCheckboxes[key];
            if(liCheckBox)
            {
                isLineItem = liCheckBox.get("v.checked");
            }
            if(isLineItem)
            {
                var fldName = ddlQuoteLineItemFields[key] == undefined ? ddlQuoteLineItemFields.get("v.value") :  ddlQuoteLineItemFields[key].get("v.value");
                var fldVal =  ddlLineItems[key] == undefined ? ddlLineItems.get("v.value") :  ddlLineItems[key].get("v.value");
                objFieldsMap[fields[key]] = {"object": "lineitem" , "field" : fldName, "lineItemId" : fldVal};
            }
            else{
                var fldName = ddlQuotes[key] == undefined ? ddlQuotes.get("v.value") :  ddlQuotes[key].get("v.value");
                objFieldsMap[fields[key]] = {"object": "quote" , "field" : fldName};
            }
        }
        
        //console.log(objFields);
        //console.log(JSON.stringify(objFields) );
        
        var participients = component.get('v.participients');
        //console.log(JSON.stringify(participients));
        
        var requestParticipients = [];
        var roles = component.get("v.roles");
        var rolesMap = {};
        for(var index in roles)
        {
            var role = roles[index];
            rolesMap[role.name] =  ddlUserContacts[index] == undefined ? ddlUserContacts.get("v.value") :  ddlUserContacts[index].get("v.value");
            if(role.data && role.data.LastName && role.data.Email)
            {
                var objp = {};
                objp.firstname = role.data.FirstName;
                objp.middlename = "";
                objp.lastname = role.data.LastName;
                objp.email = role.data.Email;
                objp.type = 0;
                objp.participantRole = role.name;
                objp.staticSignatureEnabled = true;
                objp.scriptedSignatureEnabled = true;
                objp.imageSignatureEnabled = true;
                
                requestParticipients.push(objp);                
            }
            
        }
         
        
        var finalObj = {};
        
        finalObj.name = allData.quote.Name;
        finalObj.isOrdered = false;
        finalObj.expirationDate = expirationDate == null ? "" : expirationDate+"T00:00:00.000Z";
        finalObj.callbackUrl = "##callbackurl##";
        finalObj.layoutId = component.get("v.layoutId");
        finalObj.fields = objFields;
        finalObj.participants = requestParticipients;
        
        var mappings = {};
        mappings.fieldsMap = objFieldsMap;
        mappings.rolesMap = rolesMap;
        var jsonMappings = JSON.stringify(mappings);
        
        var requestString = JSON.stringify(finalObj);
        console.log(requestString);
         
        var action = component.get("c.fillandSubmit");
        action.setParams({ requestString : requestString , quoteId : allData.quote.Id, layoutId: layoutId, mappings : jsonMappings, objectName : component.get("v.objectName") });
        
        action.setCallback(this, function(response) {
            
            component.set("v.spinner",false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var data = response.getReturnValue(); 
                console.log(data);
                if(data != '')
                {
                    /*
                    setTimeout(function(){
                        
                        var innerAction = component.get("c.savePDFasAttachment");
                        innerAction.setParams({ quoteId : allData.quote.Id, signingId: data, objectName : component.get("v.objectName") });
                        innerAction.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                // Alert the user with the value returned 
                                // from the server
                                var attachmentId = response.getReturnValue(); 
                                console.log(attachmentId);
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "success",
                                    "title": "Success!",
                                    "message": "Signing submitted successfully."
                                });
                                toastEvent.fire();
                                
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": allData.quote.Id,
                                    "slideDevName": "related"
                                });
                                navEvt.fire();
                            }
                            
                            component.set("v.spinner",false);
                        });
                        $A.enqueueAction(innerAction);
                        
                        
                            
                    },2000);*/
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "Signing submitted successfully."
                    });
                    toastEvent.fire();
                    
                    setTimeout(function(){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": allData.quote.Id,
                            "slideDevName": "related"
                        });
                        navEvt.fire();    
                    },2000);
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": "Something went wrong, please contact System Adiminstrator."
                    });
                    toastEvent.fire();
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
})