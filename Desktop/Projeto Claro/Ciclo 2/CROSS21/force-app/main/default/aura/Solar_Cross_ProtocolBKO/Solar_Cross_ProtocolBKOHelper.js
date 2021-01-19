({
    populatePicklistOptions : function(component, event, helper) {
        var contextCase = component.get("v.contextCase");
        var stringParameterLst = [];
        console.log('contextCase ====================> ' + JSON.stringify(contextCase));
        stringParameterLst.push(contextCase.RecordType.DeveloperName);
        stringParameterLst.push(contextCase.ContractBusinessUnit__c);
        stringParameterLst.push(contextCase.Channel__c);
        stringParameterLst.push(contextCase.Category__c);
        // stringParameterLst.push(contextCase.Product__c);
        stringParameterLst.push(contextCase.Modalidade__c);
        stringParameterLst.push(contextCase.EntryReason__c);

        var action = component.get("c.getPicklistOptions");        
        action.setParams({aValuesLst : stringParameterLst});

        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('BKO Picklist values ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {
            component.set("v.picklistOptions",result);            
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Erro",
                    "message": "Erro ao carregar os valores do campo Motivo de Saída. Entre em contato com um administrador do sistema."
                });
                toastEvent.fire();
                console.log("Error message BKO: " + errors[0].message);
            } else {
                console.log("Unknown error");
            }
        }
        component.set("v.isLoading", false);
        // component.set("v.alertId",null);        
        });
        $A.enqueueAction(action);   
    },

    updateCase : function(component, event, helper) {
        var leaving = component.get("v.viewSelected");
        var resolution = component.get("v.resolutionValue");
        var caseId = component.get("v.recordId");

        var action = component.get("c.updaContextRecord");        
        action.setParams({aCaseId : caseId, aResolution : resolution, aLeavingReason : leaving, aCategory : null, aProductValue : null, aModality : null, aEntry : null, aDescription : null});        
        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('BKO Picklist values ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"success",
                "title": "Sucesso",
                "message": "Alterações salvas com sucesso."
            });
            toastEvent.fire();         
            component.set("v.input", true);  
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Erro",
                    "message": "Erro ao salvar as alterações. Entre em contato com um administrador do sistema."
                });
                toastEvent.fire();
                console.log("Error message BKO: " + errors[0].message);
            } else {
                console.log("Unknown error");
            }
        }
        component.set("v.loadingSave", false);        
        });
        $A.enqueueAction(action);   
    },

    verifyUser : function(component, event, helper) {
        var action = component.get("c.isBKOUser");        
        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('BKO User ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {    
            if(result){
                component.set("v.input", false);  
            }   
            else{
                component.set("v.input", true);  
            }  
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.fire();
                console.log("Error message Verify User: " + errors[0].message);
            } else {
                console.log("Unknown error");
            }
        }
        // component.set("v.isLoading", false);        
        });
        $A.enqueueAction(action);   
    },
})