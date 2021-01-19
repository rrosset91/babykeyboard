({
    callController : function(component, event, helper) {
        var action = component.get("c.signContract");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var message;
            var messageType;
            var title;
            var isClose = true;
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    component.set("v.iframeUrl", response.getReturnValue());
                    isClose = false;
                }
                message = $A.get("$Label.c.CEC_PME_MobileButtonsSignContract_3") ;
                messageType = "SUCCESS";
                title = "Sucesso:";
            } else {
                messageType = "ERROR";
                title = "Erro:";
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                     message = errors[0].message;
                } else {
                    message = "Unknown error";
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
            
            if(isClose) {
				var iframe = component.find("myIframe");
        	    $A.util.toggleClass(iframe, "slds-hide");                  
                helper.closeAction(component, event, helper);
            }
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