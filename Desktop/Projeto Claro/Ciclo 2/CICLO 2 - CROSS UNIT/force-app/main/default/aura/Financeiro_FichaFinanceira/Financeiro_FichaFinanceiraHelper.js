({
	fetchDetails: function (component, helper) {
		this.fetchContractId(component);
	},

	fetchContractId: function (component) {
		const recordId = component.get("v.recordId");

		if (!recordId) component.set("v.hasError", true);

		component.set("v.isLoading", true);

		let action = component.get("c.getContractId");
		action.setParams({
			recordId
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (!data) {
					component.set("v.hasError", true);
					component.set("v.isLoading", false);
					//Apresentar Modal Message
					component.set("v.dialogModal", true);
					component.set("v.titleMessage", "Atenção");
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "warning");
					component.set("v.message", "Número do contrato não encontrado.");
					component.set("v.textButton2", "Fechar");
					component.find("modalMessage").open();
					//return this.showToast('Erro', 'Número do contrato não encontrado.', 'error');
				}

				component.set("v.contractId", data);
				this.fetchOperatorId(component, recordId);
			} else if (state === "ERROR") {
				const errors = response.getError();
				component.set("v.hasError", true);
				component.set("v.isLoading", false);

				if (errors[0] && errors[0].message) return this.showToast("Erro", errors[0].message, "error");
			}
		});
		$A.enqueueAction(action);
	},

	fetchInvoicesStatus: function (component) {
		const recordId = component.get("v.recordId");
		console.log("ate aqui chegou");
		//console.log('@@@@ entrou fetchInvoicesStatus ' + recordId);
		let action = component.get("c.getInvoicesStatus");
		action.setParams({ recordId });
		action.setCallback(this, function (response) {
			const state = response.getState();
			var data = response.getReturnValue();
			//console.log('@@@@ entrou fetchInvoicesStatus SETCALLBACK ' + state);
			if (state === "SUCCESS") {
				if (!data) {
					//console.log('@@@@ entrou fetchInvoicesStatus ERROR');
					component.set("v.hasError", true);
					component.set("v.isLoading", false);
					//Apresentar Modal Message
					component.set("v.dialogModal", true);
					component.set("v.titleMessage", "Atenção");
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "error");
					component.set("v.message", "Erro ao Obter Status das Faturas");
					component.set("v.textButton2", "Fechar");
					component.find("modalMessage").open();
					//return this.showToast('Erro', 'Número da operadora não encontrado.', 'error');
				}
				//console.log('@@@@ entrou SUCESSO ' + data);
				component.set("v.invoicesStatus", data);
			} else if (state === "ERROR") {
				//console.log('@@@@ entrou fetchInvoicesStatus ERROR');
				const errors = response.getError();
				component.set("v.hasError", true);

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	fetchBackOfficeN2: function (component) {
		//console.log('@@@@ entrou fetchBackOfficeN2 ');
		let action = component.get("c.isBackofficeN2");
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();
			//console.log('@@@@ entrou fetchBackOfficeN2 SETCALLBACK' + state);
			if (state === "SUCCESS") {
				if (data == null) {
					//console.log('@@@@ entroufetchBackOfficeN2 ERROR ' + data);
					component.set("v.hasError", true);
					component.set("v.isLoading", false);
					//Apresentar Modal Message
					component.set("v.dialogModal", true);
					component.set("v.titleMessage", "Atenção");
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "error");
					component.set("v.message", "Erro ao Obter nível do usuário");
					component.set("v.textButton2", "Fechar");
					component.find("modalMessage").open();
					//return this.showToast('Erro', 'Número da operadora não encontrado.', 'error');
				}
				//console.log('@@@@ entrou fetchBackOfficeN2 SUCESSO ' + data);
				component.set("v.isBackOfficeN2", data);
			} else if (state === "ERROR") {
				//console.log('@@@@ entrou fetchBackOfficeN2 ERROR');
				const errors = response.getError();
				component.set("v.hasError", true);

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	fetchOperatorId: function (component, recordId) {
		let action = component.get("c.getOperatorId");
		action.setParams({ recordId });
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (!data) {
					component.set("v.hasError", true);
					component.set("v.isLoading", false);
					//Apresentar Modal Message
					component.set("v.dialogModal", true);
					component.set("v.titleMessage", "Atenção");
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "warning");
					component.set("v.message", "Número da operadora não encontrado.");
					component.set("v.textButton2", "Fechar");
					component.find("modalMessage").open();
					//return this.showToast('Erro', 'Número da operadora não encontrado.', 'error');
				}

				component.set("v.operatorId", data);
				this.openDetails(component, recordId);
			} else if (state === "ERROR") {
				const errors = response.getError();
				component.set("v.hasError", true);

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	openDetails: function (component, recordId) {
		if (!recordId.startsWith("500")) return;

		let action = component.get("c.switchCaseType");
		action.setParams({ caseId: recordId });
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data == "FutureRelease") {
					const isBackOffice = component.get("v.isBackOfficeN2");

					if (isBackOffice) {
						component.find("tabset").set("v.selectedTabId", "lancamentosfuturos");

						window.setTimeout(
							$A.getCallback(function () {
								let lancComp = component.find("lancamentos-futuros");
								lancComp.openDetail(recordId);
							}),
							500
						);
					}
				} else {
					let faturasComp = component.find("faturas-em-aberto");
					if (!faturasComp) return;

					faturasComp.openDetailCase(recordId);
				}
			} else if (state === "ERROR") {
				const errors = response.getError();

				if (errors[0] && errors[0].message) this.showToast("Erro", errors[0].message, "error");
			}

			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	}
});