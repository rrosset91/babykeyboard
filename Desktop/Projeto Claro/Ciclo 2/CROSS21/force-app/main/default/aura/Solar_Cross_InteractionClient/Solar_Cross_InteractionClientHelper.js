({
    getInteractions : function(component) {
        var action = component.get("c.getClientHistory");
        component.set('v.disableLoadInt',true);

        action.setParams({ aCaseId : component.get("v.recordId") });
  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log("getInteractions success: " + JSON.stringify(response.getReturnValue()));
                component.set("v.data",response.getReturnValue());  
                console.log('retorno',component.get('v.data')) 
                component.set('v.disableLoadInt',false);
            
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getInteractions Error message: " + errors[0].message);
                    }
                }
            }
            component.set("v.reload", false);
        });
        $A.enqueueAction(action);
    },

    updateInteraction : function(component,event,helper){
        var objectInteraction = event.getSource().get("v.value");
        var action = component.get("c.updateInteraction");
        component.set('v.disableSaveButton',true);
        component.set('v.disableTextArea',true);

        action.setParams({ "strInteraction" : JSON.stringify(objectInteraction)});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.reload", true);

            }else{
                component.set('v.disableSaveButton',true);
                component.set('v.disableTextArea',true);
            }
        })
        $A.enqueueAction(action);
    }
})