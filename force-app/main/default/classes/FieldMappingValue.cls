/*
*********************************************************
@Apex Class Name    : FieldMappingValue
@Created Date       : Dec 13, 2023
@description        : class to save mapped values of quote or quote line item fields
@author             : FFD Developer
@Modification Log   : 
*********************************************************
*/
public with sharing class FieldMappingValue {
    public string ASFieldName {get;set;}
    public string ObjectName {get;set;}
    public string Field {get;set;}
    public string LineItemId {get;set;}
    public string Value{get;set;}
    public boolean IsLineItem {get;set;}
    public string LineItemIndex {get;set;}
    
    public FieldMappingValue()
    {
        ASFieldName = '';
        ObjectName = '';
        Field = '';
        LineItemId = '';
        LineItemIndex = '';
        Value = '';
        IsLineItem = false;
    }
}