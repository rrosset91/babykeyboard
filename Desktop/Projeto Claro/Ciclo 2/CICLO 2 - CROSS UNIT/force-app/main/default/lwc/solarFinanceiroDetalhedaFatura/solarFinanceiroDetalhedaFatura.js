/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 03-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   27-10-2020   Diego Almeida   Initial Version
**/

import { LightningElement, api, wire, track} from 'lwc';
import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoicesDetailsController.getListInvoiceDetails";
import Utils from "c/solarUtils";


export default class SolarFinanceiroDetalhedaFatura extends LightningElement {
    
    @api baseAttributes;
    @api baseDetail;
    
    @track data;
    @track error;
    
    //layout control
    hasData = false;
    hasError = false;
    disableContestacao = true;

    //sort control
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    gridExpandedRows;


    connectedCallback() {
		this.fetchDetailsInvoices();
	}

	async fetchDetailsInvoices() {
		const data = await getInvoiceDetails({ dataInvoice: '' }).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

        if (this.hasError) return;
        console.clear();
        console.log('baseDetail', JSON.parse(JSON.stringify(this.baseDetail)));
        console.log('data', JSON.parse(JSON.stringify(data).replaceAll('children', '_children')));
        
        //Alterar para criar vinculo entre a  hierarquia no DataTreeGrid
		this.data = JSON.parse(JSON.stringify(data).replaceAll('children', '_children'));
		this.hasData = !Utils.isEmptyArray(data);
    }

    handleRowAction(event) {
      console.log(event.detail.row);
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
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("contestation", { detail: selectedBill }));
	}
}