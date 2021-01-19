({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMobileUsage");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === "SUCCESS") {
                if(response.getReturnValue().data != null) {
                    component.set("v.dataMobileUsage", response.getReturnValue().data.usages);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error" ,
                        "message": "Não há consumos para a linha."
                    });
                    toastEvent.fire();
                }
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error" ,
                    "message": "Não há consumos para a linha."
                });
                toastEvent.fire();           
            }
        });
        $A.enqueueAction(action);
    }
})