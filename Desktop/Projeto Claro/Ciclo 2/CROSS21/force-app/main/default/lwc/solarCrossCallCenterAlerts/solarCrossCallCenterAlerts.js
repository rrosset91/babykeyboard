/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Parent Component used to render alerts in Case records
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-27      Jean Sganzerla          class created 
**************************************************************************************************************/
import { LightningElement, wire, track, api } from 'lwc';
import getAlerts from '@salesforce/apex/CEC_CallCenter_Alerts_Controller.getAlerts';
import concludeAlertApex from '@salesforce/apex/CEC_CallCenter_Alerts_Controller.concludeAlertApex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import { NavigationMixin } from 'lightning/navigation';
export default class SolarCrossCallCenterAlerts extends NavigationMixin(LightningElement) {

    @api recordId;
    @track data;
    containData = false; 
    containSegmentedAlerts = false;
    containGeneralAlerts = false;

    containSignalAlerts = false;

    allAlertsConcluded = false;
    segmentedAccordionLabel;
    generaldAccordionLabel;
    isModalConclusionOpen = false;
    @api contexteRecordInConclusionModal = {lId:null, lReason:null, lFeedbackToCustomer:null, lShow:null};
    @track showSpinner = false;

    @track renderOutputFields = true;
    @track fields = ["Reason__c","FeedbackToCustomer__c","CreatedById","CreatedDate","LastModifiedById","LastModifiedDate"];
    @api segmentedCount;
    @api signalCount;
    @api generalCount;
    @api signalView;
    // esc = false;
    // método que chama o controlador apex para receber os alertas

    @wire(getAlerts, { aCaseId: '$recordId' }) 
    alerts({error,data}){
        if(error){
            console.log('Alerts loaded failed - LWC ',error);
        }
        if(data){
            console.log('Alerts loaded succefully - LWC');
            // console.log('data Alerts - LWC ' +JSON.stringify(data));
            // console.log('teste length ' + data.segmentedAlerts.length );
            // console.log('teste length ' +  data.generalAlerts.length);

            if(data.segmentedAlerts.length > 0 || data.generalAlerts.length > 0 || data.signalAlerts.length > 0){

                this.data = JSON.parse(JSON.stringify(data)); 
                this.containData = true;
                this.containSegmentedAlerts = data.segmentedAlerts.length > 0 ? true : false;
                this.containGeneralAlerts = data.generalAlerts.length > 0 ? true : false;

                this.containSignalAlerts = data.signalAlerts.length > 0 ? true : false;                
                this.segmentedAccordionLabel = 'Cliente';
                this.generaldAccordionLabel = 'Gerais';
                this.segmentedCount = this.data.segmentedAlerts.length;
                this.generalCount = this.data.generalAlerts.length;
                this.signalCount = this.data.signalAlerts.length;

            }
        }  
    }   

    // método que chama o controlador apex para concluir um alerta

