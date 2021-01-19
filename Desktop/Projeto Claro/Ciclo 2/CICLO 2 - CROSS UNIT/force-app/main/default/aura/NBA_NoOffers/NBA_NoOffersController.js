({
	closeModal: function (component, event, helper) {
		
		component.set("v.showNoOffers", false);

		var Exceptions = 'SEM OFERTAS';
		helper.updateStageAndExceptionNoReturn(component, Exceptions);
	}

})