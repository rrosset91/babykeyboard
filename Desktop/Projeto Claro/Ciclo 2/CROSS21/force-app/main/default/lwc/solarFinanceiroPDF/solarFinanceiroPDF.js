/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 19-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   16-11-2020   Diego Almeida   Initial Version
 **/
import { LightningElement, api, wire} from 'lwc';
import getPDFBase64 from "@salesforce/apex/FinancialPDF.getPDFBase64";
import { CurrentPageReference } from "lightning/navigation";
import Utils from "c/solarUtils";
export default class SolarFinanceiroPDF extends LightningElement {
    @api atributosEnviados = {};

    pdfData;
    hasError = false;
    hasData = true;

    @wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		console.log("currentPageReferences =>", JSON.parse(JSON.stringify(currentPageReference)));
		this.atributosEnviados = currentPageReference.attributes.attributes;
        console.log("atributosEnviados", this.atributosEnviados);
    }

    connectedCallback() {
		this.fetchDetailsInvoices();
    }

    async fetchDetailsInvoices() {
        //console.log("companyId: " + this.baseDetail.companyId + " externalId: " + this.baseAttributes.externalId + " customerAccountId: " + this.baseDetail.customerAccountId);
		//const data = await getPDFBase64({ companyId: this.baseDetail.companyId ,externalId: this.baseAttributes.externalId, customerAccountId: this.baseDetail.customerAccountId}).catch((err) => {
        console.log('fetchDetailsInvoices atributosEnviados:', JSON.parse(JSON.stringify(this.atributosEnviados)));

        const data = await getPDFBase64({
                                companyId: 'RESIDENCIAL',
                                externalId: this.atributosEnviados.externalId,
                                operatorCode: this.atributosEnviados.operatorCode,
                                accountId: this.atributosEnviados.accountId
        }).catch((err) => {
            this.hasError = true;
            this.hasData = false;
			Utils.showToast(this, "error", null, err.body.message);
        });
        if (this.hasError) return;
        console.log('getPDFBase64 data:', JSON.parse(JSON.stringify(data)));
        if(data.hasData){
            this.hasData = data.hasData
            this.pdfData = data.responseMsg;
            this.onLoad();
        }else{
            this.hasError = data.hasError;
            this.hasData = data.hasData;
            Utils.showToast(this, "error", null, data.errorMessage);
            console.log('ERROR', data.responseMsg);
            return;
        }
    }
    onLoad() {
        this.template
        .querySelector("iframe")
        .contentWindow.postMessage(this.pdfData, "*");
    }
}