({
	doInit : function(component, event, helper) {
         helper.doInit(component, event);
    },
    addSigner : function(component, event, helper){
        helper.addSigner(component, event);
    },
    deleteSigner : function(component, event, helper){
        var btnName = event.getSource().get("v.name");
        helper.deleteSigner(component, btnName, event);
    },
    handleUserContactddl : function(component, event, helper){
        var fieldName = event.getSource().get("v.value");
        var nameAttr = event.getSource().get("v.name");
        helper.handleUserContactddl(component, fieldName, nameAttr);
    },
    createRequest : function(component, event, helper){
        helper.createRequest(component, event);
    },
    back: function(component, event, helper){
        helper.back(component, event);
    },
})