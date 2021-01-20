import { LightningElement, wire, api, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

export default class SolarFinanceiroNegociacao extends LightningElement {
	// **************** Decoradores Publicos ****************
	@api rId;
	@api baseDetail;
	@api baseAttributes;
	// ******************************************************

	// **************** Decoradores Privados ****************
	@track passoNegociacaoFaturas = true;
	@track passoConfirmacaoNegociacao = false;
	@track passoResumoNegociacao = false;
	@track passoSimulacao = false;
	// ******************************************************

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		console.log("currentPageReferences =>", JSON.parse(JSON.stringify(currentPageReference)));
		this.baseAttributes = currentPageReference.attributes.attributes;
		console.log("baseAttributes", this.baseAttributes);
		this.isLoading = false;
		this.passoListaFaturas = true;
		console.log("Base baseDetail: " + baseDetail);
		console.log("Base atributos: " + baseAttributes);
	}

	handleOpenNegociacao(event) {
		{
			this.changeStep(event, "OpenNegociacao");
		}
	}

	handleOpensimulacao(event) {
		{
			this.changeStep(event, "OpenSimulacao");
		}
	}

	handleOpenSubmitNegotiation(event) {
		{
			this.changeStep(event, "OpenResumoNegociacao");
		}
	}

	//Navegacao da estrutura Negociacao
	changeStep(event, openStep) {
		console.log("changeStep", openStep);
		this.passoNegociacaoFaturas = false;
		this.passoConfirmacaoNegociacao = false;
		this.passoResumoNegociacao = false;
		this.passoSimulacao = false;

		switch (openStep) {
			case "OpenNegociacao":
				this.passoNegociacaoFaturas = true;
				this.baseDetail = event.detail;
				break;

			case "OpenSimulacao":
				this.passoSimulacao = true;
				this.baseDetail = event.detail;
				break;

			case "OpenResumoNegociacao":
				this.passoResumoNegociacao = true;
				this.baseDetail = event.detail;
				break;

			case "OpenConfirmarNegociacao":
				this.passoConfirmacaoNegociacao = true;
				this.baseDetail = event.detail;
				break;

			default:
				this.passoNegociacaoFaturas = true;
				break;
		}
	}
}
