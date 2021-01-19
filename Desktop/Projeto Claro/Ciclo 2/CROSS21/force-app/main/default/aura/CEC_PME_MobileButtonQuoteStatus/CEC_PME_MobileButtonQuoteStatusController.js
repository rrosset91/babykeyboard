({
    doInit : function(component, event, helper) {
        helper.callController(component, event, helper);
    },
    save : function(component, event, helper) {
        helper.saveStatusQuote(component, event, helper);
    },
    closeAction : function(component, event, helper) {
        helper.closeAction(component, event, helper);
    }    
})