/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 16-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   27-10-2020   Diego Almeida   Initial Version
 **/

import { LightningElement, api, track } from "lwc";
import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoicesDetailsController.getInvoiceDetails";
import Utils from "c/solarUtils";
//import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoicesDetailsController.getListInvoiceDetails";

export default class SolarFinanceiroDetalhedaFatura extends LightningElement {
	@api baseAttributes;
	@api baseDetail;
	selectedItems = [];

	@track hasData = true;
	@track hasError = false;
	@track contestationDisabled = true;

	@track dataTable = [];

	//Verifica se o dataTable está carregado
	@track loadedPlanoContratado = false;

	//Ordenação do datatable
	@track sortBy;
	@track sortDirection;

	// **************** DATATABLE ****************
	@track columns = [
		{ label: "Item", fieldName: "item", type: "text", sortable: true },
		{ label: "Linha", fieldName: "linha", type: "text", sortable: true },
		{ label: "Data de Lançamento", fieldName: "dataLancamento", type: "text", sortable: true },
		{ label: "Consumo", fieldName: "consumo", type: "text", sortable: true },
		{ label: "Contestável", fieldName: "contestavel", type: "text", sortable: true },
		{ label: "Ajuste", fieldName: "ajuste", type: "currency", sortable: true },
		{ label: "Valor", fieldName: "valor", type: "currency", sortable: true }
	];

	contestationItems = [];

	connectedCallback() {
		console.log('baseDetail', JSON.parse(JSON.stringify(this.baseDetail)));
		console.log('baseAttributes', JSON.parse(JSON.stringify(this.baseAttributes)));
		if (this.baseDetail.contestationItems) {
			this.contestationItems = this.baseDetail.contestationItems;
			this.selectedItems = this.baseDetail.contestationItems;
		}
	}

	async fetchDetailsInvoices() {
		const data = await getInvoiceDetails({ noteFiscalNumber: this.baseDetail.noteFiscalNumber }).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (this.hasError) return;
		console.log('data.responseData: ' , data.responseData);
		if(Utils.isEmptyArray(data.responseData)){
			this.hasData = false;
		}
		else{
			this.dataTable = data.responseData;
			this.setSelectedItems();
		}
		
	}

	setSelectedItems() {
		let selectedItems = [];
		if (this.contestationItems) {
			this.contestationItems.forEach((x) => {
				selectedItems.push(x.chargeId);
			});
		}

		this.checkCanContest(this.contestationItems);

		this.template.querySelector('[data-id="datatable"]').selectedRows = selectedItems;
	}

	checkCanContest(arrItems) {
		let notContestable = [];

		if (Utils.isEmptyArray(arrItems)) {
			this.contestationDisabled = true;
		} else {
			arrItems.forEach((x) => {
				notContestable.push(x.contestavel);

				if (notContestable.includes("Não")) {
					this.contestationDisabled = true;
				} else {
					this.contestationDisabled = false;
				}
			});
		}
	}

	handleRowSelection(event) {
		this.selectedItems = event.detail.selectedRows;

		this.checkCanContest(this.selectedItems);
	}

	handleLoadPlanoContratado() {
		if (this.loadedPlanoContratado == false) {
			this.loadedPlanoContratado = true;
			this.fetchDetailsInvoices();
		}
	}

	onHandleSort(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;

		let sortField = this.sortBy;
		if (this.sortBy === "formatAmount") sortField = "rawAmount";
		if (this.sortBy === "formatDueDate") sortField = "rawDueDate";

		let data = Utils.sortData(sortField, this.sortDirection, this.dataTable);
		this.dataTable = data;
	}

	handleVoltar() {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("backfaturas", { detail: selectedBill }));
	}

	handleOpenPDF() {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("openpdf", { detail: selectedBill }));
	}

	handleContestation() {
		let newArr = [];
		if (this.contestationItems) {
			this.selectedItems.forEach((selectedInst) => {
				let newObj = JSON.parse(JSON.stringify(selectedInst));

				this.contestationItems.forEach((contestationInst) => {
					if (newObj.chargeId !== contestationInst.chargeId) return;

					newObj.reason = contestationInst.reason;
					newObj.valorContestar = contestationInst.valorContestar;
					newObj.valorCorrigido = contestationInst.valorCorrigido;
				});

				newArr.push(newObj);
			});
		}

		this.dispatchEvent(new CustomEvent("contestation", { detail: newArr }));
	}

	//------------------------------------------ Antigo GRID

	// @api baseAttributes;
	// @api baseDetail;

	// @track data;
	// @track error;

	// //layout control
	// hasData = false;
	// hasError = false;
	// disableContestacao = true;

	// //sort control
	// defaultSortDirection = 'asc';
	// sortDirection = 'asc';
	// sortedBy;
	// gridExpandedRows;

	// connectedCallback() {
	//   this.fetchDetailsInvoices();
	// }

	// async fetchDetailsInvoices() {
	// 	const data = await getInvoiceDetails({ dataInvoice: '' }).catch((err) => {
	// 		this.hasData = false;
	// 		this.hasError = true;
	// 		Utils.showToast(this, "error", null, err.body.message);
	// 	});

	//       if (this.hasError) return;
	//       console.log('baseDetail', JSON.parse(JSON.stringify(this.baseDetail)));
	//       console.log('baseAttributes', JSON.parse(JSON.stringify(this.baseAttributes)));
	//       //baseAttributes
	//       console.log('data', JSON.parse(JSON.stringify(data).replaceAll('children', '_children')));

	//       //Alterar para criar vinculo entre a  hierarquia no DataTreeGrid
	// 	this.data = JSON.parse(JSON.stringify(data).replaceAll('children', '_children'));
	// 	this.hasData = !Utils.isEmptyArray(data);
	// }

	// handleRowAction(event) {
	//     console.log(event.detail.row);
	// }

	// handleVoltar() {
	//   const selectedBill = {};
	//   this.dispatchEvent(new CustomEvent("backfaturas", { detail: selectedBill }));
	// }

	// handleOpenPDF() {
	//   const selectedBill = {};
	//   this.dispatchEvent(new CustomEvent("openpdf", { detail: selectedBill }));
	// }

	// handleContestation() {
	//   console.log('handleContestation');
	// 	const selectedBill = {};
	// 	this.dispatchEvent(new CustomEvent("contestation", { detail: selectedBill }));
	// }
}