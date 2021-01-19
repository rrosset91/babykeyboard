({
	initialLoad: function (component) {
		this.setColumns(component);
		this.setFilters(component);
	},

	callFutureInvoices: function (component, period) {
		if (!component.get("v.contractId") || !component.get("v.operatorId")) return;

		if (!period) period = 6;

		let paramsObj = {
			contractId: component.get("v.contractId"),
			operatorId: component.get("v.operatorId"),
			extractItemStatus: "FUTURE_RELEASE",
			period: period,
			recordId: component.get("v.recordId")
		};

		if (period == "CustomFilter") {
			paramsObj.dateStart = component.get("v.filterStartDate");
			paramsObj.dateEnd = component.get("v.filterEndDate");
			delete paramsObj.period;
		}
		component.set("v.isLoading", true);

		let action = component.get("c.getHistoryByDatePeriod");
		action.setParams(paramsObj);
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.success) {
					let alreadyContestedItemsId = [];
					let alreadyContestedItems = [];

					data.events.forEach((x) => {
						let vencimento = x.paymentDueDate;
						vencimento = vencimento.split("T")[0];
						vencimento = vencimento.split("-");
						x.formattedDate = vencimento[2] + "/" + vencimento[1] + "/" + vencimento[0];
						let realDueDate = x.formattedDate.split("/");
						x.realDueDate = new Date(realDueDate[2], realDueDate[1], realDueDate[0]);

						let lancamento = x.billDate;
						lancamento = lancamento.split("T")[0];
						lancamento = lancamento.split("-");
						x.formattedBillDate = lancamento[2] + "/" + lancamento[1] + "/" + lancamento[0];
						let realBillDate = x.formattedBillDate.split("/");
						x.realBillDate = new Date(realBillDate[2], realBillDate[1], realBillDate[0]);

						let correctValue = x.amountDue.toFixed(2);
						x.amountDue = "R$" + correctValue;

						x.canContest = x.hasElegibility ? "Sim" : "Não";

						if (!x.productDescription) x.productDescription = "--";

						if (!x.installmentNumber) x.installmentNumber = "--";

						if (!x.installmentsCount) x.installmentsCount = "--";

						if (!x.installments) x.installments = "--";

						if (x.isSfPendingItem) {
							alreadyContestedItemsId.push(x.id);
							alreadyContestedItems.push(x);
						}
					});

					if (alreadyContestedItems.length) {
						component.set("v.selectedReleasesRow", alreadyContestedItems);
						component.set("v.selectedRows", alreadyContestedItemsId);
						component.set("v.disabledView", false);
					}

					component.set("v.amountGroupDeparture", data.departureGroup);
					component.set("v.futureReleases", data.events);
					component.set("v.errorOnCall", false);

					const caseId = component.get("v.recordId");

					if (caseId) this.openDetailBill(component, caseId);
				} else {
					this.showToast("Erro", data.message, "error");
					component.set("v.errorOnCall", true);
					console.log("Erro", data.message);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					console.log("Erro", errors);
					component.set("v.errorOnCall", true);
				}
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	setColumns: function (component) {
		const columns = [
			{ label: "Item", fieldName: "description", type: "text", sortable: true },
			{ label: "Data de Lançamento", fieldName: "formattedBillDate", type: "text", sortable: true },
			{ label: "Valor", fieldName: "amountDue", type: "text", sortable: true },
			{ label: "Contestável", fieldName: "canContest", type: "text", sortable: true },
			{
				label: "Visualizar",
				type: "button",
				initialWidth: 150,
				typeAttributes: {
					label: "Ver Detalhe",
					title: "Ver Detalhe",
					name: "view_modal"
				}
			}
		];

		component.set("v.columns", columns);
	},

	setFilters: function (component) {
		component.set("v.periodFilters", [
			{ label: "6 Meses", value: "6" },
			{ label: "12 Meses", value: "12" },
			{ label: "24 Meses", value: "24" },
			{ label: "Customizado", value: "CustomFilter" }
		]);

		component.set("v.typeFilters", [{ label: "Visualizar Todos", value: "all" }]);
	},

	openDetailBill: function (component, caseId) {
		const isN2 = component.get("v.isBackOfficeN2");
		if (!isN2) return console.log("não é n2 openDetailBill");
		component.set("v.isLoading", true);

		let action = component.get("c.getCasedetails");
		action.setParams({ caseId });
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				let allItems = component.get("v.futureReleases");

				if (!allItems || !allItems.length || !data || !data.length) return;

				let selectedItems = [];

				data.forEach((x) => {
					let integrationItem = allItems.find((f) => f.id.toString() == x.idExtractItem__c);
					if (!integrationItem) return;

					integrationItem.valorContestar = x.ContestedAmount__c;
					integrationItem.valorCorrigido = x.vlocity_cmt__Amount__c - x.ContestedAmount__c;
					integrationItem.contestationReason = x.Reason__c;
					integrationItem.note = x.vlocity_cmt__Notes__c;
					integrationItem.fullItem = x;

					selectedItems.push(integrationItem);
				});

				const departureGroups = component.get("v.amountGroupDeparture");

				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({
					message: "OPENFUTURECONTESTATION",
					payload: { futureContestation: selectedItems, departureGroups }
				});
				cmpEvent.fire();
			} else {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					console.log("Erro", errors);
					component.set("v.errorOnCall", true);
				}
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	}
});