({
	doInit : function(component, event, helper) {
        helper.initialLoad(component);
	},
	
	openReembolso : function(component, event, helper) {
        component.set('v.openReembolso',true);
	},
})