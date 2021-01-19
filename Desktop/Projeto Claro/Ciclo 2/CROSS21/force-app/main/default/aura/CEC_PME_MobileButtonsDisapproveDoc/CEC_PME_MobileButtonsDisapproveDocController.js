({
    doInit : function(component, event, helper) {
        helper.getPicklistOptionsFront(component, event, helper);
    },
    
    saveClick : function(component, event, helper) {
        helper.closeSubStatus(component, event, helper);
    },
    
    closeAction: function(component, event, helper) {
        helper.closeAction(component, event, helper);
    }
})