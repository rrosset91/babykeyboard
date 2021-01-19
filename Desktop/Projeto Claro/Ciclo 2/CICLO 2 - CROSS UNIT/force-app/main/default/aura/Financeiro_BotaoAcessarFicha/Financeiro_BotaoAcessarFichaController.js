/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 29-10-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
({
	doInit: function (component, event, helper) {
		let action = component.get("c.getRecordProps");
		action.setParams({
			recordId: component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.isMobileContract || data.isViewOnly) {
					component.set("v.isMobile", true);
				} else {
					component.set("v.isResidential", true);
				}
			} else if (state === "ERROR") {
				const errors = response.getError();
				if (errors[0] && errors[0].message) return helper.showToast("Erro", errors[0].message, "error");
			}
		});
		$A.enqueueAction(action);
	},

	clickViewBill: function (component, event, helper) {
		const workspaceAPI = component.find("workspace");
		workspaceAPI.getEnclosingTabId().then(function (enclosingTabId) {
			workspaceAPI
				.openSubtab({
					parentTabId: enclosingTabId,
					pageReference: {
						type: "standard__component",
						attributes: {
							componentName: "c__Financeiro_FichaFinanceira"
						},
						state: {
							c__recordId: component.get("v.recordId")
						}
					}
				})
				.then(function (subtabId) {
					workspaceAPI.setTabLabel({
						tabId: subtabId,
						label: "Ficha Financeira"
					});

					workspaceAPI.setTabIcon({
						tabId: subtabId,
						icon: "standard:contract",
						iconAlt: "Ficha Financeira"
					});
				})
				.catch(function (error) {
					console.error("Erro ao abrir subtab");
				});
		});
	}
});