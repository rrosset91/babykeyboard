({
    getAlertsFromApex : function(component, event, helper) {
        var action = component.get("c.getAlerts");
        action.setParams({  aCaseId : component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue()
                console.log('Alert result ' + JSON.stringify(result));
                if(result != null && result != undefined && result != ''){                    
                    var label = result.length > 1 ? 'Existem ' + result.length + ' alertas para esse cliente' : 'Existe ' + result.length + ' alerta para esse cliente';                    
                    component.set("v.accordionLabel",label);

                    component.set("v.data",result);
                    component.set("v.isLoading", false);

                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message Alert: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    concludeAlertWithApex : function(component, event, helper) {
        
        var alertId = component.get("v.alertId");
        var action = component.get("c.concludeAlertApex");

        console.log(alertId + component.get("v.recordId"));
        action.setParams({  aAlertId : alertId,
                            aCaseId :  component.get("v.recordId"),
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue()
            if (state === "SUCCESS") {
                console.log('Alert result ' + result);
                var data = component.get("v.data");
                if(data.length > 1){
                    helper.getAlertsFromApex(component, event, helper);
                }
                else{
                    component.set("v.data", null);
                    component.set("v.isLoading", true);
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"success",
                    "title": "Sucesso",
                    "message": "Alerta concluído com sucesso."
                });
                toastEvent.fire();

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Erro ao concluir alerta",
                        "message": result
                    });
                toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        component.set("v.alertId",null);
        
        });
        $A.enqueueAction(action);

    },

    openModal: function (component, event, helper) {
        var cmpTarget = component.find('ConcludeModal');
        var cmpBack = component.find('ModalConclude');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    closeModal: function (component, event, helper) {
        var cmpTarget = component.find('ConcludeModal');
        var cmpBack = component.find('ModalConclude');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
})