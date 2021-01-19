/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 19-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   04-11-2020   Joao Neves   Initial Version
 * 1.1   17-11-2020   Caio Cesar   Inclusao PDF
 **/
import { LightningElement, api, track } from "lwc";
import getInvoiceDetails from "@salesforce/apex/InvoicesController.getInvoiceDetails";
import { NavigationMixin } from "lightning/navigation";
import Utils from "c/solarUtils";

export default class SolarResDetalhesFatura extends NavigationMixin(LightningElement){
	@api
	baseAttributes = {};
	@api
	baseDetail = {};
	@api
	atributosEnviados = {};
	@track
	fullData = {};
	alreadyRendered = false;
	isLoading = false;
	@track
	sortedBy = "";
	@track
	sortedDirection = "";
	columns = [
		{ label: "Item", fieldName: "descricao", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Data Lançamento", fieldName: "dataLancamento", type: "text", hideDefaultActions: true, sortable: true, cellAttributes: { class: "table" } },
		{ label: "Valor", fieldName: "valor", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{
			type: "button",
			initialWidth: 185,
			typeAttributes: {
				label: "Mais Informações",
				title: "Ver Detalhe",
				name: "viewDetailModal",
				iconName: "utility:preview"
			}
		}
	];
	columnsDetails = [
		{ label: "Período", fieldName: "periodo", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Telefone Destino", fieldName: "telefoneDestino", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Local Destino", fieldName: "localDestino", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "País", fieldName: "pais", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Horário Início", fieldName: "horarioInicio", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Duração", fieldName: "duracao", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } },
		{ label: "Valor", fieldName: "valor", type: "text", sortable: true, hideDefaultActions: true, cellAttributes: { class: "table" } }
	];
	modalItem = {};
	pdfValue = "";

	async renderedCallback() {
		if (this.alreadyRendered) return;
		this.alreadyRendered = true;

		console.log("initDetails baseAttributes ->", JSON.parse(JSON.stringify(this.baseAttributes)));
		console.log("initDetails baseDetail ->", JSON.parse(JSON.stringify(this.baseDetail)));

		this.isLoading = true;
		await this.initDetails();
		this.isLoading = false;
	}

	async initDetails() {
		let hasError = false;

		const data = await getInvoiceDetails({
			contractNumber: this.baseAttributes.contractId,
			invoiceId: this.baseDetail.idFatura,
			operatorCode: this.baseAttributes.operatorId,
			infoDetailLevel: "DETAILS",
			recordId: this.baseAttributes.recordId,
			contestId: ""
		}).catch((err) => {
			Utils.showToast(this, "error", null, err.body.message);
			handleOpenFaturas();
			hasError = true;
		});

		if (hasError || !data.success) return;

		this.fullData = this.processData(data.invoiceDetails);
		this.atributosEnviados.externalId = this.baseDetail.idFatura;
		this.atributosEnviados.operatorCode = this.baseAttributes.operatorId;
		this.atributosEnviados.accountId = this.baseAttributes.contractId;

	}

	handleOpenFaturas() {
		this.dispatchEvent(new CustomEvent("backfaturas"));
	}

	handleSort(event, data) {
		this.sortedBy = event.detail.fieldName;
		this.sortedDirection = event.detail.sortDirection;

		let sortField = this.sortedBy;
		if (sortField == "valor") sortField = "realValue";
		else if (sortField == "dataLancamento") sortField = "rawLancamentoMilis";

		return Utils.sortData(sortField, this.sortedDirection, data);
	}

	handleSortTelevisao = (evt) => (this.fullData.lstTelevisao = this.handleSort(evt, this.fullData.lstTelevisao));

	handleSortInternet = (evt) => (this.fullData.lstInternet = this.handleSort(evt, this.fullData.lstInternet));

	handleSortTelefone = (evt) => (this.fullData.lstTelefone = this.handleSort(evt, this.fullData.lstTelefone));

	handleSortMovel = (evt) => (this.fullData.lstMovel = this.handleSort(evt, this.fullData.lstMovel));

	handleSortEventuais = (evt) => (this.fullData.lstItensEventuais = this.handleSort(evt, this.fullData.lstItensEventuais));

	handleSortOutros = (evt) => (this.fullData.lstOutros = this.handleSort(evt, this.fullData.lstOutros));

	processData(invoiceDetails) {
		console.log("invoiceDetails ->", invoiceDetails);
		const vencimentoSplit = invoiceDetails.dataVencimento.split("/");
		const vencimentoDate = new Date(vencimentoSplit[2], vencimentoSplit[1] - 1, vencimentoSplit[0]);
		const vencimentoMonth = Utils.getMonthName(vencimentoDate);

		invoiceDetails.header = `Fatura ${vencimentoMonth.charAt(0).toUpperCase() + vencimentoMonth.slice(1)} ${vencimentoDate.getFullYear()}`;

		if (!invoiceDetails.detalheProdutos) invoiceDetails.detalheProdutos = [];

		let lstTelevisao = [];
		let lstInternet = [];
		let lstMovel = [];
		let lstItensEventuais = [];
		let lstOutros = [];
		let lstTelefone = [];
		let mapTelefone = new Map();
		let objTotalValue = {
			televisao: 0,
			internet: 0,
			telefone: 0,
			movel: 0,
			eventuais: 0,
			outros: 0
		};

		for (let i = 0; i < invoiceDetails.detalheProdutos.length; i++) {
			let element = invoiceDetails.detalheProdutos[i];
			element.realValue = parseFloat(element.valor.replace("R$", "").replace(",", ".").replace(" ", ""));

			if (element.dataLancamento) {
				const lancamentoSplit = element.dataLancamento.split("/");
				element.rawLancamentoMilis = new Date(lancamentoSplit[2], lancamentoSplit[1] - 1, lancamentoSplit[0]).getTime();
			}

			switch (element.groupIdParent) {
				case 12:
					lstTelevisao.push(element);
					objTotalValue.televisao += element.realValue;
					invoiceDetails.hasTelevisao = true;

					break;
				case 18:
					lstInternet.push(element);
					objTotalValue.internet += element.realValue;
					invoiceDetails.hasInternet = true;

					break;
				case 998:
					lstTelefone.push(element);
					if (!mapTelefone.has(element.descricao)) mapTelefone.set(element.descricao, []);

					mapTelefone.get(element.descricao).push(element);
					objTotalValue.telefone += element.realValue;
					invoiceDetails.hasTelefone = true;

					break;
				case 999:
					lstMovel.push(element);
					objTotalValue.movel += element.realValue;
					invoiceDetails.hasMovel = true;

					break;
				case 21:
					lstItensEventuais.push(element);
					objTotalValue.eventuais += element.realValue;
					invoiceDetails.hasEventuais = true;

					break;
				default:
					lstOutros.push(element);
					objTotalValue.outros += element.realValue;
					invoiceDetails.hasOutros = true;

					break;
			}
		}

		Object.keys(objTotalValue).forEach((e) => {
			invoiceDetails[e] = `${e.charAt(0).toUpperCase() + e.slice(1)} - ${new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(objTotalValue[e])}`;
		});

		let listViewTelefone = [];
		mapTelefone.forEach((value, key) => {
			let totalKey = 0;
			for (let i = 0; i < value.length; i++) totalKey += value[i].realValue;

			totalKey = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalKey);
			listViewTelefone.push({ value: value, key: key, totalValue: totalKey });
		}, mapTelefone);

		invoiceDetails.lstTelevisao = lstTelevisao;
		invoiceDetails.lstInternet = lstInternet;
		invoiceDetails.lstMovel = lstMovel;
		invoiceDetails.lstItensEventuais = lstItensEventuais;
		invoiceDetails.lstOutros = lstOutros;
		invoiceDetails.lstTelefone = lstTelefone;

		return invoiceDetails;
	}

	handleRowAction(event) {
		this.modalItem = event.detail.row;
		this.template.querySelector("c-solar-modal").open();
	}

	handleCloseModal(event) {
		this.template.querySelector("c-solar-modal").close();
	}

	//Funcao para abrir PDF
	handleViewPdf() {

		console.log('atributosEnviados', this.atributosEnviados);
        var compDefinition = {
            componentDef: "c:solarFinanceiroPDF",
			attributes: this.atributosEnviados
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
	}
}