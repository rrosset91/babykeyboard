import { LightningElement, api } from "lwc";

export default class SolarFiltros extends LightningElement {
	valuePeriod = "6";
	valueProduct = "";
	valueStatus = "";
	valueSearch = "";
	startDate = "";
	endDate = "";
	isCustomPeriod = false;
	optionsPeriod = [
		{ label: "6 meses", value: "6" },
		{ label: "12 meses", value: "12" },
		{ label: "24 meses", value: "24" },
		{ label: "Customizado", value: "custom" }
	];
	optionsProduct = [];
	optionsStatus = [];
	hasRendered = false;
	@api
	allowRefresh = false;
	@api
	hideStatus = false;

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

	handleChangeStatus(event) {
		this.valueStatus = event.detail.value;
		this.notify("status", this.valueStatus);
	}

	handleKeyupSearch(event) {
		this.valueSearch = event.target.value;
		this.notify("search", this.valueSearch);
	}

	notify(type, value) {
		this.dispatchEvent(new CustomEvent("filterchange", { detail: { filterType: type.toUpperCase(), value } }));
	}
}