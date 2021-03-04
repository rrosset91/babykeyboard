/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 05-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
**/
import { LightningElement, api, track} from "lwc";
import Utils from "c/solarUtils";
export default class SolarFinanceiroSegundaVia extends LightningElement {
  @api envioSegundaVia;

  dispatchType;
  isEmailSelected = false;
  isSmsSelected = false;
  disabledSaveCondition = true;
  get options() {
    return [
      { label: "E-mail", value: "email" },
      { label: "SMS", value: "sms" },
      { label: "Correio", value: "correio" }
    ];
  }
  handleChange(event) {
    this.dispatchType = event.detail.value;

    if(!this.envioSegundaVia){
      this.fillSendData(this.dispatchType, null, null, false);
    }

    //Habilitando o input abaixo do Combobox
    if (this.dispatchType === "email") {
      this.isEmailSelected = true;
      this.isSmsSelected = false;
    } else if (this.dispatchType === "sms") {
      this.isSmsSelected = true;
      this.isEmailSelected = false;
    } else {
      this.isEmailSelected = false;
      this.isSmsSelected = false;
      this.enableSaveButton();

      if(!this.envioSegundaVia){
        this.fillSendData(this.dispatchType, null, null, true);
      }

    }
  }
  applyPhoneMask(event) {
    let value = event.target.value;
    value = value.replace(/\D/g, "");
    value = value.replace(/^(\d{2})(\d)/g, "($1) $2");
    value = value.replace(/(\d)(\d{4})$/, "$1-$2");
    event.target.value = value;
  }
  validateFields(event){
    let fieldValue = event.target.value;
    let fieldType = event.target.type;
    let validated = false;
    if(this.dispatchType && fieldValue){
      if(fieldType === "tel"){
        validated = (fieldValue.length == 15) ? true : false;
      }
      else{
        validated = true;
      }
    }
    if(validated){
      this.enableSaveButton();

      if(!this.envioSegundaVia){
        this.fillSendData(this.dispatchType, fieldType, fieldValue, validated);
      }

    }else{
      this.disableSaveButton();
      Utils.showToast(this, "error", null, "Por favor preencher os campos antes de enviar");
    }
  }
  enableSaveButton(){
    this.disabledSaveCondition = false;
  }
  disableSaveButton(){
    this.disabledSaveCondition = true;
  }
  @api
  open() {
    this.template.querySelector("c-solar-modal").open();
  }
  close() {
    this.template.querySelector("c-solar-modal").close();
  }

  @track sendData = {};

  @api
  save() {
    let validated = false;
    if(this.dispatchType === "email"){
      let email = this.template.querySelector('[data-id="emailField"]').value;
      if(email !== ''){
        validated = true;
      }
    }else if(this.dispatchType === "sms"){
      let phoneNumber = this.template.querySelector('[data-id="phoneField"]').value;
      if( (phoneNumber !== '')){
        validated = (phoneNumber.length == 15) ? true : false;
      }
    }
    if(validated || this.dispatchType === "correio"){
      Utils.showToast(this, "success", null, "2ª via enviada com sucesso!");
      this.template.querySelector("c-solar-modal").close();
    }else{
      this.disableSaveButton();
      Utils.showToast(this, "error", null, "Por favor preencher os campos antes de enviar");
    }
  }

  fillSendData(dispach, fieldType, fieldValue, validate){
		const sendInfo = {};
      sendInfo.dispatchType = dispach;
      if(fieldType === "tel" ){
        sendInfo.phone = fieldValue;
      }
      if(fieldType === 'email'){
        sendInfo.email = fieldValue;
      }
      sendInfo.validate = validate;
    this.dispatchEvent(new CustomEvent("sendtypemethod", { detail: sendInfo }));
	}

}