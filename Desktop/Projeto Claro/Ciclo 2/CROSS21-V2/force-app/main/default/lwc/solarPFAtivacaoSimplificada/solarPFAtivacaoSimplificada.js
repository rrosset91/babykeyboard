import { LightningElement, wire, track } from 'lwc';
import getToken from '@salesforce/apex/SolarPFTokenService.getTokenForUser';
import urlCustomLabel from '@salesforce/label/c.SolarURLAtivacaoSimplificada';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class SolarPFAtivacaoSimplificada extends NavigationMixin(LightningElement) {
    @track systemURL;
    @track error;

    connectedCallback(){
        getToken().then( data => {
                this.systemURL = urlCustomLabel  +data;
                this.navigateToWebPage(this.systemURL);
            } )
            .catch(error =>{
                this.error = error.body.message;
                this.showToast();
                this.systemURL = urlCustomLabel ;
            })
    }


    showToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: this.error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    navigateToWebPage(link) {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": link
            }
        });
    }

}