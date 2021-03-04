({
	onClickFirst : function(component, event, helper) {
		const func = component.get('v.onClickFirst');      
        
        if(func)
            $A.enqueueAction(func);
	},
    
    onClickSecond : function(component, event, helper) {
		const func = component.get('v.onClickSecond');
        
         if(func)
            $A.enqueueAction(func);
	},
    
    
})