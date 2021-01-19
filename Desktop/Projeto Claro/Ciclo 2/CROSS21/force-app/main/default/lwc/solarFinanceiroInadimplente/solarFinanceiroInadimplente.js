import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import { NavigationMixin } from "lightning/navigation";
import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoicesDetailsController.getInvoiceDetails";

export default class SolarFinanceiroInadimplente extends LightningElement
{
    // **************** Decoradores Publicos ****************
    @api baseAttributes;
    @api baseDetail;
    @api selectedItems = [];
    // ******************************************************

    // **************** Decoradores Privados ****************
    @track activeSections   = ['accordionFatura', 'accordionlancamentoFuturos'];
    @track negociationItems = [];
    @track modalItem        = {};
    @track reasonContext    = {}; 
	@track hasData           = false; 
    @track hasError          = false; 
    @track buttonSimulation  = false;
    @track error;
    @track data;
    @track negotiationType;
    @track sortBy;
    @track sortDirection;
    // *******************************************************

	// **************** Interagindo com o componente ****************
    connectedCallback() 
    {
        // this.fetchDetailsInvoices();
        // if (this.baseDetail) 
        // {
        //     console.log('baseDetail', JSON.parse(JSON.stringify(this.baseDetail)));
		//     console.log('baseAttributes', JSON.parse(JSON.stringify(this.baseAttributes)));
		// 	this.negociationItems = this.baseDetail.negociationItems;
		// 	this.selectedItems = this.baseDetail.negociationItems;
		// }
    }

    async fetchDetailsInvoices() 
  {
		const data = await getInvoiceDetails({ dataInvoice: '' }).catch((err) => {
			this.hasData  = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

        if (this.hasError) return;
        console.log('data', JSON.parse(JSON.stringify(data)));

		this.data = data;
		this.hasData = !Utils.isEmptyArray(data);
    }
    // ***************************************************************
    
    // **************** Datatable ****************
    columns = [ 
                { label: "TIPO", fieldName: "type", type: "text", hideDefaultActions: true },
		        { label: "DATA VENCIMENTO", fieldName: "dataVencimento", type: "date", hideDefaultActions: true },
                { label: "VALOR", fieldName: "invoiceAmount", type: "Currency", hideDefaultActions: true }
              ];
                
    handleSortData(event) 
    {
        this.sortBy        = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        let sortField = this.sortBy;
        
        if (this.sortBy === "formatAmount") sortField = "rawAmount";
        if (this.sortBy === "formatDueDate") sortField = "rawDueDate";

        let data = Utils.sortData(sortField, this.sortDirection, this.data);
        this.data = data;
    }

    handleRowSelection(event)
    {
        this.disabledDetails = false;
		if (event.detail.selectedRows[0] != null)
        {this.buttonSimulation = false;}
         
        else {this.buttonSimulation = true;}
    }
    // ******************************************** 

    // **************** Evento Simular ****************
    handleSimulation()
    {   
        console.log("Click");
        const selectedBill = {};
		this.dispatchEvent(new CustomEvent("opensimulacao", { detail: selectedBill }));
        console.log("Nao disparou");
    }
    // ************************************************
}