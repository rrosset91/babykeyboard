({
    doInit: function(component, event, helper)
    {
        helper.getRecordTypeDetail(component, function() {
            helper.getCase(component);      
        });          
    },
    
    editCase : function(component, event, helper) 
    {
        helper.editCase(component);
    },
    
    requestReject: function(component,event,helper) 
    {
        helper.requestReject(component,event,helper);
    },
    
    closeModal:function(component,event,helper)
    {    
        helper.closeModal(component);
    },
    
    openModal: function(component,event,helper) 
    {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    
    showSpinner: function(component, event, helper) 
    { 
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper)
    {  
        component.set("v.Spinner", false);
    },
})