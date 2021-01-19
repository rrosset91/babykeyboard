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
import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import Utils from "c/solarUtils";

export default class SolarResFichaFinanceira extends LightningElement {
	baseAttributes;
	@track
	detailsStep = false;
	@api
	baseDetail;

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.baseAttributes = currentPageReference.attributes.attributes;
	}

	fetchDetails(event) {
		this.detailsStep = true;
		this.baseDetail = event.detail;
	}

	openFaturas() {
		this.detailsStep = false;
	}
}