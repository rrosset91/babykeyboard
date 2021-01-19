/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 10-30-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   27-10-2020   Diego Almeida   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import getInvoices from "@salesforce/apex/FinancialMobileInvoices.getInvoices";
import Utils from "c/solarUtils";

export default class SolarFaturasAbertas extends LightningElement {
  @api
  baseAttributes;
  @track
  data;
  @track
  sortBy;
  @track
  sortDirection;
  @track
  modalItem = {};
  columns = [
    {
      label: "TIPO",
      fieldName: "type",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "PRODUTO",
      fieldName: "product",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "STATUS",
      fieldName: "status",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "DATA DE VENCIMENTO",
      fieldName: "dueDate",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "CONTESTAÇÃO",
      fieldName: "contested",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "VALOR",
      fieldName: "value",
      type: "text",
      hideDefaultActions: true,
      sortable: "true"
    },
    {
      label: "",
      initialWidth: 73,
      type: "button",
      typeAttributes: {
        iconName: "utility:preview",
        label: "",
        name: "showDetail",
        disabled: false
      }
    }
  ];
  hasData = false;
  hasError = false;
  disableDetails = true;
  selectedItem;
  isLoading = false;

  connectedCallback() {
    this.fetchOpenInvoices();
  }

  async fetchOpenInvoices() {
    const data = await getInvoices({ contractId: null }).catch((err) => {
      this.hasData = false;
      this.hasError = true;
      Utils.showToast(this, "error", null, err.body.message);
    });

    if (this.hasError) return;

    this.data = data;
    this.hasData = !Utils.isEmptyArray(data);
  }

  handleRefreshNotification(event) {
    console.log("ev -> ", JSON.parse(JSON.stringify(event.detail)));
  }

  handleFilterNotification(event) {
    console.log("ev -> ", JSON.parse(JSON.stringify(event.detail)));
  }

  handleDetailsClick() {
    this.dispatchEvent(
      new CustomEvent("fetchdetails", { detail: this.selectedItem })
    );
  }

  handleRowAction(event) {
    this.modalItem = event.detail.row;
    this.template.querySelector("c-solar-modal").open();
  }

  handleRowSelection(event) {
    console.log("joao", event.detail.selectedRows[0]);

    this.disableDetails = false;
    this.selectedItem = event.detail.selectedRows[0];
  }

  handleCloseModal() {
    this.template.querySelector("c-solar-modal").close();
  }

  handleSortdata(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;

    let sortField = this.sortBy;
    if (this.sortBy === "value") sortField = "rawValue";

    let data = Utils.sortData(sortField, this.sortDirection, this.data);
    this.data = data;
  }

  abrirModalSegundaVia() {
    this.isLoading = true;
    this.template.querySelector("c-solar-financeiro-segunda-via").open();
  }
}