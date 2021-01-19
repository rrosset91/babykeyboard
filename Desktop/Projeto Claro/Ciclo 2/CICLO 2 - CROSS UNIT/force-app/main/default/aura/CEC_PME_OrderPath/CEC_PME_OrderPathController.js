({
	doInit : function(component, event, helper) {
		helper.setPath(component, event, helper);
	},
    
    handleComponentEvent : function(component,event,helper) {
        helper.setPath(component, event, helper); 
        $A.get('e.force:refreshView').fire();
    }, 
})