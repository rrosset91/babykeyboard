({
    callController : function(component, event, helper) {
        var action = component.get("c.deleteContDocNComp");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.inputOrderFront(component, event, helper);
            } else {                  
                var errors = response.getError();
                var errorMessage;
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    errorMessage = errors[0].message;
                } else {
                    errorMessage = "Unknown error";
                    console.log("Unknown error");
                }
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": errorMessage
                });
                resultsToast.fire();
                helper.closeAction(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    inputOrderFront : function(component, event, helper) {
        var action = component.get("c.inputOrder");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var message;
            var messageType;
            var title;
            if (response.getState() === "SUCCESS") {
                message = $A.get("$Label.c.CEC_PME_MobileButtonsInputOrder_2");
                messageType = "SUCCESS";
                title = "Sucesso:";
            } else {
                messageType = "ERROR";
                title = "Erro:";
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                     console.log(errors[0].message);
                } else {
                    message = "Unknown error";
                    console.log("Unknown error");
                }
            }
            
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": title,
                "type": messageType,
                "message": message
            });
            resultsToast.fire();
            
			var spinner = component.find("mySpinner");
			$A.util.toggleClass(spinner, "slds-hide");             
            helper.closeAction(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    closeAction : function(component, event, helper) {
        if(component.get("v.isQuickAction")) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "Detail"
            });
            navEvt.fire();
            
            $A.get("e.force:closeQuickAction").fire();
        } else {
            helper.fireComponentEvent(component, event, helper);
        }
    },
    
    fireComponentEvent : function(component, event, helper) {
        var appEvent = $A.get("e.c:CEC_PME_MobileButtonEvt");
        appEvent.fire();
    }
})