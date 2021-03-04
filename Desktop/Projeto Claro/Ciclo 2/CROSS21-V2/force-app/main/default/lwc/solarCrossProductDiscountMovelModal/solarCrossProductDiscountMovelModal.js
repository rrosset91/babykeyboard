import { LightningElement, api } from 'lwc';
const columnsDiscount = [{label:'NOME', fieldName:'name', hideDefaultActions: true},
                        {label:'TIPO', fieldName:'offerType', hideDefaultActions: true},
                        {label:'NÍVEL', fieldName:'level', hideDefaultActions: true},
                        {label:'INICIO', fieldName:'effectiveStartDate',type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true},
                        {label:'FIM', fieldName:'expiryDate',type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true},
                        {label:'MSISDN', fieldName:'msisdn', hideDefaultActions: true}

                        /*{label:'DESCONTO RECONHECIDO',fieldName: 'offerValue', hideDefaultActions: true, type:'currency', sortable : true, cellAttributes: { alignment: 'left' }},
                        {label:'DESCONTO PONTUADO',fieldName: 'monthlyDiscountValue', hideDefaultActions: true, type:'currency', sortable : true, cellAttributes: { alignment: 'left' }}*/];
export default class SolarCrossProductDiscountMovelModal extends LightningElement {


    activeSections = [];
    @api discounts;
    @api svas;
    @api others;
    @api offer;
    columns = columnsDiscount;
    sortDirectionDiscount = 'asc';
    sortedByDiscount;
    sortDirectionSVA = 'asc';
    sortedBySVA;
    sortDirectionOthers = 'asc';
    sortedByOthers;
    //defaultSortDirection = 'asc';

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

    onHandleSortDiscount(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.discounts];

        let sortedByAux = sortedBy;
        cloneData.sort(this.sortBy(sortedByAux, sortDirection === 'asc' ? 1 : -1));
        this.discounts = cloneData;
        this.sortDirectionDiscount = sortDirection;
        this.sortedByDiscount = sortedBy;
    }

    onHandleSortSVA(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.svas];

        let sortedByAux = sortedBy;
        cloneData.sort(this.sortBy(sortedByAux, sortDirection === 'asc' ? 1 : -1));
        this.svas = cloneData;
        this.sortDirectionSVA = sortDirection;
        this.sortedBySVA = sortedBy;
    }

    onHandleSortOther(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.others];

        let sortedByAux = sortedBy;
        cloneData.sort(this.sortBy(sortedByAux, sortDirection === 'asc' ? 1 : -1));
        this.others = cloneData;
        this.sortDirectionOthers = sortDirection;
        this.sortedByOthers = sortedBy;
    }


    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}