({
    doInit : function(component, event, helper) {
        helper.getListTerritorysRadiosFront(component, event, helper);
    },
    
    closeAction : function(component, event, helper) {
        helper.closeAction(component, event, helper);
    },
    
    saveClick : function(component, event, helper) {
        helper.updateAccountTerritoryFront(component, event, helper);
    }
})