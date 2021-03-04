({
	onInit: function (component, event, helper) {
		this.setColumns(component, event, helper);
	},

	setColumns: function (component, event, helper) {
		component.set('v.columns', [
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table1_Item'), fieldName: 'descricao', type: 'text', editable: false, sortable: true },
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table1_DataLancamento'), fieldName: 'dataLancamento', type: 'text', sortable: false },
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table1_ValorOriginal'), initialWidth: 160, fieldName: 'valor', type: 'text', editable: false, sortable: true },
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table1_ValorCorrigido'), initialWidth: 175, fieldName: 'valorCorrigido', type: 'currency', typeAttributes: { currencyCode: 'BRL' }, editable: false, sortable: true }
		]);

		component.set('v.notContested', [
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table2_Item'), fieldName: 'descricao', type: 'text', editable: false, sortable: true },
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table2_DataLancamento'), fieldName: 'dataLancamento', type: 'text', sortable: false },
			{ label: $A.get('$Label.c.Fin_FormaCredito_Table2_ValorOriginal'), initialWidth: 160, fieldName: 'valor', type: 'text', editable: false, sortable: true },
			{ label: ' ', initialWidth: 160, fieldName: null, type: null, editable: false, sortable: false }
		]);
	},

	/******* Funçõs da modal de segunda via da fatura ********/
	getInvoiceDuplicates: function (component, callback) {
		let operatorCode = component.get('v.operatorId');
		let billId = component.get('v.bill.idFatura');
		let action = component.get('c.getDuplicateInfo');
		action.setParams({ billId: billId, operatorCode: operatorCode });
		action.setCallback(this, function (response) {
			let state = response.getState();
			let data = response.getReturnValue();
			if (state === 'SUCCESS') {
				if (data.success) {
					let sendMethod = data.duplicates.availableSendMethods;
					var methods = [];

					for (let index = 0; index < sendMethod.length; index++) {
						let currentOption = sendMethod[index];
						var option = {
							label: currentOption.sendMethodDescription,
							value: currentOption.sendMethodId
						};
						methods.push(option);
					}
					let sendReasons = data.duplicates.availableReasons;
					var reasons = [];

					for (let index = 0; index < sendReasons.length; index++) {
						let currentOption = sendReasons[index];
						var option = {
							label: currentOption.SolarReason__c,
							value: currentOption.SolarReason__c
						};
						reasons.push(option);
					}

					component.set('v.sendMethodOptions', methods);
					component.set('v.sendReasonOptions', reasons);
					component.set('v.duplicate', data.duplicates);

					if (callback) callback(data.duplicates);
				} else {
					this.showToast('Erro', data.message, 'error');

					if (callback) callback(null, data.message);
				}
			} else if (state === 'ERROR') {
				const errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast('Erro', errors[0].message, 'error');

				if (callback) callback(null, errors);
			}
		});
		$A.enqueueAction(action);
	},

	showToast: function (title, message, type) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			title: title,
			message: message,
			type: type
		});
		toastEvent.fire();
	}
});