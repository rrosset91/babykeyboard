/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   27-10-2020   Joao Neves   Initial Version
 * 1.1   09-12-2020   Ricardo Alves - Ajustes para chamada de faturas do móvel
 * 1.2   17-12-2020   Caio Cesar 	- Adicionando modal de detalhes
 **/
import { LightningElement, api, track } from "lwc";
import getOpenInvoicesManualPeriod from "@salesforce/apex/FinancialMobileInvoices.getOpenInvoicesManualPeriod";
import getOpenInvoicesByPeriod from "@salesforce/apex/FinancialMobileInvoices.getOpenInvoicesByPeriod";
import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoices.getInvoiceDetail";
import Utils from "c/solarUtils";

export default class SolarFaturasAbertas extends LightningElement {
	@api
	baseAttributes;
	@track
	data;
	@track
	sortBy;
	@track
	sortDirection;
	@track
	modalItem = {};
	@track
	envioSegundaVia = true;
	columns = [
		{
			label: "TIPO",
			fieldName: "type",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "PRODUTO",
			fieldName: "product",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "STATUS",
			fieldName: "status",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "DATA DE VENCIMENTO",
			fieldName: "formatDueDate",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "CONTESTAÇÃO",
			fieldName: "formatIsContested",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "VALOR",
			fieldName: "formatAmount",
			type: "text",
			hideDefaultActions: true,
			sortable: "true"
		},
		{
			label: "",
			initialWidth: 73,
			type: "button",
			typeAttributes: {
				iconName: "utility:preview",
				label: "",
				name: "showDetail",
				disabled: false
			}
		}
	];
	hasData = false;
	hasError = false;
	disabledDetails = true;
	disabledSendInvoice = true;
	selectedItem = {};
	isLoading = false;
	invoiceDetailError = false;
	selectedRows = [];

	async connectedCallback() {
		this.isLoading = true;
		await this.fetchOpenInvoices();
		this.isLoading = false;
	}

	async fetchOpenInvoices(period) {
		period = period || 6;
		let hasError = false;

		const data = await getOpenInvoicesByPeriod({
			billingAccountId: this.baseAttributes.contractId,
			period: period
		}).catch((err) => {
			this.hasData = false;
			hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (hasError) return;

		if (data.success) {
			this.data = data.invoices;
			this.hasData = !Utils.isEmptyArray(this.data);
		} else {
			this.data = [];
			this.hasError = true;
			Utils.showToast(this, "error", null, data.message);
		}

		this.setSearchContent();
	}

	async fetchOpenInvoicesByDate(startDate, endDate) {
		let hasError = false;

		const data = await getOpenInvoicesManualPeriod({
			billingAccountId: this.baseAttributes.contractId,
			startDate: startDate,
			endDate: endDate
		}).catch((err) => {
			this.hasData = false;
			hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (hasError) return;

		if (data.success) {
			this.data = data.invoices;
			this.hasData = !Utils.isEmptyArray(this.data);
		} else {
			this.data = [];
			this.hasError = true;
			Utils.showToast(this, "error", null, data.message);
		}

		this.setSearchContent();
	}

	async fetchInvoiceDetail(selectedRow) {

		console.log("selectedValue ->", JSON.parse(JSON.stringify(selectedRow)));

		let hasError = false;
		let hasData = false;
		let wrapperSelectedRow = JSON.stringify(selectedRow);
		console.log("wrapperSelectedRow ->", wrapperSelectedRow);
		const dataDetail = await getInvoiceDetails({
			billingAccountId: this.baseAttributes.contractId,
			selectedInvoiceString: wrapperSelectedRow
		}).catch((err) => {
			hasData = false;
			hasError = true;
			this.invoiceDetailError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (hasError) return;

		hasData = !Utils.isEmptyArray(dataDetail);
		if (dataDetail.responseData) {
			return dataDetail.responseData;
		} else {
			this.invoiceDetailError = true;
			this.modalItem.value = "";
			this.modalItem.payDate = "";
			return this.modalItem;
		}
	}

	handleRefreshNotification() {
		this.template.querySelector("c-solar-filtros").resetFilters();
	}

	async handleFilterNotification(event) {
		this.isLoading = true;

		if (event.detail.filterType === "CUSTOMPERIOD") {
			await this.fetchOpenInvoicesByDate(event.detail.value.startDate, event.detail.value.endDate);
		} else if (event.detail.filterType === "PERIOD") {
			await this.fetchOpenInvoices(parseInt(event.detail.value, 10));
		} else if (event.detail.filterType === "SEARCHRESULT") {
			this.data = event.detail.value;
		} else if (event.detail.filterType === "STATUSRESULT") {
			this.data = event.detail.value;
		}

		this.disabledDetails = true;
		this.disabledSendInvoice = true;
		this.selectedItem = [];
		this.selectedRows = [];

		this.isLoading = false;
	}

	handleDetailsClick() {
		this.dispatchEvent(new CustomEvent("fetchdetails", { detail: this.selectedItem }));
	}

	async handleRowAction(event) {
		this.isLoading = true;
		this.modalItem = await this.fetchInvoiceDetail(event.detail.row);
		if(this.modalItem == null){
			this.invoiceDetailError = true;
		}
		else if(this.modalItem.payDate == null || this.modalItem.paymentValue == null) {
			this.invoiceDetailError = true;
		}
		else{
			this.invoiceDetailError = false;
		}
		this.template.querySelector("c-solar-modal").open();
		this.isLoading = false;
	}

	handleRowSelection(event) {
		this.disabledDetails = false;
		this.selectedItem = event.detail.selectedRows[0];
		if (event.detail.selectedRows[0].status == "Em Aberto") {
			this.disabledSendInvoice = false;
		} else {
			this.disabledSendInvoice = true;
		}
	}

	handleCloseModal() {
		this.template.querySelector("c-solar-modal").close();
	}

	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;

		let sortField = this.sortBy;
		if (this.sortBy === "formatAmount") sortField = "rawAmount";
		if (this.sortBy === "formatDueDate") sortField = "rawDueDate";

		let data = Utils.sortData(sortField, this.sortDirection, this.data);
		this.data = data;
	}

	abrirModalSegundaVia() {
		this.template.querySelector("c-solar-financeiro-segunda-via").open();
	}

	setSearchContent() {
		let statusSet = [];
		let nameArray = [];

		let copySearch = this.data || [];

		for (let i = 0; i < copySearch.length; i++) {
			const element = copySearch[i];

			if (!Utils.isEmptyString(element.status) && !nameArray.includes(element.status)) {
				statusSet.push({ label: element.status, value: element.status });
				nameArray.push(element.status);
			}
		}

		this.template.querySelector("c-solar-filtros").setstatusFilter(statusSet);
		this.template.querySelector("c-solar-filtros").setSearchContent(copySearch);
	}
}