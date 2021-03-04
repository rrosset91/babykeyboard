({
    doInit: function(component, event, helper)
    {        
        helper.getCase(component);
        helper.getProtocolLits(component);   
    },
    
    getAutomaticProtocol : function(component, event, helper)
    {
        helper.getAutomaticProtocol(component, event, helper);
    },
        
    setManualProtocol : function(component, event, helper)
    {
        helper.setManualProtocol(component, event, helper);   
    },
    
    showSpinner: function(component, event, helper) { 
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){  
        component.set("v.Spinner", false);
    }
    
})