    concludeAlertClick(){
        this.showSpinner = true;
        console.log('contexteRecordInConclusionModal.lId ' + this.contexteRecordInConclusionModal.lId);
        var alertToConclude = this.contexteRecordInConclusionModal.lId;
        concludeAlertApex({aAlertId: alertToConclude, aCaseId: this.recordId, aAlertWrapper: JSON.stringify(this.contexteRecordInConclusionModal)})
        .then(result =>{
            this.showSpinner = false;
            this.closeModalConclusion();
            console.log('Update Success: ' + result);    
            this.removeFromData(this.contexteRecordInConclusionModal);        
            const event = new ShowToastEvent({
                title: 'Sucesso',
                message: 'O alerta foi concluído com sucesso!',
                variant: 'success'
            });
            this.dispatchEvent(event);

            this.contexteRecordInConclusionModal = {lId:null, lReason:null, lFeedbackToCustomer:null, lShow:null};

        })
        .catch(error =>{
            this.showSpinner = false;
            console.log('Update failed: ',error);
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'Erro ao tentar concluir o alerta. Entre em contato com um administrador do sistema.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        })
    }

    // método que abre o modal de detalhes do alerta

    openModalDetail(event){
        console.log('event.detail' + JSON.stringify(event.detail));
        this.template.querySelector('[data-id="modalDetail"]').classList.add('slds-fade-in-open');
        this.template.querySelector('[data-id="backDropDetail"]').classList.add('slds-backdrop--open');

        this.contexteRecordInConclusionModal = JSON.parse(JSON.stringify(event.detail));
        this.contexteRecordInConclusionModal.lDescription = this.contexteRecordInConclusionModal.lDescription == null ? '--' : this.contexteRecordInConclusionModal.lDescription;
        this.contexteRecordInConclusionModal.lResolution =  this.contexteRecordInConclusionModal.lResolution == null ? '--' : this.contexteRecordInConclusionModal.lResolution;
        this.contexteRecordInConclusionModal.lGeneralAlertType = this.contexteRecordInConclusionModal.lGeneralAlertType == null ? '--' : this.contexteRecordInConclusionModal.lGeneralAlertType;
        this.contexteRecordInConclusionModal.lCategorization = this.contexteRecordInConclusionModal.lCategorization == null ? '--' : this.contexteRecordInConclusionModal.lCategorization;
        this.contexteRecordInConclusionModal.lProductType = this.contexteRecordInConclusionModal.lProductType == null ? '--' : this.contexteRecordInConclusionModal.lProductType;
        this.signalView = event.detail.lGeneralAlertType == 'Problemas de Rede' ? true : false;
        // this.keycheck();        
    }
    // método que fecha o modal de detalhes do alerta
    closeModalDetail(){
        this.template.querySelector('[data-id="modalDetail"]').classList.remove('slds-fade-in-open');
        this.template.querySelector('[data-id="backDropDetail"]').classList.remove('slds-backdrop--open');
        this.renderOutputFields = true;
        // this.contexteRecordInConclusionModal = {lId:null, lReason:null, lFeedbackToCustomer:null, lShow:null};
    }   
    // método que abre o modal de conclusão do alerta

    openModalConclusion(){
        this.closeModalDetail();
        this.template.querySelector('[data-id="modalConclude"]').classList.add('slds-fade-in-open');
        this.template.querySelector('[data-id="backDropConclude"]').classList.add('slds-backdrop--open');
        // this.contexteRecordInConclusionModal = event.target.value;
        // console.log(' event.target.value.lId ' +  event.target.value);
        // console.log('contexteRecordInConclusionModal.lId ' + this.contexteRecordInConclusionModal);
        // this.keycheck();
    }

    // método que fecha o modal de conclusão do alerta

    closeModalConclusion(){
        this.template.querySelector('[data-id="modalConclude"]').classList.remove('slds-fade-in-open');
        this.template.querySelector('[data-id="backDropConclude"]').classList.remove('slds-backdrop--open');
    }

    // método que abre ou fecha o submodal dos itens

    changeItemShow(event){
        console.log('detail ' + JSON.stringify(event.detail));
        // console.log('record ' + JSON.stringify(event.changeitem));
        var record = event.detail;
        var show = record.lShow;
        var id = record.lId;
        show = show == true ? false : true;
        if(record.lRecordTypeDeveloperName == 'Alerts'){
            for(var i = 0; i < this.data.segmentedAlerts.length; i++){
                if(this.data.segmentedAlerts[i].lId == id){
                    this.data.segmentedAlerts[i].lShow = show;
                }
            }
        }
        else{
            for(var i = 0; i < this.data.generalAlerts.length; i++){
                if(this.data.generalAlerts[i].lId == id){
                    this.data.generalAlerts[i].lShow = show;
                }
            }
        }
    }

    // método que remove o alerta concluído da lista de alertas que está sendo exibida no componente

    removeFromData(record){        
        var id = record.lId;
        if(record.lRecordTypeDeveloperName == 'Alerts'){
            for(var i = 0; i < this.data.segmentedAlerts.length; i++){
                if(this.data.segmentedAlerts[i].lId == id){
                    // i representa a posição que está sendo removida e 1 representa a quantidade de índices que serão removidos
                    this.data.segmentedAlerts.splice(i,1);

                    this.segmentedCount = this.data.segmentedAlerts.length;
                    break;
                }
            }
        }
        else{
            if(record.lGeneralAlertType == 'Problemas de Rede'){
                for(var i = 0; i < this.data.signalAlerts.length; i++){
                    if(this.data.signalAlerts[i].lId == id){
                        // i representa a posição que está sendo removida e 1 representa a quantidade de índices que serão removidos
                        this.data.signalAlerts.splice(i,1);
                        this.signalCount = this.data.signalAlerts.length;

                    break;
                }
            }
        }
        else{
            for(var i = 0; i < this.data.generalAlerts.length; i++){
                if(this.data.generalAlerts[i].lId == id){
                    // i representa a posição que está sendo removida e 1 representa a quantidade de índices que serão removidos
                    this.data.generalAlerts.splice(i,1);

                        this.generalCount = this.data.generalAlerts.length;

                    break;
                }
            }
        }

        }
        this.containSegmentedAlerts = this.data.segmentedAlerts.length > 0 ? true : false;
        this.containGeneralAlerts = this.data.generalAlerts.length > 0 ? true : false;
        this.containSignalAlerts = this.data.signalAlerts.length > 0 ? true : false;
        this.allAlertsConcluded =  this.data.segmentedAlerts.length == 0 && this.data.generalAlerts.length == 0 && this.data.signalAlerts.length == 0 ? true : false;
    }
    // método que navega até a página do usuário que criou o alerta
    navigateToCreatedBy(){
        this.navigateToUrlButton(this.contexteRecordInConclusionModal.lCreatedById);
    }
    // método que navega até a página do usuário que modificou o alerta
    navigateToModifiedBy(){
        this.navigateToUrlButton(this.contexteRecordInConclusionModal.lCreatedById);
    }
    navigateToUrlButton(aIdToNavigate){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: aIdToNavigate,
                objectApiName: 'User',
                actionName: 'view'
            },
        });

    }
    // keycheck(){        
    //     window.addEventListener("keydown", function(event) {
    //         var kcode = event.code;
    //         if(kcode == 'Escape'){
    //             console.log('esc pressionado');      
    //                 this.closeModalConclusion();
    //         }
    //     }, true);
    // }
}