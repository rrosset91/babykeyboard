/**
 * @description       : Componente para salvar forma de retorno com o cliente (E-mail/SMS/Telefone)
 * @author            : Ricardo Alves
 * @group             :
 * @last modified on  : 01-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-23-2020   Ricardo Alves   Initial Version
 **/
import { LightningElement, api, track, wire } from "lwc";
import getContactInformation from "@salesforce/apex/FinancialMobileContactContestation.getContactInformation";
import Utils from "c/solarUtils";

export default class SolarFinanceiroContatoCliente extends LightningElement {
	@wire(getContactInformation, { caseId: "$baseAttributes.numeroCase" }) contact;
	selectedValue = "";
	@api baseAttributes;
	@api tipoContato;
	communicationType;
	isEmailSelected = false;
	isSmsSelected = false;
	isPhoneSelected = false;
	get options() {
		return [
			{ label: "E-mail", value: "email" },
			{ label: "SMS", value: "sms" },
			{ label: "Telefone", value: "telefone" }
		];
	}
	handleChange(event) {
		this.communicationType = event.detail.value;
		if (!this.tipoContato) {
			this.fillSendData(this.communicationType, null, null, false);
		}
		//Habilitando o input abaixo do Combobox
		if (this.communicationType === "email") {
			this.isEmailSelected = true;
			this.selectedValue = this.contact.contactEmail;
			this.isSmsSelected = false;
			this.isPhoneSelected = false;
		} else if (this.communicationType === "sms") {
			this.isSmsSelected = true;
			this.selectedValue = this.contact.contactMobile;
			this.isEmailSelected = false;
			this.isPhoneSelected = false;
		} else if (this.communicationType === "telefone") {
			this.isPhoneSelected = true;
			this.selectedValue = this.contact.contactMobile;
			this.isSmsSelected = false;
			this.isEmailSelected = false;
		} else {
			this.isEmailSelected = false;
			this.isSmsSelected = false;
			this.isPhoneSelected = false;
			if (!this.tipoContato) {
				this.fillSendData(this.communicationType, null, null, true);
			}
		}
	}
	validateFields(event) {
		let fieldValue = event.target.value;
		let fieldType = event.target.type;
		let validated = false;
		if (this.communicationType && fieldValue) {
			if (fieldType === "tel") {
				validated = fieldValue.length > 9 ? true : false;
			} else {
				validated = true;
			}
		}
		if (validated) {
			if (!this.tipoContato) {
				this.fillSendData(this.communicationType, fieldType, fieldValue, validated);
			}
		} else {
			Utils.showToast(this, "error", null, "Por favor preencher os campos antes de enviar");
		}
	}

	@track sendData = {};
	@api
	save() {
		let validated = false;
		if (this.communicationType === "email") {
			let email = this.template.querySelector('[data-id="emailField"]').value;
			if (email !== "") {
				validated = true;
			}
		} else if (this.communicationType === "sms") {
			let phoneNumber = this.template.querySelector('[data-id="smsField"]').value;
			if (phoneNumber !== "") {
				validated = phoneNumber.length > 9 ? true : false;
			}
		} else if (this.communicationType === "telefone") {
			let phoneNumber = this.template.querySelector('[data-id="phoneField"]').value;
			if (phoneNumber !== "") {
				validated = phoneNumber.length > 9 ? true : false;
			}
		}
		if (validated) {
			Utils.showToast(this, "success", null, "Informação para retorno salva com sucesso!");
		} else {
			Utils.showToast(this, "error", null, "Por favor preencher os campos antes de enviar");
		}
	}
	fillSendData(dispach, fieldType, fieldValue, validate) {
		const sendInfo = {};
		sendInfo.communicationType = dispach;
		if (fieldType === "tel") {
			sendInfo.phone = fieldValue;
		}
		if (fieldType === "email") {
			sendInfo.email = fieldValue;
		}
		sendInfo.validate = validate;
		this.dispatchEvent(new CustomEvent("sendtypemethod", { detail: sendInfo }));
	}
}