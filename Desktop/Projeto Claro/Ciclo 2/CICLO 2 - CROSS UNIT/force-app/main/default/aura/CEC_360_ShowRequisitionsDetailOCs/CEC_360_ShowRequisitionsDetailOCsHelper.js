({
	doInit : function(component, event, helper) {
		var action = component.get("c.getOCs");
        action.setParams({ "strRequisition" : JSON.stringify(component.get("v.requisitionIn")) });
        action.setCallback(this, function(response) {
                        
            if (response.getState() === "SUCCESS") {
                console.log('SUCCESS');
                component.set('v.requisition', response.getReturnValue())
            } else {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;
                } else {
                    console.log("Unknown error");
                }
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
            }
            
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
	}
})