/**
 * @description       :
 * @author            : Joao Neves
 * @group             : IBM

 * @last modified on  : 05-11-2020
 * @last modified by  : Diego Almeida

 * Modifications Log
 * Ver   Date         Author          		Modification
 * 1.0   20-10-2020   Joao Neves   		Initial Version
 * 1.1   27-10-2020   Diego Almeida   	Add condition to open each component

 * 1.1   27-10-2020   Diego Almeida   	Add new components and stepControl

 *
 **/
import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import Utils from "c/solarUtils";
export default class SolarFichaFinanceira extends LightningElement {
	@track

	passoListaFaturas = true;
	passoDetalhesFatura = false;
	passoContestacao = false;
	passoConfirmacaoContestacao = false;
	passoReembolso = false;
	@api baseDetail;
	@api baseAttributes;
	headerInfo = {};

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.baseAttributes = currentPageReference.attributes.attributes;
	}

	fillHeader(detailData){
		const header = {};
			header.headerTitle = 'headerTitle';
			header.dataVencimento = detailData.dueDate;
			header.valor = detailData.value;
			header.status = detailData.status;
			header.formaPagamento = detailData.type;
			header.modoRecebimento = "Correio";
			header.enderecoCobranca = "Rua pinheio Machado 52";
		return header;
	}
	//Events Controlls
	openFaturas(event) {
		this.changeStep(event, 'OpenFaturas');
	}
	fetchDetails(event) {
		console.clear();
		this.headerInfo = this.fillHeader(event.detail);
		const vencimentoSplit = event.detail.dueDate.split("/");
		const vencimentoDate = new Date(vencimentoSplit[2], vencimentoSplit[1] - 1, vencimentoSplit[0]);
		const vencimentoMonth = Utils.getMonthName(vencimentoDate);
		this.headerInfo.headerTitle = 'Fatura ' + vencimentoMonth.charAt(0).toUpperCase() + vencimentoMonth.slice(1) +' '+vencimentoDate.getFullYear();
		console.log('headerInfo', this.headerInfo);
		this.changeStep(event, 'OpenDetalhes');
	}
	openPDF(event) {
		this.changeStep(event, 'OpenPDF');
	}
	openContestation(event) {
		this.headerInfo.headerTitle = 'Itens a Contestar';
		console.log('openContestation');
		this.changeStep(event, 'OpenContestacao');
	}
	openConfirmation(event) {
		this.headerInfo.headerTitle = 'Confirmação da Contestação';
		this.changeStep(event, 'OpenConfirmacao');
	}
	openRefund(event) {
		this.headerInfo.headerTitle = 'Solicitação de Reembolso';
		this.changeStep(event, 'OpenReembolso');
	}
	//Control for component steps
	//Add EventsHistory?
	changeStep(event, openStep){
		console.log('changeStep', openStep);
		this.passoListaFaturas = false;
		this.passoDetalhesFatura = false;
		this.passoContestacao = false;
		this.passoConfirmacaoContestacao = false;
		this.passoReembolso = false;
		switch (openStep) {
			case 'OpenDetalhes':
				this.passoDetalhesFatura = true;
				this.baseDetail = event.detail;
			break;
			case 'OpenContestacao':
				this.passoContestacao = true;
				// this.baseDetail = event.detail;
			break;
			case 'OpenConfirmacao':
				this.passoConfirmacaoContestacao = true;
				// this.baseDetail = event.detail;
			break;
			case 'OpenReembolso':
				this.passoReembolso = true;
				// this.baseDetail = event.detail;
			break;
			case 'OpenPDF':
				Utils.showToast(this, "error", null, "Nao implantado");
			break;
			default:
				this.passoListaFaturas = true;
				break;
		}
	}
	finishContestation(event) {
		Utils.showToast(this, "success", null, "Contestação finalizada com sucesso");
		this.changeStep(event, 'OpenFaturas');

	}
}