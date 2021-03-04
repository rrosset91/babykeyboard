({
	initialLoad: function (component, helper) {
		component.set("v.columns", this.setColumns(component));
		component.set("v.columnsDetails", this.setColumnsDetails(component));
		const status = component.get("v.selectedBill").status;

		//Apresentar Modal Message
		if (
			status != "Pago" &&
			status != "Em Aberto" &&
			status != "Pago Cartão de Crédito" &&
			status != "Em Aberto por Rejeição de Cartão de Crédito" &&
			status != "Em Aberto - Sub Júdice"
		)
			helper.showToast("Aviso", "O status da fatura não permite contestação", "warning");
	},
	// @note Bug 100632 : formatacao de variaveis para envio
	formatValuePdf: function (component, num, padlen, padchar) {
		var pad_char = typeof padchar !== "undefined" ? padchar : "0";
		var pad = new Array(1 + padlen).join(pad_char);
		var retunString = (pad + num).slice(-pad.length);
		return retunString;
	},
	setCheckedValues: function (component, bill) {
		component.set("v.isN2Contestation", false);

		if (!bill.contestation || !bill.contestation.items) return;

		const recordId = component.get("v.recordId");

		if (recordId && bill.contestation.caseId && recordId != bill.contestation.caseId) return;

		let constItems = [];
		bill.contestation.items.forEach((x) => {
			constItems.push(x.idInvoiceItem);
		});

		component.set("v.isN2Contestation", true);

		let allItems = component.get("v.invoiceItens") || [];
		let contestedItems = [];

		allItems.forEach((x) => {
			let contestationItem = bill.contestation.items.find((y) => {
				return x.idItem == y.idInvoiceItem;
			});

			if (!contestationItem) return;

			x.contestationItem = contestationItem;
			x.valorContestar = Number(x.realValue - Number(contestationItem.wishedValue)).toFixed(2);
			x.valorCorrigido = x.realValue - x.valorContestar;
			x.contestationReason = parseInt(contestationItem.reason);
			x.note = contestationItem.note;

			contestedItems.push(x);
		});

		if (contestedItems) component.set("v.disabledContest", false);

		component.set("v.selectedBill", bill);
		component.set("v.selectedItens", contestedItems);
		component.set("v.selectedRows", constItems);
		component.set("v.contestationObservation", contestedItems[0].note);
		component.set("v.currentStep", 1);
	},
	callInvoiceDetail: function (component, invoice) {
		component.set("v.isLoading", true);

		this.callElegibility(component);

		let allProducts = component.get("v.selectedBill").detalheProdutos || [];
		let correctProducts = [];
		allProducts.forEach((prd) => {
			let realValue = JSON.parse(JSON.stringify(prd.valor));
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
			prd.realValue = realValue;
			prd.valorContestar = 0;
			prd.percentualContestar = "0";
			// @note Task 100089: exibir  todos os itens enviados no detalhe da fatura mesmo q estejam de valor 0
			//if (realValue > 0) correctProducts.push(prd);
			correctProducts.push(prd);
		});

		component.set("v.invoiceItens", correctProducts);
	},
	callElegibility: function (component, invoice) {
		let bill = component.get("v.selectedBill");
		let action = component.get("c.getContestation");
		action.setParams({
			contract: component.get("v.contractId"),
			operatorCode: component.get("v.operatorId"),
			billId: component.get("v.selectedBill.idFatura"),
			userName: "REMOVER PROXIMA SPRINT"
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();

			if (state === "SUCCESS") {
				this.processContestation(component, data, bill);

				/*
				if (!data.success) {
					this.showToast("Erro", data.message, "error");
					component.set("v.errorOnCall", true);
				}*/
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
	showToast: function (title, message, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: title,
			message: message,
			type: type
		});
		toastEvent.fire();
	},
	//@audit-check
	setColumns: function (component) {
		let columns = [
			{ label: $A.get("$Label.c.Fin_DetalhesFatura_Table_Item"), fieldName: "descricao", type: "text", sortable: true, cellAttributes: { class: "table" } },
			// { label: 'GRUPO', fieldName: 'groupString', type: 'text', sortable: true, cellAttributes:{ class: 'table'}},
			{ label: $A.get("$Label.c.Fin_DetalhesFatura_Table_DataLancamento"), fieldName: "dataLancamento", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: $A.get("$Label.c.Fin_DetalhesFatura_Table_Valor"), fieldName: "valor", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: $A.get("$Label.c.Fin_DetalhesFatura_Table_Contestavel"), fieldName: "contestable", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{
				type: "button",
				initialWidth: 185,
				typeAttributes: {
					label: $A.get("$Label.c.Fin_DetalhesFatura_Table_MaisInformacoes"),
					title: "Ver Detalhe",
					name: "viewDetailModal",
					iconName: "utility:preview"
				}
			}
		];
		return columns;
	},
	// @note :Task 100089 : colunas do wrapper de details
	setColumnsDetails: function (component) {
		let columns = [
			{ label: "Período", fieldName: "periodo", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "Telefone Destino", fieldName: "telefoneDestino", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "Local Destino", fieldName: "localDestino", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "País", fieldName: "pais", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "Horário Início", fieldName: "horarioInicio", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "Duração", fieldName: "duracao", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: "Valor", fieldName: "valor", type: "text", sortable: true, cellAttributes: { class: "table" } },
			{ label: $A.get("$Label.c.Fin_DetalhesFatura_Table_Contestavel"), fieldName: "contestable", type: "text", sortable: true, cellAttributes: { class: "table" } }
		];
		return columns;
	},
	applyComponentAnimation: function (component, currentStep) {
		const cmpFound = component.find(this.getCmpName(currentStep));
		if (cmpFound) $A.util.addClass(cmpFound, "animation");
	},
	getCmpName: function (cmpNumber) {
		const cmpName = {
			0: "allItems",
			1: "selectedItems",
			2: "creditReturn",
			3: "clientReturn"
		};
		return cmpName[cmpNumber];
	},
	performSelectedItemsFunction: function (component, helper, callback) {
		const allItems = component.get("v.selectedItens");

		if (allItems.length == 0) {
			helper.showToast("Erro", "Selecione ao menos um item para contestar", "error");
			if (callback) return callback(null, true);
		} else {
			if (callback) callback(true);
		}
	},
	performContestationEfetivation: function (component, helper, callback) {
		const idsItems = component.get("v.selectedItens");
		const allItems = component.get("v.selectedItens");
		const observation = component.get("v.contestationObservation");
		const billObj = component.get("v.selectedBill");
		if (observation.length == 0) {
			helper.showToast("Erro", "Preencha o campo de observação", "error");
			if (callback) return callback(null, { type: "no_observation" });
		}
		if (idsItems.length == 0) {
			helper.showToast("Erro", "Selecione ao menos um item para contestar", "error");
			if (callback) return callback(null, { type: "no_items" });
		}
		for (let index = 0; index < allItems.length; index++) {
			const element = allItems[index];
			if (!element.contestationReason) {
				helper.showToast("Erro", `Item ${element.descricao} não tem um motivo de contestação`, "error");
				if (callback) return callback(null, { type: "no_reason" });
			}
			if (!element.valorCorrigido && element.valorCorrigido !== 0) {
				helper.showToast("Erro", `Item ${element.descricao} não tem um valor de contestação`, "error");
				if (callback) return callback(null, { type: "no_price" });
			}
			if (element.valorCorrigido != 0 && element.idParceiro == "16") {
				// if(element.valorCorrigido != element.realValue && element.idParceiro == '16'){
				helper.showToast("Erro", `Item ${element.descricao} deverá ser contestado somente o valor total`, "error");
				if (callback) return callback(null, { type: "no_price" });
			}
		}
		if (billObj.status == "Pago" || billObj.status == "Pago Cartão de Crédito") {
			helper.performContestationReturn(component, helper, callback);
		} else {
			if (callback) callback(true);
		}
	},
	performContestationReturn: function (component, helper, callback) {
		const alreadyContested = component.get("v.alreadyContested");
		const hasAuthority = component.get("v.hasAuthority");
		if (alreadyContested) {
			if (hasAuthority) {
				//Apresentar Modal Message
				// component.set('v.dialogModal', true);
				// component.set('v.titleMessage', 'Efetivação');
				// component.set('v.typeIcon', 'utility:success');
				// component.set('v.typeVariant', 'success');
				// component.set('v.textButton2', 'Fechar');
				// component.set('v.message', 'Contestação criada com sucesso');
				// component.find('modalMessage').open();
				// component.set('v.afterMessage', 'dontNeedApproval');
				return this.dontNeedApproval(component, helper);
			} else {
				if (callback) return callback(true);
			}
		}
		component.set("v.isLoading", true);
		const status = component.get("v.selectedBill").status;
		const invoiceItemsLght = component.get("v.selectedItens");
		const invoiceItems = JSON.parse(JSON.stringify(invoiceItemsLght));
		let returnMethod = component.get("v.selectedReturnMethod") || "";
		const recalculationReturn = component.get("v.selectedRecalculationMethod") || "";
		const contestationObservation = component.get("v.contestationObservation") || "";
		let bill = component.get("v.selectedBill");
		bill.contractId = component.get("v.contractId");
		bill.operatorId = component.get("v.operatorId");

		console.clear();

		console.log("returnMethod -> ", JSON.parse(JSON.stringify(bill)));

		let amountsDeparture = [];
		Object.keys(bill.amountAgainstDeparture).forEach((key) => {
			amountsDeparture.push({ groupId: key, value: bill.amountAgainstDeparture[key] });
		});

		invoiceItems.forEach((item) => {
			["allowContestation", "contestable", "dataLancamento", "dataVencimento", "descricaoProduto", "groupString", "parceiro", "percentualContestar", "valor"].forEach(
				(field) => {
					delete item[field];
				}
			);
		});
		const invoice = {
			items: invoiceItems,
			bill: {
				idFatura: bill.idFatura,
				contractId: bill.contractId,
				operatorId: bill.operatorId,
				amountAgainstDeparture: amountsDeparture
			}
		};

		if (status == "Pago" || status == "Pago Cartão de Crédito") returnMethod = "f";

		let action = component.get("c.disputeInvoice");

		let caseId;
		let isN2Update = false;

		if (bill.contestation) {
			caseId = bill.contestation.caseId;
			isN2Update = true;
		} else {
			caseId = component.get("v.recordId");
		}

		console.log("Valor Stringify -> ========== -> " + JSON.stringify(invoice));
		console.log("invoiceStg -> " + JSON.parse(JSON.stringify(invoice)));
		console.log("returnMethod -> " + JSON.parse(JSON.stringify(returnMethod)));
		console.log("recalculationReturn -> " + JSON.parse(JSON.stringify(recalculationReturn)));
		console.log("contestationObservation -> " + JSON.parse(JSON.stringify(contestationObservation)));

		action.setParams({
			invoiceStg: JSON.stringify(invoice),
			returnMethod,
			recalculationReturn,
			contestationObservation,
			caseId,
			isN2Update
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			var data = response.getReturnValue();
			if (state === "SUCCESS") {
				component.set("v.isLoading", false);
				component.set("v.caseId", data.caseId);
				component.set("v.alreadyContested", true);
				component.set("v.hasAuthority", !data.needApproval);
				if (data.code >= 500) {
					if (data.errorMessage == "[500]Claro API Erro: Erro de Contestação, caso finalizado") {
						this.showToast("Erro", "Claro API Erro: Erro de Contestação, caso finalizado", "error");
						component.set("v.errorOnCall", true);
						if (callback) return callback(null, { type: "case_closed_apiError" });
						const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
						cmpEvent.setParams({
							message: "CLOSEBILLDETAIL"
						});
						cmpEvent.fire();
					} else {
						component.set("v.dialogModal", true);
						component.set("v.titleMessage", "Efetivação");
						component.set("v.typeIcon", "utility:warning");
						component.set("v.typeVariant", "warning");
						component.set("v.showButton1", "true");
						component.set("v.textButton1", "Tentar novamente");
						component.set("v.afterMessage", "clickNextCase4");
						component.set("v.textButton2", "Voltar para ficha financeira");
						component.set("v.message", "Claro API Erro: Erro de Contestação");
						component.find("modalMessage").open();
					}
				} else {
					if (status == "Pago" || status == "Pago Cartão de Crédito") component.set("v.showFirst", false);

					if (data.needApproval) {
						helper.showToast("Contestação enviada para backoffice", "Os valores selecionados para contestação estão acima de sua alçada.", "warning");
					}
					if (!data.needApproval && status != "Pago" && status != "Pago Cartão de Crédito") {
						//verifica se foi selecionado alguma forma de envio da segunda via de boleto
						let duplicate = component.get("v.choosedDuplicate");
						if (duplicate) {
							duplicate.caseId = component.get("v.caseId");
							if (returnMethod == "recalculation") {
								console.log("Recalculo. Enviando nova fatura.");
								const newBillId = data.newBillId;

								if (!newBillId) {
									this.showToast("Falha", "Novo ID de fatura não recebido. Será enviado por email a fatura antiga.", "warning");
								} else {
									duplicate.billId = newBillId;
								}
							}
							this.postInvoiceDuplicates(component, duplicate);
						}
						return helper.dontNeedApproval(component, helper);
					}
					if (callback) callback(true);
				}
			} else if (state === "ERROR") {
				// @note 92819 Fechamento do Caso de Contestação em caso de falha de API - callerror 500
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					if (errors[0].message.indexOf("[500]") == 0) {
						if (errors[0].message == "[500]Claro API Erro: Erro de Contestação, caso finalizado") {
							this.showToast("Erro", "Claro API Erro: Erro de Contestação, caso finalizado", "error");
							component.set("v.errorOnCall", true);
							if (callback) return callback(null, { type: "case_closed_apiError" });
							const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
							cmpEvent.setParams({
								message: "CLOSEBILLDETAIL"
							});
							cmpEvent.fire();
						} else {
							component.set("v.dialogModal", true);
							component.set("v.titleMessage", "Efetivação");
							component.set("v.typeIcon", "utility:warning");
							component.set("v.typeVariant", "warning");
							component.set("v.showButton1", "true");
							component.set("v.textButton1", "Tentar novamente");
							component.set("v.afterMessage", "clickNextCase4");
							component.set("v.textButton2", "Voltar para ficha financeira");
							component.set("v.message", "Claro API Erro: Erro de Contestação");
							component.find("modalMessage").open();
						}
					} else {
						this.showToast("Erro", errors[0].message, "error");
						component.set("v.errorOnCall", true);
					}
				}
				if (callback) return callback(null, { type: "no_contestation" });
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},
	performContestationLastStep: function (component, helper, callback) {
		component.set("v.isLoading", true);
		const notificationMethod = component.get("v.notificationMethod");
		const caseId = component.get("v.caseId");
		let action = component.get("c.setReturnMethod");
		action.setParams({
			caseId: caseId,
			returnMethod: notificationMethod
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			component.set("v.isLoading", false);
			if (state === "SUCCESS") {
				if (callback) callback(true);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors[0] && errors[0].message) {
					this.showToast("Erro", errors[0].message, "error");
					component.set("v.errorOnCall", true);
				}
				if (callback) return callback(null, { type: "cant_save_notification" });
			}
		});
		$A.enqueueAction(action);
	},
	performPagination: function (component, currentStep) {
		component.set("v.currentStep", currentStep);
		this.applyComponentAnimation(component, currentStep);
	},
	dontNeedApproval: function (component, helper) {
		// component.set('v.showButtons', true);
		// const cmpEvent = component.getEvent('Financeiro_ComponentEvent');
		// cmpEvent.setParams({
		// 	message: 'CLOSEBILLDETAIL'
		// });
		// cmpEvent.fire();
		component.set("v.isLoading", false);
		component.set("v.showButtonX", false);
		//Apresentar Modal Message
		component.set("v.dialogModal", true);
        component.set("v.titleMessage", $A.get("$Label.c.Fin_send_title_success"));
        component.set("v.typeIcon", "utility:success");
        component.set("v.typeVariant", "success");
        component.set("v.textButton2", "Fechar");
        component.set("v.message", "Contestação criada com sucesso");
        component.set("v.afterMessage", "avisoContestacao");
        component.find("modalMessage").open();
	},
	denyContestation: function (component, event, helper) {
		component.set("v.isLoading", true);

		const caseId = component.get("v.recordId");
		const comment = component.get("v.contestationObservation");

		if (!component) {
			component.set("v.isLoading", false);
			return helper.showToast("Erro", "Insira um comentário para negar a contestação", "error");
		}

		let action = component.get("c.denyCase");
		action.setParams({
			caseId: caseId,
			caseComment: comment
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			component.set("v.isLoading", false);

			if (state === "SUCCESS") {
				helper.showToast("Sucesso", "Contestação negada", "success");

				component.set("v.showButtons", true);
				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({
					message: "CLOSEBILLDETAIL"
				});
				cmpEvent.fire();
			} else if (state === "ERROR") {
				var errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}
		});
		$A.enqueueAction(action);
	},
	//função para enviar a segunda via de boleto
	postInvoiceDuplicates: function (component, duplicate) {
		let action = component.get("c.postDuplicate");
		action.setParams(duplicate);
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();
			if (state === "SUCCESS") {
				if (data.success) {
					component.set("v.title", $A.get("$Label.c.Fin_send_title_success"));
					component.set("v.typeIcon", "utility:success");
					component.set("v.typeVariant", "success");
					component.set("v.message", $A.get("$Label.c.Fin_send_success"));
					component.set("v.showButtonX", false);
					component.find("modalMessage").open();
				} else {
					component.set("v.title", $A.get("$Label.c.Fin_send_title_error"));
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "error");
					component.set("v.message", data.postDuplicateResponse);
					component.find("modalMessage").open();
				}
			} else if (state === "ERROR") {
				component.set("v.title", "Alerta:");
				component.set("v.typeIcon", "utility:warning");
				component.set("v.typeVariant", "warning");
				component.set("v.message", data.message);
				component.find("modalMessage").open();
			}
		});
		$A.enqueueAction(action);
	},
	processContestation: function (component, data, bill) {
		if (!data || !data.items)
			data = {
				items: []
			};

		let allItems = component.get("v.invoiceItens");
		let arrGroups = {};
		console.log("100089 :: allItems", allItems);
		let contestation = new Map();
		data.items.forEach((element) => {
			if (element.detExtractItemId) contestation.set(element.detExtractItemId.toString(), element);
			if (element.extractItemId) contestation.set(element.extractItemId.toString(), element);
		});
		console.log("contestation", contestation);
		allItems.forEach((item) => {
			let detailItem = contestation.get(item.idItem.toString());
			// let detailItem = data.items.find((x) => {
			// 	// console.log('extractItemId: '+ x.extractItemId, 'idItem: '+item.idItem);

			// 	// return x.extractItemId == item.idItem.toString() || x.detExtractItemId.toString() == item.idItem.toString();
			// 	return x.extractItemId == item.idItem.toString();
			// });
			// for (let i = 0; i < data.items.length; i++) {
			// 	const element = array[i];
			// 	if(element.extractItemId == item.idItem.toString() || element.detExtractItemId.toString() == item.idItem.toString()){
			// 		detailItem = element;
			// 		break;
			// 	}

			// }
			// console.log('100089 :: detailItem', detailItem);
			const groupId = item.idParceiro.toString();
			// @note :Task 100089 :: caso nao  encontre o item sera tratado como nao contestavel
			//if (!detailItem) { return console.log('@@@ DETAIL ITEM NAO ENCONTRADO, ALGO NAO ESTA CERTO');}

			if (detailItem && !(detailItem.partnerId == "16" && (bill.status == "Pago" || bill.status == "Pago Cartão de Crédito"))) {
				item.allowContestation = detailItem.allowContestation;
				item.contestable = detailItem.allowContestation ? "Sim" : "Não";
				item.allowOnlyRecalculate = detailItem.allowOnlyRecalculate;
				item.contestationOptions = detailItem.contestationReasons;
				item.idPartnerStatement = detailItem.extractItemId;
				item.idDetExtractItem = detailItem.detExtractItemId;
				if (!arrGroups[groupId]) arrGroups[groupId] = detailItem.amountAgainstDeparture ? Math.abs(detailItem.amountAgainstDeparture) : 0;
			} else {
				item.allowOnlyRecalculate = true;
				item.allowContestation = false;
				item.contestable = "Não";
				item.contestationOptions = [];
				if (!arrGroups[groupId]) arrGroups[groupId] = 0;
			}

			// const groupId = item.idParceiro.toString();
			// if (!arrGroups[groupId]) arrGroups[groupId] = detailItem.amountAgainstDeparture ? Math.abs(detailItem.amountAgainstDeparture) : 0;
		});
		console.log("Valor de all items -> ", JSON.parse(JSON.stringify(allItems)));
		console.log("arrGroups => ", JSON.parse(JSON.stringify(arrGroups)));
		console.log("valor do elegibility", JSON.parse(JSON.stringify(data.items)));
		component.set("v.selectedBill.amountAgainstDeparture", arrGroups);
		component.set("v.invoiceItens", allItems);
		component.set("v.errorOnCall", false);

		let selectedBill = component.get("v.selectedBill");

		// @note 93624 Agrupamento de itens por produto dentro da tela "Fatura"
		let lstTelevisao = [];
		let lstInternet = [];
		let lstTelefone = [];
		var mapTelefone = new Map();
		var objTotalValue = {};
		objTotalValue["Televisao"] = 0;
		objTotalValue["Internet"] = 0;
		objTotalValue["Telefone"] = 0;
		objTotalValue["Movel"] = 0;
		objTotalValue["Eventuais"] = 0;
		objTotalValue["Outros"] = 0;

		let lstMovel = [];
		let lstItensEventuais = [];
		let lstOutros = [];
		for (let i = 0; i < allItems.length; i++) {
			const element = allItems[i];

			switch (element.groupIdParent) {
				case 12:
					lstTelevisao.push(element);
					objTotalValue["Televisao"] += element.realValue;
					break;
				case 18:
					lstInternet.push(element);
					objTotalValue["Internet"] += element.realValue;
					break;
				case 998:
					//lstTelefone.push(element);
					if (!mapTelefone.has(element.descricao)) {
						mapTelefone.set(element.descricao, []);
					}
					mapTelefone.get(element.descricao).push(element);
					objTotalValue["Telefone"] += element.realValue;
					break;
				case 999:
					lstMovel.push(element);
					objTotalValue["Movel"] += element.realValue;
					break;
				case 21:
					lstItensEventuais.push(element);
					objTotalValue["Eventuais"] += element.realValue;
					break;
				default:
					lstOutros.push(element);
					objTotalValue["Outros"] += element.realValue;
					break;
			}
		}
		Object.keys(objTotalValue).forEach((e, i) => {
			objTotalValue[e] = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(objTotalValue[e]);
			console.log("task :: variable", objTotalValue[e]);
		});

		console.log("var", JSON.parse(JSON.stringify(objTotalValue)));
		component.set("v.objetosTotais", objTotalValue);
		// @note Task 100089: organizar listas agrupando pela descricao do item
		// if(lstTelefone.length > 0){
		// for (let i = 0; i < lstTelefone.length; i++) {
		// 	if(!mapTelefone.has(element.descricao)){
		// 		mapTelefone.set(element.descricao, [])
		// 	}
		// 	mapTelefone.get(element.descricao).push(element);
		// }
		var listViewTelefone = [];
		mapTelefone.forEach(function (value, key) {
			var totalKey = 0;
			for (let i = 0; i < value.length; i++) {
				totalKey += value[i].realValue;
			}
			totalKey = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalKey);
			listViewTelefone.push({ value: value, key: key, totalValue: totalKey });
		}, mapTelefone);
		console.log("100089 :: mapTelefone", listViewTelefone);
		// }
		component.set("v.lstTelevisao", lstTelevisao);
		component.set("v.lstInternet", lstInternet);
		component.set("v.lstTelefone", listViewTelefone);
		component.set("v.lstMovel", lstMovel);
		component.set("v.lstItensEventuais", lstItensEventuais);
		component.set("v.lstOutros", lstOutros);

		this.setCheckedValues(component, selectedBill);
	},
	callSaveComp: function (component, event, helper, pdfData) {
		var evt = $A.get("e.force:navigateToComponent");
		evt.setParams({
			componentDef: "c:CEC_360_invoiceViewer",
			componentAttributes: { pdfData: pdfData }
		});
		evt.fire();
	},

	sortData: function (component, fieldName, sortDirection, data, event) {
		// for (let i = 0; i < groups.length; i++) {
		// const data = groups[i].debts;
		//function to return the value stored in the field
		console.log("sortData", fieldName);
		var key = function (a) {
			return a[fieldName];
		};
		var reverse = sortDirection == "asc" ? 1 : -1;

		// to handel number/currency type fields
		if (fieldName == "telefoneDestino" || fieldName == "horarioInicio") {
			data.sort(function (a, b) {
				var a = key(a) ? key(a) : "";
				var b = key(b) ? key(b) : "";
				return reverse * ((a > b) - (b > a));
			});
		}
		if (fieldName == "duracao") {
			data.sort(function (a, b) {
				return reverse * (a.duracao - b.duracao);
			});
		}

		if (fieldName == "valor") {
			data.sort(function (a, b) {
				return reverse * (a.realValue - b.realValue);
			});
		}

		//to handle dates
		if (fieldName == "dataLancamento" || fieldName == "periodo") {
			data.sort(function (a, b) {
				return reverse * (new Date(b.sortentryDate) - new Date(a.sortentryDate));
			});
		}
		if (fieldName == "descricao" || fieldName == "contestable" || fieldName == "localDestino" || fieldName == "pais") {
			// to handel text type fields
			data.sort(function (a, b) {
				var a = key(a) ? key(a).toLowerCase() : ""; //To handle null values , uppercase records during sorting
				var b = key(b) ? key(b).toLowerCase() : "";
				return reverse * ((a > b) - (b > a));
			});
		}
		// }
		event.getSource().set("v.data", data);
		//set sorted data to  attribute
		// component.set("v.wrapper.groupDebts", groups);
	}
});