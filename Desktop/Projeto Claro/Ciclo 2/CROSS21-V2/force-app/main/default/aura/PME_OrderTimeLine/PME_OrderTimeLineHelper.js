({
    load : function(component, helper) {
        console.log('Load:');
        var action = component.get("c.getTimeLine");
        action.setParams({
            'Id': component.get("v.recordId")
                  		});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.timeLine", response.getReturnValue());
                console.log('Retorno: ' + component.get("v.timeLine"));
            } else {
                helper.consoleLogErrors(response.getError());
            }
        }));
        $A.enqueueAction(action);
    },
    
    consoleLogErrors : function(errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
        $A.enqueueAction(action);
    }
})