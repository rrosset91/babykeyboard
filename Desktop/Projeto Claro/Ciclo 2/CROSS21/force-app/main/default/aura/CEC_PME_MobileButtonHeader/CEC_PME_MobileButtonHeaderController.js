({
	doInit : function(component, event, helper) {
	    helper.doInit(component);
    },
    
    closeAction : function(component, event, helper) {
	    helper.closeAction(component);
    },
    
    navigateToResume : function(component, event, helper) {
	    helper.navigateToResume(component);
    },
    
    cancelOrder : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsCancelOrder");
    },
    
    createContract : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsCreateContract");
	},
    
    sendToDocusign : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsSignContract");     
    },
    
    showTerritoryAssociation : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsTerritory");
    },
    
    validateBackoffice : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsSendToBackOffice");
    },
    
    setSubStatus : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsDisapproveDoc");
    },
    
    approveDoc : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsApproveDoc");
    },
    
    showAlterEmailModal : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsResendRequest");
    },
    
    JScloseOrder : function(component, event, helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsInputOrder");
    },
    
    setOrderInputedF : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonOrderInputed");
    },

    setOrderNotInputedF : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonOrderNotInputed");
    },
    
    setQuoteStatusF : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonQuoteStatus");
    },
    
    showResendModel : function(component,event,helper) {
        component.set("v.currentComponent", "CEC_PME_MobileButtonsResendOrder");
    },  
    
    handleComponentEvent : function(component,event,helper) {
        helper.doInit(component);  
        component.set("v.currentComponent", "CEC_PME_MobileButtonHeader");
        $A.get('e.force:refreshView').fire();
    },  
    
    refreshComponent : function(component,event,helper) {
        var componentIcon = component.find("iconHeader");
        console.log(componentIcon);
        componentIcon.set('v.iconName','action:refresh');
        componentIcon.set('v.size','x-small');
        
        helper.fireComponentEvent(component,event,helper);
    },  
    
    
})