({
    getPicklistOptionsFront : function(component, event, helper) {
        var action = component.get("c.getPicklistOptions");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                
                var res = response.getReturnValue();
                var lstSubStatus = [];
                
                lstSubStatus.push({label:"-- Nenhum --", text:null});
                
                for(var key in res) { 
                    for(var value in res[key]) { 
                        if(key === 'SubStatus__c') { 
                            lstSubStatus.push({label:res[key][value], text:res[key][value]});
                        }                       
                    }
                }
                
                component.set("v.lstSubStatus", lstSubStatus);
                
            } else {
                var errors = response.getError();
                var message;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        message = errors[0].message;
                    }
                } else {
                    message = "Unknown error";
                    console.log("Unknown error");
                }
                
                 var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
                
                var spinner = component.find("mySpinner");
				$A.util.toggleClass(spinner, "slds-hide");
                
                helper.closeAction(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeSubStatus : function(component, event, helper) {
        var action = component.get("c.disapproveDocumentation");
        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        action.setParams({ 
            recordId : component.get("v.recordId"), 
            subStatus : component.get("v.subStatus"), 
            complemento : document.getElementById("textarea-id-01").value
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Sucesso",
                    "type": "SUCCESS",
                    "message": $A.get("$Label.c.CEC_PME_MobileButtonsDisapproveDoc_6")
                });
                resultsToast.fire();
            } else {
                var errors = response.getError();
                var message;
                if(errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        message = errors[0].message;
                    }
                } else {
                    message = "Unknown error";
                    console.log("Unknown error");
                }
                
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
            }
            
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