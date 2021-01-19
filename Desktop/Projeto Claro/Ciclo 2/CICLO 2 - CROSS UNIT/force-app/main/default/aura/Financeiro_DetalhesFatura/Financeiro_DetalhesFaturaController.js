({
	doInit: function (component, event, helper) {
		helper.initialLoad(component, helper);
		component.set("v.currentStep", 0);
		component.set("v.previousLabel", "Voltar");
		$A.enqueueAction(component.get("c.dateTitle"));
		component.set("v.nextLabel", $A.get("$Label.c.Fin_DetalhesFatura_Contestar"));
		component.set("v.tableTitle", $A.get("$Label.c.Fin_DetalhesFatura_Table_Titulo"));
	},

	//verifyStatusCase para correção do bug
	verifyStatusCase: function (component, event, helper) {
		const caseStatus = component.get("v.invoicesStatus[0].Status");
		//console.log('DetalhesFatura CaseStatus: ' + caseStatus);
		if (caseStatus == "Closed") {
			component.set("v.disabledContest", true);
		}
	},

	dateTitle: function (component, event, helper) {
		//Titulo de acordo com a data
		let date = component.get("v.selectedBill.dataVencimento");
		let mes = date.substring(3, 5);
		let ano = date.substring(6, 10);
		switch (mes) {
			case "01":
				mes = "Janeiro";
				break;
			case "02":
				mes = "Fevereiro";
				break;
			case "03":
				mes = "Março";
				break;
			case "04":
				mes = "Abril";
				break;
			case "05":
				mes = "Maio";
				break;
			case "06":
				mes = "Junho";
				break;
			case "07":
				mes = "Julho";
				break;
			case "08":
				mes = "Agosto";
				break;
			case "09":
				mes = "Setembro";
				break;
			case "10":
				mes = "Outubro";
				break;
			case "11":
				mes = "Novembro";
				break;
			case "12":
				mes = "Dezembro";
				break;
		}
		component.set("v.title", $A.get("$Label.c.Fin_DetalhesFatura_Enunciado") + " " + mes + " " + ano);
	},

	handleSelectedItem: function (component, event, helper) {
		// debugger;
		const selectedRows = event.getParam("selectedRows");
		const bill = component.get("v.selectedBill");
		const status = component.get("v.selectedBill").status;
		let tableItems = component.get("v.tableItems") || {};
		let evName = event.getSource().getLocalId() + event.getSource().getGlobalId();

		if (
			status != "Pago" &&
			status != "Em Aberto" &&
			status != "Pago Cartão de Crédito" &&
			status != "Em Aberto por Rejeição de Cartão de Crédito" &&
			status != "Em Aberto - Sub Júdice"
		)
			return component.set("v.disabledContest", true);

		if (!bill.canDispute) return component.set("v.disabledContest", true);

		let arrId = [];
		selectedRows.forEach((item) => {
			arrId.push(item);
		});
		tableItems[evName] = arrId;

		console.log("var", JSON.parse(JSON.stringify(tableItems)));

		let arrProps = Object.keys(tableItems);
		let allSelected = [];
		let allSelectedObjects = [];

		arrProps.forEach((y) => {
			const element = tableItems[y];

			element.forEach((x) => {
				allSelected.push(x.idItem);
				allSelectedObjects.push(x);
			});
		});

		let notAllowedItems = allSelectedObjects.filter((x) => !x.allowContestation);

		if (allSelectedObjects.length == 0) {
			component.set("v.disabledContest", true);
			component.set("v.selectedInvoices", []);
			return component.set("v.selectedItens", []);
		}

		component.set("v.disabledContest", notAllowedItems.length > 0);
		component.set("v.tableItems", tableItems);
		component.set("v.selectedRows", allSelected);
		component.set("v.selectedInvoices", allSelectedObjects);
		component.set("v.selectedItens", allSelectedObjects);
	},

	handleRowAction: function (component, event, helper) {
		var action = event.getParam("action");
		var row = event.getParam("row");

		switch (action.name) {
			case "viewDetailModal":
				component.set("v.detailItem", row);
				component.find("itemDetail").open();
				component.set("v.isLoadingItemDetail", true);
				break;
		}

		component.set("v.isLoadingItemDetail", false);
	},

	closeModal: function (component, event, helper) {
		component.find("itemDetail").close();
	},

	clickBack: function (component, event, helper) {
		let currentStep = component.get("v.currentStep");
		currentStep--;

		switch (currentStep) {
			case 0:
				component.set("v.showBtnPDF", true);
				$A.enqueueAction(component.get("c.dateTitle"));
				component.set("v.nextLabel", $A.get("$Label.c.Fin_DetalhesFatura_Contestar"));
				component.set("v.disabledContest", false);
				break;
			case 1:
				component.set("v.title", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Enunciado"));
				component.set("v.tableTitle", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_Titulo"));
				component.set("v.nextLabel", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Contestacao"));
				//helper.
				break;
			case 2:
				component.set("v.title", $A.get("$Label.c.Fin_FormaCredito_Enunciado"));
				component.set("v.tableTitle", $A.get("$Label.c.Fin_FormaCredito_Table_Titulo"));
				component.set("v.nextLabel", $A.get("$Label.c.Fin_FormaCredito_Botao_Contestar"));
				break;
			case -1:
				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({
					message: "CLOSEBILLDETAIL"
				});
				cmpEvent.fire();
				break;
			default:
				break;
		}

		component.set("v.currentStep", currentStep);
		helper.applyComponentAnimation(component, currentStep);
	},

	clickNext: function (component, event, helper) {
		let currentStep = component.get("v.currentStep");
		currentStep++;

		component.set("v.isLoading", true);

		switch (currentStep) {
			case 1:
				helper.performSelectedItemsFunction(component, helper, (success, err) => {
					component.set("v.isLoading", false);
					const isBackOfficeN2 = component.get("v.isBackOfficeN2");
					const isInvoiceCase = component.get("v.isInvoiceCase");
					console.log("isBackOfficeN2: " + isBackOfficeN2 + " isInvoiceCase: " + isInvoiceCase);
					if (err) {
						return component.set("v.disabledContest", true);
					}
					$A.enqueueAction(component.get("c.verifyStatusCase"));
					component.set("v.showBtnPDF", false);
					component.set("v.title", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Enunciado"));
					component.set("v.tableTitle", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Table_Titulo"));
					component.set("v.nextLabel", $A.get("$Label.c.Fin_ItensSelecionadosContestar_Contestacao"));
					helper.performPagination(component, currentStep);
					if (isInvoiceCase != "empty") {
						if (isBackOfficeN2 == "true" && isInvoiceCase == "false") {
							return component.set("v.disabledContest", true);
						}
					}
				});
				break;
			case 2:
				helper.performContestationEfetivation(component, helper, (success, err) => {
					component.set("v.isLoading", false);
					component.set("v.title", $A.get("$Label.c.Fin_FormaCredito_Enunciado"));
					component.set("v.tableTitle", $A.get("$Label.c.Fin_FormaCredito_Table_Titulo"));
					component.set("v.nextLabel", $A.get("$Label.c.Fin_FormaCredito_Botao_Contestar"));
					const bill = component.get("v.selectedBill");
					const allItems = component.get("v.invoiceItens");
					component.set("v.showButtons", true);
					if (err) {
						if (err.type == "no_items") {
							return component.set("v.disabledContest", true);
						}

						return;
					}

					if (bill.status == "Pago" || bill.status == "Pago Cartão de Crédito") {
						//helper.showToast('Sucesso', 'Contestação criada com sucesso', 'success');
						component.set("v.selectedReturnMethod", "");
						component.set("v.selectedRecalculationMethod", "");
						component.set("v.nextLabel", $A.get("$Label.c.Fin_FormaCredito_Botao_Contestar"));
						component.set("v.showFirst", false);
					} else {
						const firstItem = allItems[0];
						component.set("v.disabledCredit", firstItem.allowOnlyRecalculate);
						component.set("v.selectedReturnMethod", "");
						component.set("v.selectedRecalculationMethod", "");
						component.set("v.disabledContest", true);
						component.set("v.showFirst", true);
					}

					helper.performPagination(component, currentStep);
				});
				break;
			case 3:
				helper.performContestationReturn(component, helper, (success, err) => {
					component.set("v.isLoading", false);
					component.set("v.showButtons", true);
					if (err) {
						if (err.type == "case_closed_apiError") {
							const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
							cmpEvent.setParams({
								message: "CLOSEBILLDETAIL"
							});
							cmpEvent.fire();
						} else {
							return;
						}
					}
					component.set("v.title", "Detalhe da Fatura");
					component.set("v.disabledContest", true);
					helper.performPagination(component, currentStep);
				});
				break;
			case 4:
				helper.performContestationLastStep(component, helper, (success, err) => {
					component.set("v.showButtons", true);
					if (err) return;
					component.set("v.disabledContest", false);
					//Apresentar Modal Message
					component.set("v.dialogModal", true);
					component.set("v.titleMessage", $A.get("$Label.c.Fin_FormaCredito_Title_Success_Eviada_BackOffice"));
					component.set("v.typeIcon", "utility:success");
					component.set("v.typeVariant", "success");
					component.set("v.message", $A.get("$Label.c.Fin_FormaCredito_Mensagem_Eviada_BackOffice"));
					component.find("modalMessage").open();
					component.set("v.afterMessage", "clickNextCase4");
					//helper.showToast('Sucesso', 'Contestação enviada para o backoffice.', 'success');
					//const cmpEvent = component.getEvent('Financeiro_ComponentEvent');
					//cmpEvent.setParams({
					//message: 'CLOSEBILLDETAIL'
					//});
					//cmpEvent.fire();
				});
				break;
			default:
				component.set("v.isLoading", false);
				break;
		}
	},

	onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		// let allInvoices = component.get('v.invoiceItens');
		let data = event.getSource().get("v.data");
		// console.log('data', data);

		//if (!allInvoices) return;

		//if (fieldName == 'valor') fieldName = 'realValue';

		// component.set('v.invoiceItens', helper.sortData(fieldName, sortDirection, allInvoices));
		// component.set('v.invoiceItens', helper.sortData(fieldName, sortDirection, data));
		// event.getSource().set('v.data', helper.sortData(fieldName, sortDirection, data));

		helper.sortData(component, fieldName, sortDirection, data, event);
	},

	onSelectReturnMethod: function (component, event, helper) {
		const selectedMethod = component.get("v.selectedReturnMethod");
		const selectedRecalculationMethod = component.get("v.selectedRecalculationMethod");

		if (selectedMethod == "credit") {
			component.set("v.disabledContest", false);
		} else if (selectedMethod == "recalculation" && !selectedRecalculationMethod) {
			component.set("v.disabledContest", true);
		} else if (selectedMethod == "recalculation" && selectedRecalculationMethod) {
			component.set("v.disabledContest", false);
		} else if (selectedMethod == "refund") {
			//component.set('v.showButtons', true);
		}
	},

	denyContestation: function (component, event, helper) {
		helper.denyContestation(component, event, helper);
	},

	clickPDF: function (component, event, helper) {
		// @note Bug 100632 : formatacao de variaveis para envio
		console.log("DIOGO >> @@ >>");
		component.set("v.showSpinner", true);
		let action = component.get("c.getPdf");
		let contract = component.get("v.contractId");
		let operatorCode = component.get("v.operatorId");
		let invoiceId = component.get("v.selectedBill.idFatura");
		//var sendInvoice  = helper.formatValuePdf(component, invoiceId, 15, '0')
		var sendContract = helper.formatValuePdf(component, operatorCode, 3, "0") + "/" + helper.formatValuePdf(component, contract, 9, "0");

		action.setParams({
			contract: sendContract,
			invoiceId: invoiceId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			var toastEvent;
			component.set("v.showSpinner", false);
			if (state == "SUCCESS") {
				var pdfData = response.getReturnValue();
				if (pdfData != null) {
					helper.callSaveComp(component, event, helper, pdfData);
				} else {
					toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({ title: "Erro!", type: "Error", message: "Documento inexistente." });
					toastEvent.fire();
				}
			} else {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({ title: "Erro!", type: "Error", message: "Documento inexistente." });
				toastEvent.fire();
			}
		});
		$A.enqueueAction(action);
	},

	closeModalMessage: function (component) {
		component.find("modalMessage").close();
		component.set("v.dialogModal", false);
	},

	//Função utilizada para dar seguimento no fluxo após apresentação do modalMessage
	afterMessage: function (component) {
		var afterMessage = component.get("v.afterMessage");
		switch (afterMessage) {
			case "clickNextCase4":
				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
				cmpEvent.setParams({ message: "CLOSEBILLDETAIL" });
				cmpEvent.fire();
				break;

			// case 'dontNeedApproval':
			// 	helper.dontNeedApproval(component, helper);
		}
		component.find("modalMessage").close();
		component.set("v.dialogModal", false);
	}
});