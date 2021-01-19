/**
 * @description       : Controller js
 * @author            : Roger Rosset
 * @group             : Financeiro - Eventos

 * @last modified on  : 07-12-2020

 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
 **/


//Recursos e componentes
import { LightningElement, wire, track, api } from "lwc";
import Utils from "c/solarUtils";
import loadAccordionsList from "@salesforce/apex/FinancialMobileEventsController.eventsAccordionsProvider";
import requestPerformer from "@salesforce/apex/FinancialMobileEventsController.accordionsRequestBuilder";
import getMsisdnFromApex from "@salesforce/apex/FinancialMobileUtils.getMsisdn";
import getCustomerCrmIdFromApex from "@salesforce/apex/FinancialMobileUtils.getCustomerCrmId";
import getModalApiData from "@salesforce/apex/FinancialMobileInteractionsEvents.rowActionRequestPerformer";

//Custom Labels
import eventsErrorLabel1 from "@salesforce/label/c.Financeiro_ErroGen1";
import eventsErrorLabel2 from "@salesforce/label/c.Financeiro_ErroGen2";

import filterAppliedLabel from "@salesforce/label/c.Fin_filter_success";
export default class SolarFinanceiroEventos extends LightningElement {
	@api baseAttributes;
	@track loadingSpinner = false;
	@track loadingInitSpinner = true;
	@track loadingModalSpinner = false;
	@track showModalPaginationComponent = false;
	@track accordionsList = [];

  @track activeSections = [];
  @track periodFilterValue = 6;

	@track startDateFilterValue;
	@track endDateFilterValue;
	@track isCustomDateFilterValue = false;
	@track alreadyOpenedAccordions = [];
	@track columnsIndex = [];
	@track sortBy;
	@track sortDirection;
	@track apiCallAttributes = {};
	@track modalData;
	@track selectedRow = [];
	@track rowResponseData = [];
	@track loadingProtocolSpinner;

  @track labels = {};
  @track renderList = true;
  //---------------------------------------------TRAZER LISTAGEM DOS ACCORDIONS VINDA DO CONTROLLER-------------------------------------------------------

	connectedCallback() {
		this.loadingInitSpinner = true;
		console.log(this.jsonLogger(this.baseAttributes));
		this.getMsisdnAndCrmCustomerId(this.baseAttributes.recordId);

    this.labels.eventsErrorLabel = eventsErrorLabel1 + "\n" + eventsErrorLabel2;
    this.labels.filterAppliedLabel = filterAppliedLabel;
  }

	@wire(loadAccordionsList)
		wiredAccordions({ error, data }) {
		if (error) {
			Utils.showToast(this, "error", null, error.body.message);
		} else if (data) {
			this.accordionsList = this.jsonLogger(data);
		}
	}

  //-------------------------------FUNÇÃO RESPONSÁVEL POR LIDAR COM O EVENTO DE ABERTURA / FECHAMENTO DE ACCORDION---------------------------------------
  handleSectionToggle(event) {
    let accordionsListData = this.accordionsList;
    let openedAccordions = this.jsonLogger(event.detail.openSections);
    let accordionEvent = openedAccordions.filter(
      (e) => !this.alreadyOpenedAccordions.find((a) => e == a)
    )[0];
    if (
      !this.alreadyOpenedAccordions.includes(accordionEvent) &&
      accordionEvent != undefined
    ) {

			this.alreadyOpenedAccordions.push(accordionEvent);
		} else {
			accordionEvent = undefined;
			return;
		}

    let toggledAccordionName = this.alreadyOpenedAccordions[
      this.alreadyOpenedAccordions.length - 1
    ];
    let selectedAccordion = accordionsListData.filter(
      (item) => item.accordionId == toggledAccordionName
    )[0];
    let selectedAccordionIndex = accordionsListData.indexOf(selectedAccordion);
    selectedAccordion = JSON.parse(JSON.stringify(selectedAccordion));
    if (
      accordionEvent != undefined &&
      selectedAccordion.attributes.implemented
    ) {
      this.loadingSpinner = true;
      this.performApiRequest(selectedAccordion, selectedAccordionIndex);
    } else if (
      accordionEvent != undefined &&
      selectedAccordion.attributes.implemented == false
    ) {

			alert("Não implementado");
			this.accordionsList[selectedAccordionIndex].dataEmpty = true;
			this.loadingSpinner = false;
		} else {
			this.loadingSpinner = false;
		}
	}

