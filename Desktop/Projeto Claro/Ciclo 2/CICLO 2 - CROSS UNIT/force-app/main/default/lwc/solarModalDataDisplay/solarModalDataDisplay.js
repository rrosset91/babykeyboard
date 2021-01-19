import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";

export default class SolarModalDataDisplay extends LightningElement {
  @api modalData = [];
  @api classToAdd;
  @api dlSize;

  renderedCallback(){
    if(Utils.isEmptyString(this.dlSize)){
      let dlList = this.template.querySelectorAll('dl');
      dlList.forEach(element => {
        element.classList.add('slds-p-around_x-small');
      });
    }
    let dlList = this.template.querySelectorAll('dl');
    dlList.forEach(element => {
      element.classList.add(this.classToAdd);
    });

    if(this.classToAdd == 'slds-size_1-of-2'){
      let dtList = this.template.querySelectorAll('dt');
      dtList.forEach(element => {
        element.classList.add('custom-padding-12');
    });
      let ddList = this.template.querySelectorAll('dd');
      ddList.forEach(element => {
        element.classList.add('custom-padding-12');
      });
    }else if(this.classToAdd == 'slds-size_1-of-3'){
      let dtList = this.template.querySelectorAll('dt');
      dtList.forEach(element => {
        element.classList.add('custom-padding-13');
    });
      let ddList = this.template.querySelectorAll('dd');
      ddList.forEach(element => {
        element.classList.add('custom-padding-13');
      });
    }
  }
}