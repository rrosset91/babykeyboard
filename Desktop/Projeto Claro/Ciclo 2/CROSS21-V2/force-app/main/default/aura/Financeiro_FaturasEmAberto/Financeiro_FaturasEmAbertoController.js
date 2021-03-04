({
	doInit: function (component, event, helper) {
		helper.initialLoad(component);
		helper.verifyDuplicatePermission(component);
	},

	openDetails: function (component, event, helper) {
		let params = event.getParam("arguments");
		if (!params) return;

		let recordId = params.recordId;

		if (!recordId) return;

		helper.checkCaseIsContestation(component, recordId);
	},
	//ALTERACAO CICLO 2 SPRINT 6 - US 111623 - ROGER ROSSET
	handleSelectedInvoice: function (component, event, helper) {
		const selectedRows = event.getParam("selectedRows");
		component.set("v.selectedRowsCount", selectedRows.length);
		let rowsCount = component.get("v.selectedRowsCount");
		const caseStatus = component.get("v.invoicesStatus[0].Status");
		//console.log('FaturasEmAberto CaseStatus: ' + caseStatus);
		let invoiceStatus;
		switch (rowsCount) {
			case 0:
				component.set("v.disabledGen", true);
				component.set("v.disabledView", true);
				component.set("v.disabledCompare", true);
				return component.set("v.selectedInvoices", []);
			case 1:
				component.set("v.disabledView", false);
				component.set("v.disabledCompare", true);
				component.set("v.selectedInvoices", selectedRows);
				invoiceStatus = component.get("v.selectedInvoices[0].status");
				break;
			case 2:
				let firstInvoiceDate = selectedRows[0].dataVencimento;
				let secondInvoiceDate = selectedRows[1].dataVencimento;
				let firstInvoiceRealDate = new Date(firstInvoiceDate.split("/")[2], firstInvoiceDate.split("/")[1], firstInvoiceDate.split("/")[0]);
				let secondInvoiceRealDate = new Date(secondInvoiceDate.split("/")[2], secondInvoiceDate.split("/")[1], secondInvoiceDate.split("/")[0]);
				let differenceBetweenInvoices = (secondInvoiceRealDate.getFullYear() * 12 + secondInvoiceRealDate.getMonth() - (firstInvoiceRealDate.getFullYear() * 12 + firstInvoiceRealDate.getMonth())) * -1;
				if (differenceBetweenInvoices <= 6) {
					component.set("v.disabledCompare", false);
					component.set("v.disabledGen", true);
					component.set("v.disabledView", true);
					component.set("v.invoicesToCompare", selectedRows);
					component.set("v.showCompareHelp", false);
					return component.set("v.selectedInvoices", []);
				} else {
					component.set("v.disabledView", true);
					component.set("v.disabledGen", true);
					component.set("v.showCompareHelp", true);
					component.set("v.compareHelp", "Não é possível selecionar faturas com mais de 6 meses de diferença");
				}
			default:
				break;
		}

		if (component.get("v.duplicatePermission") == true) {
			if (invoiceStatus == "Em Aberto" && caseStatus != "Closed") {
				component.set("v.disabledGen", false);
			} else {
				component.set("v.disabledGen", true);
			}
		}
	},

	clickViewBill: function (component, event, helper) {
		component.set("v.isLoading", true);
		const selectedInvoice = component.get("v.selectedInvoices");
		console.log("selectedInvoice", JSON.parse(JSON.stringify(selectedInvoice)));
		if (!selectedInvoice) return component.set("v.isLoading", false);

		helper.findInvoiceDetails(component, selectedInvoice[0], (success, error) => {
			if (error) return;

			const cmpEvent = component.getEvent("Financeiro_ComponentEvent");

			cmpEvent.setParams({
				message: "OPENBILLDETAIL",
				payload: success
			});
			component.set("v.isLoading", false);
			cmpEvent.fire();
		});
	},

	//ALTERACAO CICLO 2 SPRINT 6 - US 111623 - ROGER ROSSET
	compareBills: function (component, event, helper) {
		component.set("v.isLoading", true);
		let details = {};
		let invoicesDataToCompare = [];
		const invoicesToCompare = component.get("v.invoicesToCompare");
		if (!invoicesToCompare) return component.set("v.isLoading", false);
		helper.findInvoiceDetails(component, invoicesToCompare[0], (successFirst, errorFirst) => {
			if (errorFirst) {
				component.set("v.isLoading", false);
				console.log("Erro ao consultar os detalhes da primeira fatura");
				return;
			}

			if (successFirst) {
				let firstInvoice = {};
				firstInvoice.invoiceName = "Invoice 1";
				firstInvoice.invoice = successFirst;
				invoicesDataToCompare.push(firstInvoice);
				helper.findInvoiceDetails(component, invoicesToCompare[1], (successSecond, errorSecond) => {
					if (errorSecond) {
						component.set("v.isLoading", false);
						console.log("Erro ao consultar os detalhes da primeira fatura");
						return;
					}
					if (successSecond) {
						let secondInvoice = {};
						secondInvoice.invoiceName = "Invoice 2";
						secondInvoice.invoice = successSecond;
						invoicesDataToCompare.push(secondInvoice);
						const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
						details.invoicesDataToCompare = invoicesDataToCompare;
						details.operatorCode = component.get("v.operatorId");
						details.contractNumber = component.get("v.contractId");
						component.set("v.detailsToCompare", details);
						cmpEvent.setParams({
							message: "OPENCOMPARESCREEN",
							payload: details
						});
						component.set("v.isLoading", false);
						cmpEvent.fire();
					}
				});
			}
		});
	},

	onClickFiltrarPeriodo: function (component, event, helper) {
		if (component.get("v.contractId") && component.get("v.operatorId")) {
			helper.findInvoicePeriod(component);

			component.set("v.ShowInvoicesPeriod", true);
		}
	},

	handlePeriodFilter: function (component, event, helper) {
		if (component.get("v.contractId") && component.get("v.operatorId")) {
			helper.findInvoicePeriodSelected(component);

			component.set("v.ShowInvoicesPeriod", true);
		}
	},

	handleSelectedSendMethod: function (component, event) {
		var SelectedSendMethod = event.getParam("value");
		switch (SelectedSendMethod) {
			//case "E":
			case "3":
				component.set("v.selectedEmail", true);
				component.set("v.selectedSMS", false);
				component.set("v.selectedCorreio", false);
				//component.set("v.selectedSendMethod", "E");
				component.set("v.selectedSendMethod", "3");
				break;
			//case "S":
			case "5":
				component.set("v.selectedSMS", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedCorreio", false);
				//component.set("v.selectedSendMethod", "S");
				component.set("v.selectedSendMethod", "5");
				break;
			//case "C":
			case "2":
				component.set("v.selectedCorreio", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedSMS", false);
				//component.set("v.selectedSendMethod", "C");
				component.set("v.selectedSendMethod", "2");
				break;
			default:
				SelectedSendMethod = undefined;
				break;
		}
		if (component.get("v.selectedSendReason") === undefined || SelectedSendMethod === undefined) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
		return SelectedSendMethod;
	},

	handleSelectedSendReason: function (component, event) {
		var SelectedSendReason = event.getParam("value");
		if (component.get("v.selectedSendMethod") === undefined || SelectedSendReason === undefined) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
		return SelectedSendReason;
	},

	handleRowAction: function (component, event, helper) {
		var action = event.getParam("action");
		var row = event.getParam("row");

		switch (action.name) {
			case "view_modal":
				component.find("detailModal").open();
				component.set("v.isLoadingModal", true);

				helper.findInvoiceDetails(component, row, (success, error) => {
					if (error) component.find("detailModal").close();

					component.set("v.isLoadingModal", false);
				});
				break;
			default:
				break;
		}
	},

	sendDuplicate: function (component, event, helper) {
		component.set("v.disabledSend", false);
		const selectedInvoice = component.get("v.selectedInvoices");
		console.log("selected invoice -> ", JSON.parse(JSON.stringify(selectedInvoice[0])));

		helper.postInvoiceDuplicates(component, selectedInvoice[0], helper, (sucess, error) => {
			if (error) {
				alert("ERRO ao tentar enviar Segunda Via");
				component.find("modalMessage").close();
				component.set("v.dialogModal", false);
			}
		});
	},

	closeModalSegundaVia: function (component) {
		component.find("modalMessage").close();
		component.set("v.dialogModal", false);
	},

	voltarFichaFinanceira: function (component) {
		component.find("modalMessage").close();
		component.set("v.dialogModal", false);
		component.find("duplicateModal").close();
	},

	clickGenDuplicate: function (component, event, helper) {
		let selectedInvoice = component.get("v.selectedInvoices");

		component.find("duplicateModal").open();
		component.set("v.isLoadingModal", true);
		component.set("v.toastShowed", false);
		helper.getInvoiceDuplicates(component, selectedInvoice[0], (success, error) => {
			if (error) component.find("duplicateModal").close();
			component.set("v.isLoadingModal", false);
			return;
			if ((component.get("v.sendReasonOptions").length < 1 || component.get("v.sendMethodOptions").length < 1) && component.get("v.toastShowed") == false) {
				component.find("duplicateModal").close();
				let message = $A.get("$Label.c.Fin_cant_send");
				helper.showToast(component, message);
				component.set("v.toastShowed", true);
			}
			if (component.get("v.duplicate.userHasAccess") != "SIM" && component.get("v.toastShowed") == false) {
				component.find("duplicateModal").close();
				let message = $A.get("$Label.c.Fin_userHas_access");
				helper.showToast(component, message);
				component.set("v.toastShowed", true);
			}
			if (component.get("v.sendMethodOptions").length < 1 && component.get("v.toastShowed") == false) {
				component.find("duplicateModal").close();
				let message = $A.get("$Label.c.Fin_send_NoMethods");
				helper.showToast(component, message);
				component.set("v.toastShowed", true);
			}
			if (component.get("v.duplicate.billAllowsSending") != "SIM" && component.get("v.toastShowed") == false) {
				component.find("duplicateModal").close();
				let message = $A.get("$Label.c.Fin_cant_send");
				helper.showToast(component, message);
				component.set("v.toastShowed", true);
			}
		});
	},
	closeModal: function (component, event, helper) {
		component.find("detailModal").close();
	},

	cancelModal: function (component, event, helper) {
		component.find("duplicateModal").close();
	},

	onCloseModal: function (component, event, helper) {
		component.set("v.selectedSendReason", null);
		component.set("v.selectedSendMethod", null);
		component.set("v.selectedEmail", false);
		component.set("v.selectedSMS", false);
		component.set("v.selectedCorreio", false);
		component.set("v.disabledSend", true);
	},
	onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		let allInvoices = component.get("v.invoices");

		if (!allInvoices) return;

		if (fieldName == "valor") fieldName = "realValue";

		if (fieldName == "dataVencimento") fieldName = "realDate";

		component.set("v.invoices", helper.sortData(fieldName, sortDirection, allInvoices));
	},

	fetchData: function (component, event, helper) {
		if (component.get("v.contractId") && component.get("v.contractId")) {
			helper.callOpenInvoices(component);
		}
	}
});