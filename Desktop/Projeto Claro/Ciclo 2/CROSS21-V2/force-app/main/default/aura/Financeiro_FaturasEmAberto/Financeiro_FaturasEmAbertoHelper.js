/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 08-02-2021
 * @last modified by  : Caio Cesar
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   22-01-2021   Diego Almeida   Initial Version
 * 1.1   08-02-2021	  Caio Cesar      US110320 Regra Segunda Via
 **/
({
	initialLoad: function (component) {
		this.setColumns(component);
		this.setFilters(component);
		this.verifyDuplicatePermission(component);
	},

	verifyDuplicatePermission: function (component) {
		let action = component.get("c.verifyDuplicatePermission");
		action.setParams({
			csId: component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();
			console.log("verifyDuplicatePermission data: " + data);
			if (state === "SUCCESS") {
				if (data == null) {
					this.showToast("Erro ao Obter permissão para envio da segunda via", errors[0].message, "error");
				}
				else{
					component.set("v.duplicatePermission", data);
				}
			} else if (state === "ERROR") {
				const errors = response.getError();
				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
				component.set("v.duplicatePermission", false);
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	checkCaseIsContestation: function (component, caseId) {
		let action = component.get("c.checkOpenCase");
		action.setParams({
			caseId
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data) {
					this.findInvoiceDetails(component, { idFatura: data }, (success, error) => {
						if (error) return;

						const cmpEvent = component.getEvent("Financeiro_ComponentEvent");

						cmpEvent.setParams({
							message: "OPENBILLDETAIL",
							payload: success
						});
						component.set("v.isLoading", false);
						cmpEvent.fire();
					});
				}
			} else if (state === "ERROR") {
				const errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}
		});
		$A.enqueueAction(action);
	},

	callOpenInvoices: function (component, isRenderer) {
		console.log("callOpenInvoices");
		if (!component.get("v.contractId") || !component.get("v.operatorId")) return;

		component.set("v.isLoading", true);
		let recordId = component.get("v.recordId");
		console.log("recordId callOpenInvoices ->", recordId);
		console.log("isRenderer? isRenderer ->", isRenderer);
		if (isRenderer) recordId = null;

		let action = component.get("c.getOpenInvoices");
		action.setParams({
			contractId: component.get("v.contractId"),
			operatorId: component.get("v.operatorId"),
			recordId: recordId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.success) {
					data.invoices.forEach((x) => {
						let realValue = JSON.parse(JSON.stringify(x.valor));
						realValue = Number(
							realValue
								.replace(/[^0-9,.]/g, "")
								.replace(",", ".")
								.replace(" ", "")
						);
						x.realValue = realValue;

						x.hasContestation = x.contestation != null && x.contestation != undefined;
						x.hasContestationText = x.contestation ? "Pendente" : "Não";

						let realDate = JSON.parse(JSON.stringify(x.dataVencimento));
						realDate = realDate.split("/");
						x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
					});

					component.set("v.invoices", data.invoices);
					component.set("v.errorOnCall", false);
				} else {
					this.showToast("Erro", data.message, "error");
					component.set("v.errorOnCall", true);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					component.set("v.errorOnCall", true);
				}
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	setColumns: function (component) {
		const columns = [
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_Tipo"),
				fieldName: "tipoFatura",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_Situacao"),
				fieldName: "status",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_FormaDePagamento"),
				fieldName: "cobranca",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_DataVencimento"),
				fieldName: "dataVencimento",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_Valor"),
				fieldName: "valor",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: $A.get("$Label.c.Fin_FaturasEmAberto_Contestacao"),
				fieldName: "hasContestationText",
				type: "text",
				sortable: true,
				cellAttributes: { class: "table" }
			},
			{
				label: "",
				type: "button",
				initialWidth: 185,
				typeAttributes: {
					label: $A.get("$Label.c.Fin_FaturasEmAberto_MaisInformacoes"),
					title: "Ver Detalhe",
					name: "view_modal",
					iconName: "utility:preview"
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

		component.set("v.productFilters", [
			{ label: "Visualizar Todos", value: "all" },
			{ label: "Telefone", value: "phone" },
			{ label: "Virtua", value: "virtua" },
			{ label: "TV", value: "tv" }
		]);

		component.set("v.statusFilters", [{ label: "Visualizar Todos", value: "all" }]);
	},

	findInvoiceDetails: function (component, invoice, callback) {
		let recordId = component.get("v.recordId");
		let action = component.get("c.getInvoiceDetails");

		let contestId = "";
		if (invoice.contestation) contestId = invoice.contestation.caseId;

		action.setParams({
			contractNumber: component.get("v.contractId"),
			invoiceId: invoice.idFatura,
			operatorCode: component.get("v.operatorId"),
			infoDetailLevel: "DETAILS",
			recordId,
			contestId
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.success) {
					component.set("v.detailInvoice", data);
					component.set("v.errorOnCall", false);
					console.log("100089 :: getInvoiceDetails", JSON.parse(JSON.stringify(data)));

					let realValue = JSON.parse(JSON.stringify(data.invoiceDetails.valor));
					// realValue = Number(
					// @note Bug 10262254: erro ao somar os valores de contestacao nao conta com valores negativos
					realValue = parseFloat(
						realValue
							// .replace(/[^0-9,.]/g, '')
							.replace("R$", "")
							.replace(",", ".")
							.replace(" ", "")
					);
					//fim bug 10262254
					data.invoiceDetails.realValue = realValue;

					let realDate = JSON.parse(JSON.stringify(data.invoiceDetails.dataVencimento));
					realDate = realDate.split("/");
					data.realDate = new Date(realDate[2], realDate[1], realDate[0]);
					console.log("debug bia :", JSON.parse(JSON.stringify(data)));

					component.set("v.detailInvoice", data.invoiceDetails);

					let allInvoices = component.get("v.invoices");

					allInvoices.forEach((x) => {
						if (data.invoiceDetails.idFatura == x.idFatura) data.invoiceDetails.contestation = x.contestation;
					});
					// @note :  Bug botao -  camnada do canDispute ainda nao contem os dados de caseID
					if (data.invoiceDetails.contestation) {
						if (invoice.idFatura == data.invoiceDetails.contestation.invoiceId) {
							data.invoiceDetails.canDispute = true;
						}
					}
					//fim Bug Botao

					if (callback) {
						callback(data.invoiceDetails);
					}
				} else {
					this.showToast("Erro", data.message, "error");

					if (callback) callback(null, data.message);
				}
			} else if (state === "ERROR") {
				const errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");

				if (callback) callback(null, errors);
			}
		});
		$A.enqueueAction(action);
	},

	getInvoiceDuplicates: function (component, invoice, callback) {
		let action = component.get("c.getDuplicateInfo");
		action.setParams({
			billId: invoice.idFatura,
			operatorCode: component.get("v.operatorId")
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			let data = response.getReturnValue();

			if (state === "SUCCESS") {
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

					component.set("v.sendMethodOptions", methods);
					component.set("v.sendReasonOptions", reasons);
					component.set("v.duplicate", data.duplicates);

					if (callback) callback(data.duplicates);
				} else {
					this.showToast("Erro", data.message, "error");

					if (callback) callback(null, data.message);
				}
			} else if (state === "ERROR") {
				const errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");

				if (callback) callback(null, errors);
			}
		});
		$A.enqueueAction(action);
	},

	//MÉTODO PARA POST DE SEGUNDA VIA PARA A FATURA
	postInvoiceDuplicates: function (component, invoice, callback) {
		console.log("entrou duplicater");
		const sendMethodOption = component.get("v.sendMethodOptions");
		const selectedMethod = component.get("v.selectedSendMethod");
		const sendMethodSize = sendMethodOption.length;
		let sendMethod;

		for (var i = 0; i < sendMethodSize; i++) {
			let methodOption = sendMethodOption[i];

			if (methodOption.value == selectedMethod) sendMethod = methodOption.label;
		}

		sendMethod = sendMethod.replace(/-/g, "");

		console.log("sendMethod ->", JSON.parse(JSON.stringify(sendMethodOption)));
		console.log("method option selected", JSON.parse(JSON.stringify(component.get("v.selectedSendMethod"))));
		console.log("sendMethod", JSON.parse(JSON.stringify(sendMethod)));

		let action = component.get("c.postDuplicate");
		action.setParams({
			operatorCode: component.get("v.operatorId"),
			contractNumber: component.get("v.duplicate.contractNumber"),
			userName: "REMOVER PROXIMA SPRINT",
			billId: invoice.idFatura,
			name: component.get("v.duplicate.name"),
			phoneNumber: component.get("v.duplicate.phoneNumber"),
			email: component.get("v.duplicate.email"),
			//sendMethod: component.get('v.selectedSendMethod'),
			sendMethod: sendMethod,
			billExtend: component.get("v.duplicate.billExtend"),
			descriptionReason: component.get("v.selectedSendReason"),
			caseId: component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			console.log("data retorno duplicate ->", JSON.parse(JSON.stringify(data)));

			if (state === "SUCCESS") {
				if (data.success) {
					component.set("v.title", $A.get("$Label.c.Fin_send_title_success"));
					component.set("v.typeIcon", "utility:success");
					component.set("v.typeVariant", "success");
					component.set("v.message", $A.get("$Label.c.Fin_send_success"));
					component.set("v.dialogModal", true);
					component.find("modalMessage").open();
				} else {
					component.set("v.title", $A.get("$Label.c.Fin_send_title_error"));
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "error");
					component.set("v.message", data.postDuplicateResponse);
					component.set("v.dialogModal", true);
					component.find("modalMessage").open();
				}
			} else if (state === "ERROR") {
				component.set("v.title", "Alerta:");
				component.set("v.typeIcon", "utility:warning");
				component.set("v.typeVariant", "warning");
				component.set("v.message", data.message);
				component.set("v.dialogModal", true);
				component.find("modalMessage").open();
			}
		});
		$A.enqueueAction(action);
	},

	findInvoicePeriod: function (component, invoice, callback) {
		console.log("findInvoicePeriod");

		let action = component.get("c.getOpenInvoicesManualPeriod");
		// let action = component.get("c.getOpenInvoices");
		const recordId = component.get("v.recordId");
		console.log("recordId findInvoicePeriod ->", recordId);

		action.setParams({
			contractId: component.get("v.contractId"),
			operatorId: component.get("v.operatorId"),
			startDate: component.get("v.FilterStartDate"),
			endDate: component.get("v.FilterEndDate"),
			recordId: recordId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.success) {
					data.invoices.forEach((x) => {
						let realValue = JSON.parse(JSON.stringify(x.valor));
						realValue = Number(
							realValue
								.replace(/[^0-9,.]/g, "")
								.replace(",", ".")
								.replace(" ", "")
						);
						x.realValue = realValue;

						console.log("valor -> " + x.contestation);

						x.hasContestation = x.contestation != null && x.contestation != undefined;
						x.hasContestationText = x.contestation ? "Pendente" : "Não";

						let realDate = JSON.parse(JSON.stringify(x.dataVencimento));
						realDate = realDate.split("/");
						x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
					});

					component.set("v.invoices", data.invoices);
					component.set("v.errorOnCall", false);
				} else {
					this.showToast("Erro", data.message, "error");
					component.set("v.errorOnCall", true);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					component.set("v.errorOnCall", true);
				}
			}

			component.set("v.ShowInvoicesPeriod", false);
		});
		$A.enqueueAction(action);
	},

	showToast: function (component, message) {
		var toastEvent = $A.get("e.force:showToast");
		let msg = message;
		toastEvent.setParams({
			title: "Erro",
			message: msg,
			duration: " 6000",
			key: "info_alt",
			type: "error",
			mode: "pester"
		});
		toastEvent.fire();
	},

	findInvoicePeriodSelected: function (component, invoice, callback) {
		console.log("findInvoicePeriodSelected");

		let action = component.get("c.getOpenInvoicesByPeriod");
		const recordId = component.get("v.recordId");
		console.log("recordId findInvoicePeriodSelected ->", recordId);

		action.setParams({
			contractId: component.get("v.contractId"),
			operatorId: component.get("v.operatorId"),
			period: component.get("v.period"),
			recordId: recordId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.success) {
					data.invoices.forEach((x) => {
						let realValue = JSON.parse(JSON.stringify(x.valor));
						realValue = Number(
							realValue
								.replace(/[^0-9,.]/g, "")
								.replace(",", ".")
								.replace(" ", "")
						);
						x.realValue = realValue;

						console.log("valor -> " + x.contestation);

						x.hasContestation = x.contestation != null && x.contestation != undefined;
						x.hasContestationText = x.contestation ? "Pendente" : "Não";

						let realDate = JSON.parse(JSON.stringify(x.dataVencimento));
						realDate = realDate.split("/");
						x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
					});

					component.set("v.invoices", data.invoices);
					component.set("v.errorOnCall", false);
				} else {
					this.showToast("Erro", data.message, "error");
					component.set("v.errorOnCall", true);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					component.set("v.errorOnCall", true);
				}
			}
			component.set("v.ShowInvoicesPeriod", false);
		});
		$A.enqueueAction(action);

		component.set("v.PeriodoCustomizado", false);
	}
});