({
	doInit : function(component, event, helper) {
         helper.doInit(component, event);
    },
    
    back: function(component, event, helper){
        helper.back(component, event);
    },
    
    handleChangeQuoteddl: function(component, event, helper){
        var value = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        helper.handleChangeQuoteddl(component, value, name);
    },
    
    handleChangeQuoteLineItemddl: function(component, event, helper){
        var selection = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        helper.handleChangeQuoteLineItemddl(component, selection, name);
    },
    
    handleUserContactddl: function(component, event, helper){
        var fieldName = event.getSource().get("v.value");
        var nameAttr = event.getSource().get("v.name");
        helper.handleUserContactddl(component, fieldName, nameAttr);
    },
    
    chkQuoteLIChange: function(component, event, helper){
        helper.chkQuoteLIChange(component, event);
    },
    
    createRequest : function(component, event, helper){
         helper.submitRequest(component, event);
    },
})