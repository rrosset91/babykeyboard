({
	doInit: function (component, event, helper) {
		const pageRef = component.get("v.pageReference");

		if (!pageRef || !pageRef.state || !pageRef.state.c__recordId) component.set("v.hasError");

		component.set("v.recordId", pageRef.state.c__recordId);

		helper.fetchBackOfficeN2(component);
		helper.fetchInvoicesStatus(component);
	},

	//Verifica se a fatura selecionada é a mesma do caso
	verifyInvoiceCase: function (component, event, helper) {
		const invoiceCase = component.get("v.invoicesStatus[0].Invoice__c");
		const invoiceSelected = component.get("v.detailBill.idFatura");
		console.log("invoiceCase: " + invoiceCase + " invoiceSelected: " + invoiceSelected);
		if (invoiceCase != null) {
			if (invoiceCase == invoiceSelected) {
				component.set("v.isInvoiceCase", "true");
				console.log("isInvoiceCase: TRUE");
			} else {
				component.set("v.isInvoiceCase", "false");
				console.log("isInvoiceCase: FALSE");
			}
		} else {
			component.set("v.isInvoiceCase", "empty");
			console.log("isInvoiceCase: EMPTY");
		}
	},

	handleCpmEvent: function (component, event, helper) {
		const evMessage = event.getParam("message");
		const evPayload = event.getParam("payload");
		const nextTabId = evPayload && evPayload.tabId ? evPayload.tabId : "faturas";

		let parsedPayload;
		let stringPayload = JSON.stringify(evPayload);
		if (evPayload) parsedPayload = JSON.parse(JSON.stringify(evPayload));
		console.log("PAYLOAD--->", parsedPayload);
		switch (evMessage) {
			case "OPENBILLDETAIL":
				component.set("v.detailBill", parsedPayload);
				$A.enqueueAction(component.get("c.verifyInvoiceCase"));
				component.set("v.showDetail", true);
				break;
			case "OPENFUTURECONTESTATION":
				component.set("v.evPayload", parsedPayload);
				component.set("v.showFutureItem", true);
				break;
			case "OPENCOMPARESCREEN":
				component.set("v.comparisonData", parsedPayload);
				component.set("v.showCompareScreen", true);
				break;
			case "CLOSEBILLDETAIL":
				component.set("v.showDetail", false);
				component.find("tabset").set("v.selectedTabId", nextTabId);
				break;
			case "CLOSEFUTURECONTESTATION":
				component.set("v.showFutureItem", false);
				component.find("tabset").set("v.selectedTabId", nextTabId);
				break;
			default:
				break;
		}
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
		}
		component.find("modalMessage").close();
		component.set("v.dialogModal", false);
	},

	handleCloseComparison: function (component, event) {
		let defaultData = {};
		component.set("v.comparisonData", defaultData);
		component.set("v.showCompareScreen", false);
	}
});