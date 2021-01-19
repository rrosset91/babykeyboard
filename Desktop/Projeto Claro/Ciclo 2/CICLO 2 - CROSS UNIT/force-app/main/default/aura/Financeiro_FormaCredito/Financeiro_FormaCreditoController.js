({
	doInit: function (component, event, helper) {
		helper.onInit(component, event, helper);
		const contestedItems = component.get("v.invoiceItens");
		const allItems = component.get("v.allItems");
		const bill = component.get("v.bill");
		let optionsRefund = [
			{ label: "Crédito na Próxima Fatura", value: "false" },
			{ label: "Reembolso", value: "true" }
		];
		if (contestedItems.length == 0) return;

		let totalOriginalPrice = 0;
		let fixedTotalPrice = 0;
		let allKeysContested = [];

		allItems.forEach((x) => {
			let value = x.realValue;

			for (let index = 0; index < contestedItems.length; index++) {
				const element = contestedItems[index];
				if (element.idItem == x.idItem) {
					allKeysContested.push(element.idItem);
					value = element.valorCorrigido;
				}
				if (element.idParceiro == 2) {
					if (bill.status == "Em Aberto" || bill.status == "Em Aberto por Rejeição de Cartão de Crédito" || bill.status == "Em Aberto - Sub Júdice") {
						component.set("v.showCreditoEmAberto", false);
					} else if ((bill.status == "Pago" || bill.status == "Pago Cartão de Crédito") && optionsRefund.length > 1) {
						optionsRefund = [{ label: "Reembolso", value: "true" }];
					}
				}
				if (element.idParceiro == 16) {
					if (bill.status == "Em Aberto" || bill.status == "Em Aberto por Rejeição de Cartão de Crédito" || bill.status == "Em Aberto - Sub Júdice") {
						component.set("v.showCreditoEmAberto", false);
					}
				}
				if (element.idParceiro == 2 || element.idParceiro == 16) component.set("v.showSecond", false);
			}

			fixedTotalPrice = fixedTotalPrice + value;
			totalOriginalPrice = totalOriginalPrice + x.realValue;
		});

		const correctedItems = allItems.filter((x) => {
			return !allKeysContested.includes(x.idItem);
		});

		component.set("v.newItems", JSON.parse(JSON.stringify(correctedItems)));
		totalOriginalPrice = totalOriginalPrice.toFixed(2).toLocaleString("pt-BR");
		fixedTotalPrice = fixedTotalPrice.toFixed(2).toLocaleString("pt-BR");

		component.set("v.originalTotalPrice", totalOriginalPrice);
		component.set("v.fixedTotalPrice", fixedTotalPrice);
		component.set("v.optionsRefund", optionsRefund);
	},

	onChangeRefund: function (component, event, helper) {
		var selectedOption = component.get("v.valueTipoReembolso");

		if (selectedOption == "Conta Corrente") component.set("v.refundcc", true);
		return;
	},

	onClickCreditOptions: function (component, event, helper) {
		const returnType = component.get("v.openRefundEmAberto");
		component.set("v.selectedReturnMethod", returnType);
		component.set("v.selectedRecalculationMethod", "");

		if (returnType == "recalculation") {
			component.find("duplicateModal").open();
			component.set("v.isLoadingModal", true);
			component.set("v.toastShowed", false);
			helper.getInvoiceDuplicates(component, (success, error) => {
				if (error) component.find("duplicateModal").close();
				component.set("v.isLoadingModal", false);
				return;
				component.set("v.isLoadingModal", false);
				if (component.get("v.duplicate.userHasAccess") != "SIM") {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_userHas_access");
					helper.showToast("Error", message, "error");
					component.set("v.toastShowed", true);
				}
				if (component.get("v.sendMethodOptions").length < 1) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_send_NoMethods");
					helper.showToast("Error", message, "error");
					component.set("v.toastShowed", true);
				}
				if (component.get("v.sendReasonOptions").length < 1) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_send_NoReasons");
					helper.showToast("Error", message, "error");
					component.set("v.toastShowed", true);
				}
				if (component.get("v.duplicate.billAllowsSending") != "SIM") {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_cant_send");
					helper.showToast("Error", message, "error");
					component.set("v.toastShowed", true);
				}
			});
		} else {
			const creditOptions = ["recalculation", "credit", "refund"];
			creditOptions.forEach((option) => {
				const cmp = component.find(option);
				if (!cmp) return;

				if (option == returnType) {
					$A.util.addClass(cmp, "selected");
				} else {
					$A.util.removeClass(cmp, "selected");
				}
			});

			const returnAction = component.get("v.onSelectReturnMethod");
			if (returnAction) $A.enqueueAction(returnAction);
		}
	},

	onClickMethod: function (component, event, helper) {
		const returnMethods = ["SMS", "E-mail", "WhatsApp", "Correio"];
		const recalculationReturnMethod = event.getSource().get("v.name");

		component.set("v.selectedRecalculationMethod", recalculationReturnMethod);

		returnMethods.forEach((option) => {
			const cmp = component.find(option);
			if (!cmp) return;

			if (option == recalculationReturnMethod) {
				$A.util.addClass(cmp, "selected");
			} else {
				$A.util.removeClass(cmp, "selected");
			}
		});

		const returnAction = component.get("v.onSelectReturnMethod");
		if (returnAction) $A.enqueueAction(returnAction);
	},

	onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		let allInvoices = component.get("v.invoiceItens");

		if (!allInvoices) return;

		if (fieldName == "valor") fieldName = "realValue";

		component.set("v.invoiceItens", helper.sortData(fieldName, sortDirection, allInvoices));
	},

	onChangeContestar: function (component, event, helper) {
		let opcaoReembolso = component.get("v.openOption");

		if (opcaoReembolso == "true") {
			let bill = component.get("v.bill");

			if (bill.contestation && bill.contestation.reembolso) {
				let contestation = JSON.parse(bill.contestation.reembolso);
				console.log("contestation ->", JSON.parse(JSON.stringify(contestation)));

				const isPaymentAccount = contestation.paymentForm.refundType == "CC";
				component.set("v.valueTipoReembolso", isPaymentAccount ? "Conta Corrente" : "Ordem de Pagamento");
				component.set("v.refundcc", isPaymentAccount);
			}

			component.set("v.openModal", true);
			component.find("tipoReembolso").open();
		}
	},

	openReembolso: function (component, event, helper) {
		component.set("v.openReembolso", true);
		component.set("v.initialComponents", false);
		component.set("v.showSecond", false);
		component.find("tipoReembolso").close();
		component.find("v.openModal", false);
	},

	/******* Funçõs da modal de segunda via da fatura ********/
	handleSelectedSendMethod: function (component, event) {
		var selectedSendMethod = event.getParam("value");
		switch (selectedSendMethod) {
			case "3":
				component.set("v.selectedEmail", true);
				component.set("v.selectedSMS", false);
				component.set("v.selectedCorreio", false);
				component.set("v.selectedSendMethod", "3");
				break;
			case "5":
				component.set("v.selectedSMS", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedCorreio", false);
				component.set("v.selectedSendMethod", "5");
				break;
			case "2":
				component.set("v.selectedCorreio", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedSMS", false);
				component.set("v.selectedSendMethod", "2");
				break;
			default:
				selectedSendMethod = undefined;
				break;
		}
		if (component.get("v.selectedSendReason") === undefined || selectedSendMethod === undefined) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
	},

	handleSelectedSendReason: function (component, event) {
		var selectedSendReason = event.getParam("value");
		if (component.get("v.selectedSendMethod") === undefined || selectedSendReason === undefined) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
	},

	closeRefundModal: function (component, event, helper) {
		component.find("tipoReembolso").close();
		component.find("v.openModal", false);
	},

	onCloseRefundModal: function (component, event, helper) {
		component.set("v.openOption", []);
	},

	onCloseModal: function (component, event, helper) {
		component.set("v.selectedSendReason", null);
		component.set("v.selectedSendMethod", null);
		component.set("v.selectedEmail", false);
		component.set("v.selectedSMS", false);
		component.set("v.selectedCorreio", false);
		component.set("v.disabledSend", true);
	},

	cancelModal: function (component, event, helper) {
		component.find("duplicateModal").close();
	},

	chooseDuplicate: function (component, event, helper) {
		var sendMethodOption = component.get("v.sendMethodOptions");
		var sendMethod;
		for (var i = 0; i < sendMethodOption.length; i++) {
			if (sendMethodOption[i].value == component.get("v.selectedSendMethod")) {
				sendMethod = sendMethodOption[i].label;
			}
		}
		let duplicate = {
			operatorCode: component.get("v.operatorId"),
			contractNumber: component.get("v.duplicate.contractNumber"),
			userName: "ALTERAR PROXIMA SPRINT",
			billId: component.get("v.bill.idFatura"),
			name: component.get("v.duplicate.name"),
			phoneNumber: component.get("v.duplicate.phoneNumber"),
			email: component.get("v.duplicate.email"),
			sendMethod: sendMethod,
			billExtend: component.get("v.duplicate.billExtend"),
			descriptionReason: component.get("v.selectedSendReason")
		};

		component.set("v.choosedDuplicate", duplicate);

		//habilita no componente detalhe da fatura o botão de continuar quando a segunda via for escolhida
		component.set("v.selectedRecalculationMethod", "choosed");
		const returnAction = component.get("v.onSelectReturnMethod");
		if (returnAction) $A.enqueueAction(returnAction);
		component.find("duplicateModal").close();
	}

	/*openDuplicateModal: function (component, event, helper) {
		component.find("duplicateModal").open();
		component.set("v.isLoadingModal", true);

		helper.getInvoiceDuplicates(
			component,
			(success, error) => {
				if (error) component.find("duplicateModal").close();
				component.set("v.isLoadingModal", false);
				if (component.get("v.duplicate.userHasAccess") != "SIM") {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_userHas_access");
					helper.showToast('Error', message, 'error');
				}
				if (component.get("v.sendMethodOptions").length < 1) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_send_NoMethods");
					helper.showToast('Error', message, 'error');
				}
				if (component.get("v.sendReasonOptions").length < 1) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_send_NoReasons");
					helper.showToast('Error', message, 'error');
				}
				if (component.get("v.duplicate.billAllowsSending") != "SIM") {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_cant_send");
					helper.showToast('Error', message, 'error');
				}
			}
		);
	},*/
});