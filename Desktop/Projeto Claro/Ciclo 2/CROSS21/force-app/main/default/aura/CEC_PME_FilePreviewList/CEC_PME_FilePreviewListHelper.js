({
	getAttachmentList: function(component) {
    	var action = component.get("c.carregar");
        action.setParams({
            'Id': component.get("v.recordId")
        });
        
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.attachments", response.getReturnValue());
            }
        }));
        $A.enqueueAction(action);
      }
})