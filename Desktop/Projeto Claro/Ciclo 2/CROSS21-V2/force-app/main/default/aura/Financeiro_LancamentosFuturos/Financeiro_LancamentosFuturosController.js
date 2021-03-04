({
	doInit: function (component, event, helper) {
		helper.initialLoad(component);
	},

	handleSelectedRelease: function (component, event, helper) {
		const selectedRows = event.getParam("selectedRows");
		const caseStatus = component.get("v.invoicesStatus[0].Status");
		console.log("selectedRows ->", JSON.parse(JSON.stringify(selectedRows)));

		if (!selectedRows.length) {
			component.set("v.disabledView", true);
			return component.set("v.selectedReleasesRow", []);
		}

		if (caseStatus == "Closed") return component.set("v.disabledView", true);

		let hasInvalidItem = false;
		let vals = [];
		selectedRows.forEach((x) => {
			if (!x.hasElegibility) hasInvalidItem = true;
			vals.push(x.id);
		});

		component.set("v.selectedReleasesRow", selectedRows);
		component.set("v.selectedRows", vals);
		component.set("v.disabledView", hasInvalidItem);
	},

	handleRowAction: function (component, event, helper) {
		var action = event.getParam("action");
		var row = event.getParam("row");
		component.set("v.selectedRelease", row);
		switch (action.name) {
			case "view_modal":
				component.find("detailModal").open();
				component.set("v.isLoadingModal", true);
				component.set("v.isLoadingModal", false);
				break;
			default:
				break;
		}
	},

	closeModal: function (component, event, helper) {
		component.find("detailModal").close();
	},

	handlePeriodFilter: function (component, event, helper) {
		var period = component.get("v.period");
		helper.callFutureInvoices(component, period);
	},

	handleTypeFilter: function (component, event, helper) {
		console.warn("Não implementado");
	},

	handleStatusFilter: function (component, event, helper) {
		console.warn("Não implementado");
	},

	clickViewBill: function (component, event, helper) {
		const futureContestation = component.get("v.selectedReleasesRow");
		const departureGroups = component.get("v.amountGroupDeparture");

		const cmpEvent = component.getEvent("Financeiro_ComponentEvent");
		cmpEvent.setParams({
			message: "OPENFUTURECONTESTATION",
			payload: { futureContestation, departureGroups }
		});
		cmpEvent.fire();
	},

	onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		let allReleases = component.get("v.futureReleases");

		if (!allReleases) return;

		if (fieldName == "formattedBillDate") fieldName = "realBillDate";

		component.set("v.futureReleases", helper.sortData(fieldName, sortDirection, allReleases));
	},

	fetchData: function (component, event, helper) {
		if (component.get("v.contractId") && component.get("v.contractId")) helper.callFutureInvoices(component);
	},

	openDetails: function (component, event, helper) {
		const params = event.getParam("arguments");
		if (!params) return;

		component.set("v.recordId", params.recordId);
	}
});