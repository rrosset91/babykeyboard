({
    populatePicklist : function(component, event, helper, call) {
        console.log('call ' + call);
        var contextCase = component.get("v.contextCase");
        var stringParameterLst = [];
        console.log('contextCase ====================> ' + JSON.stringify(contextCase));
        
        stringParameterLst.push(contextCase.RecordType.DeveloperName);
        stringParameterLst.push(contextCase.ContractBusinessUnit__c);
        stringParameterLst.push(contextCase.Channel__c);
        switch (call) {        
            case 2:
                stringParameterLst.push(component.get("v.categoryValue"));
                console.log('second call Protocol Open');
                break;
            case 3:
                stringParameterLst.push(component.get("v.categoryValue"));
                stringParameterLst.push(component.get("v.modalityValue"));
              console.log('third call Protocol Open');
                break;
            case 4:
                stringParameterLst.push(component.get("v.categoryValue"));
                stringParameterLst.push(component.get("v.modalityValue"));
                stringParameterLst.push(component.get("v.entryValue"));
                console.log('fourth call Protocol Open');

                break;
            default:
                console.log('first call Protocol Open');
        }


        var action = component.get("c.getPicklistOptions");        
        action.setParams({aValuesLst : stringParameterLst});

        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('OPEN Picklist values ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {
            component.set("v.picklistOptions",result);   
            
            switch (call) {  
                case 1:
                    component.set("v.categoryOptions",result);
                    component.set("v.showBKO", false);
                    component.set("v.showFCR", false);
                    component.set("v.enableUpdate",true);
                    // console.log('second call Protocol Open');
                    break;
                case 2:
                    component.set("v.modalityOptions",result);
                    // console.log('third call Protocol Open');
                    component.set("v.modalityShow", true);
                    component.set("v.entryShow", false);
                    component.set("v.leaveShow", false);
                    component.set("v.showBKO", false);
                    component.set("v.showFCR", false);
                    component.set("v.enableUpdate",true);
                    break;
                case 3:
                    component.set("v.entryOptions",result);
                //   console.log('fourth call Protocol Open');
                    component.set("v.entryShow", true);
                    component.set("v.leaveShow", false);
                    component.set("v.showBKO", false);
                    component.set("v.showFCR", false);
                    component.set("v.enableUpdate",true);
                    break;
                case 4:
                    component.set("v.leaveShow", true);
                    component.set("v.leaveOptions",result);
                    component.set("v.showBKO", false);
                    component.set("v.showFCR", false);
                    component.set("v.enableUpdate",true);
                    // console.log('fifth call Protocol Open');    
                    break;
                default:
                    console.log('out of call ERROR');
            }           
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Erro",
                    "message": "Erro ao carregar os valores do campo. Entre em contato com um administrador do sistema."
                });
                toastEvent.fire();
                console.log("Error message BKO: " + errors[0].message);
            } else {
                console.log("Unknown error");
            }
        }
        component.set("v.isLoading", false);
        component.set("v.loadingSave",false);        
        // component.set("v.alertId",null);        
        });
        $A.enqueueAction(action);
    },

    firstCallResolution : function(component, event, helper) {
        var leaveOptions = component.get("v.leaveOptions");
        var leaveValue = component.get("v.leaveValue");

        for(var i = 0; i < leaveOptions.length; i++){
            if(leaveOptions[i].value == leaveValue){
                console.log('FCR leaveOptions[i] ' + leaveOptions[i].fcr);
                if(leaveOptions[i].fcr == true){
                    component.set("v.showFCR", true);
                }
                else{
                    component.set("v.showBKO", true);
                }
            }
        }
        component.set("v.loadingSave",false);        
    },

    updateCase : function(component, event, helper) {
        var aCaseId = component.get("v.recordId");
        var aLeavingReason = component.get("v.leaveValue");
        var aResolution = component.get("v.resolutionValue");
        var aCategory = component.get("v.categoryValue");
        // var aProductValue = component.get("v.productValue");
        var aModality = component.get("v.modalityValue");
        var aEntry = component.get("v.entryValue");
        var aDescription = component.get("v.descriptionValue"); 

        var action = component.get("c.updaContextRecord");        
        action.setParams({aCaseId : aCaseId, aResolution : aResolution, aLeavingReason : aLeavingReason, aCategory : aCategory, /*aProductValue : aProductValue,*/ aModality : aModality, aEntry : aEntry, aDescription : aDescription});        
        action.setCallback(this, function(response) {

        var state = response.getState();
        var result = response.getReturnValue()
        console.log('BKO Picklist values ' +JSON.stringify(result));
        
        if (state === "SUCCESS") {
            component.set("v.viewMode", true);   
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
})