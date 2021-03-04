import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import urlReagendar from '@salesforce/label/c.URL_Reagendar';
import urlCancelar from '@salesforce/label/c.URL_Cancelar';
import urlPreAgendar from '@salesforce/label/c.URL_PreAgendar';

const FIELDS = [
    'Case.CaseNumber',
    'Case.Status'
];

export default class CEC_ME_CaseDetailButtons extends NavigationMixin(LightningElement) {
    @api recordId;

    label = {
        urlReagendar,
        urlPreAgendar,
        urlCancelar
    };

    @track MANAGER = {
        'New':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Cancel':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Solicitação Executada':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Solicitação em Analise':
        { 'reagendar': true, 'cancelar': false, 'agendar': true },
        'Pré-Agendamento':
        { 'reagendar': false, 'cancelar': false, 'agendar': false },
        'Agendamento':
        { 'reagendar': false, 'cancelar': true, 'agendar': true },
        'Pedido Realizado':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Realizado Entrega para o Técnico':
        { 'reagendar': true, 'cancelar': false, 'agendar': true },
        'Não executado':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Answered':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'Closed':
        { 'reagendar': true, 'cancelar': true, 'agendar': true },
        'In Progress':
        { 'reagendar': false, 'cancelar': false, 'agendar': true }
    };

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    caso;

    get agendar() {
        if (this.caso.data) {
            if(this.MANAGER[this.caso.data.fields.Status.value]){
                return this.MANAGER[this.caso.data.fields.Status.value].agendar;
            }
            return true;
        }
        return true;
    }
    get reagendar() {
        if (this.caso.data) {
            if(this.MANAGER[this.caso.data.fields.Status.value]){
                return this.MANAGER[this.caso.data.fields.Status.value].reagendar;
            }
            return true;
        }
        return true;    
    }
    get cancelar() {
        if (this.caso.data) {
            if(this.MANAGER[this.caso.data.fields.Status.value]){
                return this.MANAGER[this.caso.data.fields.Status.value].cancelar;
            }
            return true;
        }
        return true;
    }

    getManagerProperties(){

    }

    goToAgendar() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.urlPreAgendar.replace('{0}', this.recordId).replace('{0}', this.recordId)
            }
        },
            true
        );
    } 
    goToReagendar() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.urlReagendar.replace('{0}', this.recordId).replace('{0}', this.recordId)
            }
        },
            true
        );
    }
    goToCancelar() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.urlCancelar.replace('{0}', this.recordId).replace('{0}', this.recordId)
            }
        },
            true
        );
    }

}