  //-----------------------------------FUNÇÃO RESPONSÁVEL POR REALIZAR CHAMADAS DOS ACCORDIONS PARA API NO BACKEND----------------------------------------
  performApiRequest(requesterAccordion, accordionIndex) {
    let requireMsisdn = this.accordionsList[accordionIndex].requireMsisdn;
    let requireCrmCustomerId = this.accordionsList[accordionIndex]
      .requireCrmCustomerId;

			if (Utils.isEmptyString(this.apiCallAttributes.msisdn) && requireMsisdn) {
				let error = "MSISDN não definido";
				this.accordionsList[accordionIndex].dataError = true;
				this.loadingSpinner = false;
				return Utils.showToast(this, "error", null, error);

    } else if (
      Utils.isEmptyString(this.apiCallAttributes.customerCrmId) &&
      requireCrmCustomerId
    ) {

				let error = "CrmCustomerId não definido";
				this.apiCallFailed(accordionIndex);
				this.accordionsList[accordionIndex].dataError = true;
				this.loadingSpinner = false;
				return Utils.showToast(this, "error", null, error);
			} 
			let accordionName = requesterAccordion.accordionTitle;
			requesterAccordion = JSON.stringify(requesterAccordion.attributes);
			let apiCallAttributes = JSON.parse(JSON.stringify(this.apiCallAttributes));
		let baseAttributes = JSON.parse(JSON.stringify(this.baseAttributes));

    baseAttributes.msisdn = apiCallAttributes.msisdn;
    baseAttributes.customerCrmId = apiCallAttributes.customerCrmId;
    baseAttributes = JSON.stringify(baseAttributes);

			let filtersParams = this.checkDateFilterParams();
			console.log("requesterAccordionText", requesterAccordion);
			console.log("apiCallAttributes", baseAttributes);
			console.log("filterParams", filtersParams);
			requestPerformer({
			requesterAccordionText: requesterAccordion,
			baseAttributesText: baseAttributes,
			filterParamsText: filtersParams
			})
			.then((success) => {
				//Organizando os dados retornados da API
				this.loadingSpinner = false;
				if (success.accordionData) {

          this.setAccordionData(
            success.accordionData,
            accordionIndex,
            accordionName
          );

				}
				if (success.columnsData) {
					this.setAccordionColumns(success.columnsData, accordionIndex);
				}
				if (success.modalFieldsData) {
					this.setAccordionModalFields(success.modalFieldsData, accordionIndex);
				}
				//Organizando a exibiçao condicional dos dados
				this.accordionsList[accordionIndex].dataError = false;
				this.logColumnsIndex(success.columnsData, accordionIndex);
			})
			.catch((error) => {
				this.apiCallFailed(accordionIndex);
				Utils.showToast(this, "error", null, error.body.message);
				this.loadingSpinner = false;
				this.accordionsList[accordionIndex].dataError = true;
				Utils.showToast(this, "error", null, error);
			});
	}


