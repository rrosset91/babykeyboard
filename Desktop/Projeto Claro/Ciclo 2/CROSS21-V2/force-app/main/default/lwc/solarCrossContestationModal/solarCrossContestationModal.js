import { LightningElement,api } from 'lwc';

export default class SolarCrossContestationModal extends LightningElement {

    @api item;
    
    handleCloseModal(){
        console.log('entrou no close modal');
        this.dispatchEvent(new CustomEvent('close'));
    }
}