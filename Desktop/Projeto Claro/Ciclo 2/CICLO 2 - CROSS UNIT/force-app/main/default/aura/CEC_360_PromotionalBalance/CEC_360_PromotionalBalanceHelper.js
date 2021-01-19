({
    loadOtherBalancesPromotional: function (component, helper) {
        console.log('promotional balance init');
        component.set("v.showSpinner", true);
        var id_msisdn = component.get("v.recordId");
        var action = component.get("c.getOtherBalancesPromotional");
        action.setParams({ "recordId": id_msisdn });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            console.log('promotional balance state: ' + state);
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                console.log('promotional balance result: ' + JSON.stringify(retorno));
                component.set("v.showSpinner", false);
                if (retorno != null) {
                    component.set('v.dataPromotional', retorno);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                }
            } else {
                let errors = response.getError();
                console.log('error promotional balance: ' + JSON.stringify(errors));
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