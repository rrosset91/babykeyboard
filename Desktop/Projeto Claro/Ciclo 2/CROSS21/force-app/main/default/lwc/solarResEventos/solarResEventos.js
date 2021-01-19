/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 21-12-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   11-11-2020   Joao Neves   Initial Version
 **/

/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 21-12-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   09-11-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import getEventDetail from "@salesforce/apex/EventsController.getEventDetails";

import getEvents from "@salesforce/apex/EventsController.getEvents";
import getEventsByDate from "@salesforce/apex/EventsController.getEventsByDate";

import getHistoryByDate from "@salesforce/apex/EventsController.getHistoryByDate";
import getHistoryByPeriod from "@salesforce/apex/EventsController.getHistoryByPeriod";

import getOccurrencesByPeriod from "@salesforce/apex/EventsController.getOccurrencesByPeriod";
import getOccurrencesByDate from "@salesforce/apex/EventsController.getOccurrencesByDate";

import getReadjustments from "@salesforce/apex/EventsController.getReadjustments";

import getNewProductsByPeriod from "@salesforce/apex/EventsController.getNewProductsByPeriod";
import getNewProductsByDate from "@salesforce/apex/EventsController.getNewProductsByDate";

import getRequestFeesByPeriod from "@salesforce/apex/EventsController.getRequestFeesByPeriod";
import getRequestFeesByDate from "@salesforce/apex/EventsController.getRequestFeesByDate";

import getPpvByPeriod from "@salesforce/apex/EventsController.getPpvByPeriod";
import getPpvByDate from "@salesforce/apex/EventsController.getPpvByDate";

import getOutageByPeriod from "@salesforce/apex/EventsController.getOutageByPeriod";
import getOutageByDate from "@salesforce/apex/EventsController.getOutageByDate";

import getEventDetails from "@salesforce/apex/EventsController.getEventDetails";

