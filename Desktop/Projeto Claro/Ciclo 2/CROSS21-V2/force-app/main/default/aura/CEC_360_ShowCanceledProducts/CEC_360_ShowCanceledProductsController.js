({
	doInit : function(component, event, helper) 
    {
        helper.getCancelAssets(component,event,helper);
    },
    
    openDetailPage: function (component, event) 
    {
        var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.getAttribute('data-id');
        navEvt.setParams({
            "recordId":id
        });
        
        navEvt.fire();
    },

})