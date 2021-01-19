({
	doInit : function (component, event, helper) { 
		var action = component.get("c.showComponent");
        action.setParams({ idOrder : component.get("v.recordId") });
        action.setCallback(this, function(response) {
			var obj = response.getReturnValue();
			if(obj != null && !obj.isSuccess){
				component.set('v.showCMP', false);
			}
        });
		$A.enqueueAction(action);
	},

	enviarPedido : function (component, event, helper) {
		component.set('v.loaded', true);
		var action = component.get("c.sendPedido");
        var toastEvent;
		action.setParams({ idOrder : component.get("v.recordId") });
		
		action.setCallback(this, function(response){
			var obj = response.getReturnValue();
			
			if(obj !== null && obj.isSuccess){
				component.set("v.ret", obj);
				toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					"title": "Success!",
					"message": obj.message,
					"type": "success"
					});
				toastEvent.fire();
				location.reload();

			}else {
				toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error!",
					"message": (obj !== null ? obj.message : 'Não foi possível enviar!'),
					"type": "error"
					});
				toastEvent.fire();
				//location.reload();
				component.set('v.loaded', false);
			}
		});
		$A.enqueueAction(action);
	}
})