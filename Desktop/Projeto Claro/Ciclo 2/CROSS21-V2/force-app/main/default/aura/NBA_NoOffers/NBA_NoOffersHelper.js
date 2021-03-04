({
	updateStageAndExceptionNoReturn : function (component, Exceptions){
	
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		var msg = component.get('v.erroOfertas');

		var action = component.get('c.updateStageAndExceptionNoReturn');
		action.setParams({
			"recordId": caseId,
			"Exceptions": Exceptions,
			"mensagemSemOfertas" : msg
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.getEvent("refresh").fire();
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao atualizar o caso!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
		});
		$A.enqueueAction(action);
	}
})