/**
 * @description       : Tela de confirmação da jornada de contestação
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociação
 * @last modified on  : 04-02-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   20-01-2021   Roger Rosset   Initial Version
 **/
import { api, track, LightningElement } from "lwc";
import Utils from "c/solarUtils";
import submitNegotiation from "@salesforce/apex/FinancialNegotiationEfetivation.performNegotiation";

export default class SolarFinanceiroConfirmacaoParcelamento extends LightningElement {
	@api
	baseAttributes;

	@api
	baseDetail;

	@track isLoading = true;
	@track negotiatedAmount;
	@track negotiationConditions;
	@track columns;
	@track tableData;
	@track negotiationObservation = "";
	@track negotiationSubmitted = false;
	@track negotiationBody;
	@track observationLocked = false;

	connectedCallback() {
		this.fetchValues();
	}

	fetchValues() {
		console.log("@@@ Debug da variavel: this.baseAttributes", JSON.parse(JSON.stringify(this.baseAttributes)));
		console.log("@@@ Debug da variavel: this.baseDetail", JSON.parse(JSON.stringify(this.baseDetail)));

		this.originalAmount = this.baseDetail.fullSumSelectedItems;
		this.negotiatedAmount = Number(this.baseDetail.negotiatedValue);
		this.negotiationConditions = this.baseDetail.negotiationConditions;
		this.columns = this.baseDetail.columns;
		this.tableData = this.baseDetail.tableData;
		this.isLoading = false;
	}

	handleObservation(event) {
		let observation = event.detail.value;
		this.negotiationObservation = observation;
	}
	handleBack() {
		console.log("EVENTO DE VOLTAR DISPARADO");
		this.dispatchEvent(new CustomEvent("backstep", { detail: this.baseDetail }));
	}
	validateNegotiation() {
		if (!Utils.isEmptyString(this.negotiationObservation)) {
			this.submitNegotiation();
		}
	}

	submitNegotiation() {
		this.isLoading = true;
		console.log("@@@ Debug da variavel: this.baseAttributes", JSON.parse(JSON.stringify(this.baseAttributes)));
		console.log("@@@ Debug da variavel: this.baseDetail", JSON.parse(JSON.stringify(this.baseDetail)));
		submitNegotiation({
			negotiationDetail: JSON.stringify(this.baseDetail),
			baseAttributes: JSON.stringify({ ...this.baseAttributes, comment: this.negotiationObservation })
		})
			.then(() => {
				this.negotiationSubmitted = true;
				this.isLoading = false;
				this.observationLocked = true;
				this.showSuccessModal();
			})
			.catch((error) => {
				console.log("@@@ Debug da variavel: error", JSON.parse(JSON.stringify(error)));
				Utils.showToast(this, "error", "Erro", error.body.message);
				this.negotiationSubmitted = false;
				this.isLoading = false;
			});
	}

	showSuccessModal() {
		this.template.querySelector("c-solar-modal").open();
	}
	closeTab() {
		this.template.querySelector("c-solar-modal").close();
		this.invokeWorkspaceAPI("isConsoleNavigation").then((isConsole) => {
			if (isConsole) {
				this.invokeWorkspaceAPI("getFocusedTabInfo").then((focusedTab) => {
					this.invokeWorkspaceAPI("closeTab", {
						tabId: focusedTab.tabId
					}).then((tabId) => {
						console.log("Tab fechada :", tabId);
					});
				});
			}
		});
	}
	invokeWorkspaceAPI(methodName, methodArgs) {
		return new Promise((resolve, reject) => {
			const apiEvent = new CustomEvent("internalapievent", {
				bubbles: true,
				composed: true,
				cancelable: false,
				detail: {
					category: "workspaceAPI",
					methodName: methodName,
					methodArgs: methodArgs,
					callback: (err, response) => {
						if (err) {
							return reject(err);
						} else {
							return resolve(response);
						}
					}
				}
			});
			window.dispatchEvent(apiEvent);
		});
	}
}