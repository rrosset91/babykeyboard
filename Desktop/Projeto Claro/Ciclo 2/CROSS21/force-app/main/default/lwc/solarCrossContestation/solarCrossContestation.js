import { LightningElement, api, wire} from 'lwc';
import getContestion from '@salesforce/apex/Solar_Cross_ContestationController.getContestations';

const columns = [{label:'PROTOCOLO',        fieldName: 'URL', hideDefaultActions: true, type:'url',typeAttributes: {label : {fieldName: 'protocolNumber'},target:'_self'},sortable : true },
                 {label: 'DATA DE CRIAÇÃO', fieldName: 'creationDate' ,type: 'date-local',typeAttributes: {month:"2-digit",day: "2-digit"},hideDefaultActions: true, sortable : true},
                 {label: 'HORA DE CRIAÇÃO', fieldName: 'creationTime',hideDefaultActions: true },
                 {label: 'STATUS',          fieldName: 'status',hideDefaultActions: true,sortable : true},
                 {label: 'VALOR',           fieldName: 'value', hideDefaultActions: true, type:'currency', sortable : true, cellAttributes: { alignment: 'left' }},
                {label: 'VER MAIS', type: 'button-icon', title:'getMoreInfo',typeAttributes: {iconName:'utility:preview'}, cellAttributes: { alignment: 'left' }}];

export default class SolarCrossContestation extends LightningElement {

    @api recordId;
    columns = columns;
    data;
    hasData;
    @api selectedRow;
    openModal = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire(getContestion,{recordId: '$recordId'})
    contestations({error,data}){
        if(error){
            console.log('rr: ' + this.recordId);
        }
        if(data){
            console.log('data: ' + data);
            this.data = data;
            console.log('lengthdata: ',data.length);
            this.hasData =  this.data.length > 0 ? true:false;
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                    return primer(x[field]);
                }
            : function(x) {
                    return x[field];
                };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    getMoreInfo(event){
        console.log('aaaa')
        const row = event.detail.row;
        console.log('row',row);
    }

    handleRowAction(event){
       const actionName =  event.detail;
       const row = event.detail.row;
       this.selectedRow = row;
       this.openModal = true;
       console.log('row',row);
       console.log('action',JSON.parse(JSON.stringify(actionName)));
    }

    closeModal(){
        this.openModal=false;
    }
}