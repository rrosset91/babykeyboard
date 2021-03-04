({
    doInit : function(component, event, helper) {
        helper.getInteractions(component);
    },

    reload : function(component, event, helper) {
        console.log("changed inter");
        component.set('v.disableLoadInt',true);

        if(component.get("v.reload") == true){
            console.log('Entrou no if')
            window.setTimeout(
                $A.getCallback(function() {
                    helper.getInteractions(component);
                    component.set('v.disableSaveButton',false);
                    component.set('v.disableTextArea',false);
                    component.set('v.disableLoadInt',false);
                }), 5500
            );
            
        }
    },

    reloadInteractionsManually : function(component,event,helper){
        component.set("v.reload",true);
    },

    updateTopic : function(component, event, helper){
        helper.updateInteraction(component,event,helper);
    }
})