import { LightningElement, wire, track } from 'lwc';
import getToken from '@salesforce/apex/SolarPFTokenService.getTokenForUser';
import urlCustomLabel from '@salesforce/label/c.SolarURLAtivacaoSimplificada';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SolarPFAtivacaoSimplificada extends LightningElement {
    @track systemURL;
    @track error;
    @wire(getToken, {
    })
    wireToken({
        error,
        data
    }) {
        if (error) {
            this.error = error.body.message;
            this.showToast();
            this.systemURL = urlCustomLabel ;
        } else if (data) {
            //this.systemURL = 'http://BRUX0690:8922/SVCv2/login/sso/'+data;
           // this.systemURL = 'https://vendasapp.claro.com.br/SVCv2/login/sso/' + data;
            this.systemURL = urlCustomLabel  +data;
            window.open(this.systemURL, "_blank");
        }
    };

    showToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: this.error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}