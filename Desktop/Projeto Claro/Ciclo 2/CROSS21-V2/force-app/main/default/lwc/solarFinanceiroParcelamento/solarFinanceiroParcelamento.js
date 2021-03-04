/**
 * @description       : Componente responsável por exibir as opcoes de parcelamento para negociacao
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociacao
 * @last modified on  : 08-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   12-01-2021   Roger Rosset   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Utils from "c/solarUtils";
import getInstallmentsOptions from "@salesforce/apex/FinancialNegotiationInstallment.getInstallmentPlan";
import getInstallmentValues from "@salesforce/apex/FinancialNegotiationInstallment.getInstallmentValues";
export default class SolarFinanceiroParcelamento extends NavigationMixin(LightningElement) {
	@api
	baseAttributes;
	@api
	negotiationAmount;
	@api
	baseDetail;

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
					hideDefaultActions: true,
					cellAttributes: { alignment: "left" }
				},
				{
					label: "Parcela",
					fieldName: "installmentNumber",
					type: "text",
					sortable: false,
					hideDefaultActions: true,
					// cellAttributes: { alignment: "left" }
					cellAttributes: { class: 'installment-column'}

				},
				{
					label: "Valor",
					fieldName: "installmentValue",
					type: "currency",
					sortable: false,
					hideDefaultActions: true,
					// cellAttributes: { alignment: "left" },
					cellAttributes: { class: 'value-column'}
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
	@track alcadaAprovada;
	@track negotiationAmount;
	@track negotiatedValue;
	@track negotiationConditions;
	@track selectedInstallment;
	@track installmentsOptions = [];
	@track installmentsValues = [];
	@track availableOptions = {};
	@track mock = false;

	//Ao carregar, ativa o spinner geral e chama o método backend para trazer as opçoes de parcelamento
	connectedCallback() {
		this.uiProperties.generalUi.isLoading = true;
		this.uiProperties.installmentOptions.isLoading = true;
		this.fetchInstallmentOptions();
	}

	//Função pra trazer do apex as opçoes de parcelamento disponíveis
	fetchInstallmentOptions() {
		console.log("@@@ Debug da variavel: this.baseAttributes", JSON.parse(JSON.stringify(this.baseAttributes)));
		console.log("@@@ Debug da variavel: this.baseDetail", JSON.parse(JSON.stringify(this.baseDetail)));
		getInstallmentsOptions({
			stringBaseAtributes: JSON.stringify(this.baseAttributes),
			stringBaseDetail: JSON.stringify(this.baseDetail)
		})
			.then((success) => {
				console.log("@@@ Debug da variavel: success", JSON.parse(JSON.stringify(success)));
				if (success.alcada) {
					console.log("SUCESSO - CARREGANDO OPCOES");
					console.log(Utils.jsonLogger(success.dadosParcelamento));
					this.hasAuthority = true;
					this.uiProperties.generalUi.hasError = false;
					this.show("general");
					this.installmentsOptions = this.treatOptions(success.dadosParcelamento, "installmentOptions");
					this.negotiationAmount = this.baseDetail.fullSumSelectedItems;
					this.alcadaAprovada = success.alcadaAprovada;
					this.show("installments");
				} else {
					console.log("ERRO - SEM ALCADA");
					this.uiProperties.generalUi.isLoading = false;
					this.uiProperties.generalUi.hasError = true;
					this.hasAuthority = false;
					this.uiProperties.installmentOptions.isLoading = false;
					this.errorHandler("Usuário sem alçada " + success.errorMessage, "modal");
				}
			})
			.catch((error) => {
				console.log("@@@ Debug da variavel: error", JSON.parse(JSON.stringify(error)));
				console.log("ERRO - CHAMADA NAO REALIZADA", error);
				this.uiProperties.generalUi.isLoading = false;
				this.uiProperties.generalUi.hasError = true;
				this.installmentsOptions = [];
				this.uiProperties.installmentOptions.isLoading = false;
				this.errorHandler("Erro na chamada: " + error, "toast");
				setTimeout(() => {
					this.exitToCase();
				}, 2000);
			});
	}

	//Função resopnsável por monitorar a opção escolhida
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

		console.log("@@@ Debug da variavel: this.installmentsOptions", JSON.parse(JSON.stringify(this.installmentsOptions)));
		console.log("@@@ Debug da variavel: installmentId", JSON.parse(JSON.stringify(installmentId)));

		this.installmentsOptions.forEach((x) => {
			if (x.installmentId == installmentId) {
				this.selectedInstallment = { ...x.details };
			}
		});

		console.log("@@@ Debug da variavel: this.selectedInstallment", JSON.parse(JSON.stringify(this.selectedInstallment)));
		this.fetchInstallmentValues();
	}

	//Função responsável por buscar no backend os detalhes da opção de parcelamento escolhida
	fetchInstallmentValues() {
		this.baseDetail = { ...this.baseDetail, selectedInstallment: this.selectedInstallment };
		console.log("baseAttributes", JSON.stringify(this.baseAttributes));
		console.log("baseDetail", JSON.stringify(this.baseDetail));

		getInstallmentValues({
			stringBaseAtributes: JSON.stringify(this.baseAttributes),
			stringBaseDetail: JSON.stringify(this.baseDetail)
		})
			.then((success) => {
				if (success) {
					this.installmentsValues = this.treatOptions(success.installmentValues, "installmentValues");
					this.uiProperties.dataTable.hasError = false;
					this.show("datatable");
					console.log("sucesso, datatable");
					this.baseDetail.tableData = this.installmentsValues;
				} else {
					this.uiProperties.dataTable.isLoading = false;
					this.uiProperties.dataTable.hasError = true;
					this.errorHandler("Erro ao consultar os detalhes do parcelamento: " + success.errorMessage, "toast");
					console.log("erro, datatable");
					setTimeout(() => {
						this.exitToCase();
					}, 2000);
				}
			})

			.catch((error) => {
				console.log("erro, datatable, retornou erro", error);
				this.installmentsValues = [];
				this.uiProperties.dataTable.hasError = true;
				this.uiProperties.dataTable.isLoading = false;
				this.errorHandler("Erro ao consultar os detalhes do parcelamento: " + error, "toast");
				setTimeout(() => {
					this.exitToCase();
				}, 2000);
			});
	}

	//Função responsável por tratar o retorno do backend
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
				console.log("DADOS PARA TRATAR--->", treatedData);
				let installmentDetails = [];
				let totalInstallments = treatedData.parcelas.length;
				let installmentTotalValue;
				this.negotiatedValue = 0;
				this.baseDetail.apiData = treatedData.apiData;

				treatedData.parcelas.forEach((parcela) => {
					let dueMonth = parcela.vencimento.split("/")[1];
					console.log("MES", dueMonth);
					parcela.dueMonth = Utils.getPtBrMonthName(dueMonth);
					console.log(parcela.vencimento);
					parcela.installmentNumber = `${Number(parcela.numeroParcela)}/${totalInstallments}`;
					parcela.installmentValue = parcela.valorTotal;
					installmentTotalValue = parcela.valorTotal;
					this.negotiatedValue = this.negotiatedValue + parcela.valorTotal;
					installmentDetails.push(parcela);
				});
				installmentTotalValue = this.negotiatedValue / totalInstallments;
				this.negotiationConditions = `${totalInstallments}x`;
				// this.negotiationConditions = `${totalInstallments}x ${installmentTotalValue}`;
				this.submitInfos();
				return installmentDetails;
			default:
				break;
		}
		return treatedData;
	}

	//Função para ativar ou desativar os componentes na tela
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

	//Função para lidar com erros, tipo modal ou toast
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

	exitToCase() {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: this.baseAttributes.caseId,
				objectApiName: "Case",
				actionName: "view"
			}
		});
	}

	submitInfos() {
		let negotiationConditions = this.negotiationConditions;
		let columns = this.uiProperties.dataTable.columns;
		this.baseDetail.negotiationConditions = negotiationConditions;
		this.baseDetail.negotiatedValue = this.negotiatedValue;
		this.baseDetail.columns = columns;
		this.baseDetail.alcadaAprovada = this.alcadaAprovada;
	}

	handleBack() {
		this.template.querySelector("c-solar-modal").close();
		this.dispatchEvent(new CustomEvent("opennegociacao"));
	}
	handleBackModal() {
		this.template.querySelector("c-solar-modal").close();
		this.exitToCase();
	}

	submitNegotiation() {
		console.log("BaseDetails Enviado pelo evento ---->", Utils.jsonLogger(this.baseDetail));
		this.dispatchEvent(new CustomEvent("openresumonegociacao", { detail: this.baseDetail }));
	}
}