export default class SolarResEventos extends LightningElement {
	@api
	baseAttributes;
	@track
	accordionFunctions = {
		comprasCancelamentosByDate: getEvents,
		comprasCancelamentosByPeriod: getEvents,

		comprasMovimentacoesByDate: getEvents,
		comprasMovimentacoesByPeriod: getEvents,

		eventosTecnicosByDate: getEvents,
		eventosTecnicosByPeriod: getEvents,

		lancamentosManuaisByDate: getHistoryByDate,
		lancamentosManuaisByPeriod: getHistoryByPeriod,

		ocorrenciasAcompanhamentosByDate: getOccurrencesByDate,
		ocorrenciasAcompanhamentosByPeriod: getOccurrencesByPeriod,

		ocorrenciasFinanceirasByDate: getOccurrencesByDate,
		ocorrenciasFinanceirasByPeriod: getOccurrencesByPeriod,

		ocorrenciasCancelamentoByDate: getOccurrencesByDate,
		ocorrenciasCancelamentoByPeriod: getOccurrencesByPeriod,

		ocorrenciasServicosByDate: getOccurrencesByDate,
		ocorrenciasServicosByPeriod: getOccurrencesByPeriod,

		ocorrenciasSolicitacoesByDate: getOccurrencesByDate,
		ocorrenciasSolicitacoesByPeriod: getOccurrencesByPeriod,

		ocorrenciasOutrasByDate: getOccurrencesByDate,
		ocorrenciasOutrasByPeriod: getOccurrencesByPeriod,

		ofertaContratadaByDate: getNewProductsByDate,
		ofertaContratadaByPeriod: getNewProductsByPeriod,

		outageByDate: getOutageByDate,
		outageByPeriod: getOutageByPeriod,

		ppvByDate: getPpvByDate,
		ppvByPeriod: getPpvByPeriod,

		reajusteAnualByDate: getReadjustments,
		reajusteAnualByPeriod: getReadjustments,

		taxasTecnicasByDate: getRequestFeesByDate,
		taxasTecnicasByPeriod: getRequestFeesByPeriod,

		eventDetails: getEventDetails
	};
	eventAccordions = ["comprasCancelamentosByDate", "comprasCancelamentosByPeriod", "comprasMovimentacoesByDate", "comprasMovimentacoesByPeriod", "eventosTecnicosByDate", "eventosTecnicosByPeriod"];
	occurrencesAccordions = [
		"ocorrenciasAcompanhamentosByDate",
		"ocorrenciasAcompanhamentosByPeriod",
		"ocorrenciasFinanceirasByDate",
		"ocorrenciasFinanceirasByPeriod",
		"ocorrenciasCancelamentoByDate",
		"ocorrenciasCancelamentoByPeriod",
		"ocorrenciasServicosByDate",
		"ocorrenciasServicosByPeriod",
		"ocorrenciasSolicitacoesByDate",
		"ocorrenciasSolicitacoesByPeriod",
		"ocorrenciasOutrasByDate",
		"ocorrenciasOutrasByPeriod"
	];
	nameMap = {
		"Ocorrências de Acompanhamento de Chamados": "ocorrenciasAcompanhamentos",
		"Ocorrências Financeiras": "ocorrenciasFinanceiras",
		"Ocorrências de Cancelamento": "ocorrenciasCancelamento",
		"Ocorrências de Serviços": "ocorrenciasServicos",
		"Ocorrências de Solicitações": "ocorrenciasSolicitacoes",
		"Ocorrências - Outros": "ocorrenciasOutras",
		"Cancelamentos em andamento ou executados": "comprasCancelamentos",
		"Compras/ Movimentações de Produtos e Serviços": "comprasMovimentacoes",
		"Eventos Técnicos / Serviços": "eventosTecnicos"
	};
	@track
	eventsValues = {
		comprasCancelamentos: [],
		comprasMovimentacoes: [],
		eventosTecnicos: [],
		lancamentosManuais: [],
		ocorrenciasAcompanhamentos: [],
		ocorrenciasFinanceiras: [],
		ocorrenciasCancelamento: [],
		ocorrenciasServicos: [],
		ocorrenciasSolicitacoes: [],
		ocorrenciasOutras: [],
		ofertaContratada: [],
		outage: [],
		ppv: [],
		reajusteAnual: [],
		taxasTecnicas: [],
		eventDetailsConfigurations: [],
		eventDetailsOrderNote: ""
	};
	@track
	sortedBy = {
		details: "",
		comprasCancelamentos: "",
		comprasMovimentacoes: "",
		eventosTecnicos: "",
		lancamentosManuais: "",
		ocorrenciasAcompanhamentos: "",
		ocorrenciasFinanceiras: "",
		ocorrenciasCancelamento: "",
		ocorrenciasServicos: "",
		ocorrenciasSolicitacoes: "",
		ocorrenciasOutras: "",
		ofertaContratada: "",
		outage: "",
		ppv: "",
		reajusteAnual: "",
		taxasTecnicas: ""
	};
	@track
	sortedDirection = {
		details: "",
		comprasCancelamentos: "",
		comprasMovimentacoes: "",
		eventosTecnicos: "",
		lancamentosManuais: "",
		ocorrenciasAcompanhamentos: "",
		ocorrenciasFinanceiras: "",
		ocorrenciasCancelamento: "",
		ocorrenciasServicos: "",
		ocorrenciasSolicitacoes: "",
		ocorrenciasOutras: "",
		ofertaContratada: "",
		outage: "",
		ppv: "",
		reajusteAnual: "",
		taxasTecnicas: ""
	};
	@track
	calloutProps = {
		comprasCancelamentos: {
			hasError: false,
			emptyData: false
		},
		comprasMovimentacoes: {
			hasError: false,
			emptyData: false
		},
		eventosTecnicos: {
			hasError: false,
			emptyData: false
		},
		lancamentosManuais: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasAcompanhamentos: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasFinanceiras: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasCancelamento: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasServicos: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasSolicitacoes: {
			hasError: false,
			emptyData: false
		},
		ocorrenciasOutras: {
			hasError: false,
			emptyData: false
		},
		ofertaContratada: {
			hasError: false,
			emptyData: false
		},
		outage: {
			hasError: false,
			emptyData: false
		},
		ppv: {
			hasError: false,
			emptyData: false
		},
		reajusteAnual: {
			hasError: false,
			emptyData: false
		},
		taxasTecnicas: {
			hasError: false,
			emptyData: false
		}
	};
	columns = {
		general: [
			{ label: "Descrição", fieldName: "requestTypeDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		detail: [
			{ label: "Tipo de OCs", fieldName: "type", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Produto", fieldName: "productDescription", type: "text", sortable: true, hideDefaultActions: true }
		],
		history: [
			{ label: "Descrição", fieldName: "extractItemTypeDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		newProducts: [
			{ label: "Descrição", fieldName: "productDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		adjustment: [
			{ label: "Nome do Evento", fieldName: "readjustmentType", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data do Reajuste", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		ocurrence: [
			{ label: "Nº Ocorrência", fieldName: "stringNumber", type: "text", sortable: false, hideDefaultActions: true },
			{ label: "Tipo / Descrição", fieldName: "typeDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data / Hora Abertura", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		fees: [
			{ label: "Nome / Descrição", fieldName: "requestTypeDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		ppv: [
			{ label: "Produto", fieldName: "typeSaleDescription", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		],
		outage: [
			{ label: "Natureza", fieldName: "outageNature", type: "text", sortable: true, hideDefaultActions: true },
			{ label: "Data", fieldName: "formattedDate", type: "text", sortable: true, hideDefaultActions: true }
		]
	};
	@track
	openModal = {
		eventsModal: false,
		lancamentosManuais: false,
		occurrencesModal: false,
		ofertaContratada: false,
		outage: false,
		ppv: false,
		reajusteAnual: false,
		taxasTecnicas: false,
		detailsDatatable: false
	};
	@track
	startDate;
	@track
	endDate;
	@track
	alreadyOpenedAccordions = [];
	selectedEvent = {};
	isLoading = false;
	period = 6;
	sameSource = ["comprasCancelamentos", "comprasMovimentacoes", "eventosTecnicos"];
	sameSourceOccurrences = ["ocorrenciasAcompanhamentos", "ocorrenciasFinanceiras", "ocorrenciasCancelamento", "ocorrenciasServicos", "ocorrenciasSolicitacoes", "ocorrenciasOutras"];

	async toggleSection(event) {
		let openedAccordions = event.detail.openSections;
		console.log("openedAccordions ->", openedAccordions);
		if (openedAccordions.length < this.alreadyOpenedAccordions.length) {
			const closedItem = this.alreadyOpenedAccordions.filter((x) => !openedAccordions.includes(x));
			this.alreadyOpenedAccordions = openedAccordions;
		} else {
			const newItem = openedAccordions.filter((x) => !this.alreadyOpenedAccordions.includes(x))[0];
			if (Utils.isEmptyArray(newItem)) return;
			this.isLoading = true;
			await this.fetchEvent(newItem);
			this.isLoading = false;
			this.alreadyOpenedAccordions = openedAccordions;
		}
	}

	async handleRowSelection(event) {
		this.isLoading = true;

		this.selectedEvent = event.detail.selectedRows[0];
		this.handleOpenModal(this.selectedEvent.accordion);
		await this.fetchPreInfo(this.selectedEvent);
		this.template.querySelector("c-solar-modal").open();

		this.isLoading = false;
	}

	async fetchPreInfo(event) {
		console.log("fetchPreInfo event ->", JSON.parse(JSON.stringify(event)));

		if (this.sameSource.includes(event.accordion)) {
			let hasError = false;
			this.openModal.detailsDatatable = true;
			const data = await getEventDetail({
				contractId: this.baseAttributes.contractId,
				operatorId: this.baseAttributes.operatorId,
				requestId: event.requestID
			}).catch((err) => {
				hasError = true;
				Utils.showToast(this, "error", null, err.body.message);
			});
			if (hasError) return;
			this.eventDetailsConfigurations = this.treatResponseData(data.configurations, "eventDetails");
			this.eventDetailsOrderNote = data.orders[0].note;
			this.openModal.detailsDatatable = true;
			console.log("fetchPreInfo getEventDetail ->", JSON.parse(JSON.stringify(data)));
		}
	}

	handleFilterNotification(event) {
		if (event.detail.filterType === "CUSTOMPERIOD") {
			this.startDate = event.detail.value.startDate;
			this.endDate = event.detail.value.endDate;
		} else if (event.detail.filterType === "PERIOD") {
			this.period = event.detail.value;
		}

		this.alreadyOpenedAccordions = [];
	}

	handleOpenModal(relatedAccordion) {
		let specialAccordion = relatedAccordion.includes("comprasCancelamentos") || relatedAccordion.includes("comprasMovimentacoes") || relatedAccordion.includes("eventosTecnicos");
		let occurrencesAccordion = relatedAccordion.includes("ocorrencias");

		if (specialAccordion) relatedAccordion = "eventsModal";
		if (occurrencesAccordion) relatedAccordion = "occurrencesModal";

		Object.keys(this.openModal).forEach((modal) => {
			this.openModal[modal] = modal == relatedAccordion;
		});

		console.log("this.openModal ->", JSON.parse(JSON.stringify(this.openModal)));
	}

	handleCloseModal() {
		this.template.querySelector("c-solar-modal").close();
		Object.keys(this.openModal).forEach((modal) => {
			this.openModal[modal] = false;
		});
	}

	async fetchEvent(newAccordion) {
		const accordionInfo = this.getAccordionInfo(newAccordion);
		if (!accordionInfo.shouldPerformRequest) return;

		let hasError = false;
		this.eventsValues[newAccordion] = [];

		const params = this.buildParams(newAccordion);
		const newAccordionFunction = Utils.isEmptyString(this.startDate) && Utils.isEmptyString(this.endDate) ? newAccordion + "ByDate" : newAccordion + "ByPeriod";
		const data = await this.accordionFunctions[newAccordionFunction](params).catch((err) => {
			hasError = true;
			this.removeFromAccordionsArray(newAccordion);
			Utils.showToast(this, "error", null, err.body.message);
		});
		this.setErrorAtt(newAccordion, hasError);

		if (hasError) return;

		let responseData = this.getResponseData(data, newAccordion);

		const hasData = !Utils.isEmptyArray(responseData);

		if (hasData && accordionInfo.isMultipleCallAccordion) {
			this.spreadMultipleAccordionsData(newAccordion, this.treatResponseData(responseData, newAccordion));
		} else if (hasData) {
			this.eventsValues[newAccordion] = this.treatResponseData(responseData, newAccordion);
		}

		this.setDataAtt();
	}

	setErrorAtt(newAccordion, errorAtt) {
		if (this.sameSource.includes(newAccordion)) {
			this.sameSource.forEach((x) => {
				this.calloutProps[x].hasError = errorAtt;
			});
		} else if (this.sameSourceOccurrences.includes(newAccordion)) {
			this.sameSourceOccurrences.forEach((x) => {
				this.calloutProps[x].hasError = errorAtt;
			});
		} else {
			this.calloutProps[newAccordion].hasError = errorAtt;
		}
	}

	setDataAtt() {
		Object.keys(this.eventsValues).forEach((x) => {
			let obj = this.calloutProps[x];
			if (!obj) return;

			obj.emptyData = !Boolean(this.eventsValues[x].length);
		});
	}

	getAccordionInfo(newAccordion) {
		let retObj = {
			shouldPerformRequest: true,
			isMultipleCallAccordion: this.sameSource.includes(newAccordion) || this.sameSourceOccurrences.includes(newAccordion)
		};
		if (newAccordion.includes("ocorrencias")) {
			if (retObj.isMultipleCallAccordion) retObj.shouldPerformRequest = !this.alreadyOpenedAccordions.some((x) => this.sameSourceOccurrences.includes(x));
		} else {
			if (retObj.isMultipleCallAccordion) retObj.shouldPerformRequest = !this.alreadyOpenedAccordions.some((x) => this.sameSource.includes(x));
		}
		return retObj;
	}

	spreadMultipleAccordionsData(newAccordion, treatedResponseData) {
		console.log("@SpreadMultiple - Treated Response Data --->", treatedResponseData);
		console.log("@SpreadMultiple - Accordion --->", newAccordion);

		let occuMap = {};

		treatedResponseData.forEach((x) => {
			const arrkey = this.nameMap[x.groupType];

			let updatedArray = occuMap[arrkey] ? occuMap[arrkey] : [];

			updatedArray.push(x);

			occuMap[arrkey] = updatedArray;
		});

		Object.keys(occuMap).forEach((x) => {
			this.eventsValues[x] = occuMap[x];
		});
	}

	buildParams(newAccordion) {
		let retObj = {
			contractId: this.baseAttributes.contractId,
			operatorId: this.baseAttributes.operatorId
		};

		if (!Utils.isEmptyString(this.startDate) && !Utils.isEmptyString(this.endDate)) {
			retObj.startDate = this.startDate;
			retObj.endDate = this.endDate;
		} else {
			retObj.period = this.period;
		}

		if (newAccordion === "lancamentosManuais") {
			retObj.extractItemStatus = "ISSUED";
			retObj.infoDetailLevel = "DETAILS";
			return retObj;
		}
		return retObj;
	}

	handleSort(context, event, data) {
		this.sortedBy[context] = event.detail.fieldName;
		this.sortedDirection[context] = event.detail.sortDirection;

		let sortField = this.sortedBy[context];
		if (sortField == "valor") sortField = "realValue";

		return Utils.sortData(sortField, this.sortedDirection[context], data);
	}

	handleDefaultSort(context, fieldName, data) {
		this.sortedBy[context] = fieldName;
		this.sortedDirection[context] = "desc";
		let sortField = this.sortedBy[context];
		return Utils.sortData(sortField, this.sortedDirection[context], data);
	}

	getResponseData(data, accordionName) {
		if (accordionName.includes("comprasCancelamentos") || accordionName.includes("comprasMovimentacoes") || accordionName.includes("eventosTecnicos")) {
			return data.events;
		} else if (
			accordionName.includes("ocorrenciasAcompanhamentos") ||
			accordionName.includes("ocorrenciasFinanceiras") ||
			accordionName.includes("ocorrenciasCancelamento") ||
			accordionName.includes("ocorrenciasServicos") ||
			accordionName.includes("ocorrenciasSolicitacoes") ||
			accordionName.includes("ocorrenciasOutras") ||
			accordionName.includes("ocorrenciasSolicitacoes") ||
			accordionName.includes("ocorrenciasSolicitacoes")
		) {
			return data.occurrences;
		} else if (accordionName.includes("ofertaContratada")) {
			return data.newProducts;
		} else if (accordionName.includes("outage")) {
			return data.outage;
		} else if (accordionName.includes("ppv")) {
			return data.ppvs;
		} else if (accordionName.includes("reajusteAnual")) {
			return data.readjustments;
		} else if (accordionName.includes("taxasTecnicas")) {
			return data.requestFees;
		}

		return [];
	}

	removeFromAccordionsArray(accordionName) {
		let indexToRemove = this.alreadyOpenedAccordions.indexOf(accordionName);
		this.alreadyOpenedAccordions.splice(indexToRemove, 1);
	}

	treatResponseData(responseData, accordion) {
		if (accordion.includes("comprasCancelamentos") || accordion.includes("comprasMovimentacoes") || accordion.includes("eventosTecnicos")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (!x.closeDate) return;
				const [dayName, month, day, hour, timezone, year] = x.closeDate.split(" ");
				x.realDate = new Date(year, this.getMonth(month), day);
				x.formattedDate = `${day}/${this.getMonth(month)}/${year}`;
			});
			responseData = this.handleDefaultSort(accordion, "realDate", data);
			return responseData;
		} else if (accordion == "eventDetails") {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (!x.executionDate) return;
				const [dayName, month, day, hour, timezone, year] = x.executionDate.split(" ");

				x.realDate = new Date(year, this.getMonth(month), day);
				x.formattedDate = `${day}/${this.getMonth(month)}/${year}`;
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("lancamentosManuais")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.billDate) {
					let historyDate = x.billDate;
					historyDate = historyDate.split("T")[0];
					historyDate = historyDate.split("-");
					x.formattedDate = historyDate[2] + "/" + historyDate[1] + "/" + historyDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
				if (x.extractItensDetails[0].productDescription == null) x.extractItensDetails[0].productDescription = "--";
				if (x.installments == null) x.installments = "--";
				x.registrationUser = x.extractItensDetails[0].registrationUser;
				x.productDescription = x.extractItensDetails[0].productDescription;
				x.detTypeExtractItemNote = x.extractItensDetails[0].detTypeExtractItemNote;
				x.partnerName = x.extractItensDetails[0].partnerName;
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("ocorrencias")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.creationDate) {
					let occurrenceDate = x.creationDate;
					let occurrenceTime = occurrenceDate.split("T")[1];
					occurrenceTime = occurrenceTime.replace("Z", "");
					occurrenceDate = occurrenceDate.split("T")[0];
					occurrenceDate = occurrenceDate.split("-");
					x.formattedDate = occurrenceDate[2] + "/" + occurrenceDate[1] + "/" + occurrenceDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
					x.formattedDate = occurrenceDate[2] + "/" + occurrenceDate[1] + "/" + occurrenceDate[0] + " - " + occurrenceTime;
				}
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("reajusteAnual")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.readjustmentDate) {
					let readjustmentDate = x.readjustmentDate;
					readjustmentDate = readjustmentDate.split("T")[0];
					readjustmentDate = readjustmentDate.split("-");
					x.formattedDate = readjustmentDate[2] + "/" + readjustmentDate[1] + "/" + readjustmentDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("ofertaContratada")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.effectiveDate) {
					let effectiveDate = x.effectiveDate;
					effectiveDate = effectiveDate.split("T")[0];
					effectiveDate = effectiveDate.split("-");
					x.formattedDate = effectiveDate[2] + "/" + effectiveDate[1] + "/" + effectiveDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("ofertaContratada")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.releaseDate) {
					let releaseDate = x.releaseDate;
					releaseDate = releaseDate.split("T")[0];
					releaseDate = releaseDate.split("-");
					x.formattedDate = releaseDate[2] + "/" + releaseDate[1] + "/" + releaseDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("ppv")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.saleDate) {
					let saleDate = x.saleDate;
					saleDate = saleDate.split("T")[0];
					saleDate = saleDate.split("-");
					x.formattedDate = saleDate[2] + "/" + saleDate[1] + "/" + saleDate[0];
					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else if (accordion.includes("outage")) {
			responseData.forEach((x) => {
				x.accordion = accordion;
				if (x.products[0].startDate) {
					let startDate = x.products[0].startDate;
					startDate = startDate.split("/");
					x.formattedDate = startDate[0] + "/" + startDate[1] + "/" + startDate[2];
					x.products[0].startDate = x.formattedDate;

					let realDate = x.formattedDate.split("/");
					x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
				}
				if (x.products[0].previsionDate != null) {
					let formattedPrevisionDate = x.products[0].previsionDate.split("/");
					formattedPrevisionDate = formattedPrevisionDate[0] + "/" + formattedPrevisionDate[1] + "/" + formattedPrevisionDate[2];
					x.products[0].previsionDate = formattedPrevisionDate;
				}
				if (x.products[0].endDate != null) {
					let formattedEndDate = x.products[0].endDate.split("/");
					formattedEndDate = formattedEndDate[0] + "/" + formattedEndDate[1] + "/" + formattedEndDate[2];
					x.products[0].endDate = formattedEndDate;
				}
				x.outageNature = x.products[0].nature;
				x.productType = x.products[0].productType;
				x.affectedServices = x.products[0].affectedServices;
				x.symptom = x.products[0].symptom;
				x.coverage = x.products[0].coverage;
				x.nature = x.products[0].nature;
				x.responsible = x.products[0].responsible;
				x.startDate = x.products[0].startDate;
				x.previsionDate = x.products[0].previsionDate;
				x.endDate = x.products[0].endDate;
				x.status = x.products[0].status;
			});
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		} else {
			responseData = this.handleDefaultSort(accordion, "realDate", responseData);

			return responseData;
		}
	}

	handleSortComprasCancelamentos = (evt) => (this.eventsValues.comprasCancelamentos = this.handleSort("comprasCancelamentos", evt, this.eventsValues.comprasCancelamentos));

	handleSortComprasMovimentacoess = (evt) => (this.eventsValues.comprasMovimentacoes = this.handleSort("comprasMovimentacoes", evt, this.eventsValues.comprasMovimentacoes));

	handleSortEventosTecnicos = (evt) => (this.eventsValues.eventosTecnicos = this.handleSort("eventosTecnicos", evt, this.eventsValues.eventosTecnicos));

	handleSortLancamentosManuais = (evt) => (this.eventsValues.lancamentosManuais = this.handleSort("lancamentosManuais", evt, this.eventsValues.lancamentosManuais));

	handleSortOcorrenciasAcompanhamentos = (evt) => (this.eventsValues.ocorrenciasAcompanhamentos = this.handleSort("ocorrenciasAcompanhamentos", evt, this.eventsValues.ocorrenciasAcompanhamentos));

	handleSortOcorrenciasFinanceiras = (evt) => (this.eventsValues.ocorrenciasFinanceiras = this.handleSort("ocorrenciasFinanceiras", evt, this.eventsValues.ocorrenciasFinanceiras));

	handleSortOcorrenciasCancelamento = (evt) => (this.eventsValues.ocorrenciasCancelamento = this.handleSort("ocorrenciasCancelamento", evt, this.eventsValues.ocorrenciasCancelamento));

	handleSortOcorrenciasServicos = (evt) => (this.eventsValues.ocorrenciasServicos = this.handleSort("ocorrenciasServicos", evt, this.eventsValues.ocorrenciasServicos));

	handleSortOcorrenciasOutras = (evt) => (this.eventsValues.ocorrenciasOutras = this.handleSort("ocorrenciasOutras", evt, this.eventsValues.ocorrenciasOutras));

	handleSortOutage = (evt) => (this.eventsValues.outage = this.handleSort("outage", evt, this.eventsValues.outage));

	handleSortPpv = (evt) => (this.eventsValues.ppv = this.handleSort("ppv", evt, this.eventsValues.ppv));

	handleSortReajusteAnual = (evt) => (this.eventsValues.reajusteAnual = this.handleSort("reajusteAnual", evt, this.eventsValues.reajusteAnual));

	handleSortTaxasTecnicas = (evt) => (this.eventsValues.taxasTecnicas = this.handleSort("taxasTecnicas", evt, this.eventsValues.taxasTecnicas));

	handleSortDetails = (evt) => (this.eventsValues.eventDetailsConfigurations = this.handleSort("details", evt, this.eventsValues.eventDetailsConfigurations));
}