/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 29-10-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Utils from "c/solarUtils";
import getRecordProps from "@salesforce/apex/FinancialMobileGeneralService.getRecordProps";

export default class SolarAcessarFicha extends NavigationMixin(LightningElement) {
	@api
	recordId;
	@track
	isDisabled = true;
	@track
	componentStep = "Carregando dados...";
	@track
	recordProps;

	connectedCallback() {
		this.fillComponentData();
	}

	async fillComponentData() {
		const data = await getRecordProps({ recordId: this.recordId }).catch((err) => {
			Utils.showToast(this, "error", null, err.body.message);
			this.componentStep = "Erro ao buscar informações";
		});

		console.log("Valor do data -> ", data);

		if (!data) return;

		if (!data.contractId || !data.recordId) {
			this.componentStep = "Informações indisponíveis para acessar a ficha";
			return;
		}

		this.isDisabled = false;
		this.componentStep = "Continuar para Ficha Financeira Móvel";
		this.recordProps = data;
	}

	handleNavigate() {
		let componentName = this.recordProps.isViewOnly ? "c:solarResFichaFinanceira" : "c:solarFichaFinanceira";

		let compDetails = {
			componentDef: componentName,
			attributes: this.recordProps
		};

		let encodedCompDetails = btoa(JSON.stringify(compDetails));

		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: "/one/one.app#" + encodedCompDetails
			}
		});
	}
}