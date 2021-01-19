/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 10-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   11-11-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";

export default class SolarFiltros extends LightningElement {
	valuePeriod = "6";
	valueProduct = "";
	valueStatus = "";
	valueSearch = "";
	startDate = "";
	endDate = "";
	isCustomPeriod = false;
	hasRendered = false;
	optionsPeriod = [
		{ label: "6 meses", value: "6" },
		{ label: "12 meses", value: "12" },
		{ label: "24 meses", value: "24" },
		{ label: "Customizado", value: "custom" }
	];
	@api
	optionsProduct = [];
	@track
	optionsStatus = [];
	@api
	allowRefresh = false;
	@api
	hideStatus = false;
	@api
	handleSearch = false;
	@api
	showMsisdn = false;
	@api
	optionsMsisdn;

	@api
	handleStatus = false;
	@api
	defaultMsisdn;
	filteredContent = [];
	originalContent = [];
	customPeriodButtonDisabled = true;

	@api
	resetFilters() {
		this.valuePeriod = "6";
		this.valueStatus = "";
		this.valueSearch = "";
		this.startDate = "";
		this.endDate = "";
		this.isCustomPeriod = false;
		this.filteredContent = this.originalContent;
		this.notify("searchResult", this.originalContent);
	}

	@api
	setSearchContent(content) {
		this.originalContent = content;
		this.filteredContent = content;
	}

	@api
	setstatusFilter(statusArr) {
		statusArr.unshift({ label: "Todos", value: "Todos" });
		this.optionsStatus = statusArr;
	}

	renderedCallback() {
		if (this.hasRendered) return;

		const cssClass = this.allowRefresh ? "almost-full-width" : "full-width";

		this.template.querySelector("div[data-id=search]").classList.add(cssClass);
		this.hasRendered = true;
	}

	handleRefresh() {
		this.dispatchEvent(new CustomEvent("requestrefresh"));
	}

	handleDateChange(event) {
		this[event.target.name] = event.target.value;
		this.checkCustomPeriod();
	}

	checkCustomPeriod() {
		let validDates;
		let filledStartDate = !Utils.isEmptyString(this.startDate);
		let filledEndDate = !Utils.isEmptyString(this.endDate);

		if (this.endDate >= this.startDate && filledStartDate && filledEndDate) {
			validDates = true;
		} else {
			validDates = false;
		}
		if (filledStartDate && filledEndDate) {
			if (!validDates) {
				this.customPeriodButtonDisabled = true;
				Utils.showToast(this, "warning", null, "A data de fim deve ser maior do que a data de início");
			} else {
				this.customPeriodButtonDisabled = false;
			}
		} else {
			this.customPeriodButtonDisabled = true;
		}
	}

	handleCustomPeriod() {
		this.notify("customPeriod", { startDate: this.startDate, endDate: this.endDate });
	}

	handleChangePeriod(event) {
		this.valuePeriod = event.detail.value;
		this.isCustomPeriod = event.detail.value === "custom";
		if (this.isCustomPeriod) return;

		this.notify("period", this.valuePeriod);
	}

	handleChangeMsisdn(event) {
		this.valueMsisdn = event.detail.value;
		this.notify("msisdn", this.valueMsisdn);
	}

	handleChangeStatus(event) {
		this.valueStatus = event.detail.value;

		if (this.handleStatus) {
			if (this.valueStatus === "Todos") {
				this.filteredContent = this.originalContent;
				this.notify("statusResult", this.filteredContent);
				return;
			}

			let filteredArray = this.originalContent.filter((x) => {
				if (x.status.toLocaleLowerCase() === this.valueStatus.toLowerCase()) return x;
			});

			this.filteredContent = filteredArray;
			this.notify("statusResult", this.filteredContent);
		} else {
			this.notify("status", this.valueStatus);
		}
	}

	handleChange(event) {
		this.valueSearch = event.target.value;

		if (this.handleSearch) {
			if (Utils.isEmptyString(this.valueSearch)) {
				this.filteredContent = this.originalContent;
				this.notify("searchResult", this.filteredContent);
				return;
			}

			let filteredArray = this.originalContent.filter((x) => {
				if (JSON.stringify(Object.values(x)).toLocaleLowerCase().includes(this.valueSearch.toLowerCase())) return x;
			});

			this.filteredContent = filteredArray;

			this.notify("searchResult", this.filteredContent);
		} else {
			this.notify("search", this.valueSearch);
		}
	}

	notify(type, value) {
		this.dispatchEvent(new CustomEvent("filterchange", { detail: { filterType: type.toUpperCase(), value } }));
	}
}