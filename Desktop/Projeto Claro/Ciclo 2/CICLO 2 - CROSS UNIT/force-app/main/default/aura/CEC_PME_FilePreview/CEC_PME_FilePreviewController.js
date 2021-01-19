({
    doInit : function(component, event, helper) {
    	var action = component.get("c.fetchUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
				console.log(storeResponse);
                if (storeResponse != "VENDEDOR" && storeResponse != null && storeResponse != "") {
                    helper.load(component, helper);
                }
            }
        });
        $A.enqueueAction(action);
    }
})