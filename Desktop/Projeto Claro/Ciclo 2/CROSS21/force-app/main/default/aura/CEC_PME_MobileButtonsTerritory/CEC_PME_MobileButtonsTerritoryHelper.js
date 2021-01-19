({
    getListTerritorysRadiosFront : function(component, event, helper) {
        
        var action = component.get("c.getListTerritorysRadios");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                var list = JSON.parse(response.getReturnValue());
                
                component.set("v.optionsTerritory", list);
            } else {
                var errors = response.getError();
                var message;
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                } else {
                    message = "Erro não esperado!";
                }
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erro",
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
    
    updateAccountTerritoryFront : function(component, event, helper) {
        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var action = component.get("c.updateAccountTerritory");
        action.setParams({ 
            "recordId" : component.get("v.recordId"),
            "territoryId" : component.get("v.valueTerritory") 
        });
        
        action.setCallback(this, function(response) {
            var resultsToast = $A.get("e.force:showToast");
            
            if (response.getState() === "SUCCESS") {
                resultsToast.setParams({
                    "title": "Sucesso",
                    "type": "SUCCESS",
                    "message": $A.get("$Label.c.CEC_PME_MobileButtonsTerritory_5")
                });
            } else {
                var errors = response.getError();
                var message;
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                } else {
                    message = "Erro não esperado!";
                }
                
                resultsToast.setParams({
                    "title": "Erro:",
                    "type": "ERROR",
                    "message": message
                });
            }
            
            resultsToast.fire();
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