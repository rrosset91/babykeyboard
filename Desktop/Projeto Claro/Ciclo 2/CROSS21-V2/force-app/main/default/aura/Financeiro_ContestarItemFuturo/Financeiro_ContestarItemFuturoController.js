({
	doInit: function (component, event, helper) {
		helper.initialLoad(component);
	},

	clickBack: function (component, event, helper) {
		const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
		cmpEvent.setParams({
			message: "CLOSEFUTURECONTESTATION",
			payload: {
				tabId: "lancamentosfuturos"
			}
		});
		cmpEvent.fire();
	},

	handleSaveEdition: function (component, event, helper) {
		let drafts = event.getParam("draftValues");
		let allItems = component.get("v.selectedItem");

		console.log("var", JSON.parse(JSON.stringify(drafts)));
		console.log("allItems", JSON.parse(JSON.stringify(allItems)));

		for (let index = 0; index < allItems.length; index++) {
			let element = allItems[index];

			for (let idxDraft = 0; idxDraft < drafts.length; idxDraft++) {
				let draft = drafts[idxDraft];

				if (element.id.toString() != draft.id.toString()) continue;

				const contestValue = parseFloat(draft.valorContestar);

				if (contestValue < 0) return helper.showToast("Valor inválido", "O valor inserido não pode ser negativo.", "warning");

				element.valorContestar = contestValue;
				element.valorCorrigido = element.realValue - element.valorContestar;
			}

			if (element.valorContestar > element.realValue) {
				element.valorContestar = 0;
				element.valorCorrigido = "";
				return helper.showToast("Valor inválido", "O valor a contestar não pode ser maior que o valor original.", "warning");
			}
		}

		component.set("v.draftValues", []);
	},

	handleRowAction: function (component, event, helper) {
		const action = event.getParam("action");
		let row = event.getParam("row");

		switch (action.name) {
			case "CalcularButton":
				component.set("v.objectContext", row);
				component.find("calcModal").open();
				break;
			case "ItemMotivo":
				helper.handleSelectReason(component, row);
				break;
			case "Deletar":
				helper.handleDelete(component, helper, row);
				break;
		}

		let selectedItems = component.get("v.selectedItem");
		if (!selectedItems.length) return component.set("v.disabledContest", true);

		component.set("v.disabledContest", false);
	},

	saveCalc: function (component, event, helper) {
		const calcPerc = component.get("v.calculoTipoPorcentagem");
		const percVal = component.get("v.calculoPorcentagem");
		const daysVal = component.get("v.calculoDias");

		let allItems = component.get("v.selectedItem");
		let selectedItem = component.get("v.objectContext");
		let orgValue = JSON.parse(JSON.stringify(selectedItem.realValue));
		let correctedValue = 0;

		console.log("allItems ->", JSON.parse(JSON.stringify(allItems)));
		console.log("selectedItem", JSON.parse(JSON.stringify(selectedItem)));
		console.log("orgValue", JSON.parse(JSON.stringify(orgValue)));

		if (!calcPerc && daysVal > 30) return helper.showToast("Dia inválido", "O dia não pode ser maior que 30", "warning");

		if (!calcPerc && daysVal <= 0) return helper.showToast("Dia inválido", "O dia não pode menor ou igual a 0", "warning");

		if (calcPerc && percVal > 100) return helper.showToast("Porcentagem inválida", "A porcentagem não pode ser maior que 100", "warning");

		if (calcPerc && percVal <= 0) return helper.showToast("Porcentagem inválida", "A porcentagem não pode ser menor ou igual a zero", "warning");

		if (calcPerc) {
			correctedValue = orgValue - (percVal / 100) * selectedItem.realValue;
		} else {
			correctedValue = orgValue - (daysVal * selectedItem.realValue) / 30;
		}

		if (correctedValue < 0) return helper.showToast("Valor inválido", "O valor corrigido não pode ser negativo", "warning");

		allItems.forEach((x) => {
			if (x.idItem == selectedItem.idItem) {
				x.valorContestar = orgValue - correctedValue;
				x.valorCorrigido = correctedValue;
			}
		});

		component.set("v.selectedItem", allItems);
		component.find("calcModal").close();
	},

	handleSaveReason: function (component, event, helper) {
		const reasonValue = component.get("v.selectedReason");
		const contextRecord = component.get("v.reasonContext");
		let allItems = component.get("v.selectedItem");

		allItems.forEach((x) => {
			if (x.id == contextRecord.id) x.contestationReason = reasonValue;
		});

		component.set("v.selectedItem", allItems);
		component.find("reasonModal").close();
	},

	onCloseModal: function (component, event, helper) {
		component.set("v.calcSelected", null);
		component.set("v.objectContext", null);
		component.set("v.calculoPorcentagem", "");
		component.set("v.calculoDias", "");
	},

	onCloseReason: function (component, event, helper) {
		component.set("v.selectedReason", null);
	},

	handleRecalc: function (component, event, helper) {
		var calcSelected = component.get("v.calcSelected");

		if (calcSelected == "Dias") {
			component.set("v.calculoTipoDias", true);
			component.set("v.calculoTipoPorcentagem", false);
			return component.set("v.calculoTipoDias", true);
		}
		component.set("v.calculoTipoDias", false);

		if (calcSelected == "Porcentagem") {
			component.set("v.calculoTipoPorcentagem", true);
			component.set("v.calculoTipoDias", false);
			return component.set("v.calculoTipoPorcentagem", true);
		}
		component.set("v.calculoTipoPorcentagem", false);
	},

	clickContest: function (component, event, helper) {
		helper.contestItems(component, helper);
	},

	onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		let allInvoices = component.get("v.selectedItem");
		if (!allInvoices) return;

		if (fieldName == "amountDue") fieldName = "realValue";

		component.set("v.selectedItem", helper.sortData(fieldName, sortDirection, allInvoices));
	},

	approveContestation: function (component, event, helper) {
		helper.approveContestation(component, event, helper);
	},

	denyContestation: function (component, event, helper) {
		helper.denyContestation(component, event, helper);
	},

	saveReturnMethod: function (component, event, helper) {
		component.set("v.selectedReturn", event.getSource().get("v.name"));

		helper.saveReturnMethod(component, event, helper);
	}
});