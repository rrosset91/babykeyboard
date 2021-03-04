import { LightningElement, api, wire } from 'lwc';
import getPromotionAndDiscount from '@salesforce/apex/Solar_Cross_PromotionDiscountController.getPromotionsAndDiscounts';


export default class SolarCrossProductDiscountsPromotions extends LightningElement {


    @api recordId;
    discounts;
    promotions;
    discountsMovel;
    othersMovel;
    svaMovel;
    offerMovel;
    completeListDiscounts;
    completeListPromotions;
    sumsList;
    totalSumDisc;
    totalSumPromo;
    total;
    success;
    disableButton;
    message;
    isMobile;
    openModalMovel = false;
    openModal = false;
    title;


    @wire(getPromotionAndDiscount,{recordId: '$recordId'}) 
    contestations({error,data}){
        console.log('data',data);
        if(data){
            if(data.success){
                if(!data.isMobile){
                    this.isMobile = false;
                    this.completeListDiscounts = data.completeListDiscounts;
                    this.completeListPromotions = data.completeListPromotions;
                    this.sumsList = data.sumsList;
                    this.totalSumDisc = this.sumsList.reduce((acumulador, atual)=>{return acumulador += atual.sumDisc},0);
                    console.log('this.totalSumDisc: ' + this.totalSumDisc);
                    this.totalSumPromo =  this.sumsList.reduce((acumulador, atual)=>{return acumulador += atual.sumPromo},0);
                    console.log('this.totalSumPromo: ' + this.totalSumPromo);
                    this.total = this.totalSumDisc + this.totalSumPromo;
                    this.title = 'Residencial';
                }else{
                    this.isMobile = true;
                    this.title = 'Móvel';
                    this.sumsList = data.planOffer;
                    this.totalSumDisc = this.sumsList.reduce((acumulador, atual)=>{return acumulador += atual.sumDisc},0);
                    this.totalSumPromo =  this.sumsList.reduce((acumulador, atual)=>{return acumulador += atual.sumPromo},0);
                   // this.discountsMovel = data.discounts;
                   // this.othersMovel = data.others;
                   // this.svaMovel = data.svaOffers; 
                    this.offerMovel = data.offer;
                    this.total = this.offerMovel.reduce((acumulador, atual)=>{return acumulador += atual.totalMonthlyValue},0);;
                    console.log('offerMovel',this.offerMovel);
                }
            }else{
                if(!data.isMobile){
                    this.title = 'Residencial';
                }else{
                    this.title = 'Móvel';
                }
                this.message = data.message;
            }
            this.success = data.success;
            this.disableButton = !data.success;
        }
    }

    openModalDisc(){
        console.log('Entrou no openModal')
        sessionStorage.setItem('teste','teste');
        if(this.isMobile){
            this.openModalMovel = true;
        }else{
            this.openModal = true;
        }
    }

    closeModal(){
        this.openModal = false;
        this.openModalMovel = false;
    }
}