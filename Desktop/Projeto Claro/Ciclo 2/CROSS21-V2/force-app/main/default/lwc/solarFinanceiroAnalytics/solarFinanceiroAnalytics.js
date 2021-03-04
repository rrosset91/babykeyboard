/**
 * @description       : Classe js responsável pelo cmponente de comparação entre faturas
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
export default class SolarFinancialAnalytics extends LightningElement {
	@api
	comparisonData;
	@track baseAttributes;
	//CONTROLE DE INTERFACE
	@track uiProperties = {
		generalUi: {
			isLoading: false,
			hasError: false,
			show: false
		}
	};

	//DADOS PARA EXIBIÇÃO
	@track mock = true;
	@track invoicesData = {};
	@track columns = {};
	@track content = {
		details: []
	};
	//VARIÁVEIS DE COMPARAÇÃO ENTRE FATURAS
	@track invoicesDifference;
	@track monthYearNewer;
	@track monthYearOlder;
	@track newerMonth;
	@track newerValue;
	@track olderMonth;
	@track olderValue;
	@track newerDueDate;
	@track olderDueDate;
	@track newerInvoiceNumber;
	@track olderInvoiceNumber;
	@track operatorCode;
	@track contractNumber;

	connectedCallback() {
		this.baseAttributes = JSON.stringify(this.comparisonData);
		console.log("DADOS PARA COMPARAÇÃO --->", JSON.parse(JSON.stringify(this.comparisonData)));
		this.setColumns();
		if (this.mock) {
			this.showMockData();
			this.uiProperties.generalUi.isLoading = true;
		} else {
			this.uiOrchestrer("general", "isLoading");
		}
		this.invoicesData = this.comparisonData;
		console.log("Componente carregado. Dados para análise", Utils.jsonLogger(this.invoicesData));
		this.checkInvoicesBasicInfos();
	}

	async renderedCallback() {
		const diff = await this.getInvoicesDifference();
		if (diff > 0) {
			let elements = this.template.querySelectorAll(`[data-id="value-resume"]`);
			elements.forEach((element) => {
				element.classList.add("card-infos");
				element.classList.add("resume-positive");
			});
		} else {
			let elements = this.template.querySelectorAll(`[data-id="value-resume"]`);
			elements.forEach((element) => {
				element.classList.add("card-infos");
			});
		}
	}
	//COMPARATIVO GERAL ENTRE FATURAS (diferença de valores)
	getInvoicesDifference() {
		const newerInvoice = this.comparisonData.invoicesDataToCompare[0];
		const olderInvoice = this.comparisonData.invoicesDataToCompare[1];
		const difference = Number(newerInvoice.invoice.valor.replace("R$", "")) - Number(olderInvoice.invoice.valor.replace("R$", ""));
		const upArrow = String.fromCharCode(8593);
		const downArrow = String.fromCharCode(8595);
		difference > 0 ? (this.valueSummaryChange = upArrow) : (this.valueSummaryChange = downArrow);
		this.invoicesDifference = difference;
		return difference;
	}

	//COMPARATIVO GERAL ENTRE FATURAS
	checkInvoicesBasicInfos() {
		let newerInvoice = this.comparisonData.invoicesDataToCompare[0];
		let olderInvoice = this.comparisonData.invoicesDataToCompare[1];
		this.operatorCode = this.comparisonData.operatorCode;
		this.contractNumber = this.comparisonData.contractNumber;
		let validComparison = this.checkValidDataForCompare(newerInvoice, olderInvoice);
		if (validComparison) {
			let newerDueDate = newerInvoice.invoice.dataVencimento;
			this.newerDueDate = newerDueDate;
			let [newerDay, newerMonth, newerYear] = newerDueDate.split("/");
			let newerInvoiceNumber = newerInvoice.invoice.idFatura;
			this.newerMonth = this.getMonth("full", newerMonth);
			this.smallNewerMonth = this.getMonth("parcial", newerMonth);
			this.newerInvoiceNumber = newerInvoiceNumber;
			this.newerValue = Number(newerInvoice.invoice.valor.replace("R$", ""));
			this.monthYearNewer = `${this.smallNewerMonth} ${newerYear}`;

			let olderDueDate = olderInvoice.invoice.dataVencimento;
			this.olderDueDate = olderDueDate;
			let [olderDay, olderMonth, olderYear] = olderDueDate.split("/");
			let olderInvoiceNumber = olderInvoice.invoice.idFatura;
			this.olderMonth = this.getMonth("full", olderMonth);
			this.smallOlderMonth = this.getMonth("parcial", olderMonth);
			this.olderInvoiceNumber = olderInvoiceNumber;
			this.olderValue = Number(olderInvoice.invoice.valor.replace("R$", ""));
			this.monthYearOlder = `${this.smallOlderMonth} ${olderYear}`;
			this.uiOrchestrer("general", "show");
		} else {
			this.uiOrchestrer("general", "hasError");
		}
	}

	//FUNÇÃO PARA CHECAR SE AMBAS AS FATURAS POSSUEM TODOS OS ATRIBUTOS NECESSÁRIOS PARA COMPARAÇÃO
	checkValidDataForCompare(newerInvoice, olderInvoice) {
		if (
			!Utils.isEmptyString(newerInvoice.invoice.dataVencimento) &&
			!Utils.isEmptyString(newerInvoice.invoice.valor) &&
			!Utils.isEmptyString(newerInvoice.invoice.idFatura) &&
			!Utils.isEmptyString(olderInvoice.invoice.dataVencimento) &&
			!Utils.isEmptyString(olderInvoice.invoice.valor) &&
			!Utils.isEmptyString(olderInvoice.invoice.idFatura)
		) {
			return true;
		} else {
			return false;
		}
	}
	getMonth(mode, monthNumber) {
		if (mode === "full") {
			return Utils.getPtBrMonthName(monthNumber);
		} else if (mode === "parcial") {
			let month = Utils.getPtBrMonthName(monthNumber);
			return month.slice(0, 3).toUpperCase();
		} else {
			return;
		}
	}

	//FUNÇÃO PARA DEFINIR AS COLUNAS DO COMPONENTE
	setColumns() {
		this.columns.details = [
			{
				label: "ITEM",
				fieldName: "item",
				type: "text",
				sortable: false,
				hideDefaultActions: true,
				wrapText: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "RESULTADO DA ANÁLISE",
				fieldName: "analysisResult",
				type: "text",
				sortable: false,
				hideDefaultActions: true,
				wrapText: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "MÊS DA FATURA",
				fieldName: "invoiceMonth",
				type: "text",
				fixedWidth: 120,
				sortable: false,
				hideDefaultActions: true,
				wrapText: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "VALOR DO ITEM DA FATURA MAIS ANTIGA",
				fieldName: "olderInvoiceValue",
				type: "currency",
				sortable: false,
				fixedWidth: 400,
				hideDefaultActions: true,
				wrapText: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "DIFERENÇA",
				fieldName: "difference",
				type: "currency",
				sortable: false,
				fixedWidth: 90,
				hideDefaultActions: true,
				wrapText: true,
				cellAttributes: { class: { fieldName: "cellClass" }, alignment: "left" }
			},
			{
				type: "button-icon",
				fixedWidth: 90,
				typeAttributes: {
					iconName: "utility:preview",
					name: "view_invoice_modal",
					title: "View",
					variant: "brand-outline",
					alternativeText: "Visualizar",
					disabled: false
				}
			}
		];
		this.columns.events = [
			{
				label: "TIPO",
				fieldName: "eventType",
				type: "text",
				sortable: false,
				wrapText: true,
				hideDefaultActions: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "EVENTO",
				fieldName: "eventDescription",
				type: "text",
				wrapText: true,
				sortable: false,
				hideDefaultActions: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "DATA DE EXECUÇÃO",
				fieldName: "eventDate",
				type: "text",
				wrapText: true,
				sortable: false,
				hideDefaultActions: true,
				cellAttributes: { alignment: "left" }
			},
			{
				label: "CONTEÚDO/ARTIGO RELACIONADO AO EVENTO",
				fieldName: "eventKB",
				wrapText: true,
				type: "url",
				sortable: false,
				hideDefaultActions: true,
				typeAttributes: {
					label: { fieldName: "nameKB" },
					target: "_self"
				}
			},
			{
				type: "button-icon",
				fixedWidth: 90,
				typeAttributes: {
					iconName: "utility:preview",
					name: "view_event_modal",
					title: "View",
					variant: "brand-outline",
					alternativeText: "Visualizar",
					disabled: false
				}
			}
		];
	}

	//MÉTODOs / FUNÇÕES PARA INTERFACE E NAVEGABILIDADE, INCLUINDO MOCK
	handleBackComparison() {
		const handleBackEvent = new CustomEvent("closecomparison", { detail: {} });
		this.dispatchEvent(handleBackEvent);
		this.dispatchEvent(new CustomEvent("backfaturas", { detail: {} }));
	}

	//ORQUESTRADOR DA INTERFACE DE USUÁRIO
	uiOrchestrer(element, context) {
		if (element == "general") {
			switch (context) {
				case "hasError":
					this.uiProperties.generalUi.hasError = true;
					this.uiProperties.generalUi.show = false;
					this.uiProperties.generalUi.isLoading = false;
					break;
				case "isLoading":
					this.uiProperties.generalUi.hasError = false;
					this.uiProperties.generalUi.show = false;
					this.uiProperties.generalUi.isLoading = true;
					break;
				case "show":
					this.uiProperties.generalUi.hasError = false;
					this.uiProperties.generalUi.show = true;
					this.uiProperties.generalUi.isLoading = false;
					break;
				default:
					break;
			}
		} else {
			console.log("Erro de interface não mapeado");
		}
	}

	//EXIBIÇÃO DE DADOS MOCKADOS PARA EFEITOS DE TESTE E DESENVOLVIMENTO
	showMockData() {
		this.uiOrchestrer("general", "show");
	}
}