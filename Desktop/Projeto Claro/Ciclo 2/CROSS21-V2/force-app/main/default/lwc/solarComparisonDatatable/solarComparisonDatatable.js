import { LightningElement, api } from "lwc";

export default class SolarComparisonDatatable extends LightningElement {
	@api
	content;
	@api
	columns;
}