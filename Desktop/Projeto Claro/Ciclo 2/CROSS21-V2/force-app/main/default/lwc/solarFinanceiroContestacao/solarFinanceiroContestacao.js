/**
 * @description       :
 * @author            : Diogo Domingos
 * @group             :
 * @last modified on  : 07-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
 * 1.1   11-11-2020   Caio Cesar      layout de acordo com o perfil
 **/
import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import { NavigationMixin } from "lightning/navigation";
import getContestationReasons from "@salesforce/apex/FinancialMobileContestationReasons.getContestationReasons";

export default class solarFinanceiroContestacao extends NavigationMixin(LightningElement) {
	@api baseAttributes;
	@api baseDetail;
	@track layoutN2;
	@track labelButtonVoltar;
	@track labelTextArea;
	/*Lembrar de Tirar o exemplo*/ @track observacaoN1 =
		"Cliente alega que não tem mais pacotes PFC Premier, que seu ponto adicional já foi retirado e que o filme a la carte não foi contratado. Sobre a Virtua, Cliente informa que houve outage de 10 dias durante o mês.";
	@track error;
	@track data;
	@track selectedReason;
	@track calcSelected;
	@track value;
	@track motivoValue = {};
	@track modalItem = {};
	@track reasonContext = {};
	@track disableConfirmacao = false;
	@track readOnlyObservacao = false; // em teste
	@track readonly = false; // em teste
	@track readOnlyButton = false; // em teste
	@track calculoTipoDias = false;
	@track calculoTipoPorcentagem = false;
	@track hasData = false;
	@track hasError = false;
	columns = [
		{ label: "ITEM", fieldName: "item", type: "text", hideDefaultActions: true },
		{ label: "LINHA", fieldName: "linha", type: "text", hideDefaultActions: true },
		{ label: "SALDO", fieldName: "ajusteFormat", type: "Currency", hideDefaultActions: true },
		{ label: "VALOR ORIGINAL", fieldName: "valueFormat", type: "Currency", hideDefaultActions: true },
		{ label: "CALCULADORA", type: "button", initialWidth: 200, typeAttributes: { label: "Calcular por Dia ou %", variant: "destructive-text" }, hideDefaultActions: true },
		{
			label: "VALOR A CONTESTAR",
			fieldName: "valorContestar",
			type: "currency",
			typeAttributes: { currencyCode: "BRL", step: "0.01" },
			editable: true,
			hideDefaultActions: true
		},
		{ label: "VALOR CORRIGIDO", fieldName: "valorCorrigido", type: "currency", cellAttributes: { currencyCode: "BRL" }, hideDefaultActions: true },
		{
			label: "MOTIVO",
			type: "text",
			fieldName: "reasonLabel",
			hideDefaultActions: true
		},
		{
			label: "",
			type: "button",
			initialWidth: 140,
			typeAttributes: { label: "", name: "ItemMotivo", iconName: "utility:edit", alignment: "center" },
			hideDefaultActions: true
		},
		{ type: "button", initialWidth: 75, typeAttributes: { name: "Deletar", iconName: "utility:delete", variant: "destructive" }, hideDefaultActions: true }
	];
	filtersCalc = [
		{ label: "Cálculo por Dias", value: "Dias" },
		{ label: "Cálculo por Porcentagem", value: "Porcentagem" }
	];
	fixedReasons = [
		{ label: "Sistema", value: "system" },
		{ label: "Procedimento", value: "procedure" }
	];
	filtersMotivo = [];
	rawValues = {};
	valorMotivo = "";
	labelMotivo = "";
	groupValue = "";
	draftValues = [];
	@api
	selectedItems = [];
	@api
	comment = "";

	//Funcao para mudar layout de acordo com o nivel do usuario e invoice atrelado
	changeLayout() {
		if (this.baseAttributes.isN2User && this.baseAttributes.invoiceCase) {
			this.layoutN2 = true;
			this.labelButtonVoltar = "Ir para Fatura Completa";
			this.labelTextArea = "OBSERVAÇÃO DE FECHAMENTO";
		} else {
			this.labelButtonVoltar = "Voltar";
			this.labelTextArea = "OBSERVAÇÃO";
		}
	}

	//Se o Caso foi encerrado
	closeCase() {
		if (this.baseAttributes.statusCase === "Closed") {
			this.readOnlyObservacao = true;
			this.readonly = true;
			this.readOnlyButton = true;
		}
	}

	// **************** VALIDAÇÕES DA DATATABLE ****************

	// **************** DOINIT ****************
	connectedCallback() {
		this.changeLayout();
		this.closeCase();
		this.syncItems();
	}

	syncItems() {
		let newItems = JSON.parse(JSON.stringify(this.selectedItems));
		newItems.forEach((x) => {
			x.valueFormat = `R$ ${parseFloat(x.valor.toFixed(2))}`;
			x.ajusteFormat = `R$ ${parseFloat(x.ajuste.toFixed(2))}`;
		});
		this.data = newItems;
		this.hasData = true;
		this.obsValue = this.comment;
	}

