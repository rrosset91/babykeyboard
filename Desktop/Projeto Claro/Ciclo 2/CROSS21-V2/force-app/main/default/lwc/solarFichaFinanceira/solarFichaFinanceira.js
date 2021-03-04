/**
 * @description       :
 * @author            : Joao Neves
 * @group             : IBM

 * @last modified on  : 17-02-2021
 * @last modified by  : Roger Rosset

 * Modifications Log
 * Ver   Date         Author          		Modification
 * 1.0   20-10-2020   Joao Neves   		Initial Version
 * 1.1   27-10-2020   Diego Almeida   	Add condition to open each component
 * 1.1   27-10-2020   Diego Almeida   	Add new components and stepControl
 * 1.2   02-02-2021   Diego Almeida     BUG 113351 -BUG PROD RELEASE - Acesso a ficha financeiro sem caso
 *
 **/
import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { decodeDefaultFieldValues } from "lightning/pageReferenceUtils";

import Utils from "c/solarUtils";
export default class SolarFichaFinanceira extends LightningElement {
	@track
	passoListaFaturas = false;

	passoDetalhesFatura = false;
	passoContestacao = false;
	passoConfirmacaoContestacao = false;
	passoReembolso = false;

	@api baseDetail;
	@api baseAttributes;
	@api encodedbaseAttributes;

	headerInfo = {};
	titleDetalheFatura;

	faturaString;
	isLoading = true;
	contestationComment = "";
	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		// console.log("currentPageReferences =>", JSON.parse(JSON.stringify(currentPageReference)));
		// this.baseAttributes = currentPageReference.attributes.attributes;
		//BUG 113351 -BUG PROD RELEASE - Acesso a ficha financeiro sem caso - @author: Diego Almeida
		const dfvObject = decodeDefaultFieldValues(atob(this.encodedbaseAttributes));
		console.log("SolarResFichaFinanceira dfvObject:", JSON.stringify(dfvObject));
		this.baseAttributes = dfvObject;

		console.log("baseAttributes", this.baseAttributes);
		this.isLoading = false;
		this.passoListaFaturas = true;

		if (this.baseAttributes.invoiceCase != null) {
			const detailData = {};
			detailData.dueDate = "23/08/2020";
			detailData.valor = "R$ 250,00";
			detailData.status = "Em Aberto";
			detailData.type = "";
			const vencimentoSplit = detailData.dueDate.split("/");
			const vencimentoDate = new Date(vencimentoSplit[2], vencimentoSplit[1] - 1, vencimentoSplit[0]);
			const vencimentoMonth = Utils.getMonthName(vencimentoDate);
			this.faturaString = vencimentoMonth.charAt(0).toUpperCase() + vencimentoMonth.slice(1) + " " + vencimentoDate.getFullYear();

			this.headerInfo = this.fillHeader(detailData);
			this.headerInfo.headerTitle = this.baseAttributes.isN2User ? this.faturaString : "Itens a Contestar";
			this.headerInfo.numerocaso = this.baseAttributes.numeroCase;
			this.headerInfo.tipocaso = this.baseAttributes.typeCase;
			this.headerInfo.isN2access = this.baseAttributes.isN2User;
			this.openContestation();
		}
		console.log("baseAttributes apos if -->", this.baseAttributes);
	}
	fillHeader(detailData) {
		const header = {};
		header.headerTitle = "headerTitle";

		header.dataVencimento = detailData.dueDate;
		header.valor = detailData.value;
		header.status = detailData.status;
		header.formaPagamento = detailData.type;
		header.modoRecebimento = "Correio";
		header.enderecoCobranca = "Rua pinheio Machado 52";

		header.isN2access = false;
		header.numeroCase = "0";
		header.tipocaso = "x";
		return header;
	}
	openFaturas(event) {
		this.changeStep(event, "OpenFaturas");
	}

	fetchDetails(event) {
		let eventObj = JSON.parse(JSON.stringify(event.detail));
		eventObj.value = eventObj.formatAmount;
		eventObj.dueDate = eventObj.formatDueDate;
		this.headerInfo = this.fillHeader(eventObj);
		const vencimentoSplit = eventObj.dueDate.split("/");
		const vencimentoDate = new Date(vencimentoSplit[2], vencimentoSplit[1] - 1, vencimentoSplit[0]);
		const vencimentoMonth = Utils.getMonthName(vencimentoDate);

		this.faturaString = vencimentoMonth.charAt(0).toUpperCase() + vencimentoMonth.slice(1) + " " + vencimentoDate.getFullYear();
		this.headerInfo.headerTitle = "Fatura " + this.faturaString;
		this.titleDetalheFatura = this.headerInfo.headerTitle;
		console.log("headerInfo", this.headerInfo);
		this.changeStep(event, "OpenDetalhes");
	}

	reopenDetails(event) {
		this.headerInfo.headerTitle = this.titleDetalheFatura;

		this.contestationComment = event.detail.comment;

		this.changeStep(event, "OpenDetalhes");
	}
	openPDF(event) {
		this.changeStep(event, "OpenPDF");
	}

	openContestation(event) {
		if (Utils.isEmptyArray(event.detail)) {
			Utils.showToast(this, "error", null, "Selecione algum item para contestar.");
			return;
		}

		this.selectedItems = event.detail;
		this.headerInfo.headerTitle = this.baseAttributes.isN2User ? this.faturaString : "Itens a Contestar";
		this.headerInfo.numerocaso = this.baseAttributes.numeroCase;
		this.headerInfo.tipocaso = this.baseAttributes.typeCase;
		// this.headerInfo.isN2access = this.baseAttributes.isN2User;
		console.log("openContestation", this.headerInfo);
		this.changeStep(event, "OpenContestacao");
	}
	openConfirmation(event) {
		this.headerInfo.headerTitle = "Confirmação da Contestação";
		this.changeStep(event, "OpenConfirmacao");
	}

	openRefund(event) {
		this.headerInfo.headerTitle = "Solicitação de Reembolso";
		this.changeStep(event, "OpenReembolso");
	}

	//Control for component steps
	//Add EventsHistory?
	changeStep(event, openStep) {
		console.log("changeStep", openStep);

		this.passoListaFaturas = false;
		this.passoDetalhesFatura = false;
		this.passoContestacao = false;
		this.passoConfirmacaoContestacao = false;
		this.passoReembolso = false;
		switch (openStep) {
			case "OpenDetalhes":
				this.passoDetalhesFatura = true;
				this.baseDetail = event.detail;
				break;

			case "OpenContestacao":
				this.passoContestacao = true;
				break;

			case "OpenConfirmacao":
				this.passoConfirmacaoContestacao = true;
				break;
			case "OpenReembolso":
				this.passoReembolso = true;
				// this.baseDetail = event.detail;
				break;
			case "OpenPDF":
				Utils.showToast(this, "error", null, "Nao implantado");
				break;
			default:
				this.passoListaFaturas = true;
				break;
		}
	}
	finishContestation(event) {
		Utils.showToast(this, "success", null, "Contestação finalizada com sucesso");
		this.changeStep(event, "OpenFaturas");
	}
}