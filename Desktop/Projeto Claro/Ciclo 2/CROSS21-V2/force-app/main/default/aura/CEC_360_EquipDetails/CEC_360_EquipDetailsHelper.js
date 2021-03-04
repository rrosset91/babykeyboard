({
    getDeviceDetail : function(component, event, helper) {
                
        component.set("v.hasSpinner", true);
        
        //Validar se botão está habilitado
        var btnDeviceDetail = event.getSource().get("v.label");
        if(btnDeviceDetail){
            
            var action = component.get("c.getDevices");
            action.setParams({ 
                recordId : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                
                if (state === "SUCCESS") {                	
                    //Abrir modal de detalhe
                    component.set("v.showDetail", true);
                    component.set("v.equipDetails", response.getReturnValue()); 
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Não há detalhes para este produto.'
                    });
                    toastEvent.fire();
                }
                component.set("v.hasSpinner", false);
            });
            $A.enqueueAction(action);
        }
    }
})