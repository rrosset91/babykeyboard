import { LightningElement, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getRecordProps from "@salesforce/apex/FinancialMobileGeneralService.getRecordProps";

import Utils from "c/solarUtils";

export default class SolarFinanceiroNegociacao extends LightningElement {
	@api rId;
	baseDetail = {};
	baseAttributes = {};
	isLoading = false;
	passoNegociacaoFaturas = false;
	passoConfirmacaoNegociacao = false;
	passoResumoNegociacao = false;
	passoSimulacao = false;

	@wire(CurrentPageReference)
	async setCurrentPageReference() {
		this.isLoading = true;

		let hasError = false;
		const returnedData = await getRecordProps({ recordId: this.rId }).catch((err) => {
			hasError = true;
			Utils.showToast(this, "error", "Erro", err.body.message);
		});
		this.isLoading = false;
		if (hasError) return null;

		this.baseAttributes = {
			...returnedData,
			caseId: this.rId
		};

		this.passoNegociacaoFaturas = true;
		return null;
	}

	handleOpenNegociacao(event) {
		this.changeStep(event, "OpenNegociacao");
	}

	handleOpenSimulacao(event) {
		this.changeStep(event, "OpenSimulacao");
	}

	handleOpenSubmitNegotiation(event) {
		this.changeStep(event, "OpenResumoNegociacao");
	}

	handleBackConfirmation(event) {
		this.changeStep(event, "OpenSimulacao");
	}

	changeStep(event, openStep) {
		console.log("@@@ Debug da variavel: event", JSON.parse(JSON.stringify(event)));
		console.log("@@@ Debug da variavel: openStep", JSON.parse(JSON.stringify(openStep)));

		this.passoNegociacaoFaturas = false;
		this.passoConfirmacaoNegociacao = false;
		this.passoResumoNegociacao = false;
		this.passoSimulacao = false;

		switch (openStep) {
			case "OpenNegociacao":
				this.passoNegociacaoFaturas = true;
				this.baseDetail = { ...event.detail, ...this.baseDetail };
				break;

			case "OpenSimulacao":
				this.passoSimulacao = true;
				this.baseDetail = { ...event.detail, ...this.baseDetail };
				break;

			case "OpenResumoNegociacao":
				this.passoResumoNegociacao = true;
				this.baseDetail = { ...event.detail, ...this.baseDetail };
				break;

			default:
				this.passoNegociacaoFaturas = true;
				break;
		}
	}
}