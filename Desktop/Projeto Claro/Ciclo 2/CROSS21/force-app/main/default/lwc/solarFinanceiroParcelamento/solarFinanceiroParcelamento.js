/**
 * @description       : Componente responsável por exibir as opcoes de parcelamento para negociacao
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociacao
 * @last modified on  : 20-01-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   12-01-2021   Roger Rosset   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import getInstallmentsOptions from "@salesforce/apex/FinancialNegotiationInstallment.getInstallmentPlan";
import getInstallmentValues from "@salesforce/apex/FinancialNegotiationInstallment.getInstallmentValues";

export default class SolarFinanceiroParcelamento extends LightningElement {
	@api
	baseAttributes;
	@api
	negotiationAmount;

	@track uiProperties = {
		dataTable: {
			isLoading: false,
			hasError: false,
			show: false,
			columns: [
				{
					label: "Mês",
					fieldName: "dueMonth",
					type: "text",
					sortable: false,
					hideDefaultActions: true
				},
				{
					label: "Parcela",
					fieldName: "installmentNumber",
					type: "text",
					sortable: false,
					hideDefaultActions: true
				},
				{
					label: "Valor",
					fieldName: "installmentValue",
					type: "currency",
					sortable: false,
					hideDefaultActions: true
				}
			]
		},
		generalUi: {
			isLoading: false,
			hasError: false,
			show: false
		},
		installmentOptions: {
			show: false,
			isLoading: false,
			hasError: false
		},
		modal: {
			message: undefined
		}
	};

	@track hasAuthority;
	@track selectedInstallment;
	@track installmentsOptions = [];
	@track installmentsValues = [];
	@track availableOptions = {};
	@track mock = true;

	connectedCallback() {
		this.uiProperties.generalUi.isLoading = true;
		this.uiProperties.installmentOptions.isLoading = true;
		this.fetchInstallmentOptions();
	}

	fetchInstallmentOptions() {
		let caseId;
		let bills;
		let statements;
		let negotiationValue;
		if (this.mock) {
			caseId = "5000n000008sadSAAQ";
			bills = [];
			statements = [];
			negotiationValue = "10.00";
		} else {
			negotiationValue = this.negotiationAmount.replace("R$", "");
			negotiationValue = negotiationValue.replace(",", ".");
			negotiationValue = negotiationValue.replace(" ", "");
			caseId = this.baseAttributes.caseId;
			bills = this.baseAttributes.bills;
			statements = this.baseAttributes.statements;
		}
		getInstallmentsOptions({
			caseId: caseId,
			bills: bills,
			statements: statements,
			valorNegociacao: negotiationValue
		})
			.then((success) => {
				if (Utils.jsonLogger(success.alcada) && Utils.jsonLogger(success.success)) {
					console.log("SUCESSO - CARREGANDO OPCOES");
					console.log(Utils.jsonLogger(success.dadosParcelamento));
					this.hasAuthority = true;
					this.uiProperties.generalUi.hasError = false;
					this.show("general");
					this.installmentsOptions = this.treatOptions(success.dadosParcelamento, "installmentOptions");
					this.show("installments");
				} else {
					console.log("ERRO - SEM ALCADA");
					this.uiProperties.generalUi.isLoading = false;
					this.uiProperties.generalUi.hasError = true;
					this.hasAuthority = false;
					this.uiProperties.installmentOptions.isLoading = false;
					this.errorHandler("Usuário sem alçada", "modal");
				}
			})

			.catch((error) => {
				console.log("ERRO - CHAMADA NAO REALIZADA");
				this.uiProperties.generalUi.isLoading = false;
				this.uiProperties.generalUi.hasError = true;
				this.installmentsOptions = [];
				this.uiProperties.installmentOptions.isLoading = false;
				this.errorHandler("Erro na chamada", "toast");
			});
	}

	handleInstallmentSelection(event) {
		let installmentId = event.currentTarget.id.split("-")[0];
		let frontId = event.currentTarget.id;
		console.log(installmentId);
		let allOptions = this.template.querySelectorAll('[data-id="installmentOption"]');
		allOptions.forEach((option) => {
			let usedClasses = [];
			let appliedClasses = option.classList;
			appliedClasses.forEach((usedClass) => {
				usedClasses.push(usedClass);
			});
			if (!usedClasses.includes("installment-selected") && option.id == frontId) {
				option.classList.remove("installment-option");
				option.classList.add("installment-selected");
			} else if (usedClasses.includes("installment-selected") && option.id != frontId) {
				option.classList.add("installment-option");
				option.classList.remove("installment-selected");
			}
		});
		this.uiProperties.dataTable.show = false;
		this.uiProperties.dataTable.isLoading = true;

		this.installmentsOptions.forEach((x) => {
			if (x.installmentId == installmentId) {
				this.selectedInstallment = x.details;
			}
		});
		this.fetchInstallmentValues();
	}

	fetchInstallmentValues() {
		let selectedInstallment;
		if (this.mock) {
			selectedInstallment = "mock";
		} else {
			selectedInstallment = JSON.stringify(this.selectedInstallment);
		}
		getInstallmentValues({
			request: selectedInstallment
		})
			.then((success) => {
				if (Utils.jsonLogger(success.success)) {
					this.installmentsValues = this.treatOptions(success.dadosParcelamento, "installmentValues");
					this.uiProperties.dataTable.hasError = false;
					this.show("datatable");
					console.log("sucesso, datatable");
				} else {
					this.uiProperties.dataTable.isLoading = false;
					this.uiProperties.dataTable.hasError = true;
					this.errorHandler("Erro ao consultar os detalhes do parcelamento", "toast");
					console.log("erro, datatable");
				}
			})

			.catch((error) => {
				console.log("erro, datatable, retornou erro", error);
				this.installmentsValues = [];
				this.uiProperties.dataTable.hasError = true;
				this.uiProperties.dataTable.isLoading = false;
				this.errorHandler("Erro ao consultar os detalhes do parcelamento: " + error.errorMessage, "toast");
			});
	}

	treatOptions(data, context) {
		let treatedData = Utils.jsonLogger(data);
		switch (context) {
			case "installmentOptions":
				let installmentsList = [];
				treatedData.forEach((parcela, index) => {
					let installmentId = "installment" + index;
					parcela.installmentId = installmentId;
					let details = {};
					details.ofertaParcelamento = parcela.ofertaParcelamento;
					details.descontoParcelamento = parcela.descontoParcelamento;
					details.quantidadeParcelamento = parcela.quantidadeParcelamento;
					details.valorDesconto = parcela.valorDesconto;
					details.porcentagemDesconto = parcela.porcentagemDesconto;
					details.primeiroVencimento = parcela.primeiroVencimento;

					parcela.details = details;
					installmentsList.push(parcela);
				});
				return installmentsList;
			case "installmentValues":
				let installmentDetails = [];
				let totalInstallments = treatedData.parcelas.length;
				treatedData.parcelas.forEach((parcela) => {
					let dueMonth = parcela.vencimento.split("/")[1];
					console.log("MES", dueMonth);
					parcela.dueMonth = Utils.getPtBrMonthName(dueMonth);
					console.log(parcela.vencimento);
					parcela.installmentNumber = `${Number(parcela.numeroParcela) + 1}/${totalInstallments}`;
					parcela.installmentValue = parcela.valorParcela;
					installmentDetails.push(parcela);
				});
				return installmentDetails;
			default:
				break;
		}
		return treatedData;
	}

	errorHandler(message, errorType) {
		if (errorType == "toast") {
			Utils.showToast(this, "error", null, message);
			return;
		} else if (errorType == "modal") {
			this.uiProperties.modal.message = message;
			this.show("modal");
			return;
		} else {
			return;
		}
	}

	show(component) {
		switch (component) {
			case "general":
				this.uiProperties.generalUi.isLoading = false;
				this.uiProperties.generalUi.show = true;
				break;
			case "installments":
				this.uiProperties.installmentOptions.isLoading = false;
				this.uiProperties.installmentOptions.show = true;
				break;
			case "datatable":
				this.uiProperties.dataTable.isLoading = false;
				this.uiProperties.dataTable.show = true;
				break;
			case "modal":
				this.uiProperties.generalUi.show = false;
				this.template.querySelector("c-solar-modal").open();
				break;
			default:
				break;
		}
	}

	handleBack() {
		this.template.querySelector("c-solar-modal").close();
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("opennegociacao", { detail: selectedBill }));
	}

	submitNegotiation() {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("openresumonegociacao", { detail: selectedBill }));
	}
}
