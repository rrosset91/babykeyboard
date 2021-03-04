({
	doInit : function(component, event, helper) {
        helper.load(component, helper);
    },
    
    refresh : function(component, event, helper) {
    	helper.load(component, event, helper);
	}
})