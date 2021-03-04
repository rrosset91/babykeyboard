({
    callController : function(component, event, helper) {
        var action = component.get("c.getPicklistStausQuote");
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                component.set("v.statusQuoteOptions", JSON.parse(response.getReturnValue()));
            } else {
                var message;
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;
                } else {
                    console.log("Unknown error");
                    message = "Unknown error";
                }
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
            }
            
            var spinner = component.find("mySpinner");
			$A.util.toggleClass(spinner, "slds-hide");  
        });
        $A.enqueueAction(action);
    },
    
    saveStatusQuote : function(component, event, helper) {
        var action = component.get("c.setQuoteStatus");
        
        action.setParams({ 
            "recordId" : component.get("v.recordId"),
            "quoteStatus" : component.get("v.order.StatusQuote__c") 
        });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Sucesso",
                    "type": "SUCCESS",
                    "message": $A.get("$Label.c.CEC_PME_MobileButtonOrderInputed_5")
                });
                resultsToast.fire();
            } else {
                var message;
                var errors = response.getError();
                console.log(errors);
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;
                } else {
                    console.log("Unknown error");
                    message = "Unknown error";
                }
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
            }
            
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