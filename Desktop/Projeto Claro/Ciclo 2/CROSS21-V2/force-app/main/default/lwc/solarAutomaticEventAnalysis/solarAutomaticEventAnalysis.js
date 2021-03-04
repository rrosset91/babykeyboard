import { LightningElement, track, api } from "lwc";
import Utils from "c/solarUtils";
import getAllEvents from "@salesforce/apex/FinancialEventAnalysisController.getAllEvents";
import getEventDetail from "@salesforce/apex/EventsController.getEventDetails";

export default class SolarAutomaticEventAnalysis extends LightningElement {
	@api
	baseAttributes;
	@api
	columns = [];
	@track
	modalData = [];
	@track
	isLoading = false;
	@track
	allEvents = [];
	@track
	eventDetailsDataTable;
	@track
	openDetailsDatatable = false;
	@track
	columnsEventDetails = [
		{ label: "Tipo de OCs", fieldName: "type", type: "text", sortable: false, hideDefaultActions: true },
		{ label: "Produto", fieldName: "productDescription", type: "text", sortable: false, hideDefaultActions: true }
	];

	@track isLoading = false;
	@track hasError = false;
	@track isEmpty = false;
	@track show = false;

	async connectedCallback() {

		this.isLoading = true;

		await getAllEvents({parameters: this.baseAttributes})
			.then((result) => {
				if (result.data.length > 0) {
					this.allEvents = this.allEvents.concat(result.data);
					this.uiHandler("show");
				} else {
					this.uiHandler("isEmpty");
				}
			})
			.catch((error) => {
				console.log("Erro: " + error);
				Utils.showToast(this, "error", null, error.body.message);
				this.uiHandler("hasError");
			});

		this.isLoading = false;
	}

	handleRowAction(event) {

		const eventType = event.detail.row.eventType;

		if (eventType.includes("Cancelamentos em andamento ou executados") || eventType.includes("Compras/ Movimentações de Produtos e Serviços") || eventType.includes("Eventos Técnicos / Serviços")) {
			this.showRequestDetail(event.detail.row);
		} else if (eventType.includes("Lançamentos Manuais")) {
			this.showManualPostingDetail(event.detail.row);
		} else if (eventType.includes("Oferta Contratada")) {
			this.showContractedOfferDetail(event.detail.row);
		} else if (eventType.includes("PPV")) {
			this.showPPVDetail(event.detail.row);
		} else if (eventType.includes("Reajuste Anual")) {
			this.showReadjustmentDetail(event.detail.row);
		} else if (eventType.includes("Taxas Técnicas")) {
			this.showFeeDetail(event.detail.row);
		} 
	}

	async showRequestDetail (event) {

		this.uiHandler('isLoading');
		const attributes = JSON.parse(this.baseAttributes); 
		const data = await getEventDetail({
			contractId: attributes.contractNumber,
			operatorId: attributes.operatorCode,
			requestId: event.requestID
		}).catch((error) => {
			console.log("Erro: " + error);
			Utils.showToast(this, "error", null, error.body.message);
		});
		this.uiHandler('show');

		this.modalData.push({ label: "Tipo de solicitação", fieldName: event.eventType });
		this.modalData.push({ label: "Data de fechamento", fieldName: event.eventDate });
		this.modalData.push({ label: "Usuário", fieldName: event.user });
		this.modalData.push({ label: "Tipo de Fechamento", fieldName: event.closeType });
		this.modalData.push({ label: "Número de Solicitação", fieldName: event.requestID });

		if (data != undefined && data.orders[0] != undefined)
			this.modalData.push({ label: "Observação", fieldName: data.orders[0].note });
		else
			this.modalData.push({ label: "Observação", fieldName: "" });

		this.openDetailsDatatable = true;

		if (data != undefined && data.configurations != undefined && data.configurations.length != 0) 
			this.eventDetailsDataTable = data.configurations;

		this.showDetailsModal();
	}

	showManualPostingDetail (event) {

		this.modalData.push({ label: "Descrição", fieldName: event.eventDescription });
		this.modalData.push({ label: "Tipo", fieldName: event.eventType });
		this.modalData.push({ label: "Data", fieldName: event.eventDate });
		this.modalData.push({ label: "Parcelas", fieldName: event.installment });
		this.modalData.push({ label: "Valor", fieldName: event.value });
		this.modalData.push({ label: "Usuário", fieldName: event.user });
		this.modalData.push({ label: "Produto", fieldName: event.product });
		this.modalData.push({ label: "Item", fieldName: event.item });
		this.modalData.push({ label: "Parceiro", fieldName: event.partner });

		this.showDetailsModal();
	}

	showContractedOfferDetail (event) {

		this.modalData.push({ label: "Tipo de Evento", fieldName: event.eventType });
		this.modalData.push({ label: "Nome / Descrição", fieldName: event.eventDescription });
		this.modalData.push({ label: "Data", fieldName: event.eventDate });
		this.modalData.push({ label: "Valor", fieldName: event.value });

		this.showDetailsModal();
	}

	showPPVDetail (event) {

		this.modalData.push({ label: "Produto", fieldName: event.product });
		this.modalData.push({ label: "Data do Lançamento", fieldName: event.eventDate });
		this.modalData.push({ label: "Valor", fieldName: event.value });

		this.showDetailsModal();
	}

	showReadjustmentDetail (event) {

		this.modalData.push({ label: "Nome do Evento", fieldName: event.eventDescription });
		this.modalData.push({ label: "Data do Reajuste", fieldName: event.eventDate });
		this.modalData.push({ label: "Tipo de Evento", fieldName: event.eventType });
		this.modalData.push({ label: "Produto", fieldName: event.product });
		this.modalData.push({ label: "Percentual de Reajuste", fieldName: event.readjustmentPercentage });
		this.modalData.push({ label: "Preço Anterior", fieldName: event.previousPrice });
		this.modalData.push({ label: "Preço Reajustado", fieldName: event.readjustmentPrice });
		this.modalData.push({ label: "Valor do Reajuste", fieldName: event.readjustmentValue });

		this.showDetailsModal();
	}

	showFeeDetail (event) {

		this.modalData.push({ label: "Nome do Item", fieldName: event.itemName });
		this.modalData.push({ label: "Tipo de Solicitação", fieldName: event.eventDescription });
		this.modalData.push({ label: "Valor", fieldName: event.value });
		this.modalData.push({ label: "Total de Parcelas", fieldName: event.installment });
		this.modalData.push({ label: "Número da Parcela", fieldName: event.installmentNumber });
		this.modalData.push({ label: "Produto", fieldName: event.product });
		this.modalData.push({ label: "Usuário Solicitação", fieldName: event.requestUser });
		this.modalData.push({ label: "Usuário Taxa", fieldName: event.feeUser });

		this.showDetailsModal();
	}

	showDetailsModal() {
		this.template.querySelector("c-solar-modal").open();
	}

	handleCloseModal() {
		this.openDetailsDatatable = false;
		this.modalData = [];
		this.template.querySelector("c-solar-modal").close();
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
}