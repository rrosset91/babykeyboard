import { LightningElement,api } from 'lwc';
const columns = [{label:'TIPO', fieldName:'type', hideDefaultActions: true,sortable: true},
                 {label:'DESCRIÇÃO',fieldName: 'description',hideDefaultActions: true},
                 {label:'INICIO', fieldName:'startDate',type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true, sortable: true},
                 {label:'FIM', fieldName:'endDate',type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true, sortable: true},
                 {label:'MESES RESTANTES', fieldName:'months', type:'number',hideDefaultActions: true,cellAttributes: { alignment: 'left' },sortable: true},
                 {label:'VALOR', fieldName:'treatedValue',hideDefaultActions: true,sortable: true}];
export default class SolarCrossPromotionsDiscountsModal extends LightningElement {

    activeSections = ['A', 'B'];
    @api promotions;
    @api discounts;
    sortDirectionDiscount = 'asc';
    sortedByDiscount;
    sortDirectionPromotion = 'asc';
    sortedByPromotion;
    columns = columns;

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
        if(sortedBy =='treatedValue'){
            sortedByAux = 'value';
        }
        cloneData.sort(this.sortBy(sortedByAux, sortDirection === 'asc' ? 1 : -1));
        this.discounts = cloneData;
        this.sortDirectionDiscount = sortDirection;
        this.sortedByDiscount = sortedBy;
    }

    onHandleSortPromotion(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.promotions];

        let sortedByAux = sortedBy;
        if(sortedBy =='treatedValue'){
            sortedByAux = 'value';
        }
        cloneData.sort(this.sortBy(sortedByAux, sortDirection === 'asc' ? 1 : -1));
        this.promotions = cloneData;
        this.sortDirectionPromotion = sortDirection;
        this.sortedByPromotion = sortedBy;
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }



}