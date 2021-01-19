({
	initialLoad: function (component) {
		component.set("v.isLoading", true);

		const evPayload = component.get("v.evPayload");

		component.set("v.selectedItem", evPayload.futureContestation);
		component.set("v.departureObject", evPayload.departureGroups);

		Promise.all([this.correctItems(component), this.setFilters(component), this.setColumns(component), this.setContestationReasons(component)]).then(() => {
			component.set("v.isLoading", false);
		});
	},

	correctItems: function (component) {
		return new Promise((resolve) => {
			const selectedItem = component.get("v.selectedItem");
			let contestationReason = "";
			let hasFullItem = false;

			selectedItem.forEach((x) => {
				let realValue = JSON.parse(JSON.stringify(x.amountDue));
				realValue = Number(
					realValue
						.replace(/[^0-9,.]/g, "")
						.replace(",", ".")
						.replace(" ", "")
				);
				x.realValue = realValue;
				x.valorContestar = x.valorContestar == null ? "0" : x.valorContestar;
				x.percentualContestar = "0";

				if (x.fullItem || x.dbAdjustment) hasFullItem = true;

				if (x.note) contestationReason = x.note;

				if (x.dbAdjustment) {
					x.valorContestar = x.realValue - x.dbAdjustment.ContestedAmount__c;
					x.contestationReason = x.dbAdjustment.Reason__c;
					x.valorCorrigido = x.dbAdjustment.ContestedAmount__c;
					contestationReason = x.dbAdjustment.vlocity_cmt__Notes__c;
				}
			});

			component.set("v.fullItem", hasFullItem);
			component.set("v.contestationObservation", contestationReason);
			component.set("v.selectedItem", selectedItem);
			resolve();
		});
	},

	setFilters: function (component) {
		return new Promise((resolve) => {
			component.set("v.calcValues", [
				{ label: "Cálculo por Dias", value: "Dias" },
				{ label: "Cálculo por Porcentagem", value: "Porcentagem" }
			]);
			resolve();
		});
	},

	setColumns: function (component) {
		return new Promise((resolve) => {
			const columns = [
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_ItemSelecionado"),
					fieldName: "description",
					type: "text",
					editable: false,
					sortable: true,
					cellAttributes: { class: "table" }
				},
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_ValorOriginal"),
					initialWidth: 160,
					fieldName: "amountDue",
					type: "text",
					editable: false,
					sortable: true,
					cellAttributes: { class: "table" }
				},
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_Calculadora"),
					type: "button",
					initialWidth: 200,
					typeAttributes: { label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_DiaPercentual"), name: "CalcularButton" }
				},
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_ValorContestar"),
					initialWidth: 185,
					fieldName: "valorContestar",
					type: "currency",
					typeAttributes: { currencyCode: "BRL" },
					editable: true,
					sortable: true,
					cellAttributes: { class: "table" }
				},
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_Motivo"),
					type: "button",
					initialWidth: 140,
					typeAttributes: {
						label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_Selecionar"),
						name: "ItemMotivo",
						iconName: "utility:down"
					}
				},
				{
					label: $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_ValorCorrigido"),
					initialWidth: 180,
					fieldName: "valorCorrigido",
					type: "currency",
					typeAttributes: { currencyCode: "BRL" },
					editable: false,
					sortable: true,
					cellAttributes: { class: "table" }
				},
				{ type: "button", initialWidth: 75, typeAttributes: { name: "Deletar", iconName: "utility:delete" } }
			];

			component.set("v.columns", columns);
			resolve();
		});
	},

	setContestationReasons: function (component) {
		return new Promise((resolve) => {
			let action = component.get("c.getContestationOptions");
			action.setCallback(this, function (response) {
				const state = response.getState();
				const data = response.getReturnValue();

				if (state === "SUCCESS") {
					component.set("v.reasonValuesOriginal", data);
				} else if (state === "ERROR") {
					const errors = response.getError();
					if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
				}

				resolve();
			});
			$A.enqueueAction(action);
		});
	},

	handleDelete: function (component, helper, row) {
		let invoiceItems = component.get("v.selectedItem");
		let newArr = [];
		let idsItems = [];

		newArr = invoiceItems.filter((x) => {
			if (x.id != row.id) {
				idsItems.push(x.id);
				return true;
			}

			return false;
		});

		component.set("v.selectedRows", idsItems);
		component.set("v.selectedItem", newArr);
	},

	handleSelectReason: function (component, row) {
		component.set("v.reasonValues", []);
		component.set("v.reasonContext", row);

		const availableReasons = row.contestationOptions;

		let newReasons = [];
		const allReasons = component.get("v.reasonValuesOriginal");

		newReasons = allReasons.filter((x) => {
			return x.partnerId == row.partnerId;
		});

		let fixedReasons = [];

		for (let i = 0; i < newReasons.length; i++) {
			const reason = newReasons[i];

			for (let j = 0; j < availableReasons.length; j++) if (parseInt(reason.value) == availableReasons[j].contestationReasonId) fixedReasons.push(reason);
		}

		component.set("v.reasonValues", fixedReasons);
		component.find("reasonModal").open();
	},

	contestItems: function (component, helper) {
		if (!this.performChecks(component, helper)) return;

		component.set("v.isLoading", true);

		const comment = component.get("v.contestationObservation");

		let contestationObj = {
			operatorCode: component.get("v.operatorId"),
			contractNumber: component.get("v.contractId"),
			caseId: component.get("v.recordId"),
			comment: comment,
			items: this.createContestationItems(component.get("v.selectedItem"), comment),
			dpGroup: this.formatDpGroup(component.get("v.departureObject"))
		};

		console.log("@@@@@ performContestation ->", contestationObj);

		let action = component.get("c.performContestation");
		action.setParams({
			contestationString: JSON.stringify(contestationObj),
			isCaseApprovation: component.get("v.isN2User") && component.get("v.fullItem")
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.hasAuthority) {
					this.showToast("Sucesso", "Contestação realizada com sucesso.", "success");

					const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
					cmpEvent.setParams({
						message: "CLOSEFUTURECONTESTATION",
						payload: { tabId: "lancamentosfuturos" }
					});
					cmpEvent.fire();
				} else {
					this.showToast("Sucesso", "Você não tem alcada suficiente.", "warning");

					component.set("v.contestedWithoutPermission", true);
					component.set("v.disabledBack", true);
					component.set("v.disabledContest", true);

					let cmpTarget = component.find("contestation");
					$A.util.addClass(cmpTarget, "disable-contestation");

					cmpTarget = component.find("buttons-contestation");
					$A.util.addClass(cmpTarget, "disable-contestation");
				}
			} else if (state === "ERROR") {
				const errors = response.getError();
				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	performChecks: function (component, helper) {
		const allItems = component.get("v.selectedItem");
		const observation = component.get("v.contestationObservation") || "";

		if (observation.length == 0) return helper.showToast("Erro", "Preencha o campo de observação", "error");

		if (allItems.length == 0) return helper.showToast("Erro", "Selecione ao menos um item para contestar", "error");

		for (let index = 0; index < allItems.length; index++) {
			const element = allItems[index];

			if (!element.contestationReason) return helper.showToast("Erro", `Item ${element.description} não tem um motivo de contestação`, "error");

			if (!element.valorCorrigido && element.valorCorrigido !== 0) return helper.showToast("Erro", `Item ${element.description} não tem um valor de contestação`, "error");

			if (element.valorCorrigido != 0 && element.partnerId == "16")
				return helper.showToast("Erro", `Item ${element.description} deverá ser contestado somente o valor total`, "error");
		}

		return true;
	},

	createContestationItems: function (items, comment) {
		if (!items || !items.length) return;

		let itemsArr = [];

		items.forEach((x) => {
			itemsArr.push({
				contestationReason: parseInt(x.contestationReason),
				partnerId: parseInt(x.partnerId),
				originalValue: x.realValue,
				valorContestar: parseFloat(x.valorContestar.toFixed(2)),
				valorCorrigido: parseFloat(x.valorCorrigido.toFixed(2)),
				itemId: Number(x.id),
				description: x.description,
				note: comment
			});
		});

		return itemsArr;
	},

	formatDpGroup: function (groups) {
		let newFormat = [];

		Object.keys(groups).forEach((x) => {
			newFormat.push({
				partnerId: parseInt(x),
				value: groups[x]
			});
		});

		return newFormat;
	},

	approveContestation: function (component, event, helper) {
		this.contestItems(component, helper);
	},

	denyContestation: function (component, event, helper) {
		const caseId = component.get("v.recordId");
		const comment = component.get("v.contestationObservation");

		component.set("v.isLoading", true);
		component.set("v.disabledContest", true);

		let action = component.get("c.denyCase");
		action.setParams({
			caseId,
			caseComment: comment
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				this.showToast("Sucesso", "Contestação negada com sucesso.", "success");

				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({
					message: "CLOSEFUTURECONTESTATION",
					payload: { tabId: "lancamentosfuturos" }
				});
				cmpEvent.fire();
			} else if (state === "ERROR") {
				const errors = response.getError();
				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.disabledContest", false);
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	saveReturnMethod: function (component, event, helper) {
		const caseId = component.get("v.recordId");
		const selectedReturn = component.get("v.selectedReturn");

		component.set("v.isLoading", true);

		let action = component.get("c.setReturnMethod");
		action.setParams({
			caseId,
			returnMethod: selectedReturn
		});
		action.setCallback(this, function (response) {
			const state = response.getState();

			if (state === "SUCCESS") {
				this.showToast("Sucesso", "Contestacao enviada para o backoffice.", "success");

				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({
					message: "CLOSEFUTURECONTESTATION",
					payload: { tabId: "lancamentosfuturos" }
				});
				cmpEvent.fire();
			} else if (state === "ERROR") {
				const errors = response.getError();
				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	}
});