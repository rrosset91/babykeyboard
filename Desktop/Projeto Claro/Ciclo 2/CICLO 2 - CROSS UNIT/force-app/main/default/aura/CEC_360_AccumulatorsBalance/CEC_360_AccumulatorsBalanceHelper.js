({
    loadOtherBalances: function (component, helper) {
        console.log('init accumulators balance: ' + component.get("v.recordId"));
        component.set("v.showSpinner", true);
        var id_msisdn = component.get("v.recordId");
        var action = component.get("c.getOtherBalances");
        action.setParams({ "recordId": id_msisdn });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('accumulators balance state: ' + state);
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                console.log('accumulators balance  result: ' + JSON.stringify(retorno));
                component.set("v.showSpinner", false);
                if (retorno != null) {
                    component.set('v.dataAccumulators', retorno);
                } else {
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                }
            } else {
                let errors = response.getError();
                console.log('error accumulators balance. Details: ' + JSON.stringify(errors));
                component.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Erro",
                    "type": "Error",
                    "message": 'Não foi possível encontrar registros.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})