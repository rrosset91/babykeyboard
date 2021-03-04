({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getContextRecord");        
        action.setParams({aCaseId : component.get("v.recordId")});

        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('Codificação do protocolo ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {
            component.set("v.contextCase",result);
            if(result.IsClosed == true && (result.Solar_Cross_forwardingReason__c == undefined || result.Solar_Cross_forwardingReason__c == null)){
                component.set("v.decision", 'firstScenario');
            }
            else if(result.IsClosed == true && result.Solar_Cross_forwardingReason__c != null){
                component.set("v.decision", 'secondScenario');
            }
            else if(result.Solar_Cross_forwardingReason__c != null){
                component.set("v.decision", 'thirdScenario');
            }
            else{
                component.set("v.decision", 'fourthScenario');
            }
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Erro",
                    "message": "Erro ao carregar Codificação do Protocolo. Entre em contato com um administrador do sistema."
                });
                toastEvent.fire();
                console.log("Error message ProtocolCodification: " + errors[0].message);
            } else {
                console.log("Unknown error");
            }
        }
        // component.set("v.alertId",null);        
        });
        $A.enqueueAction(action);   
    },
})