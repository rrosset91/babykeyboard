/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 17-02-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-10-2020   Joao Neves   Initial Version
 * 1.1   04-02-2021   Diego Almeida   	BUG 113351 -BUG PROD RELEASE - Acesso a ficha financeiro sem caso
 * 1.2   04-02-2021   Diego Almeida   	BUG 113351 -BUG PROD RELEASE - Acesso a ficha de comparação financeiro sem caso
 * 1.3 	 17-02-2021   Roger Rosset Acesso a tela de comparação de faturas
 *
 *
 *
 **/
import { LightningElement, track, wire, api } from "lwc";
import { decodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { CurrentPageReference } from "lightning/navigation";
import Utils from "c/solarUtils";

export default class SolarResFichaFinanceira extends LightningElement {
	@api baseAttributes;
	@api encodedbaseAttributes;
	@api baseDetail;
	@track detailsStep = false;
	@track compareScreen = false;
	@track comparisonData = {};
	/*
	// @wire(CurrentPageReference)
	// setCurrentPageReference(currentPageReference) {
	// 	console.log('SolarResFichaFinanceira', this.baseAttributes);

		//this.baseAttributes = currentPageReference.attributes.attributes;
	// }
*/
	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		const dfvObject = decodeDefaultFieldValues(atob(this.encodedbaseAttributes));
		console.log("SolarResFichaFinanceira dfvObject:", JSON.stringify(dfvObject));
		this.baseAttributes = dfvObject;
	}

	fetchDetails(event) {
		this.detailsStep = true;
		this.compareScreen = false;
		this.baseDetail = event.detail;
	}

	fetchCompare(event) {
		this.compareScreen = true;
		this.detailsStep = false;
		this.comparisonData = event.detail;
	}

	openFaturas() {
		this.detailsStep = false;
		this.compareScreen = false;
	}
}