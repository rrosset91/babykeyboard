({
	setEnvelop : function(component, event, helper) {
        var action = component.get("c.getEnvelop");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, $A.getCallback(function(response) {

            if (response.getState() === "SUCCESS") {
                
                var envelop = JSON.parse(response.getReturnValue());
                console.log(response.getReturnValue());
                component.set("v.envelop", envelop);
                
            } else if (response.getState() === "ERROR") {
                var message;
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                } else {
                    message = "Unknown error";
                }
                console.log(message);
            }
            
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            
        }));
                           
        $A.enqueueAction(action);
	}, 
})