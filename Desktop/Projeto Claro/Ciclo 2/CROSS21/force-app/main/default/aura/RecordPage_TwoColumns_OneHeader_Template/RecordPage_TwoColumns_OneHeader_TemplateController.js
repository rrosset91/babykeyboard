({
	toggleSectionSidebar : function(component, event, helper) {
        component.set('v.isSidebarCollapsed', !component.get('v.isSidebarCollapsed'));
    },
    
    toggleSectionHeader : function(component, event, helper) {
        component.set('v.isHeaderCollapsed', !component.get('v.isHeaderCollapsed'));
    }
})