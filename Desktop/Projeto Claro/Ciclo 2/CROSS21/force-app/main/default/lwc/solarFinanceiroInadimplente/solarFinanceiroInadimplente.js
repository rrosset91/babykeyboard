import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import InvoicesPending from "@salesforce/apex/FinancialNegotiationInadimplente.getInvoicesPending";

export default class SolarFinanceiroInadimplente extends LightningElement {
	// **************** Decoradores Publicos ****************
	@api baseAttributes;
	@api baseDetail;
	@api selectedItems = [];
	// ******************************************************

	// **************** Decoradores Privados ****************
	@track activeSections = ["accordionFatura", "accordionlancamentoFuturos"];
	@track negociationItems = [];
	@track modalItem = {};
	@track reasonContext = {};
	@track hasData = false;
	@track hasError = false;
	@track buttonSimulation = false;
	@track chamadaSemSucesso = false;
	@track error;
	@track data;
	@track negotiationType;
	@track sortBy;
	@track sortDirection;
	@track negotiatonItems = [];
	// *******************************************************

	// **************** Interagindo com o componente ****************
	connectedCallback() {
		// console.log('baseDetail', JSON.parse(JSON.stringify(this.baseDetail)));
		// console.log('baseAttributes', JSON.parse(JSON.stringify(this.baseAttributes)));
		if (this.baseDetail.negotiatonItems) {
			this.negotiatonItems = this.baseDetail.negotiatonItems;
			this.selectedItems = this.baseDetail.negotiatonItems;
		}
		this.fetchDetailsInvoices();
		console.log("Base baseDetail: " + baseDetail);
		console.log("Base atributos: " + baseAttributes);
	}

	async fetchDetailsInvoices() {
		const data = await InvoicesPending({ operatorCode: this.baseDetail.operatorCode, contractNumber: this.baseDetail.contractNumber }).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (this.hasError) return;
		console.log("data", JSON.parse(JSON.stringify(data)));

		this.data = data;
		this.hasData = !Utils.isEmptyArray(data);
	}
	// ***************************************************************

	// **************** Datatable ****************
	columns = [
		{ label: "TIPO", fieldName: "type", type: "text", hideDefaultActions: true },
		{ label: "DATA VENCIMENTO", fieldName: "dataVencimento", type: "date", hideDefaultActions: true },
		{ label: "VALOR", fieldName: "invoiceAmount", type: "Currency", hideDefaultActions: true }
	];

	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		let sortField = this.sortBy;

		if (this.sortBy === "formatAmount") sortField = "rawAmount";
		if (this.sortBy === "formatDueDate") sortField = "rawDueDate";

		let data = Utils.sortData(sortField, this.sortDirection, this.data);
		this.data = data;
	}

	handleRowSelection(event) {
		this.disabledDetails = false;
		if (event.detail.selectedRows[0] != null) {
			this.buttonSimulation = false;
		} else {
			this.buttonSimulation = true;
		}
	}
	// ********************************************

	// **************** Evento Simular ****************
	handleSimulation() {
		const selectedBill = {};
		if (condition) {
			this.dispatchEvent(new CustomEvent("opensimulacao", { detail: selectedBill }));
		} else {
			this.chamadaSemSucesso = true;
			this.handleItegrationFalse();
		}
	}
	// ************************************************

	// **************** Mostra Modal ****************
	handleItegrationFalse(event) {
		if (this.chamadaSemSucesso) {
			this.template.querySelector('[data-id="chamadaSemSucesso"]').open();
		}
	}
	// ************************************************
}
