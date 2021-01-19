/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 30-12-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
 * 1.1   30-12-2020   Caio Cesar      Inserindo chamada para ContestationAdjustment
**/
import { LightningElement, api, wire, track} from 'lwc';
import getInvoiceDetails from "@salesforce/apex/FinancialMobileInvoicesConfirmation.getListContestation";
import postContestationAdjustment from "@salesforce/apex/FinancialMobileContestationAdjustment.postContestationAdjustment";
import Utils from "c/solarUtils";
import vlocity_cmt__FailureMessage__c from '@salesforce/schema/vlocity_cmt__ContextRule__c.vlocity_cmt__FailureMessage__c';

export default class SolarFinanceiroConfirmacaoContestacao extends LightningElement {

    @api baseAttributes;
    @api baseDetail;
    @api sendData;

    @track isAuthority = true; //Alçada

    @track StatusOpen = false;
    @track envioSegundaVia = false;
    @track data;
    @track error;
    @track disabledNextStep = true;
    statusFatura = 'Paga';
    @track activeSections = ['accordionChanged'];

    //layout control
    hasData = false;
    hasError = false;
    disableContestacao = true;

    //sort control
    defaultSortDirection = 'asc';
    sortDirectionChanged = 'asc';
    sortByChanged;
    sortDirection = 'asc';
    sortedBy;
    gridExpandedRows;

    //Modal
    @track modalHeader = 'Efetivação';
    @track modalIcon = 'utility:success';
    @track modalVariantIcon = 'success';
    @track ModalText;

    connectedCallback() { this.fetchDetailsInvoices();}

  async fetchDetailsInvoices() 
  {
		const data = await getInvoiceDetails({ dataInvoice: '' }).catch((err) => {
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

        if (this.hasError) return;
        console.log('data', JSON.parse(JSON.stringify(data)));

		this.data = data;
		this.hasData = !Utils.isEmptyArray(data);
    }

    handleSortChanged(event) 
    {
        this.sortByChanged = event.detail.fieldName;
        this.sortDirectionChanged = this.sortDirectionChanged == 'asc' ? 'dsc' : 'asc';

        let sortField = this.sortByChanged;
        if (this.sortByChanged === "value") sortField = "rawValue";

        let data = Utils.sortData(sortField, this.sortDirectionChanged, this.data.lstChanged);
        this.data.lstChanged = data;
    }

    handleSortNotChanged(event) 
    {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = this.sortDirection == 'asc' ? 'dsc' : 'asc';

        let sortField = this.sortBy;
        if (this.sortBy === "value") sortField = "rawValue";

        let data = Utils.sortData(sortField, this.sortDirection, this.data.lstNotChanged);
        this.data.lstNotChanged = data;
    }

    @track creditType;
    get options() 
    {
      if(this.statusFatura != 'Paga')
      {
        return [ { label: 'Emitir Boleto com valor corrigido', value: 'boleto'},
                 { label: 'Crédito no proximo faturamento', value: 'credito' }];
                
        StatusOpen = true;
      }
      else
      {
        return [ { label: 'Crédito Pendente', value: 'credito', variant:'destructive-text'},
                 { label: "Reembolso", type: "button", value: 'reembolso', typeAttributes: { label: "Reembolso", variant: "destructive", disable: true }} ];
                 
         StatusOpen = false;    
      }
    }

   // Troquei os valores do if pelo else, para atender a Estoria 100168 - 
  getTypeCredit(event)
  {
    this.creditType = event.detail.value;
    if(this.creditType == 'reembolso')
    {
      this.disabledNextStep = true;
    }
    else{
      this.disabledNextStep = false;
    }
  }

  handleVoltar() 
  {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("backcontestation", { detail: selectedBill }));
  }

  handleNextStep() 
  {
    console.log('handleNextStep', this.creditType);
    if(this.isAuthority == true){
      console.log('isAuthority: ', this.isAuthority, ' (Dentro da alçada)');
      if(this.creditType == 'credito')
      {
        this.postContestationAdjustments();
      }
      else if(this.creditType == 'reembolso' )
      {
        this.handleRefund();
      }
      else
      {
        this.handleFinish();
      }
    }
    else{
      this.modalIcon = 'utility:warning';
      this.modalVariantIcon = 'warning';
      this.ModalText = 'Contestação enviada para o Back Office. Você não possui alçada para uma operação com este valor';
      this.template.querySelector("c-solar-modal").open();
      console.log('isAuthority: ', this.isAuthority, ' (Fora da alçada)');
      Utils.showToast(this, "warning", null, 'Envio para BackOffice Não implementado');
    }
  }

  handleRefund() 
  {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("openrefund", { detail: selectedBill }));
  }

  handleFinish() 
  {
		const selectedBill = {};
		this.dispatchEvent(new CustomEvent("finishcontestation", { detail: selectedBill }));
  }

  handleSendMethod(event)
  {
    this.sendData = event.detail;
    console.log('handleSendMethod', JSON.parse(JSON.stringify(this.sendData)));
    this.disabledNextStep = !this.sendData.validate;
  }

  async postContestationAdjustments() {
    let wrapperSelectedRow = {};
    //wrapperSelectedRow.accountIdInfo            = '123456';
    wrapperSelectedRow.charged                  = '98465123';
    wrapperSelectedRow.adjustmentAmount         = '1234,42';
    wrapperSelectedRow.adjustmentReasonCode     = 'Alteração de xpto';
    //wrapperSelectedRow.userComment              = 'comentario do usuário';
    //wrapperSelectedRow.cycleHeader              = 'Cycle Header';
    wrapperSelectedRow.subscriberNo             = '123456';
    //wrapperSelectedRow.voucher                  = '1';
    wrapperSelectedRow.billSeqNo                = '123'; //3 ultimos numeros do campo noteFiscalNumber
    //wrapperSelectedRow.voucherSeqNo             = '13645';
    //wrapperSelectedRow.externalProtocol         = 'External Protocol Id';
    wrapperSelectedRow.userMemo                 = 'comentário';
  	wrapperSelectedRow = JSON.stringify(wrapperSelectedRow);
    const dataPost = await postContestationAdjustment({contestationAdjustmentString: wrapperSelectedRow, caseId: this.baseAttributes.numeroCase}).catch((err) => {
      //this.hasData = false;
			//this.hasError = true;  
      Utils.showToast(this, "error", null, err.body.message);
    });

    if (this.hasError) return;
    console.log('dataPost: ' , dataPost);
    if(Utils.isEmptyArray(dataPost)){
        console.log('dataPost: VAZIO!!');
    }
    else{
      this.modalIcon = 'utility:success';
      this.modalVariantIcon = 'success';
      this.ModalText = 'Contestação realizada com sucesso';
      this.template.querySelector("c-solar-modal").open();
      console.log('dataPost SUCESSO!: ' , dataPost);
      let accountIdInfo = dataPost.accountIdInfo;
      let adjustmentSequenceNumber = dataPost.adjustmentSequenceNumber;
      console.log('AccointIdInfo: ' ,  accountIdInfo, ' AdjustmentSequenceNumber: ' , adjustmentSequenceNumber);
    }
  }

  handleCloseModal() {
		this.template.querySelector("c-solar-modal").close();
	}
}