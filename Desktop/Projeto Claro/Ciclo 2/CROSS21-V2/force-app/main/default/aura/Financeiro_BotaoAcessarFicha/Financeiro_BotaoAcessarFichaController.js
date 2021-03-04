/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 03-03-2021
 * @last modified by  : Felipe Ducheiko
 * @last modified on  : 03-03-2021
 * @last modified by : Felipe Ducheiko
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
({
	doInit: function (component, event, helper) {
		
		//this.getHasPermission(component);
		$A.enqueueAction(component.get('c.getHasPermission'));
		//$A.enqueueAction(component.get('c.getHasButtonNegotiationVisibility'));
		let action = component.get("c.getRecordProps");
		action.setParams({
			recordId: component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			const state = response.getState();
			const data = response.getReturnValue();

			if (state === "SUCCESS") {
				if (data.isProfileFinancial && (data.isMobileContract || data.isViewOnly)) {
					console.log('Yes its mobile');

					component.set("v.isMobileAndProfile", true);
				} else if (data.isProfileFinancial) {
					console.log('Yes its residential');
					
					component.set("v.isResidentialAndProfile", true);
					component.set("v.isVisible", !data.isFinancialPermissionSet);
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
	},

	clickViewNegotiation: function (component,event) {
		const workspaceAPI = component.find("workspace");
		workspaceAPI.getEnclosingTabId().then(function (enclosingTabId) {
			console.log('-------> v.recordId' + component.get("v.recordId"));
			workspaceAPI
				.openSubtab({
					
					parentTabId: enclosingTabId,
					pageReference: {
						type: "standard__component",
						attributes: {
							componentName: "c__Financeiro_SubTab_Negotiation"
						},
						state: {
							c__crecordId: component.get("v.recordId")
						}
					}
				})
				.then(function (subtabId) {
					workspaceAPI.setTabLabel({
						tabId: subtabId,
						label: "Negociação"
					});

					workspaceAPI.setTabIcon({
						tabId: subtabId,
						icon: "standard:contract",
						iconAlt: "Negociação"
					});
				})
				.catch(function (error) {
					console.error("Erro ao abrir subtab");
				});
		});
	},

	getHasPermission: function(component){
		let action = component.get("c.hasPermissionSet");
		action.setParams({
			caseId: component.get("v.recordId")
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
				component.set("v.hasPermission", response.getReturnValue());

			}
			else{
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	}
/* Método que define a visibilidade do botão PU28, devido a regras de negócio, decidiu-se retirar
	getHasButtonNegotiationVisibility : function(component){
		let action = component.get("c.getButtonVisibility");
		console.log('Entrou::::::::::::')
		action.setParams({
			caseId: component.get("v.recordId")
		});

		action.setCallback(this, function(response){
			console.log(' entrou aqui response haspermission sucess2', response.getReturnValue());
			var state = response.getState();
			if(state === "SUCCESS"){
				component.set("v.hasButtonVisibility", response.getReturnValue());
				console.log('response haspermission sucess2', response.getReturnValue());

			}
			else{
				console.log("Failed with state: " + state);
			}
		});

		$A.enqueueAction(action);

	}
*/

});