({
    loadBalance: function (component, helper) {
        component.set("v.showSpinner", true);
        console.log('init main balance: ' + component.get("v.recordId"));
        var action = component.get("c.getBalance");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('main balance state: ' + state);
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                console.log('result main balance : ' + JSON.stringify(retorno));
                component.set("v.showSpinner", false);
                if (retorno != null) {
                    component.set('v.balance', retorno);
                    component.set('v.hasBalance', true);
                } else {
                    component.set('v.hasBalance', false); 
                }
            } else {
                component.set('v.hasBalance', false); 
                component.set("v.showSpinner", false);               
            }
        });
        $A.enqueueAction(action);
    },

})