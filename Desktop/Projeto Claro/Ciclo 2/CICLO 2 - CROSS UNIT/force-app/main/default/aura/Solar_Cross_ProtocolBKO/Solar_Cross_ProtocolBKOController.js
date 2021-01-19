({
    onInit : function(component, event, helper) {
        helper.verifyUser(component, event, helper);
    },
    loaded : function(component, event, helper) {
        helper.populatePicklistOptions(component, event, helper);
    },
    requiredValidation : function(component, event, helper) {
        var leaving = component.get("v.viewSelected");
        var resolution = component.get("v.resolutionValue");

        if(leaving == null || leaving.match(/^ *$/)  !== null || resolution == null || resolution.match(/^ *$/) !== null){
            component.set("v.enableUpdate",true);
        }
        else{
            component.set("v.enableUpdate",false);
        }
    },
    updateContextCase : function(component, event, helper) {
        component.set("v.loadingSave", true);
        helper.updateCase(component, event, helper);
    },
})