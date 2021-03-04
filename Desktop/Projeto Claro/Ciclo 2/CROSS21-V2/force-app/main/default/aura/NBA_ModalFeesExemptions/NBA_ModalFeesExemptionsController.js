({
	doInit: function (component, event, helper) {
		if (!component.get('v.temporarySuspension.hasSuspension')) {
			component.set('v.selectedPeriod', '');
			component.set('v.selectedModality', '');
			component.set('v.selectedProducts', '');
		}
		
		helper.getSuspensionOptions(component);
		helper.getSuspensionProducts(component);
		helper.getProductOptions(component);
	},

	closeFeesExemption: function (component, event, helper) {
		var listT = component.get("v.lstIsencaoTaxa");
		for (var i = 0; i < listT.length; i++) {
			listT[i].checked = false;
		}
		component.set("v.lstIsencaoTaxa",listT);
		let temporarySuspension = component.get('v.temporarySuspension');
		if (temporarySuspension.hasSuspension) {
			component.set('v.selectedPeriod', temporarySuspension.period);
			component.set('v.selectedModality', temporarySuspension.modality);
			component.set('v.selectedProducts', temporarySuspension.selectedProducts);
		} else {
			component.set('v.selectedPeriod', '');
			component.set('v.selectedModality', '');
			component.set('v.selectedProducts', '');
		}
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

		let valid = helper.validateSuspension(component);
		if (valid) {
			component.set('v.showFeesExemptions', false);
		} else {
			helper.showToast('Erro', $A.get('$Label.c.NBA_Text_Temporary_Suspension_Missing_Data'), 'error');
		}
	},

	handlePeriodChange: function (component, event, helper) {
		let selectedPeriod = component.get('v.selectedPeriod');
		component.set('v.selectedModality', '');
		component.set('v.selectedProducts', '');

		if ($A.util.isEmpty(selectedPeriod)) {
			return;
		}

		let options = component.get('v.periodOptions');

		let period = options.find(option => option.period == selectedPeriod);
		component.set('v.modalityOptions', period.modalities);		
		if(period.modalities.length == 1){
			window.setTimeout(
				$A.getCallback(function() {
					component.set('v.selectedModality',period.modalities[0]);		
				}), 1
		   );						
		}
	},

	handlePageEvent: function (component, event, helper) {
		let action = event.getParam('action');
		let data = event.getParam('data');
        var hasSuspensao = component.get('v.temporarySuspension.hasSuspension');
		if (action == 'RESET_SUSPENSION') {
			helper.cleanSuspension(component, event,data);
		}
	}

})