/*
*********************************************************
@Apex Class Name    : LayoutListVFController
@Created Date       : Dec 12, 2023
@description        : Extension Class for LayoutList vf page for classic implementation
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutListVFController {
    
    private Id recordId {get;set;}
    private string objectName {get;set;}
    private string signingId {get;set;}
    private LayoutWrapper selectedLayoutData {get;set;}
    private LayoutResponse response {get;set;}
    private LayoutListVFHelper helper {get;set;}
    private string expirationDateField {get;set;}
    
    public RecordsFields allMappingData {get;set;}
    public boolean showLayoutPage {get;set;}
    public List<SelectOption> layouts {get;set;}
    public List<SelectOption> documents {get;set;}
    public List<SelectOption> selectOptions {get;set;}
    public string selectedLayout {get;set;}
    public string selectedDocument {get;set;}
    public string selectedOption {get;set;}
    public string savedLayoutId {get;set;}
    public string signingStatus {get;set;}
    public string documentSigningStatus {get;set;}
    public string documentSigningId {get;set;}
    public string documentLink {get;set;}
    public string attachmentId {get;set;}
    public string documentAttachmentId {get;set;}
         
    public List<SelectOption> selectOptionQuote {get;set;}
    public List<SelectOption> selectOptionQuoteLI {get;set;}
    public List<SelectOption> selectOptionLIRecords {get;set;}
    public List<SelectOption> selectOptionUserContact {get;set;}
    public List<FieldMappingValue> mappingValues {get;set;}
    public List<ParticipantMappingValue> participantMappingValues {get;set;}
    
    /*
    *********************************************************
    @Method Name    : LayoutListVFController
    @description    : constructor with standard controller parameter
    @param          : ApexPages.StandardController con
    @return         : void
    ********************************************************
    */
    public LayoutListVFController(ApexPages.StandardController con)
    {
        initialize();
        response = LayoutListHelper.getLayouts(recordId, objectName);
        populateInitialValues();
    }
    
    /*
    *********************************************************
    @Method Name    : LayoutListVFController
    @description    : empty constructor
    @param          : N/A
    @return         : void
    ********************************************************
    */
    public LayoutListVFController()
    {
        initialize();
    }
    
    /*
    *********************************************************
    @Method Name    : initialize
    @description    : empty constructor
    @param          : N/A
    @return         : void
    ********************************************************
    */
	public void initialize()
    {
        helper = new LayoutListVFHelper();
        recordId  = ApexPages.CurrentPage().getparameters().get('id');
        objectName = recordId.getSObjectType().getDescribe().getName();
        signingId = '';
        showLayoutPage = true;
        selectedLayoutData = new LayoutWrapper();
        selectedLayout = '';
        selectedDocument = '';
        selectedOption = 'Document';
        savedLayoutId = '';
        signingStatus = '';
        documentSigningStatus = '';
        documentSigningId = '';
        documentLink = '';
        attachmentId = '';
        documentAttachmentId = '';
        layouts = new List<SelectOption>();
        documents = new List<SelectOption>();
        selectOptions = new List<SelectOption>();
        
        if(objectName.toLowerCase() == 'quote'){
            expirationDateField = 'ExpirationDate';
        }else{
            expirationDateField = 'SBQQ__ExpirationDate__c';
        }
    }
    
    /*
    *********************************************************
    @Method Name    : populateInitialValues
    @description    : populate initial values
    @param          : N/A
    @return         : void
    ********************************************************
    */
    public void populateInitialValues()
    {
        populateLayoutSelectOption();
        
        populateDocumentSelectOption();
        
        populateMainSelectOption();
        
        setSigningStatus();
        
        popualteAuthentisignFields();
    }
    
    public void setSigningStatus()
    {
        signingStatus = response.signingStatus;
        
        documentSigningStatus = response.documentSigningStatus;
        /*
        if(!(response.documentSigningStatus == '' || response.documentSigningStatus == null))
        {
            if(response.documentSigningStatus.indexOf('error:') == 0)
            {
                documentSigningStatus = response.documentSigningStatus.replace('error:','');
            }
            else if(response.documentSigningStatus.indexOf('url:') == 0)
            {
                documentSigningStatus = 'success';
                documentLink = response.documentSigningStatus.replace('url:','');
                documentLink = documentLink.trim();
            }
        }*/
    }
    
    /*
    *********************************************************
    @Method Name    : populateLayoutSelectOption
    @description    : populate drop down values 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateLayoutSelectOption()
    {
        layouts = helper.populateLayoutSelectOption(response);
    }
    
    /*
    *********************************************************
    @Method Name    : populateDocumentSelectOption
    @description    : populate drop down values 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateDocumentSelectOption()
    {
        documents = helper.populateDocumentSelectOption(response);
    }
    
    /*
    *********************************************************
    @Method Name    : populateMainSelectOption
    @description    : populate drop down values 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateMainSelectOption()
    {
        SelectOption option1 = new SelectOption('Document', 'Document');
        SelectOption option2 = new SelectOption('Layout', 'Layout');
        selectOptions.add(option1);
        selectOptions.add(option2);
    }
    
    /*
    *********************************************************
    @Method Name    : popualteAuthentisignFields
    @description    : get saved values and populate it to the fields
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void popualteAuthentisignFields()
    {
        //Get saved authentisign quote field values
        if(response.quote != null)
        {
            if(response.quote.get('Layout_Id__c') != null){
                selectedLayout = (string)response.quote.get('Layout_Id__c');
                savedLayoutId = selectedLayout;
            }
            if(response.quote.get('AttachmentId__c') != null){
                attachmentId = string.valueOf( response.quote.get('AttachmentId__c'));
            }
            if(response.quote.get('Signing_Id__c') != null){
                signingId = string.valueOf(response.quote.get('Signing_Id__c'));
            }
            if(response.quote.get('Document_Id__c') != null){
                selectedDocument = string.valueOf(response.quote.get('Document_Id__c'));
            }
            if(response.quote.get('Document_Signing_Id__c') != null){
                documentSigningId = string.valueOf(response.quote.get('Document_Signing_Id__c'));
            }
            if(response.quote.get('Document_Attachment_Id__c') != null)
            {
                documentAttachmentId = string.valueOf(response.quote.get('Document_Attachment_Id__c'));
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : GeneratePDF
    @description    : calls utility class to save pdf as attachment
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference GeneratePDF()
    {
        attachmentId = DataLayer.getAttachmentId(recordId, objectName, true);
        if(attachmentId == '')
        {
            attachmentId = Utility.savePDFasAttachment(recordId, signingId, 'ls', objectName);
        }
         
        
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : GeneratePDFDocument
    @description    : calls utility class to save document pdf as attachment
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference GenerateDocumentPDF()
    {
        documentAttachmentId = DataLayer.getAttachmentId(recordId, objectName, false);
        if(documentAttachmentId == '')
        {
            documentAttachmentId = attachmentId = Utility.savePDFasAttachmentDocument(recordId, documentSigningId, 'ls', objectName);
        }
        
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : GotoMappings
    @description    : change screen from layout to mappings and set all the values for next screen 
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference GotoMappings()
    {
        showLayoutPage = false;
        mappingValues = new List<FieldMappingValue>();
        participantMappingValues = new List<ParticipantMappingValue>();
        
        allMappingData = AuthentiSignMappingHelper.getAllData(recordId, objectName);
        string existingMapJSON = DataLayer.getLayoutMappings(selectedLayout, objectName);
        //System.debug('existingMapJSON: '+ existingMapJSON);
        populateSelectedLayoutData();
        
        //System.debug('selectedLayoutData: '+ selectedLayoutData);
        //System.debug('existingMapJSON: '+ existingMapJSON);
        
        
        if(selectedLayoutData != null)
        {
            Map<string,object> existingMap = new Map<string,object>();
            if(string.IsNotBlank(existingMapJSON))
            {
                existingMap = (Map<string,object>)JSON.deserializeUntyped(existingMapJSON);
            }
            
            fillFieldsMap(existingMap);            
            fillParticipantMap(existingMap);
        }
        
        populateAllSelectOptions();

        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : GotoSignersLayout
    @description    : change screen from layout to add signer screen 
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference GotoSignersLayout()
    {
        showLayoutPage = false;
        participantMappingValues = new List<ParticipantMappingValue>();
        
        allMappingData = AuthentiSignMappingHelper.getAllData(recordId, objectName);
         
        populateUserContactSelectOption();

        addDefaultSigner();
        return null;
    }
    
    public void addDefaultSigner()
    {
        ParticipantMappingValue record = new ParticipantMappingValue();
        record.name = '';
        record.email = '';
        record.lookupid = '';
        record.objecttype = '';
        record.firstname = '';
        record.lastname = '';
        record.role = 'Signer 1';
        if(objectName == 'SBQQ__Quote__c')
        {
        	record.lookupfield = 'SBQQ__PrimaryContact__c';
        }
        else{
            record.lookupfield = 'ContactId';
        }
        participantMappingValues.add(record);
        
        integer index = -1;
        for(ParticipantMappingValue rec : participantMappingValues)
        {
            index = index+1; 
            rec.index = index;
        }
        
        SetParticipantValues();
        
        System.debug('participantMappingValues: '+ participantMappingValues);
    }
    
    /*
    *********************************************************
    @Method Name    : populateSelectedLayoutData
    @description    : set the variable selectedLayoutData when drop down is changed in the layout screen  
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateSelectedLayoutData()
    {
        for(LayoutWrapper record : response.wrapper)
        {
            if(record.id == selectedLayout)
            {
                selectedLayoutData = record;
                break;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : fillFieldsMap
    @description    : populate the fields data when on mapping screen   
    @param          : Map<string,object> existingMap
    @return         : void
    ********************************************************
    */
    private void fillFieldsMap(Map<string,object> existingMap){
        //Setting Fields Map
        Map<string,Map<string,string>> fieldsMap = new Map<string,Map<string,string>>();
        
        if(existingMap != null && existingMap.size() > 0 && existingMap.get('fieldsMap') != null)
        {
            string strExistingFIeldMap = JSON.serialize(existingMap.get('fieldsMap'));
            //System.debug('strExistingFIeldMap: '+strExistingFIeldMap);
            fieldsMap =  (Map<string,Map<string,string>>)JSON.deserialize(strExistingFIeldMap,Map<string,Map<string,string>>.class);
        }
        
        //System.debug('fieldsMap: '+ fieldsMap);
        for(string field : selectedLayoutData.fields)
        {
            FieldMappingValue item = new FieldMappingValue();
            item.ASFieldName = field;
            if(fieldsMap != null)
            {
                if(fieldsMap.containsKey(field))
                {
                    Map<string,string> fieldProp = fieldsMap.get(field);
                    item.Field = (string)fieldProp.get('field');
                    item.ObjectName = (string)fieldProp.get('object');
                    if(item.ObjectName == 'lineitem')
                    {
                        item.IsLineItem = true;
                        item.LineItemId = (string)fieldProp.get('lineItemId');
                    }
                }
            }
            mappingValues.add(item);
        }
        
        integer index = 0;
        Map<string, integer> lineItemIndex = new Map<string,integer>();
        if(allMappingData.quoteLineItems != null)
        {
            for(SObject record : allMappingData.quoteLineItems)
            {
                lineItemIndex.put((string)record.get('Id'),index);
                index +=1;
            }
        }
        
        
        //Setting line item index
        for(FieldMappingValue record : mappingValues)
        {
            if(record.IsLineItem)
            {
                record.LineItemIndex = string.valueOf(lineItemIndex.get(record.LineItemId));
            }
        }
        
        SetFieldValues();
    }
    
    /*
    *********************************************************
    @Method Name    : fillParticipantMap
    @description    : populate the participants data when on mapping screen   
    @param          : Map<string,object> existingMap
    @return         : void
    ********************************************************
    */
    private void fillParticipantMap(Map<string,object> existingMap){
        Map<string, string> participantsMap = new Map<string, string>();        
        if(existingMap != null && existingMap.get('rolesMap') != null)
        {
            string strExistingParticipantMap = JSON.serialize(existingMap.get('rolesMap'));
            //System.debug('strExistingParticipantMap: '+strExistingParticipantMap);
            participantsMap =  (Map<string, string>)JSON.deserialize(strExistingParticipantMap,Map<string, string>.class);
        }
        
        //System.debug('participantsMap: '+ participantsMap);
        //System.debug('selectedLayoutData.layoutParticipants: '+ selectedLayoutData.layoutParticipants);
        //Setting Participant Map
        for(LayoutParticipant record : selectedLayoutData.layoutParticipants)
        {
            ParticipantMappingValue pa = new ParticipantMappingValue();
            pa.role = record.role;
            pa.lookupfield = participantsMap.size() == 0 ? '' : string.valueOf(participantsMap.get(record.role)) ;
            pa.lookupid = '';
            pa.name = '';
            pa.email = '';
            pa.objecttype = '';
            pa.firstname = '';
            pa.lastname = '';
            
            participantMappingValues.add(pa);
        }
        SetParticipantValues();
    }
    
	/*
    *********************************************************
    @Method Name    : BackToLayout
    @description    : go back to layout screen from mapping screen    
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference BackToLayout(){
        showLayoutPage = true;
        documentSigningStatus = '';
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : AddSigners
    @description    :     
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference AddSigners(){
                 
        ParticipantMappingValue record = new ParticipantMappingValue();
        record.name = '';
        record.email = '';
        record.lookupid = '';
        record.objecttype = '';
        record.firstname = '';
        record.lastname = '';
        record.role = '';
        participantMappingValues.add(record);
        
        integer index = -1;
        for(ParticipantMappingValue rec : participantMappingValues)
        {
            index = index+1; 
            rec.index = index;
        }
        
        System.debug('participantMappingValues: '+ participantMappingValues);
        
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : DeleteSigner
    @description    :     
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference DeleteSigner(){
        
        string rowIndex = Apexpages.currentPage().getParameters().get('rowIndex');
        System.debug(rowIndex);
        participantMappingValues.remove(integer.valueOf(rowIndex)); 
        
        integer index = -1;
        for(ParticipantMappingValue record : participantMappingValues)
        {
        	index = index+1; 
        	record.index = index;
        }
        
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : populateAllSelectOptions
    @description    : populate all drop down with values  
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateAllSelectOptions()
    {
        populateQuoteSelectOption();
        populateQuoteLineItemSelectOption();
        populateQuoteLineItemRecordsSelectOption();
        populateUserContactSelectOption();
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteSelectOption
    @description    : populate quote fields drop down 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateQuoteSelectOption()
    {
        selectOptionQuote = helper.populateQuoteSelectOption(allMappingData);
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteLineItemSelectOption
    @description    : populate quote line item fields drop down 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateQuoteLineItemSelectOption()
    {
        selectOptionQuoteLI = helper.populateQuoteLineItemSelectOption(allMappingData);
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteLineItemRecordsSelectOption
    @description    : populate quote line item record drop down 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateQuoteLineItemRecordsSelectOption()
    {
        SelectOptionLIRecords = helper.populateQuoteLineItemRecordsSelectOption(allMappingData, objectName);
    }
    
    /*
    *********************************************************
    @Method Name    : populateUserContactSelectOption
    @description    : populate participant drop down with user/contact lookup fields 
    @param          : N/A
    @return         : void
    ********************************************************
    */
    private void populateUserContactSelectOption()
    {
        selectOptionUserContact = helper.populateUserContactSelectOption(allMappingData);
    }

    /*
    *********************************************************
    @Method Name    : SetFieldValues
    @description    : show the field value of a record when quote or quote line item drop down is changed
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference SetFieldValues()
    {
        //System.debug('Mapping Values: '+ MappingValues);
        
        for(FieldMappingValue record : mappingValues)
        {
            record.Value = '';
            //System.debug('record.Field: '+record.Field);
            if(record.IsLineItem && !(string.ISBLANK(record.LineItemIndex) || string.ISEMPTY(record.LineItemIndex)))
            {
                integer lineItemIndex = integer.valueOf(record.LineItemIndex);
                SObject QuoteLineItem = allMappingData.quoteLineItems[lineItemIndex];
                record.LineItemId = (string)QuoteLineItem.get('Id');
                record.ObjectName = 'lineitem';
                
                
                if(!(string.ISBLANK(record.Field) || string.ISEMPTY(record.Field)))
                {
                    Map<string,string> fieldProps = allMappingData.quoteLineItemFieldProps.get(record.Field);
                    //System.debug('fieldProps: '+ fieldProps);
                    if(fieldProps == null)  {
                        if(QuoteLineItem.getSObject(record.Field) != null)
                            record.Value = string.valueOf(QuoteLineItem.getSObject(record.Field).get('Name'));
                    }else{
                        record.Value = string.valueOf(QuoteLineItem.get(record.Field));
                    } 
                } 
                
            }
            else{
                record.ObjectName = objectName.toLowerCase();//'quote';
                if(record.ObjectName == 'quote')
                {
                    if(!(string.ISBLANK(record.Field) || string.ISEMPTY(record.Field)))
                    {
                        Map<string,string> fieldProps = allMappingData.quoteFieldProps.get(record.Field);
                        if(fieldProps == null)  {
                            if(allMappingData.quote.getSObject(record.Field) != null)
                                record.Value =  string.valueOf(allMappingData.quote.getSObject(record.Field).get('Name'));
                        }else{
                            record.Value =  string.valueOf(allMappingData.quote.get(record.Field)) ;
                        }
                    }
                }
                else{
                    if(!(string.ISBLANK(record.Field) || string.ISEMPTY(record.Field)))
                    {
                        Map<string,string> fieldProps = allMappingData.quoteFieldProps.get(record.Field);
                        //System.debug('fieldProps: '+fieldProps);
                        //record.Value =  string.valueOf(allMappingData.quote.get(record.Field)) ;
                        if(fieldProps == null)  {
                            try{
                                if(allMappingData.quote.getSObject(record.Field) != null)
                                    record.Value =  string.valueOf(allMappingData.quote.getSObject(record.Field).get('Name'));
                            }
                            catch(exception ex)
                            {
                                record.Value =  string.valueOf(allMappingData.quote.get(record.Field));
                            }
                        }else{
                            record.Value =  string.valueOf(allMappingData.quote.get(record.Field));
                        }
                    }
                }
            }
        }
        
        //System.debug('Mapping Values: '+ mappingValues);

        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : SetParticipantValues
    @description    : show the field value of a record when participant drop down is changed
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference SetParticipantValues()
    {
        for(ParticipantMappingValue record : participantMappingValues)
        {
            //System.debug('record.lookupfield: '+ record.lookupfield);
            
            if(!(string.ISBLANK(record.lookupfield) || string.ISEMPTY(record.lookupfield)))
            {
                string objectName = allMappingData.usercontactfieldmap.get(record.lookupfield);
                List<string> fields = allMappingData.participientFields.get(objectName);
                
                for(string field : fields)
                {
                    if(field.indexOf('(') >=0 && field.indexOf(')') >=0)
                    {
                        record.objecttype = field.replace('(','').replace(')','').replace('Group,','');
                    }
                }
                
                string quoteField = string.valueOf(allMappingData.quote.get(record.lookupfield));
                
                if(!(string.ISBLANK(quoteField) || string.ISEMPTY(quoteField)))
                {
                    if(!Test.IsRunningTest())
                    {
                        SObject lookupObject = allMappingData.quote.getSObject(objectName);
                        record.name = string.valueOf(lookupObject.get('Name')) ;
                        record.email = string.valueOf(lookupObject.get('Email'));
                        record.lookupid = string.valueOf(lookupObject.get('Id'));
                        record.firstname = string.valueOf(lookupObject.get('FirstName')) ;
                        record.lastname = string.valueOf(lookupObject.get('LastName')) ;
                    }
                }
                else{
                    record.name = '';
                    record.email = '';
                    record.lookupid = '';
                    record.firstname = '';
                    record.lastname = '';
                    record.index = 0;
                }
            }else{
                record.name = '';
                record.email = '';
                record.lookupid = '';
                record.objecttype = '';
                record.firstname = '';
                record.lastname = '';
                record.index = 0;
            }
        }
        //System.debug('participantMappingValues: '+ participantMappingValues);

        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : Submit
    @description    : Submit the final request to authentisign api
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference Submit()
    {        
        string savedMappings = helper.getSavedMappings(mappingValues, participantMappingValues);
        string requestFinalBody  = getFinalRequestBody();
        
        signingId = AuthentiSignMappingHelper.fillandSubmit(requestFinalBody, recordId, selectedLayout, savedMappings, objectName);
        
        if(signingId != null)
        {
            showLayoutPage = true;
            //signingStatus = 'document signed';
        	savedLayoutId = selectedLayout;
        }
           
        return null;
    }
    
     /*
    *********************************************************
    @Method Name    : Submit
    @description    : Submit the final request to authentisign api
    @param          : N/A
    @return         : PageReference
    ********************************************************
    */
    public PageReference SubmitSigners()
    {        
		System.debug('participantMappingValues: '+participantMappingValues);

        List<SignersRequest> signersData = new List<SignersRequest>();
        for(ParticipantMappingValue record : participantMappingValues)
        {
            SignersRequest sReq = new SignersRequest();
            sReq.Data = new SignersRequest.Data();
            
            sReq.Data.Role = record.Role;
            sReq.Data.Email = record.Email;
            sReq.Data.FirstName = record.FirstName;
            sReq.Data.LastName = record.LastName;
            sReq.Data.Id =  record.lookupid;
            sReq.Data.Name =  record.Name;
            sReq.Data.Type = record.objecttype;
            
            signersData.add(sReq);
        }
        
        if(signersData.size() > 0)
        {
            string quoteId = string.valueOf(response.quote.get('Id'));
            string quoteName = string.valueOf(response.quote.get('Name'));
            
            Map<string,string> result = AuthentisignDocumentHelper.fillandSubmit(signersData, quoteId, quoteName, selectedDocument, selectedDocument, objectName);
            
            if(result.get('status') == 'success')
            {
                documentSigningId = result.get('result');
                showLayoutPage = true;
                documentSigningStatus = 'Signing has not been finalized.';
                //documentSigningStatus = 'sent';
            }else{
                showLayoutPage = false;
                documentSigningStatus = result.get('result');
            }
        }
        
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : getFinalRequestBody
    @description    : generate request for final submission
    @param          : N/A
    @return         : string (signing id)
    ********************************************************
    */
    private string getFinalRequestBody()
    {
        SubmitRequest sr = new SubmitRequest();
        sr.name  = string.valueOf(allMappingData.quote.get('Name'));
        sr.expirationDate = string.valueOf(allMappingData.quote.get(expirationDateField));
        sr.expirationDate = sr.expirationDate.replace(' ','T')+'.000Z';
        sr.layoutId = selectedLayout;
        sr.isOrdered = false;
        sr.callbackUrl = '##callbackurl##';
        
        sr.fields = new Map<string,string>();
        for(FieldMappingValue record : mappingValues)
        {
            sr.fields.put(record.ASFieldName,record.Value);
        }
        
        sr.participants = new List<Map<string,object>>();
        for(ParticipantMappingValue record : participantMappingValues)
        {
            if(record.lastname != '')
            {
                Map<string,object> participant = new Map<string,object>();
                participant.put('email', record.email);
                participant.put('firstname', record.firstname);
                participant.put('imageSignatureEnabled', true);
                participant.put('lastname', record.lastname);
                participant.put('middlename','');
                participant.put('participantRole', record.role);
                participant.put('scriptedSignatureEnabled', true);
                participant.put('staticSignatureEnabled', true);
                participant.put('type', 0);
                
                sr.participants.add(participant);
            }
        }
        //System.debug('ParticipantMappingValues: '+ participantMappingValues);
        return JSON.serialize(sr);
    }

}