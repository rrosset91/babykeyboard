({
    doInit : function(component, event, helper) {
        helper.callController(component, event, helper);
    },
    
    closeAction : function(component, event, helper) {
        helper.closeAction(component, event, helper);
    }
})