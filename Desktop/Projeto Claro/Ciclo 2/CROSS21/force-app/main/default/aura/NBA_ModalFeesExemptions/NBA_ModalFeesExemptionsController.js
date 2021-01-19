({
	closeFeesExemption: function (component, event, helper) {
		var listT = component.get("v.lstIsencaoTaxa");
		for (var i = 0; i < listT.length; i++) {
			listT[i].checked = false;
		}
		component.set("v.lstIsencaoTaxa",listT);
		component.set("v.showFeesExemptions", false);
	},

	incluirIsencaoTaxas: function (component, event, helper) {

		var disabled = component.get('v.disabledTaxas');
		if(! disabled){
			var feesExemptions = component.get("v.feesExemptions");
			/*var disabled = component.get('v.disabledTaxas');

			if(disabled === false ){ 
				component.set('v.showAdditionalTaxas', true);
			}*/

			if(!feesExemptions) {
				feesExemptions = { 
					wifi: false,
					visit: false,
					address: false,
					docsis: false
				};

				component.set("v.feesExemptions", feesExemptions);
		
			}

			component.set("v.showFeesExemptions", true);
		}
	},

	updateFeesExemptions: function (component, event, helper) {
		helper.updateFeesExemptions(component, event, helper);
	},

})