({
    toggleSection : function(component, event, helper) {
        component.set('v.isSidebarCollapsed', !component.get('v.isSidebarCollapsed'));
    }, 
    
    toggleSection2 : function(component, event, helper) {
        component.set('v.isSidebarCollapsed2', !component.get('v.isSidebarCollapsed2'));
    }
})