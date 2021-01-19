/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Child Component used to iterate and show the alerts data in solarCrossCallCenterAlerts component
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-27      Jean Sganzerla          class created 
**************************************************************************************************************/

import { LightningElement, api, track } from 'lwc';

export default class SolarCrossShowAlerts extends LightningElement {
    @api records;
    @api contexteRecordInConclusionModal;    
    @api itemToChangeShow;    
    @api accordionlabel;    

    @api accordionicon;    
    @api count;    
    @track mainAccordionOpen = true;    
    @track accordionArrow = "utility:chevrondown";    

    activeSections = ['A'];
    openModalDetail(event){
        this.contexteRecordInConclusionModal = event.target.value;
        // console.log('detailing Segmented Alerts ' +  this.contexteRecordInConclusionModal);
        this.dispatchEvent(new CustomEvent('detail', {detail: this.contexteRecordInConclusionModal}));
    }
    //método utilizado para abrir e fechar os acordions dos registros de alertas;
    changeItemShow(event){
        this.itemToChangeShow = event.target.value;
        // console.log('record child' + JSON.stringify(this.itemToChangeShow));
        this.dispatchEvent(new CustomEvent('changeitem', {detail: this.itemToChangeShow}));
    }

    //método utilizado para abrir e fechar o accordion principal
    mainAccordion(){
       this.mainAccordionOpen = this.mainAccordionOpen == true ? false : true;
       this.accordionArrow = this.accordionArrow == "utility:chevrondown" ? "utility:chevronright" : "utility:chevrondown";
    }

}