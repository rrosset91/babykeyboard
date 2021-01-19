/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 04-11-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-10-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import getOpenInvoicesByPeriod from "@salesforce/apex/InvoicesController.getOpenInvoicesByPeriod";
import getOpenInvoicesManualPeriod from "@salesforce/apex/InvoicesController.getOpenInvoicesManualPeriod";
import Utils from "c/solarUtils";

export default class SolarResFaturasAbertas extends LightningElement {
	@api
	baseAttributes = {};
	@track
	data;
	@track
	sortBy;
	@track
	sortDirection;
	@track
	modalItem = {};
	columns = [
		{
			label: "TIPO",
			fieldName: "tipoFatura",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "SITUAÇÃO",
			fieldName: "status",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "FORMA DE PAGAMENTO",
			fieldName: "cobranca",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "DATA DE VENCIMENTO",
			fieldName: "dataVencimento",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "VALOR",
			fieldName: "valor",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "CONTESTAÇÃO",
			fieldName: "contested",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "",
			initialWidth: 190,
			type: "button",
			typeAttributes: {
				iconName: "utility:preview",
				label: "Mais informações",
				name: "showDetail",
				disabled: false
			}
		}
	];
	hasData = false;
	hasError = false;
	disableDetails = true;
	isLoading = false;
	@track
	selectedItem = {};

	connectedCallback() {
		this.fetchInvoices();
	}

	async fetchInvoices(period) {
		if (!period) period = 6;
		this.isLoading = true;

		const data = await getOpenInvoicesByPeriod({
			contractId: this.baseAttributes.contractId,
			operatorId: this.baseAttributes.operatorId,
			period: period,
			recordId: this.baseAttributes.recordId
		}).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});
		this.isLoading = false;

		if (this.hasError) return;

		this.hasData = !Utils.isEmptyArray(data.invoices);
		if (this.hasData) this.data = this.normalizeData(data.invoices);
	}

	async fetchInvoicesByPeriod(startDate, endDate) {
		this.isLoading = true;

		const data = await getOpenInvoicesManualPeriod({
			contractId: this.baseAttributes.contractId,
			operatorId: this.baseAttributes.operatorId,
			startDate: startDate,
			endDate: endDate,
			recordId: this.baseAttributes.recordId
		}).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});
		this.isLoading = false;

		if (this.hasError) return;

		this.hasData = !Utils.isEmptyArray(data.invoices);
		if (this.hasData) this.data = this.normalizeData(data.invoices);
	}

	handleFilterNotification(event) {
		if (event.detail.filterType === "CUSTOMPERIOD") {
			this.fetchInvoicesByPeriod(event.detail.value.startDate, event.detail.value.endDate);
		} else if (event.detail.filterType === "PERIOD") {
			this.fetchInvoices(parseInt(event.detail.value));
		}
	}

	handleDetailsClick() {
		this.dispatchEvent(new CustomEvent("fetchdetails", { detail: this.selectedItem }));
	}

	handleRowAction(event) {
		this.modalItem = event.detail.row;
		this.template.querySelector("c-solar-modal").open();
	}

	handleRowSelection(event) {
		this.disableDetails = false;
		this.selectedItem = event.detail.selectedRows[0];
	}

	handleCloseModal() {
		this.template.querySelector("c-solar-modal").close();
	}

	handleSortdata(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;

		let sortField = this.sortBy;
		if (this.sortBy === "valor") sortField = "rawValor";
		if (this.sortBy === "dataVencimento") sortField = "rawVencimentoMilis";

		let data = Utils.sortData(sortField, this.sortDirection, this.data);
		this.data = data;
	}

	normalizeData(invoices) {
		for (let index = 0; index < invoices.length; index++) {
			let invoice = invoices[index];
			const vencimentoSplit = invoice.dataVencimento.split("/");

			invoice.contested = invoice.contestation ? "Sim" : "Não";
			invoice.rawVencimentoMilis = new Date(vencimentoSplit[2], vencimentoSplit[1] - 1, vencimentoSplit[0]).getTime();
			invoice.rawValor = parseFloat(invoice.valor.replace("R$", "").replace(",", ".").replace(" ", ""));
		}

		console.log("after normalizeData -> ", JSON.parse(JSON.stringify(invoices)));

		return invoices;
	}
}