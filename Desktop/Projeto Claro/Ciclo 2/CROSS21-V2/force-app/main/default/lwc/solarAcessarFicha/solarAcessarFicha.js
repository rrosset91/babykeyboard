/**
 * @description       :
 * @author            : Joao Neves
 * @group             : IBM
 * @last modified on  : 03-03-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 * 1.1   04-02-2021   Diego Almeida   	BUG 113351 -BUG PROD RELEASE - Acesso a ficha financeiro sem caso
 **/
import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import Utils from "c/solarUtils";
import getRecordProps from "@salesforce/apex/FinancialMobileGeneralService.getRecordProps";
import hasPermissionSet from "@salesforce/apex/FinancialMobileGeneralService.hasPermissionSet";

export default class SolarAcessarFicha extends NavigationMixin(LightningElement) {
	@api
	recordId;
	@track
	isActive = false;
	@track
	isDisabled = false;
	@track
	componentStep = "Carregando dados...";
	@track
	recordProps;
	alreadyRendered = false;

	@wire (hasPermissionSet, { caseId: '$recordId' })
	hasPermissionSet ({error, data}){
		if(error){
			console.log('SolarAcessarFicha','deu erro HasPermission!');
		}
		if(data){
			console.log('SolarAcessarFicha isActive -> ', data);
			this.isActive = data;
		}
	}


	renderedCallback() {
		console.log("alreadyRendered", this.alreadyRendered);

		//if (this.alreadyRendered) return;
		this.alreadyRendered = true;
		this.fillComponentData();

	}

	async fillComponentData() {
		console.log('SolarAcessarFicha','fillComponentData');
		const data = await getRecordProps({ recordId: this.recordId }).catch((err) => {
			Utils.showToast(this, "error", null, err.body.message);
			this.componentStep = "Erro ao buscar informações";
		});

		console.log('SolarAcessarFicha fillComponentData -> ', data);

		if (!data) return;

		if (!data.contractId || !data.recordId) {
			this.componentStep = "Informações indisponíveis para acessar a ficha";
			return;
		}

		if(data.isCase){
			this.componentStep = "Ir para a Ficha Financeira";
			this.isDisabled = !data.isFinancialPermissionSet;
		} else {
			this.componentStep = "Ir para a Ficha Financeira (Somente consulta)";
			this.isActive = true;
			this.isDisabled = !data.isN2User;
		}

		//this.isDisabled = false; TU98 (Vinicius Damasceno)

		/*const cssClass = data.isViewOnly ? "small-button-wrapper" : "button-wrapper";

		this.template.querySelector("div").className = cssClass;
		*/


		this.recordProps = data;
	}

/*
	// async handleNavigate() {
	// 	console.log("handleNavigate ->");
	// 	console.log("handleNavigate ->", this.recordProps);
	// 	if (!this.recordProps) await this.fillComponentData();

	// 	let componentName = this.recordProps.isViewOnly ? "c:solarResFichaFinanceira" : "c:solarFichaFinanceira";

	// 	let compDetails = {
	// 		componentDef: componentName,
	// 		attributes: this.recordProps
	// 	};
	// 	console.log("handleNavigate compDetails ->", JSON.parse(JSON.stringify(compDetails)));

	// 	let encodedCompDetails = btoa(JSON.stringify(compDetails));

	// 	this[NavigationMixin.Navigate]({
	// 		type: "standard__webPage",
	// 		attributes: {
	// 			url: "/one/one.app#" + encodedCompDetails
	// 		}
	// 	});
	// }
*/
	handleNavigate() {
		console.clear();
		const encodedAttributes = btoa(encodeDefaultFieldValues(this.recordProps));
		const componentName = this.recordProps.isViewOnly ? "solarResFichaFinanceira" : "solarFichaFinanceira";

        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__Solar_Financeiro_Acessar_FichaFinanceira"
            },
            state: {
				c__encodedattributes: encodedAttributes,
				c__lwc: componentName
            }
        });
    }
}