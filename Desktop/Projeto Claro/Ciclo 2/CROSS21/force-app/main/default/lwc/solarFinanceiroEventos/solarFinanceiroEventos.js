/**
 * @description       : Controller js
 * @author            : Roger Rosset
 * @group             : Financeiro - Eventos

 * @last modified on  : 11-12-2020

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

import msisdnEventsGroup from "@salesforce/label/c.Fin_mob_msisdn_accordion_title";
import contractEventsGroup from "@salesforce/label/c.Fin_mob_contract_accordion_title";

import filterAppliedLabel from "@salesforce/label/c.Fin_filter_success";
export default class SolarFinanceiroEventos extends LightningElement {
  @api baseAttributes;
  @track loadingSpinner = false;
  @track loadingInitSpinner = true;
  @track loadingModalSpinner = false;

	@track loadingProtocolSpinner = false;
	@track showModalPaginationComponent = false;
	@track accordionsList = [];

  @track periodFilterValue = 6;
  @track startDateFilterValue;
  @track endDateFilterValue;
  @track isCustomDateFilterValue = false;

	@track activeSections = [];

  @track columnsIndex = [];
  @track sortBy;
  @track sortDirection;
  @track apiCallAttributes = {};
  @track modalData;
  @track selectedRow = [];
  @track rowResponseData = [];

	@track labels = {};
	@track renderList = true;
	@track msisdnList = [];
	@track defaultMsisdn;
	@track valueMsisdn;
	@track msisdnListSet = false;

  //---------------------------------------------TRAZER LISTAGEM DOS ACCORDIONS VINDA DO CONTROLLER-------------------------------------------------------
  connectedCallback() {
    this.loadingInitSpinner = true;

		this.getMsisdnList(this.baseAttributes.recordId);
		console.log(this.jsonLogger(this.baseAttributes));
		this.defineLabels();
	}
	defineLabels() {
		this.labels.eventsErrorLabel = eventsErrorLabel1 + "\n" + eventsErrorLabel2;
		this.labels.filterAppliedLabel = filterAppliedLabel;
		this.labels.contractEvents = contractEventsGroup;
		this.labels.msisdnEvents = msisdnEventsGroup;

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

		let accordionEvent = openedAccordions.filter((e) => !this.activeSections.find((a) => e == a))[0];
		if (!this.activeSections.includes(accordionEvent) && accordionEvent != undefined) {
			this.activeSections.push(accordionEvent);

    } else {
      accordionEvent = undefined;
      return;
    }

		let toggledAccordionName = this.activeSections[this.activeSections.length - 1];
		let selectedAccordion = accordionsListData.filter((item) => item.accordionId == toggledAccordionName)[0];
		let selectedAccordionIndex = accordionsListData.indexOf(selectedAccordion);
		selectedAccordion = JSON.parse(JSON.stringify(selectedAccordion));
		if (accordionEvent != undefined && selectedAccordion.attributes.implemented) {
			this.loadingSpinner = true;
			this.performApiRequest(selectedAccordion, selectedAccordionIndex);
		} else if (accordionEvent != undefined && selectedAccordion.attributes.implemented == false) {
			alert("Não implementado");
			this.accordionsList[selectedAccordionIndex].dataEmpty = true;
			this.spinnerOff("loading");
		} else {
			this.spinnerOff("loading");

    }
  }
  //-----------------------------------FUNÇÃO RESPONSÁVEL POR REALIZAR CHAMADAS DOS ACCORDIONS PARA API NO BACKEND----------------------------------------
  performApiRequest(requesterAccordion, accordionIndex) {
    let requireMsisdn = this.accordionsList[accordionIndex].requireMsisdn;

		let requireCrmCustomerId = this.accordionsList[accordionIndex].requireCrmCustomerId;
		if (Utils.isEmptyString(this.apiCallAttributes.msisdn) && requireMsisdn) {
			let error = "MSISDN não definido";
			this.accordionsList[accordionIndex].dataError = true;
			this.spinnerOff("loading");
			return Utils.showToast(this, "error", null, error);
		} else if (Utils.isEmptyString(this.apiCallAttributes.customerCrmId) && requireCrmCustomerId) {
			let error = "CrmCustomerId não definido";
			this.apiCallFailed(accordionIndex);
			this.accordionsList[accordionIndex].dataError = true;
			this.spinnerOff("loading");

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

				this.spinnerOff("loading");
				if (success.accordionData) {
					this.setAccordionData(success.accordionData, accordionIndex, accordionName);

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

				this.spinnerOff("loading");

        this.accordionsList[accordionIndex].dataError = true;
        Utils.showToast(this, "error", null, error);
      });
  }

	// --------------------------------------------- FUNÇÕES RELACIONADAS AOS DATATABLES -----------------------------------------------------------------

  onHandleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    let sortField = this.sortBy;

		let accordionId = this.columnsIndex.filter((item) => item.accordionColumnsData.includes(sortField))[0];

    let i = accordionId.accordionIndex;
    if (sortField.includes("formatted")) {
      sortField = sortField.replace("formatted", "real");
    }

		let sortedData = Utils.sortData(sortField, this.sortDirection, this.accordionsList[i].responseData);
		this.accordionsList[i].responseData = sortedData;
	}
	handleRowAction(event) {
		let relatedAccordion = event.detail.row.relatedAccordion;
		let accordionIndex = this.accordionsList.findIndex((element) => element.accordionId == relatedAccordion);
		let accordionData = this.accordionsList[accordionIndex];
		if (accordionData.attributes.callApiOnRowAction) {
			this.loadingProtocolSpinner = true;
			this.performRowApiRequest(accordionData.attributes.apiToCallOnRowAction, event.detail.row.protocolNumber);
		}
		let dataTemplate = this.accordionsList[accordionIndex].modalFields;
		let rowToLookup = this.jsonLogger(event.detail.row);

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

			Utils.showToast(this, "error", null, "O modal não possui dados para exibição");
			this.spinnerOff("modal");

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

				this.spinnerOff("protocol");

      })
      .catch((error) => {
        let message = error.body.message;
        if (!Utils.isEmptyString) {

					Utils.showToast(this, "warning", null, "Falha ao carregar os dados de protocolo: " + message);
				} else {
					Utils.showToast(this, "warning", null, "Falha ao carregar os dados de protocolo");
				}
				this.spinnerOff("protocol");

        this.rowResponseData = [];
      });
  }

	handleRefresh(event) {
		let accordionToRefresh = event.target.value;
		let callParams = { detail: { openSections: [] } };
		callParams.detail.openSections.push(accordionToRefresh);
		let filteredactiveSections = this.activeSections.filter((x) => x != accordionToRefresh);
		this.activeSections = filteredactiveSections;
		this.handleSectionToggle(callParams);
	}
	//-----------FUNÇÕES RESPONSÁVEIS POR ATUALIZAR OS DADOS DE CADA ACCORDION, QUE SERÃO USADOS NOS DATATABLES E DEFINIR PARAMETROS DE CHAMADAS-------------
	getMsisdnList(recordId) {
		if (!this.msisdnListSet) {
			getMsisdnFromApex({ caseId: recordId })
				.then((data) => {
					let msisdnOptions = this.generateMsisdnOptions(data);
					this.msisdnList = msisdnOptions;
					this.defaultMsisdn = msisdnOptions[0].value;
					this.apiCallAttributes.msisdn = this.defaultMsisdn;
					this.msisdnListSet = true;
					this.getCrmCustomerId(this.defaultMsisdn);
				})
				.catch((error) => {
					console.log(error);
					Utils.showToast(this, "error", null, "Não foi possível obter as linhas do contrato (MSISDN)");
					this.spinnerOff("loading");
					this.spinnerOff("init");
				});
		}
	}
	generateMsisdnOptions(list) {
		let optionList = [];
		list.forEach((item) => {
			let optionItem = {};
			optionItem.label = item;
			optionItem.value = item;
			optionList.push(optionItem);
		});
		console.log("MSISDN OPTIONS LIST ---->", optionList);
		return optionList;
	}
	getCrmCustomerId(msisdn) {
		getCustomerCrmIdFromApex({ msisdn: msisdn })
			.then((data) => {
				let returnedValue = data;
				this.apiCallAttributes.customerCrmId = returnedValue;
				console.log(this.jsonLogger(this.apiCallAttributes));
				this.spinnerOff("init");
				this.spinnerOff("loading");
			})
			.catch((error) => {
				console.log(error);
				Utils.showToast(this, "error", null, "Não foi possível definir o CrmCustomerId do contrato");
				this.spinnerOff("init");
				this.spinnerOff("loading");
			});
	}
	setAccordionData(accordion, index, accordionTitle) {
		let parsedResponse = JSON.parse(accordion);
		console.log("AccordionData definido ---->", parsedResponse);
		if (parsedResponse.length == 0) {
			console.log("Dados vazios --> emptyArray = true");
			this.spinnerOff("loading");
			this.accordionsList[index].showDataTable = false;
			this.accordionsList[index].noEventsLabel = `Não há itens de "${accordionTitle}" disponíveis para este resultado`;
			return (this.accordionsList[index].dataEmpty = true);
		}
		this.accordionsList[index].showDataTable = true;
		this.accordionsList[index].originalContent = parsedResponse;
		return (this.accordionsList[index].responseData = parsedResponse);
	}
	setAccordionColumns(accordion, index) {
		console.log("Colunas definidas ---->", (this.accordionsList[index].columns = JSON.parse(accordion)));
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
	apiCallFailed(index) {
		let accordionName = this.accordionsList[index].accordionId;
		this.activeSections = this.activeSections.filter((item) => item.accordionId == accordionName);
	}
	//-----------FUNÇÕES RELACIONADAS A FILTROS E CONTROLE DE EXIBIÇÃO-------------

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
			case "MSISDN":
				this.applyMsisdnFilterHandler(event.detail.value);

        break;
      default:
        break;
    }
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
	applyFilterHandler(option) {
		switch (option) {
			case "msisdnGroup":
				let msisdnAccordionsToCollapse = [];
				this.accordionsList.forEach((accordion) => {
					if (accordion.isMsisdnGroup) {
						msisdnAccordionsToCollapse.push(accordion.accordionId);
						accordion.dataEmpty = false;
						accordion.dataError = false;
					}
				});
				let filteredactiveSections = this.activeSections.filter((x) => !msisdnAccordionsToCollapse.includes(x));
				this.activeSections = filteredactiveSections;
				break;
			default:
				this.accordionsList.forEach((accordion) => {
					accordion.dataEmpty = false;
					accordion.dataError = false;
				});
				this.activeSections = [];
				break;
		}
		Utils.showToast(this, "success", null, this.labels.filterAppliedLabel);
	}
	//FILTRO DE MSISDN
	applyMsisdnFilterHandler(value) {
		this.getCrmCustomerId(value);
		this.apiCallAttributes.msisdn = value;
		this.applyFilterHandler("msisdnGroup");
		Utils.showToast(this, "success", null, this.labels.filterAppliedLabel);
	}
	//BUSCA VIVA
	filterDataTables(keyword) {
		this.renderList = false;
		this.loadingSpinner = true;

    this.accordionsList.forEach((accordion, i) => {
      if (Utils.isEmptyArray(accordion.responseData)) {
        if (Utils.isEmptyString(keyword)) {
          this.accordionsList[i].responseData = accordion.originalContent;
        }
        return;
      }
      let filteredContent = accordion.originalContent.filter((x) => {

				if (JSON.stringify(Object.values(x)).toLocaleLowerCase().includes(keyword.toLowerCase())) return x;

      });
      if (!Utils.isEmptyString(keyword)) {
        this.accordionsList[i].responseData = filteredContent;
      } else {
        this.accordionsList[i].responseData = accordion.originalContent;
      }
    });

		setTimeout(() => {
			this.spinnerOff("loading");
			this.renderList = true;
		}, 50);
	}
	//---------------------------------------------------------FUNÇÕES RELACIONADAS AO MODAL---------------------------------------------------------------
	showDetailsModal() {
		this.template.querySelector("c-solar-modal").open();
	}
	handleCloseModal() {
		console.clear();
		this.selectedRow = [];
		this.template.querySelector("c-solar-modal").close();
	}
	//---------------------------------------------------------FUNÇÕES UTILITÁRIAS---------------------------------------------------------------
	spinnerOff(context) {
		switch (context) {
			case "init":
				this.loadingInitSpinner = false;
				break;
			case "loading":
				this.loadingSpinner = false;
				break;
			case "protocol":
				this.loadingProtocolSpinner = false;
				break;
			case "modal":
				this.loadingModalSpinner = false;
				break;
			case "all":
				this.loadingInitSpinner = false;
				this.loadingSpinner = false;
				this.loadingProtocolSpinner = false;
				this.loadingModalSpinner = false;
				break;
			default:
				break;
		}
	}
	jsonLogger(value) {
		return JSON.parse(JSON.stringify(value));
	}

}