	// **************** Botão SELECIONAR do DATATABLE ****************
	handleRowAction(event) {
		if (event.detail.action.name === "ItemMotivo") {
			this.modalItem = event.detail.row;
			this.openReasonsModal(this.modalItem);
		} else if (event.detail.action.label === "Calcular por Dia ou %") {
			this.modalItem = event.detail.row;
			this.template.querySelector('[data-id="modalCaculadora"]').open();
		} else if (event.detail.action.name === "Deletar") {
			this.deleteSelectedRow(event.detail.row);
		}
	}

	async openReasonsModal(item) {
		let hasError = false;
		this.isLoading = true;

		if (!item.chargeCode) {
			Utils.showToast(this, "error", null, "Item especificado não contém charge code.");
			return;
		}

		const data = await getContestationReasons({
			chargeCode: item.chargeCode
		}).catch((err) => {
			this.isLoading = false;
			hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (hasError) return;

		let procedureGroupN1 = [];
		for (const k in data.procedureGroupN1) if (Object.prototype.hasOwnProperty.call(data.procedureGroupN1, k)) procedureGroupN1.push({ label: k, value: data.procedureGroupN1[k] });

		let procedureGroupN2 = [];
		for (const k in data.procedureGroupN2) if (Object.prototype.hasOwnProperty.call(data.procedureGroupN2, k)) procedureGroupN2.push({ label: k, value: data.procedureGroupN2[k] });

		let systemGroupN1 = [];
		for (const k in data.systemGroupN1) if (Object.prototype.hasOwnProperty.call(data.systemGroupN1, k)) systemGroupN1.push({ label: k, value: data.systemGroupN1[k] });

		let systemGroupN2 = [];
		for (const k in data.systemGroupN2) if (Object.prototype.hasOwnProperty.call(data.systemGroupN2, k)) systemGroupN2.push({ label: k, value: data.systemGroupN2[k] });

		let groupsValues = {
			procedureGroupN1: procedureGroupN1,
			procedureGroupN2: procedureGroupN2,
			systemGroupN1: systemGroupN1,
			systemGroupN2: systemGroupN2
		};

		this.rawValues = groupsValues;
		console.log("@@@ Debug da variavel: groupsValues", JSON.parse(JSON.stringify(groupsValues)));
		this.isLoading = false;
		this.template.querySelector('[data-id="modalMotivo"]').open();
	}

	// **************** Botão SAVE do valor da contestação do DATATABLE ****************
	handleSave(event) {
		this.draftValues = event.detail.draftValues;
		const valueContestation = this.draftValues;
		let allItem = this.data;

		for (let x = 0; x < valueContestation.length; x++) {
			const draftValue = valueContestation[x];

			for (let y = 0; y < allItem.length; y++) {
				let allItemInstance = allItem[y];

				if (allItemInstance.chargeId != draftValue.chargeId) continue;

				if (draftValue.valorContestar < allItemInstance.currentTaxAmount) {
					//voltar para draftValue.valorContestar > allItemInstance.currentTaxAmount
					Utils.showToast(this, "error", null, "Não é possivel contestar um valor maior que o original.");
					return;
				}

				if (draftValue.valorContestar <= 0) {
					Utils.showToast(this, "error", null, "Não é possivel contestar um valor menor ou igual que zero.");
					return;
				}

				allItemInstance.valorCorrigido = allItemInstance.currentTaxAmount - parseFloat(draftValue.valorContestar).toFixed(2);
				allItemInstance.valorContestar = parseFloat(draftValue.valorContestar).toFixed(2);
				break;
			}
		}

		this.data = JSON.parse(JSON.stringify(allItem));
		this.draftValues = [];
	}

	// **************** DELETANDO A LINHA INTEIRA DO DATATABLE ****************
	deleteSelectedRow(deleteRow) {
		let newData = JSON.parse(JSON.stringify(this.data));
		newData = newData.filter((row) => row.chargeId !== deleteRow.chargeId);
		this.data = newData;
	}

	// **************** Validação no Observação e Botão NEXT ****************
	handleConfirmation() {
		let obsField = this.template.querySelector('[data-id="observacao"]').value;

		if (!obsField) {
			Utils.showToast(this, "error", null, "Campo de Observação, está vazio.");
			this.template.querySelector('[data-id="observacao"]').focus();
			return;
		}

		if (!this.validateItems()) {
			Utils.showToast(this, "error", null, "Preencha o valor e motivo de todos os itens selecionados para contestar.");
			return;
		}
		console.log("Selected data", this.data);
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("openconfirmation", { detail: selectedBill }));
	}

	validateItems() {
		let isValid = true;

		this.data.forEach((x) => {
			if (!x.reason || !x.valorContestar || !x.valorCorrigido) isValid = false;
		});

		return isValid;
	}

	// **************** Botão Back ****************
	handleVoltar() {
		this.comment = this.template.querySelector('[data-id="observacao"]').value;
		this.dispatchEvent(new CustomEvent("backdetails", { detail: { contestationItems: this.data, comment: this.comment } }));
	}

	// **************** Condição para cada opção na calculadora ****************
	handleChange(event) {
		this.calculoTipoDias = event.target.value === "Dias";
		this.calculoTipoPorcentagem = event.target.value === "Porcentagem";
	}

	// **************** Tratativa de erros com os input da Calculadora ****************
	validationValue() {
		console.log("Valor -> ", JSON.parse(JSON.stringify(this.modalItem)));
		let calcPerc = this.calculoTipoPorcentagem;
		let percVal = this.calculoTipoPorcentagem ? this.template.querySelector('[data-id="percentModalCalculo"]').value : 0;
		let daysVal = !this.calculoTipoPorcentagem ? this.template.querySelector('[data-id="qtdModalCalculo"]').value : 0;
		let allItems = this.data;
		let dataCalc = this.modalItem;
		let orgValue = JSON.parse(JSON.stringify(dataCalc.currentTaxAmount));
		let correctedValue = 0;

		if (calcPerc && percVal.includes) {
			percVal = percVal.replace(/,/g, ".");
			this.template.querySelector('[data-id="percentModalCalculo"]').value = percVal;
		}

		// Dias
		if (!calcPerc && daysVal > 30) {
			return Utils.showToast(this, "warning", null, "Dia inválido, o dia não pode ser maior que 30");
		}
		if (!calcPerc && daysVal <= 0) {
			return Utils.showToast(this, "warning", null, "Dia inválido, o dia não pode menor ou igual a 0");
		}

		// Porcentagem
		if (calcPerc && percVal > 100) {
			return Utils.showToast(this, "warning", null, "Porcentagem inválida, a porcentagem não pode ser maior que 100");
		}
		if (calcPerc && percVal <= 0) {
			return Utils.showToast(this, "warning", null, "Porcentagem inválida, a porcentagem não pode ser menor ou igual a zero");
		}

		if (calcPerc) {
			correctedValue = orgValue - (percVal / 100) * dataCalc.currentTaxAmount;
		} else {
			correctedValue = orgValue - (daysVal * dataCalc.currentTaxAmount) / 30;
		}

		if (correctedValue < 0) return Utils.showToast(this, "warning", null, "Valor inválido, o valor corrigido não pode ser negativo");

		let clonedAllItems = [];
		allItems.forEach((x) => {
			clonedAllItems.push(Object.assign({}, x));
		});

		clonedAllItems.forEach((z) => {
			if (z.chargeId === dataCalc.chargeId) {
				z.valorContestar = (orgValue - correctedValue).toFixed(2);
				z.valorCorrigido = correctedValue.toFixed(2);
			}
		});

		this.data = clonedAllItems;
	}

	handleChangeReason(event) {
		const selectedLabel = event.target.options.find((opt) => opt.value === event.detail.value).label;
		this.modalItem.reason = event.target.value;
		this.modalItem.reasonLabel = selectedLabel;
		this.valorMotivo = event.target.value;
	}

	// **************** Botão confirmar os input da Calculadora ****************
	saveCalculadora() {
		this.validationValue();
		this.calcSelected = null;
		this.calculoTipoPorcentagem = false;
		this.calculoTipoDias = false;
		this.template.querySelector('[data-id="modalCaculadora"]').close();
	}

	naoImplementado() {
		return Utils.showToast(this, "warning", null, "Não Implementado");
	}

	// **************** VALIDAÇÕES DO MODAL MOTIVO ****************

	// **************** Botão save do Motivo ****************
	handleSaveMotivo() {
		let valorMotivo = this.valorMotivo;
		let allItems = this.data;

		if (Utils.isEmptyString(valorMotivo)) {
			Utils.showToast(this, "warning", null, "Selecione um motivo válido para salvar.");
			return;
		}

		allItems.forEach((z) => {
			if (z.chargeId === this.modalItem.chargeId) z.reason = valorMotivo;
		});

		this.data = JSON.parse(JSON.stringify(allItems));
		this.template.querySelector('[data-id="modalMotivo"]').close();
		this.valorMotivo = null;
	}

	handleChangeGroup(event) {
		this.groupValue = event.target.value;
		let isN2 = this.baseAttributes.isN2User;

		if (event.target.value === "system") {
			this.filtersMotivo = isN2 ? this.rawValues.systemGroupN2 : this.rawValues.systemGroupN1;
		} else {
			this.filtersMotivo = isN2 ? this.rawValues.procedureGroupN2 : this.rawValues.procedureGroupN1;
		}
	}

	handleOpenTestModal(event) {
		this.template.querySelector('[data-id="modalSemAlcada"]').open();
	}

	handleCancelReason(event) {
		this.template.querySelector('[data-id="modalSemAlcada"]').close();
	}

	handleSaveReason(event) {
		this.template.querySelector('[data-id="modalSemAlcada"]').close();
	}
}