  // --------------------------------------------- FUNÇÕES RELACIONADAS AO SORT DAS COLUNAS -----------------------------------------------------------------
	onHandleSort(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		let sortField = this.sortBy;

    let accordionId = this.columnsIndex.filter((item) =>
      item.accordionColumnsData.includes(sortField)
    )[0];

		let i = accordionId.accordionIndex;
			if (sortField.includes("formatted")) {
				sortField = sortField.replace("formatted", "real");
			}

    let sortedData = Utils.sortData(
      sortField,
      this.sortDirection,
      this.accordionsList[i].responseData
    );
    this.accordionsList[i].responseData = sortedData;
  }
  //-----------FUNÇÕES RESPONSÁVEIS POR ATUALIZAR OS DADOS DE CADA ACCORDION, QUE SERÃO USADOS NOS DATATABLES E DEFINIR PARAMETROS DE CHAMADAS-------------
  apiCallFailed(index) {
    let accordionName = this.accordionsList[index].accordionId;
    this.alreadyOpenedAccordions = this.alreadyOpenedAccordions.filter(
      (item) => item.accordionId == accordionName
    );
  }
  setAccordionData(accordion, index, accordionTitle) {
    let parsedResponse = JSON.parse(accordion);
    console.log("AccordionData definido ---->", parsedResponse);
    if (parsedResponse.length == 0) {
      console.log("Dados vazios --> emptyArray = true");
      this.loadingSpinner = false;
      this.accordionsList[index].showDataTable = false;
      this.accordionsList[index].noEventsLabel = `Não há itens de "${accordionTitle}" disponíveis para este resultado`;
      return (this.accordionsList[index].dataEmpty = true);
    }
    this.accordionsList[index].showDataTable = true;
    this.accordionsList[index].originalContent = parsedResponse;
    return (this.accordionsList[index].responseData = parsedResponse);
  }
  setAccordionColumns(accordion, index) {
    console.log(
      "Colunas definidas ---->",
      (this.accordionsList[index].columns = JSON.parse(accordion))
    );

		return (this.accordionsList[index].columns = JSON.parse(accordion));
	}
	setAccordionModalFields(accordion, index) {
		let modalData = JSON.parse(accordion);
		console.log("ModalFields definidos -->", modalData);
		this.accordionsList[index].modalFields = modalData;
	}
	logColumnsIndex(accordion, index) {
		let parsedColumns = JSON.stringify(accordion);
		let log = { accordionColumnsData: parsedColumns, accordionIndex: index };
		this.columnsIndex.push(log);
		return;
	}
	checkDateFilterParams() {
		let filterParams = {
			periodFilter: this.periodFilterValue,
			startDateFilter: this.startDateFilterValue,
			endDateFilter: this.endDateFilterValue,
			isCustomDateFilter: this.isCustomDateFilterValue
		};
		return JSON.stringify(filterParams);
	}


	getMsisdnAndCrmCustomerId(recordId) {
		getMsisdnFromApex({ caseId: recordId })
			.then((data) => {
				let returnedValue = data;
				this.apiCallAttributes.msisdn = returnedValue;
				this.getCrmCustomerId(data);
				})
				.catch((error) => {
				console.log(error);

        Utils.showToast(
          this,
          "error",
          null,
          "Não foi possível definir o MSISDN do contrato"
        );

				this.loadingInitSpinner = false;
				this.loadingSpinner = false;
			});
	}


	getCrmCustomerId(msisdn) {
		getCustomerCrmIdFromApex({ msisdn: msisdn })
			.then((data) => {
				let returnedValue = data;
				this.apiCallAttributes.customerCrmId = returnedValue;
				console.log(this.jsonLogger(this.apiCallAttributes));
				this.loadingSpinner = false;
				this.loadingInitSpinner = false;
				})
				.catch((error) => {
				console.log(error);

        Utils.showToast(
          this,
          "error",
          null,
          "Não foi possível definir o CrmCustomerId do contrato"
        );

				this.loadingInitSpinner = false;
				this.loadingSpinner = false;
			});
	}

