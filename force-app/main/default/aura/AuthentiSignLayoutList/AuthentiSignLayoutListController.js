({
	doInit : function(component, event, helper) {
       helper.init(component, event);
	},
    
    handleLayoutChange: function(component, event, helper){
        helper.handleLayoutChange(component, event);
    },
    
    navigateToMappings: function(component, event, helper){
         helper.navigateToMappings(component, event);
    },
    
    displaypdf: function(component, event, helper){
         helper.displaypdf(component, event);
    },
    displaypdfdocument: function(component, event, helper){
         helper.displaypdfdocument(component, event);
    },
    handleChangeRadio: function(component, event, helper) {
        var selectedOption = component.get("v.selectedOption");
        // Handle the change
        console.log("Selected Option: " + selectedOption);
    },
    handleChangeDocument: function(component, event, helper) {
         helper.handleChangeDocument(component, event);
    },
    navigateToSigners: function(component, event, helper){
         helper.navigateToSigners(component, event);
    },
})