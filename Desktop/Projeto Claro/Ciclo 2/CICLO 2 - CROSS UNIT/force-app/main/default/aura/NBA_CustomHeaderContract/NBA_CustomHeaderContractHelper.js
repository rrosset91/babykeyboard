({
    searchContract : function(component, event) {

        var action = component.get("c.initContract");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.contract', response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    getAccount: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.contract.idConta")
        });
        navEvt.fire();
    }
    
})