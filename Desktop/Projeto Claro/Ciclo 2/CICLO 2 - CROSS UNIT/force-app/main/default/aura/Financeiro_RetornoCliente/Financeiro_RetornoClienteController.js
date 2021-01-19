({
 
    doInit : function(component, event, helper) {
		helper.initialLoad(component);
        
	},
    
    
    handleClick : function (component, event, helper) {
		component.set('v.notificationMethod', event.getSource().get("v.name"));

		const func = component.get('v.onSelectNotification');      
        
        if(func)
            $A.enqueueAction(func);

    },
    
 
 })