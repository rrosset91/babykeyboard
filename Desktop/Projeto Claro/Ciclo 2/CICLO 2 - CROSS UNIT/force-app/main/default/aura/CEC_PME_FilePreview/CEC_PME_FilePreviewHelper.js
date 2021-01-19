({
    load : function(component, helper) {
        var action = component.get("c.carregar");
        action.setParams({
            'Id': component.get("v.recordId")
        });
        
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contVersion", response.getReturnValue());
                var pickListAction = component.get("c.obterPickListValues");
                pickListAction.setCallback(this, function(response) {
                    component.set("v.lstTipoAnexo", response.getReturnValue());
                })
                
                $A.enqueueAction(pickListAction);
            } else {
                helper.consoleLogErrors(response.getError());
            }
        }));
        $A.enqueueAction(action);
    }
})