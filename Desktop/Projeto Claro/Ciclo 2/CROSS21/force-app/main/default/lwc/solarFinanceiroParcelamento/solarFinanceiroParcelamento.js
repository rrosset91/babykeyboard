/**
 * @description       : Componente responsável por exibir as opcoes de parcelamento para negociacao
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociacao
 * @last modified on  : 19-01-2021
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
      show: false,
      message: undefined
    }
  };

  @track hasAuthority;
  @track selectedInstallment;
  @track installmentsOptions = [];
  @track installmentsValues = [];

  connectedCallback() {
    //this.uiProperties.generalUi.isLoading = true;
    //this.uiProperties.installmentOptions.isLoading = true;
    //this.fetchInstallmentOptions();
  }

  fetchInstallmentOptions() {
    getInstallmentsOptions({
      caseId: this.baseAttributes.caseId,
      bills: this.baseAttributes.bills,
      statements: this.baseAttributes.statements
    })
      .then((success) => {
        if (
          Utils.jsonLogger(success.alcada) &&
          Utils.jsonLogger(success.success)
        ) {
          this.hasAuthority = true;
          this.uiProperties.generalUi.hasError = false;
          this.show("general");
          this.installmentsOptions = this.treatOptions(
            success,
            "installmentOptions"
          );
          this.show("installments");
        } else {
          this.uiProperties.generalUi.isLoading = false;
          this.uiProperties.generalUi.hasError = true;
          this.hasAuthority = false;
          this.uiProperties.installmentOptions.isLoading = false;
          this.errorHandler("Usuário sem alçada", "modal");
        }
      })

      .catch((error) => {
        this.uiProperties.generalUi.isLoading = false;
        this.uiProperties.generalUi.hasError = true;
        this.installmentsOptions = [];
        this.uiProperties.installmentOptions.isLoading = false;
        this.errorHandler(error.errorMessage, "toast");
      });
  }

  handleInstallmentSelection(event) {
    console.log(event.currentTarget.id);
    let installmentId = event.currentTarget.id;
    let allOptions = this.template.querySelectorAll(
      '[data-id="installmentOption"]'
    );
    allOptions.forEach((option) => {
      let usedClasses = [];
      let appliedClasses = option.classList;
      appliedClasses.forEach((usedClass) => {
        usedClasses.push(usedClass);
      });
      if (
        !usedClasses.includes("installment-selected") &&
        option.id == installmentId
      ) {
        option.classList.remove("installment-option");
        option.classList.add("installment-selected");
      } else if (
        usedClasses.includes("installment-selected") &&
        option.id != installmentId
      ) {
        option.classList.add("installment-option");
        option.classList.remove("installment-selected");
      }
    });
    //this.uiProperties.dataTable.isLoading = true;
    //this.selectedInstallment = Utils.jsonLogger(event.target.value);
    //this.fetchInstallmentValues();
  }

  fetchInstallmentValues() {
    getInstallmentValues({
      request: JSON.stringify(this.selectedInstallment)
    })
      .then((success) => {
        if (Utils.jsonLogger(success.success)) {
          this.installmentsValues = this.treatOptions(
            success.dadosParcelamento,
            "installmentValues"
          );
          this.uiProperties.dataTable.hasError = false;
          this.show("datatable");
        } else {
          this.uiProperties.dataTable.isLoading = false;
          this.uiProperties.dataTable.hasError = true;
          this.errorHandler(
            "Erro ao consultar os detalhes do parcelamento",
            "modal"
          );
        }
      })

      .catch((error) => {
        this.installmentsValues = [];
        this.uiProperties.dataTable.hasError = true;
        this.uiProperties.dataTable.isLoading = false;
        this.errorHandler(error.errorMessage, "toast");
      });
  }

  treatOptions(data, context) {
    let treatedData = Utils.jsonLogger(data);
    switch (context) {
      case installmentOptions:
        let installmentsList = [];
        treatedData.dadosParcelamento.forEach((parcela, index) => {
          parcela.label = parcela.labelParcelamento;
          parcela.details = parcela;
          parcela.installmentId = parcela.label + index;
          installmentsList.push(parcela);
        });
        return installmentsList;
      case installmentValues:
        let installmentDetails = [];
        let totalInstallments = treatedData.parcelas.length();
        treatedData.parcelas.forEach((parcela) => {
          parcela.dueMonth = Utils.getMonthName(parcela.vencimento);
          parcela.installmentNumber = `${parcela.numeroParcela}/${totalInstallments}`;
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
        this.uiProperties.general.isLoading = false;
        this.uiProperties.general.show = true;
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
        this.uiProperties.modal.isLoading = false;
        this.uiProperties.modal.show = true;
        break;
      default:
        break;
    }
  }
  handleBack() {
    const selectedBill = {};
    this.dispatchEvent(
      new CustomEvent("opennegociacao", { detail: selectedBill })
    );
  }

  submitNegotiation() {
    const selectedBill = {};
    this.dispatchEvent(
      new CustomEvent("openresumonegociacao", { detail: selectedBill })
    );
  }
}
