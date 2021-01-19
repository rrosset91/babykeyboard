/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 11-12-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-12-2020   Diego Almeida   Initial Version
**/
import Utils from "c/solarUtils";
import getPDFUrl from "@salesforce/apex/FinancialPDF.getPDFURL";
import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api } from 'lwc';

export default class SolarFinanceiroPDFDownload extends NavigationMixin(LightningElement) {
    @api baseAttributes;
    @api baseDetail;
    hasData;
    pdfData;
    hasError;



    handleOpenPDF(){
        console.log('getPDFUrl baseAttributes:', JSON.parse(JSON.stringify(this.baseAttributes)));
        console.log('getPDFUrl baseDetail:', JSON.parse(JSON.stringify(this.baseDetail)));
        this.fechPDF();
    }

    fechPDF() {
        getPDFUrl({
			companyId: 'MOVEL',
			dueDate: this.baseDetail.rawDueDate,
			billingAccountId: this.baseDetail.noteFiscalNumber
		})
        .then((success) => {
            console.log('getPDFUrl success:', JSON.parse(JSON.stringify(success)));

            if (this.hasError) return;

            if(success.hasData){
                this.hasData = success.hasData
                this.pdfData = success.responseMsg;
                this.openWindow()
            }else{
                this.hasError = success.hasError;
                this.hasData = success.hasData;
                Utils.showToast(this, "error", null, success.errorMessage);
                console.log('ERROR', success.responseMsg);
                return;
            }
        })
        .catch((error) => {
            console.log('getPDFUrl error:', JSON.parse(JSON.stringify(error)));

            this.hasData = false;
            this.hasError = true;
            Utils.showToast(this, "error", null, error.body.message);
        });


    }
    openWindow(){
        // var url = this.pdfData; // get from processing apex response
        // window.open(url, "_blank");
        //this.pdfData = 'https://americalatina.dint.fgv.br/sites/americalatina.dint.fgv.br/files/teste33.pdf';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.pdfData
            }
        }, false );
    }
}