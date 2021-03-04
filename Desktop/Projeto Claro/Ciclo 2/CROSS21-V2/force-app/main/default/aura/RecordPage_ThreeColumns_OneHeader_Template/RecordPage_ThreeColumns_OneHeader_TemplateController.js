({
	toggleSectionHeader : function(component, event, helper) {
        component.set('v.isHeaderCollapsed', !component.get('v.isHeaderCollapsed'));
    },

	toggleSectionSidebarLeft : function(component, event, helper) {
        component.set('v.isSidebarLeftCollapsed', !component.get('v.isSidebarLeftCollapsed'));
    },
    
    toggleSectionSidebarRight : function(component, event, helper) {
        component.set('v.isSidebarRightCollapsed', !component.get('v.isSidebarRightCollapsed'));
    },

	expandContractAll : function(component, event, helper){
		component.set('v.isAllCollapsed', !component.get('v.isAllCollapsed'));

		if(component.get('v.isAllCollapsed')){
			component.set('v.isHeaderCollapsed', true);
			component.set('v.isSidebarLeftCollapsed', true);
			component.set('v.isSidebarRightCollapsed', true);
		} else {
			component.set('v.isHeaderCollapsed', false);
			component.set('v.isSidebarLeftCollapsed', false);
			component.set('v.isSidebarRightCollapsed', false);
		}		
	},

	recordUpdated : function(component, event, helper){

		var changeType = event.getParams().changeType;

		if (changeType === "CHANGED") { 
			component.set('v.refresh', false);
			component.set('v.refresh', true );
		 }
	},
    
    handlerRefresh: function(component, event, helper){
        
        component.set('v.refresh', false);
        component.set('v.refresh', true);
        
    }
})