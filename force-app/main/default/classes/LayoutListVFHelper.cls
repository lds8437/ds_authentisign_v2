/*
*********************************************************
@Apex Class Name    : LayoutListVFHelper
@Created Date       : Dec 15, 2023
@description        : Helper class for LayoutListVFController to populate dropdown options
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Removed CPQ dependencies (quoteFieldProps, quoteLineItemFieldProps, quoteLineItems). Renamed to recordFieldProps, lineItemFieldProps, lineItems. Fixed participientFields to participantFields. Added try-catch with AuraHandledException. Confirmed support for Opportunity.
  - Updated July 31, 2025: Added FieldMappingValue and ParticipantMappingValue inner classes to resolve invalid type errors in getSavedMappings.
*********************************************************
*/
public with sharing class LayoutListVFHelper {

    /*
    *********************************************************
    @description    : Wrapper for field mapping values
    ********************************************************
    */
    public class FieldMappingValue {
        @AuraEnabled public String Field { get; set; }
        @AuraEnabled public String ObjectName { get; set; }
        @AuraEnabled public String ASFieldName { get; set; }
        @AuraEnabled public Boolean IsLineItem { get; set; }
        @AuraEnabled public String LineItemId { get; set; }
    }

    /*
    *********************************************************
    @description    : Wrapper for participant mapping values
    ********************************************************
    */
    public class ParticipantMappingValue {
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String lookupField { get; set; }
    }

    /*
    *********************************************************
    @Method Name    : populateLayoutSelectOption
    @description    : Populate select options for layout dropdown
    @param          : LayoutResponse response
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateLayoutSelectOption(LayoutResponse response) {
        try {
            if (response == null || response.wrapper == null) {
                throw new AuraHandledException('Invalid LayoutResponse provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select Layout--'));
            for (LayoutWrapper record : response.wrapper) {
                options.add(new SelectOption(record.id, record.name));
            }
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateLayoutSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating layout options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : populateDocumentSelectOption
    @description    : Populate select options for document dropdown
    @param          : LayoutResponse response
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateDocumentSelectOption(LayoutResponse response) {
        try {
            if (response == null || response.documents == null) {
                throw new AuraHandledException('Invalid LayoutResponse provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select Document--'));
            for (String key : response.documents.keySet()) {
                options.add(new SelectOption(response.documents.get(key), key));
            }
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateDocumentSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating document options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : populateRecordSelectOption
    @description    : Populate select options for record fields dropdown on mapping screen
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateRecordSelectOption(RecordsFields allMappingData) {
        try {
            if (allMappingData == null || allMappingData.recordFieldProps == null) {
                throw new AuraHandledException('Invalid RecordsFields provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select Record Field--'));
            for (String fieldKey : allMappingData.recordFieldProps.keySet()) {
                Map<String,String> fieldProps = allMappingData.recordFieldProps.get(fieldKey);
                String fieldName = String.valueOf(fieldProps.get('localName'));
                options.add(new SelectOption(fieldName, fieldProps.get('label')));

                if (fieldProps.get('type') != null && fieldProps.get('type') == 'REFERENCE') {
                    String lookupFieldName = '';
                    String typeOfField = String.valueOf(fieldProps.get('custom'));
                    if (typeOfField == 'true') {
                        lookupFieldName = fieldName.replace('__c', '__r');
                    } else {
                        lookupFieldName = fieldName.replace('Id', '').replace('id', '');
                    }
                    options.add(new SelectOption(lookupFieldName, fieldProps.get('label') + ' > Name'));
                }
            }
            options.sort();
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateRecordSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating record field options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : populateLineItemSelectOption
    @description    : Populate select options for line item fields dropdown on mapping screen
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateLineItemSelectOption(RecordsFields allMappingData) {
        try {
            if (allMappingData == null || allMappingData.lineItemFieldProps == null) {
                throw new AuraHandledException('Invalid RecordsFields provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select Line Item Field--'));
            for (String fieldKey : allMappingData.lineItemFieldProps.keySet()) {
                Map<String,String> fieldProps = allMappingData.lineItemFieldProps.get(fieldKey);
                String fieldName = String.valueOf(fieldProps.get('localName'));
                options.add(new SelectOption(fieldName, fieldProps.get('label')));

                if (fieldProps.get('type') != null && fieldProps.get('type') == 'REFERENCE') {
                    String lookupFieldName = '';
                    String typeOfField = String.valueOf(fieldProps.get('custom'));
                    if (typeOfField == 'true') {
                        lookupFieldName = fieldName.replace('__c', '__r');
                    } else {
                        lookupFieldName = fieldName.replace('Id', '').replace('id', '');
                    }
                    options.add(new SelectOption(lookupFieldName, fieldProps.get('label') + ' > Name'));
                }
            }
            options.sort();
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateLineItemSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating line item field options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : populateLineItemRecordsSelectOption
    @description    : Populate select options for line item records dropdown on mapping screen
    @param          : RecordsFields allMappingData, String objectName
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateLineItemRecordsSelectOption(RecordsFields allMappingData, String objectName) {
        try {
            if (allMappingData == null || allMappingData.lineItems == null) {
                throw new AuraHandledException('Invalid RecordsFields provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select Line Item Record--'));
            Integer index = 0;
            for (SObject record : allMappingData.lineItems) {
                String productName = (String)record.getSObject('Product2').get('Name');
                options.add(new SelectOption(String.valueOf(index), productName));
                index += 1;
            }
            options.sort();
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateLineItemRecordsSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating line item record options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : populateUserContactSelectOption
    @description    : Populate select options for participant contact/user lookup fields dropdown
    @param          : RecordsFields allMappingData
    @return         : List<SelectOption>
    ********************************************************
    */
    public List<SelectOption> populateUserContactSelectOption(RecordsFields allMappingData) {
        try {
            if (allMappingData == null || allMappingData.participantFields == null || allMappingData.usercontactfieldmap == null) {
                throw new AuraHandledException('Invalid RecordsFields provided.');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select User/Contact Field--'));
            for (String fieldName : allMappingData.usercontactfieldmap.keySet()) {
                List<String> fields = allMappingData.participantFields.get(fieldName);
                String fieldLabel = String.valueOf(allMappingData.recordFieldProps.get(fieldName).get('label'));
                options.add(new SelectOption(fieldName, fieldLabel));
            }
            options.sort();
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in populateUserContactSelectOption: ' + e.getMessage());
            throw new AuraHandledException('Error populating user/contact field options: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getSavedMappings
    @description    : Generate mapping string to save from FieldMappingValues and ParticipantMappingValues
    @param          : List<FieldMappingValue> fieldMappingValues, List<ParticipantMappingValue> participantMappingValues
    @return         : String (JSON mapping string)
    ********************************************************
    */
    public String getSavedMappings(List<FieldMappingValue> fieldMappingValues, List<ParticipantMappingValue> participantMappingValues) {
        try {
            if (fieldMappingValues == null || participantMappingValues == null) {
                throw new AuraHandledException('Invalid mapping values provided.');
            }
            Map<String, Map<String,String>> fieldsMap = new Map<String, Map<String,String>>();
            for (FieldMappingValue record : fieldMappingValues) {
                Map<String,String> propFieldMap = new Map<String,String>();
                propFieldMap.put('field', record.Field);
                propFieldMap.put('object', record.ObjectName);
                if (record.IsLineItem) {
                    propFieldMap.put('lineItemId', record.LineItemId);
                }
                fieldsMap.put(record.ASFieldName, propFieldMap);
            }

            Map<String,String> propParticipantMap = new Map<String,String>();
            for (ParticipantMappingValue record : participantMappingValues) {
                propParticipantMap.put(record.role, record.lookupField);
            }

            Map<String, Object> allMap = new Map<String, Object>();
            allMap.put('fieldsMap', fieldsMap);
            allMap.put('rolesMap', propParticipantMap);

            return JSON.serialize(allMap);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getSavedMappings: ' + e.getMessage());
            throw new AuraHandledException('Error generating mapping string: ' + e.getMessage());
        }
    }
}