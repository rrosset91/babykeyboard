({
    loadAccount : function(component, helper) {
    var action = component.get("c.getAccount");
        action.setParams({
            'accId': component.get("v.recordId")
                  		});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               	component.set("v.acc", response.getReturnValue());
            } else {
                helper.consoleLogErrors(response.getError());
            }
        }));
        $A.enqueueAction(action);
    },
    
    buscarCepCob : function(component, helper) {
        component.set("v.tipoBusca", "Cobranca");
        component.set("v.cep", component.get("v.cepCob"));
        this.buscarCep(component, helper);
    },
    
    buscarCepEnt : function(component, helper) {
        component.set("v.tipoBusca", "Entrega");
        component.set("v.cep", component.get("v.cepEnt"));
    	this.buscarCep(component, helper);    
    },
    
	buscarCep : function(component, helper) {
        var action = component.get("c.getAddress");
        action.setParams({
            'cep': component.get("v.cep"),'acc':component.get("v.acc"),'tipoEndereco':component.get("v.tipoBusca")
                  		});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(component.get("v.tipoBusca"));
                component.set("v.acc", response.getReturnValue());
                console.log(component.get("v.acc"));
                
                if(component.get("v.tipoBusca") == 'Cobranca'){
                    if(!$A.util.isEmpty(component.get("v.acc").BillingStreet)){
                        component.set("v.disableEnderecoCob", true);
                    } else {
                        component.set("v.disableEnderecoCob", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").CEC_BillingNeighborhood__c)){
                        component.set("v.disableBairroCob", true);
                    } else {
                        component.set("v.disableBairroCob", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").BillingCity)){
                        component.set("v.disableCidadeCob", true);
                    } else {
                        component.set("v.disableCidadeCob", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").BillingState)){
                        component.set("v.disableEstadoCob", true);
                    } else {
                        component.set("v.disableEstadoCob", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").BillingCountry)){
                        component.set("v.disableCountryCob", true);
                    } else {
                        component.set("v.disableCountryCob", false);
                    }
                }
        
                if(component.get("v.tipoBusca") == 'Entrega') {
                    if(!$A.util.isEmpty(component.get("v.acc").ShippingStreet)){
                        component.set("v.disableEnderecoEnt", true);
                    } else {
                        component.set("v.disableEnderecoEnt", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").CEC_ShippingNeighborhood__c)){
                        component.set("v.disableBairroEnt", true);
                    } else {
                        component.set("v.disableBairroEnt", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").ShippingCity)){
                        component.set("v.disableCidadeEnt", true);
                    } else {
                        component.set("v.disableCidadeEnt", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").ShippingState)){
                        component.set("v.disableEstadoEnt", true);
                    } else {
                        component.set("v.disableEstadoEnt", false);
                    }
                    
                    if(!$A.util.isEmpty(component.get("v.acc").ShippingCountry)){
                        component.set("v.disableCountryEnt", true);
                    } else {
                        component.set("v.disableCountryEnt", false);
                    }
                }
                
            } else {
                helper.consoleLogErrors(response.getError());
            }
        }));
        $A.enqueueAction(action);
	},
    
    save : function(component, helper) {
        var action = component.get("c.gravar");
        action.setParams({
                    	'acc': component.get("v.acc")
                  		});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                helper.consoleLogErrors(response.getError());
            }
        }));
        $A.enqueueAction(action);
    },
    
    consoleLogErrors : function(errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
        $A.enqueueAction(action);
    }
})