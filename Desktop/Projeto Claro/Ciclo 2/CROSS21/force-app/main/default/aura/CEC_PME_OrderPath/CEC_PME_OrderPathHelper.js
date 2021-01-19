({
	setPath : function(component, event, helper) {
        var action = component.get("c.getPath");
        action.setParams({ "recordId" : component.get("v.recordId") });
        
        action.setCallback(this, $A.getCallback(function(response) {

            if (response.getState() === "SUCCESS") {
                
                var path = JSON.parse(response.getReturnValue());
                
                component.set("v.path", path);
                
            } else if (response.getState() === "ERROR") {
                var message;
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                } else {
                    message = "Unknown error";
                }
            }
        }));
                           
        $A.enqueueAction(action);
	}, 
    
    
})