  //---------------------------------------------------------FUNÇÕES RELACIONADAS AO MODAL---------------------------------------------------------------
  handleRowAction(event) {
    let relatedAccordion = event.detail.row.relatedAccordion;
    let accordionIndex = this.accordionsList.findIndex(
      (element) => element.accordionId == relatedAccordion
    );
    let accordionData = this.accordionsList[accordionIndex];
    if (accordionData.attributes.callApiOnRowAction) {
      this.loadingProtocolSpinner = true;
      this.performRowApiRequest(
        accordionData.attributes.apiToCallOnRowAction,
        event.detail.row.protocolNumber
      );
    }
    let dataTemplate = this.accordionsList[accordionIndex].modalFields;
    console.log("DATATEMPLATE PARA BUSCA---->", this.jsonLogger(dataTemplate));
    let rowToLookup = this.jsonLogger(event.detail.row);
    console.log("BASE DE BUSCA --->", rowToLookup);

		dataTemplate.forEach((element) => {
			let tempObject = {};
			tempObject.label = element.label;
				if (element.fieldName == "Sem valor na API") {
					tempObject.fieldName = "Sem valor na API";
				} else {
					let foundValue = rowToLookup[element.fieldName];
					if (Utils.isEmptyString(foundValue)) {
						foundValue = " - ";
					} else {
						tempObject.fieldName = foundValue;
					}
				}
			this.selectedRow.push(tempObject);
		});

    if (!Utils.isEmptyString(this.selectedRow)) {
      this.showDetailsModal();
    } else {
      Utils.showToast(
        this,
        "error",
        null,
        "O modal não possui dados para exibição"
      );
      this.loadingModalSpinner = false;
    }
  }

	performRowApiRequest(apiToCallOnRowRequest, protocolNumber) {
		getModalApiData({
			serviceToCall: apiToCallOnRowRequest,
			param: protocolNumber
		})
			.then((success) => {
				console.log("SUCESSO--->", JSON.parse(success.apiRowCallResponseData));
				this.rowResponseData = JSON.parse(success.apiRowCallResponseData);
				this.showModalPaginationComponent = true;
				this.loadingProtocolSpinner = false;
			})
			.catch((error) => {
				let message = error.body.message;
				if(!Utils.isEmptyString){

          Utils.showToast(
            this,
            "warning",
            null,
            "Falha ao carregar os dados de protocolo: " + message
          );
        } else {
          Utils.showToast(
            this,
            "warning",
            null,
            "Falha ao carregar os dados de protocolo"
          );

				}
				this.loadingProtocolSpinner = false;
				this.rowResponseData = [];
			});
		}

  showDetailsModal() {
    this.template.querySelector("c-solar-modal").open();
  }

		handleCloseModal() {
			console.clear();
			this.selectedRow = [];
			this.template.querySelector("c-solar-modal").close();
		}
	handleFilterNotification(event) {
		console.log(this.jsonLogger(event));
		switch (event.detail.filterType) {
			case "CUSTOMPERIOD":
				this.startDateFilterValue = event.detail.value.startDate;
				this.endDateFilterValue = event.detail.value.endDate;
				this.isCustomDateFilterValue = true;
				this.applyFilterHandler();
				break;
			case "PERIOD":
				this.periodFilterValue = event.detail.value;
				this.isCustomDateFilterValue = false;
				this.applyFilterHandler();
				break;
			case "SEARCH":
				this.filterDataTables(event.detail.value);


				break;
			default:
				break;
		}
	}

  jsonLogger(value) {
    return JSON.parse(JSON.stringify(value));
  }

	applyFilterHandler() {
		this.alreadyOpenedAccordions = [];
		this.openedAccordions = [];
		this.activeSections = [];

	this.accordionsList.forEach(accordion => {
		accordion.dataEmpty = false;
		accordion.dataError = false;
	});
    Utils.showToast(this, "success", null, this.labels.filterAppliedLabel);
  }
  filterDataTables(keyword) {
    this.renderList = false;
    this.loadingSpinner = true;
    this.accordionsList.forEach((accordion, i) => {
      if (Utils.isEmptyArray(accordion.responseData)) {

				if(Utils.isEmptyString(keyword)){
					this.accordionsList[i].responseData = accordion.originalContent;
				}
				return;
			}
			let filteredContent = accordion.originalContent.filter((x) => {

        if (
          JSON.stringify(Object.values(x))
            .toLocaleLowerCase()
            .includes(keyword.toLowerCase())
        )
          return x;
      });
      if (!Utils.isEmptyString(keyword)) {
        this.accordionsList[i].responseData = filteredContent;
      } else {
        this.accordionsList[i].responseData = accordion.originalContent;

			}
		});
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			this.loadingSpinner = false;
			this.renderList = true;
		}, 50);
	}


}