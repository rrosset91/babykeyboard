/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 06-11-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   06-11-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api } from "lwc";
import Utils from "c/solarUtils";
import getHistoryByDatePeriod from "@salesforce/apex/LancamentosFuturosController.getHistoryByDatePeriod";
export default class SolarResLancamentosFuturos extends LightningElement {
	@api baseAttributes; //EX: {"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","customerAccountSalesforceId":"0011g00000pnn9pAAA","isCase":false,"isMobileContract":false,"isN2User":false,"isViewOnly":true,"operatorId":"005","recordId":"0011g00000pmhAeAAI"}
	dataOnTable; //dados filtrados ou não para o data table
	dataAll; //cópia de todos os dados do data table para refresh caso necessário
	selectedDataRow = {}; // ao clicar no botão "Mais informações", esse atributo é preenchido com o lançamento escolhido
    loading; //atributo de controle para mostrar ou não o spinner
    hasData; //atributo de controle para mostrar ou não o conteúdo
	//estrutura de colunas para o datatable
	columns = [
		{ label: "TIPO", fieldName: "description", type: "text", hideDefaultActions: true, sortable: true },
		{ label: "DATA DE LANÇAMENTO", fieldName: "formattedBillDate", type: "text", hideDefaultActions: true, sortable: true },
		{ label: "CONTESTÁVEL?", fieldName: "canContest", type: "text", hideDefaultActions: true, sortable: true },
		{ label: "CONTESTAÇÃO", fieldName: "contestacao", type: "text", hideDefaultActions: true, sortable: true },
		{ label: "VALOR", fieldName: "amountDue", type: "text", hideDefaultActions: true, sortable: true },
		{
			label: "",
			type: "button",
			typeAttributes: { label: "Mais informações", title: "Mais informações", name: "view_modal", iconName: "utility:preview", iconPosition: "left" }
		}
	];
	//do Init - no carregamento da page
	connectedCallback() {
        this.selectedDataRow = {};
		this.loading = true;
		let historyParams = {
			contractId: this.baseAttributes.contractId,
			operatorId: this.baseAttributes.operatorId,
			extractItemStatus: "FUTURE_RELEASE",
			period: 12,
			recordId: this.baseAttributes.recordId
		};
		//serverside callback - Promise
		getHistoryByDatePeriod(historyParams)
			.then((result) => {
                if(result){
                    if(result.events.length > 0){
                        let proccessedData = this.proccessDataEvents(result);
                        this.dataOnTable = proccessedData.events;
                        this.dataAll = proccessedData.events;
                        this.hasData = true;
                        this.loading = false;
                    }else{
                        this.hasData = false;
                        this.dataOnTable = [];
                        this.dataAll = [];
                    }
                }else{
                    this.hasData = false;
                    this.dataOnTable = [];
                    this.dataAll = [];
                }
				this.loading = false;
			})
			.catch((error) => {
				console.log(error);
                this.loading = false;
                this.hasData = false;
				Utils.showToast(this, "error", null, "Ops... Algo de errado aconteceu, por favor tente novamente");
			});
	}
	//processa os dados vindos do servidor para formatar datas, valores monetários e etc.
	proccessDataEvents(data) {
		data.events.forEach((x) => {
			let vencimento = x.paymentDueDate;
			vencimento = vencimento.split("T")[0];
			vencimento = vencimento.split("-");
			x.formattedDate = vencimento[2] + "/" + vencimento[1] + "/" + vencimento[0];
			let realDueDate = x.formattedDate.split("/");
			x.realDueDate = new Date(realDueDate[2], realDueDate[1], realDueDate[0]);

			let lancamento = x.billDate;
			lancamento = lancamento.split("T")[0];
			lancamento = lancamento.split("-");
			x.formattedBillDate = lancamento[2] + "/" + lancamento[1] + "/" + lancamento[0];
			let realBillDate = x.formattedBillDate.split("/");
			x.realBillDate = new Date(realBillDate[2], realBillDate[1], realBillDate[0]);

			let correctValue = x.amountDue.toFixed(2);
			x.amountDue = "R$" + correctValue;

			x.canContest = x.hasElegibility ? "Sim" : "Não";

			if (!x.productDescription) x.productDescription = "--";

			if (!x.installmentNumber) x.installmentNumber = "--";

			if (!x.installmentsCount) x.installmentsCount = "--";

			if (!x.installments) x.installments = "--";

			if (x.isSfPendingItem) {
				alreadyContestedItemsId.push(x.id);
				alreadyContestedItems.push(x);
			}
		});

		return data;
	}

	//função chamada no campo de busca, para filtrar os resultados em tela
	handleFiltroBusca(event) {
		//decidir se for usar a tecla enter para busca ou não
		/*const isEnterKey = event.keyCode === 13; //tecla enter
        if (isEnterKey) {}*/
		let lista = this.dataAll;
		let busca = event.target.value;
		let chave = "";
		let regex = /[áàâãéèêíìîóòôõúù]/g;
		let acento = busca != "" ? regex.test(busca) : false;
		if (lista.length > 0) {
			let filtrada = lista.filter(function (elem, index, array) {
				if (acento) {
					return elem.description.toUpperCase().startsWith(busca.toUpperCase()) || elem.description.toUpperCase().includes(busca.toUpperCase());
				} else {
					chave = elem.description.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
					busca = busca.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
					return chave.toUpperCase().startsWith(busca.toUpperCase()) || chave.toUpperCase().includes(busca.toUpperCase());
				}
			});
			let listaFiltrada = busca != "" ? filtrada : this.dataAll;
			this.dataOnTable = listaFiltrada;
		}
	}
	//ação de click do botão mais informalções
	handleRowAction(event) {
		const row = event.detail.row;
		this.selectedDataRow = row;
		this.handleOpenModal();
	}
	//abre modal
	handleOpenModal() {
		this.template.querySelector("c-solar-modal").open();
	}
	//fecha modal
	handleCloseModal() {
		this.template.querySelector("c-solar-modal").close();
	}
}