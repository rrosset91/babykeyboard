/**
 * @description       : Componente responsável pela exibição da comparação entre faturas de 2 meses
 * @author            : Roger Rosset
 * @group             :
 * @last modified on  : 18-02-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-02-2021   Roger Rosset   Initial Version
 **/
import { LightningElement, track, api } from "lwc";
import Utils from "c/solarUtils";
import getDetails from "@salesforce/apex/FinancialInvoiceDiagnostic.compareInvoices";

export default class SolarAutomaticDetailsAnalysis extends LightningElement {
	@api
	columns = [];
	@api
	comparisonData;
	@api
	operatorCode;
	@api
	contractNumber;
	@api
	newerInvoiceNumber;
	@api
	oldestInvoiceNumber;
	@track
	modalData = [];
	@track
	allDetails = [];
	@track isLoading = false;
	@track hasError = false;
	@track isEmpty = false;
	@track show = false;
	@track modalItem = {};
	@track mock = false;
	@track modalData = [];

	async connectedCallback() {
		if (!this.mock) {
			this.uiHandler("isLoading");
			const params = this.setParams();
			getDetails(params)
				.then((result) => {
					console.log("result", result);
					if (result.length > 0) {
						this.allDetails = this.treatData(result);
						this.uiHandler("show");
					} else {
						this.uiHandler("isEmpty");
					}
				})
				.catch((error) => {
					console.log("err", error);
					this.uiHandler("hasError");
					if (!Utils.isEmptyString(error.body.message)) {
						Utils.showToast(this, "error", null, error.body.message);
					} else {
						Utils.showToast(this, "error", null, error);
					}
				});
		} else {
			this.showMockData();
		}
	}
	//FUNÇÃO RESPONSÁVEL POR GERAR OS PARÂMETROS PARA CHAMADA NO BACKEND
	setParams() {
		let params = {};
		params.operatorCode = this.operatorCode;
		params.contractNumber = this.contractNumber;
		params.newerInvoiceNumber = this.newerInvoiceNumber;
		params.oldestInvoiceNumber = this.oldestInvoiceNumber;
		return params;
	}
	//TRATAMENTO DOS DADOS RETORNADOS
	treatData(data) {
		data.forEach((row) => {
			if (parseFloat(row.difference) > 0) row.cellClass = "slds-text-color_error";
			console.log("O VALOR É MENOR QUE ZERO");
		});
		return data;
	}
	//HANDLER PARA AÇÃO DE LINHA DA TABELA DE DETALHES
	handleRowAction(event) {
		this.modalItem = event.detail.row.productDetails;
		this.setModalTemplate();
		this.template.querySelector("c-solar-modal").open();
		console.log("MODAL ITEM AO ABRIR--->", JSON.parse(JSON.stringify(this.modalItem)));
	}

	//FUNÇÃO PARA FECHAR E RESETAR O MODAL
	handleCloseModal() {
		this.modalItem = {};
		this.modalData = [];
		this.template.querySelector("c-solar-modal").close();
		console.log("MODAL ITEM AO FECHAR--->", JSON.parse(JSON.stringify(this.modalItem)));
	}

	//FUNÇÃO PARA GERAR DADOS MOCKADOS PARA EXIBIÇÃO
	showMockData() {
		this.uiHandler("show");
		this.allDetails = [
			{
				item: "Maria e João - O Conto das Bruxas",
				analysisResult: "Este item existe na fatura do mês de outubro e não foi cobrado na fatura de novembro",
				invoiceMonth: "Outubro",
				idItem: "2192746421",
				olderInvoiceValue: 7.45,
				difference: -7.45,
				productDetails: {
					dataVencimento: "07/01/2021",
					dataProporcionalidade: "07/12/2020",
					dataLancamento: "07/11/2020",
					totalParcela: 1,
					numeroParcela: 1,
					descricao: "PPV Avulso",
					descricaoProduto: "Contratação de PPV Avulso - João e Maria",
					parceiro: "NET"
				}
			},
			{
				item: "O Poço",
				analysisResult: "Este item existe na fatura do mês de novembro e não foi cobrado na fatura de outubro",
				invoiceMonth: "Outubro",
				idItem: "3812361421",
				olderInvoiceValue: -19.45,
				difference: 19.45,
				productDetails: {
					dataVencimento: "01/02/2021",
					dataProporcionalidade: "05/04/2021",
					dataLancamento: "01/01/2021",
					totalParcela: 10,
					numeroParcela: 2,
					descricao: "PPV Avulso",
					descricaoProduto: "Contratação de PPV Avulso - O Poço",
					parceiro: "NET"
				}
			}
		];
		let dataToTreat = this.allDetails;
		this.allDetails = this.treatData(dataToTreat);
	}
	uiHandler(mode) {
		switch (mode) {
			case "show":
				this.show = true;
				this.hasError = false;
				this.isLoading = false;
				this.isEmpty = false;
				break;
			case "isLoading":
				this.show = false;
				this.hasError = false;
				this.isLoading = true;
				this.isEmpty = false;
				break;
			case "isEmpty":
				this.show = false;
				this.hasError = false;
				this.isLoading = false;
				this.isEmpty = true;
				break;
			case "hasError":
				this.show = false;
				this.hasError = true;
				this.isLoading = false;
				this.isEmpty = false;
				break;
			default:
				break;
		}
	}
	//ESPECIFICAÇÃO DOS CAMPOS E LABELS CORRESPONDENTES PARA USO NO COMPONENTE MODAL-DATA-DISPLAY
	setModalTemplate() {
		this.modalData.push({ label: "Item de Extrato", fieldName: this.modalItem.descricao });
		this.modalData.push({ label: "Parceiro", fieldName: this.modalItem.parceiro });
		this.modalData.push({ label: "Produto", fieldName: this.modalItem.descricaoProduto });
		this.modalData.push({ label: "Data de Lançamento", fieldName: this.modalItem.dataLancamento });
		this.modalData.push({ label: "Data de Vencimento", fieldName: this.modalItem.dataVencimento });
		this.modalData.push({ label: "Data Início Proporcionalidade", fieldName: this.modalItem.dataProporcionalidade });
		this.modalData.push({ label: "Total de Parcelas", fieldName: this.modalItem.totalParcela });
		this.modalData.push({ label: "Número da Parcela", fieldName: this.modalItem.numeroParcela });
	}
}