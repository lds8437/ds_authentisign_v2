/*
*********************************************************
@Apex Class Name    : LayoutListVFHelper
@Created Date       : Dec 15, 2023
@description        : Helper class for LayoutListVFController
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class LayoutListVFHelper {

    /*
    *********************************************************
    @Method Name    : populateLayoutSelectOption
    @description    : select option data for layout drop down on first screen 
    @param          : LayoutResponse response
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateLayoutSelectOption(LayoutResponse response)
    {
        List<SelectOption> options = new List<SelectOption>();
        SelectOption firstOption = new SelectOption('', '--Select Layout--');
        options.add(firstOption);
        for(LayoutWrapper record : response.wrapper)
        {
            SelectOption option = new SelectOption(record.id, record.name);
            options.add(option);
        }
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : populateDocumentSelectOption
    @description    : select option data for document drop down on first screen 
    @param          : LayoutResponse response
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateDocumentSelectOption(LayoutResponse response)
    {
        List<SelectOption> options = new List<SelectOption>();
        SelectOption firstOption = new SelectOption('', '--Select Document--');
        options.add(firstOption);
        for(string key : response.documents.keySet())
        {
            SelectOption option = new SelectOption(response.documents.get(key),key );
            options.add(option);
        }
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteSelectOption
    @description    : select option data for quote fields drop down on mapping screen 
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateQuoteSelectOption(RecordsFields allMappingData)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select Quote Field--'));
        for(string fieldKey : allMappingData.quoteFieldProps.keySet())
        {
            Map<string,string> fieldProps = allMappingData.quoteFieldProps.get(fieldKey);
            string fieldName = string.valueOf(fieldProps.get('localName'));
            options.add(new SelectOption(fieldName,  fieldProps.get('label')));
            
            if(fieldProps.get('type') != null && (string)fieldProps.get('type') == 'REFERENCE')
            {
                string lookupFieldName = '';
                string typeOfField = string.valueOf(fieldProps.get('custom'));
                if(typeOfField == 'true')
                {
                    lookupFieldName = fieldName.replace('__c', '__r');
                }
                else{
                    lookupFieldName = fieldName.replace('Id', '').replace('Id', '');
                }
                
                options.add(new SelectOption(lookupFieldName,  fieldProps.get('label') +' > Name'));
            }
        }
        options.sort();
        
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteLineItemSelectOption
    @description    : select option data for quote line item fields drop down on mapping screen 
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateQuoteLineItemSelectOption(RecordsFields allMappingData)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select Quote Line Item Field--'));
        for(string fieldKey : allMappingData.quoteLineItemFieldProps.keySet())
        {
            Map<string,string> fieldProps = allMappingData.quoteLineItemFieldProps.get(fieldKey);
            string fieldName = string.valueOf(fieldProps.get('localName'));
            options.add(new SelectOption(fieldName,  fieldProps.get('label')));
            
            if(fieldProps.get('type') != null && (string)fieldProps.get('type') == 'REFERENCE')
            {
                string lookupFieldName = '';
                string typeOfField = string.valueOf(fieldProps.get('custom'));
                if(typeOfField == 'true')
                {
                    lookupFieldName = fieldName.replace('__c', '__r');
                }
                else{
                    lookupFieldName = fieldName.replace('Id', '').replace('Id', '');
                }
                
                options.add(new SelectOption(lookupFieldName,  fieldProps.get('label') +' > Name'));
            }
        }
        options.sort();
        
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteLineItemRecordsSelectOption
    @description    : select option data for quote line item records drop down on mapping screen 
    @param          : RecordsFields allMappingData, string objectName
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateQuoteLineItemRecordsSelectOption(RecordsFields allMappingData, string objectName)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select Quote Line Item Record--'));
        integer index = 0;
        if(allMappingData.quoteLineItems != null)
        {
            for(SObject record : allMappingData.quoteLineItems)
            {
                //System.debug('line item record:'+ record);
                if(objectName.toLowerCase() == 'quote')
                {
                    SelectOption so = new SelectOption(string.valueOf(index), (string)record.getSObject('Product2').get('Name'));
                    options.add(so);
                }
                else{
                    SelectOption so = new SelectOption(string.valueOf(index), (string)record.getSObject('SBQQ__Product__r').get('Name'));
                    options.add(so);
                }
                index +=1;
            }
        }
        
        options.sort();
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : populateQuoteLineItemRecordsSelectOption
    @description    : select option data for participant contact/user lookup fields drop down on mapping screen 
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateUserContactSelectOption(RecordsFields allMappingData)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select User/Contact Field--'));
        
        for(string fieldName : allMappingData.usercontactfieldmap.keySet())
        {
            List<string> fields = allMappingData.participientFields.get(fieldName);
            string fieldLabel =  string.valueOf(allMappingData.quoteFieldProps.get(fieldName).get('label'));
            
            options.add(new SelectOption(fieldName, fieldLabel));
        }
        options.sort();
        return options;
    }
    
    /*
    *********************************************************
    @Method Name    : getSavedMappings
    @description    : generate mapping string to save from FieldMappingValues and ParticipantMappingValues properties
    @param          : List<FieldMappingValue> FieldMappingValues, List<ParticipantMappingValue> ParticipantMappingValues
    @return         : string (json mapping stirng)
    ********************************************************
    */
    public string getSavedMappings(List<FieldMappingValue> FieldMappingValues, List<ParticipantMappingValue> ParticipantMappingValues)
    {
        //System.debug('FieldMappingValues: '+ JSON.serialize(FieldMappingValues));
        //System.debug('ParticipantMappingValues: '+ JSON.serialize(ParticipantMappingValues) );
        
        Map<string, Map<string,string>> fieldsMap = new Map<string, Map<string,string>>();
        
        for(FieldMappingValue record : FieldMappingValues)
        {
            Map<string,string> propFieldMap = new Map<string,string>();
            propFieldMap.put('field', record.Field);
            propFieldMap.put('object', record.ObjectName);
            if(record.IsLineItem){
                propFieldMap.put('lineItemId', record.LineItemId);
            }
            
            fieldsMap.put(record.ASFieldName, propFieldMap);
        }
        
        Map<string,string> propParticipantMap = new Map<string,string>();
        for(ParticipantMappingValue record : ParticipantMappingValues)
        {
            propParticipantMap.put(record.role, record.lookupField);
        }
        
        Map<string, object> allMap = new Map<string, object>();
        allMap.put('fieldsMap',fieldsMap);
        allMap.put('rolesMap',propParticipantMap);
        
         
        string finalMappingString = JSON.serialize(allMap);
      
        //System.debug('finalMappingString: '+finalMappingString);
        
        return finalMappingString;
    }
}