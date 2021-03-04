/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 17-02-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-10-2020   Joao Neves   Initial Version
 * 1.1 	 17-02-2021   Roger Rosset Acesso a tela de comparação de faturas
 **/
import { LightningElement, api, track } from "lwc";
import getOpenInvoicesByPeriod from "@salesforce/apex/InvoicesController.getOpenInvoicesByPeriod";
import getOpenInvoicesManualPeriod from "@salesforce/apex/InvoicesController.getOpenInvoicesManualPeriod";
import Utils from "c/solarUtils";

export default class SolarResFaturasAbertas extends LightningElement {
	@api baseAttributes;
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
	showHelp = false;
	helpText = "Não é possível selecionar faturas com mais de 6 meses de diferença";
	hasData = false;
	hasError = false;
	disableDetails = true;
	disableCompare = true;
	isLoading = false;
	@track
	selectedItem = {};
	@track
	comparisonData = {};
	connectedCallback() {
		this.fetchInvoices();
	}

	async fetchInvoices(period) {
		console.log("SolarResFaturasAbertas", this.baseAttributes);

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
		console.log("SolarResFaturasAbertas", this.baseAttributes);

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
	handleCompareClick() {
		this.dispatchEvent(new CustomEvent("fetchcompare", { detail: this.comparisonData }));
	}

	handleRowAction(event) {
		this.modalItem = event.detail.row;
		this.template.querySelector("c-solar-modal").open();
	}

	handleRowSelection(event) {
		let selectedRows = event.detail.selectedRows;
		if (selectedRows.length === 0) return (this.disableDetails = true);
		switch (selectedRows.length) {
			case 1:
				this.disableDetails = false;
				this.disableCompare = true;
				this.selectedItem = event.detail.selectedRows[0];
				this.showHelp = false;
				break;
			case 2:
				this.disableDetails = true;
				this.disableCompare = this.checkComparisonDisponibility(selectedRows);
				if (this.disableCompare) {
					this.showHelp = true;
				} else {
					this.showHelp = false;
				}
				this.setComparisonData(selectedRows);
			default:
				break;
		}
	}
	checkComparisonDisponibility(invoices) {
		let firstInvoiceDate = invoices[0].dataVencimento;
		let secondInvoiceDate = invoices[1].dataVencimento;
		let firstInvoiceRealDate = new Date(firstInvoiceDate.split("/")[2], firstInvoiceDate.split("/")[1], firstInvoiceDate.split("/")[0]);
		let secondInvoiceRealDate = new Date(secondInvoiceDate.split("/")[2], secondInvoiceDate.split("/")[1], secondInvoiceDate.split("/")[0]);
		let differenceBetweenInvoices = (secondInvoiceRealDate.getFullYear() * 12 + secondInvoiceRealDate.getMonth() - (firstInvoiceRealDate.getFullYear() * 12 + firstInvoiceRealDate.getMonth())) * -1;
		let result = true;
		differenceBetweenInvoices <= 6 ? (result = false) : (result = true);
		return result;
	}

	setComparisonData(invoices) {
		let comparisonObject = {};
		let firstInvoice = {};
		let secondInvoice = {};
		firstInvoice.invoice = invoices[0];
		secondInvoice.invoice = invoices[1];
		comparisonObject.operatorCode = this.baseAttributes.operatorId;
		comparisonObject.contractNumber = this.baseAttributes.contractId;
		comparisonObject.invoicesDataToCompare = [];
		comparisonObject.invoicesDataToCompare[0] = firstInvoice;
		comparisonObject.invoicesDataToCompare[1] = secondInvoice;
		this.comparisonData = comparisonObject;
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