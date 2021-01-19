({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAlerts");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue().data != null) {
                    for(var i = 0; i < response.getReturnValue().data.alerts.length; i++) {
                        if(response.getReturnValue().data.alerts[i].notes == 'Carência Upgrade') {
                            if(response.getReturnValue().data.alerts[i].value == 'true') {
                                component.set("v.carenciaUpgrade", 'Sim');
                            } else {
                                component.set("v.carenciaUpgrade", 'Não');
                            }	                       
                        }
                        if(response.getReturnValue().data.alerts[i].notes == 'Inadimplência'){
                            if(response.getReturnValue().data.alerts[i].value == 'true') {
                                component.set("v.inadimplencia", 'Sim');
                            } else {
                                component.set("v.inadimplencia", 'Não');
                            }                       
                        }
                        if(response.getReturnValue().data.alerts[i].notes == 'Retenção'){
                            if(response.getReturnValue().data.alerts[i].value == 'true') {
                                component.set("v.retencao", 'Sim');
                            } else {
                                component.set("v.retencao", 'Não');
                            }                       
                        }
                        if(response.getReturnValue().data.alerts[i].notes == 'Campanhas/Promoções'){
                            if(response.getReturnValue().data.alerts[i].value == 'true') {
                                component.set("v.campanhasPromocoes", 'Sim');
                            } else {
                                component.set("v.campanhasPromocoes", 'Não');
                            }                        
                        }
                    }
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})