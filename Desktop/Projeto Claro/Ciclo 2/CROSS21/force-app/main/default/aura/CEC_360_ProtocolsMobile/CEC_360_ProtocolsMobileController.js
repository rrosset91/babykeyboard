({
    doInit : function(component, event, helper) {
        helper.setDates(component,event,helper);
        var action = component.get("c.getAssets");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        var inputsel = component.find("cmbAsset");
        var opts=[];
        action.setCallback(this, function(action) {
            for(var i=0;i< action.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: action.getReturnValue()[i], value: action.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);
        });
        $A.enqueueAction(action);
        
    },
    
    onRadio : function(component,event,helper){
        var recId = component.get("v.contractNumber");
        component.set("v.selectLine",recId);
        component.set( "v.disabledButton",false);
    },
    
    callProtocols: function(component,event,helper){
        component.set("v.showProtocols",false);
        var validScreen = helper.validScreen(component,event,helper);
        if(validScreen == true ){
            component.set("v.showSpinner",true);
            if(component.get('v.protocolNumber') != null){
                helper.getProtocolsNumber(component,event,helper);
            }else{
                helper.getProtocolsDate(component,event,helper);
            }
            
        }
        
    },
    
    callProtocolsDetails: function(component,event,helper){
        component.set("v.showProtocols",false);
        component.set("v.selectedContract",component.get("v.selectLine"));
        var validScreen = helper.validScreen(component,event,helper);
        if(validScreen == true ){
            component.set("v.showSpinner",true);
            helper.getProtocolsDetails(component,event,helper);
        }
        
    },
    
    
    getOptionsData : function(component,event,helper){
        component.set('v.disabledButton',true);
        component.set('v.isDate',true);
        component.set('v.isNumber',false);
        component.set('v.protocolNumber',null);
        component.set('v.protocolSearch',false);
        component.set('v.showProtocols',false);
        component.set('v.enableLine',false);
        
    },
    
    getOptionsNumber : function(component,event,helper){
        component.set('v.isDate',false);
        component.set('v.isNumber',true);
        component.set('v.protocolSearch',false);
        component.set('v.showProtocols',false);
        component.set('v.enableLine',true);
        component.set('v.disabledButton',false);
        component.set('v.assetNumber',' ');
        helper.setDates(component,event,helper);
        
    },
    
    callDetails : function(component,event,helper){
        component.set('v.showModalDetails',true);
        component.set('v.showSpinnerModal',true);
        var protocolNumber = event.target.getAttribute('data-end');
        
        var action = component.get("c.getDetails");
        action.setParams({ 
            msisdn: component.get("v.assetNumber"),
            protocolNumber : protocolNumber,
        });
        
        action.setCallback(this, function(response) {
            var result;
            var state = response.getState();
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                if(result != null) {
                    alert('deu');
                    component.set('v.showSpinnerModal',false);
                    component.set('v.protocolsDetails', result);
                }
            }else{
                component.set('v.showSpinnerModal',false);
                component.set('v.showModalDetails',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Detalhes do protocolo não carregados corretamente.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModal : function(component,event,helper){
        component.set("v.showModalDetails",false);
    },
    
    expandDetails : function(component,event,helper){
        var list = component.get("v.protocolsList");
        var index = event.getSource().get("v.value");
        list[index].isExpandable = !list[index].isExpandable;
        component.set("v.protocolsList",list);
    }
})