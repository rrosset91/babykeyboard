/**
 * @description       : Tela de confirmação da jornada de contestação
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociação
 * @last modified on  : 20-01-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   20-01-2021   Roger Rosset   Initial Version
 **/
import { api, track, LightningElement } from "lwc";

export default class SolarFinanceiroConfirmacaoParcelamento extends LightningElement {
	@api
	negotiatedAmount;

	@api
	negotiationConditions;

	@api
	columns;

	@api
	tableData;

	@track negotiationObservation;

	handleObservation(event) {
		let observation = event.detail.value;
		this.negotiationObservation = observation;
	}
	handleBack() {
		this.template.querySelector("c-solar-modal").close();
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("voltarparaparcelamento", { detail: selectedBill }));
	}
	validateNegotiation() {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("submitnegotiation", { detail: selectedBill }));
		alert(this.negotiationObservation);
	}
}
