({
    openModal: function (component, event, helper) {
        var cmpTarget = component.find('DescriptionModal');
        var cmpBack = component.find('ModalDescription');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },

    closeModal: function (component, event, helper) {
        var cmpTarget = component.find('DescriptionModal');
        var cmpBack = component.find('ModalDescription');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },

    getPicklistValues : function(component, event, helper) {
        var action = component.get("c.picklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.options", result);
                // console.log('result ==========================> ' +JSON.stringify(result));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message Links Úteis: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateRecordIcon : function(component, event, helper) {
        var action = component.get("c.setRecordIcon");
        action.setParams({ aRecordId :  component.get("v.recordId"), aIcon : component.get("v.icon")});
        action.setCallback(this, function(response) {     
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Successo!",
                    "message": "Ícone definido com sucesso!",
                    "type": "success"
                });
                toastEvent.fire();
            
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Erro " + errors[0],
                            "message": "Não foi possível atualizar o ícone. Tente novamente.",
                            "type": "error"
                        });
                        toastEvent.fire();
                        
                        console.log("Error message Atualização do ícone: " +  errors[0].message);
                    }
                } 
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    load : function(component, event, helper) {
        var action = component.get("c.getRecordIcon");
        action.setParams({  aRecordId :  component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();            
            var result = response.getReturnValue()
            if (state === "SUCCESS") {
                component.set("v.icon",result);              
            
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message Atualização do ícone: " +  errors[0].message);
                    }
                } 
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
})