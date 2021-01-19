({
    openOmniScript:function(component,event,helper) {
        var contextId = component.get("v.recordId");
        //var url = '/apex/testeMe?ContextId=' + contextId;
        var url = '/apex/CEC_ME_ChangeAddress?ContextId=' + contextId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})