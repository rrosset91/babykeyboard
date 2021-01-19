({
    doInit : function(component, event, helper) {
        console.log(component.get("v.isQuickAction"));
        helper.callController(component, event, helper);
    },
    closeAction : function(component, event, helper) {
        helper.closeAction(component, event, helper);
    }
})