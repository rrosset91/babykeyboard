/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 16-11-2020
 * @last modified by  : Joao Neves
 * @last modified on  : 03-12-2020
 * @last modified by  : Vinicius Damasceno
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Utils from "c/solarUtils";
import getRecordProps from "@salesforce/apex/FinancialMobileGeneralService.getRecordProps";
import hasPermissionSet from "@salesforce/apex/FinancialMobileGeneralService.hasPermissionSet";



export default class SolarAcessarFicha extends NavigationMixin(LightningElement) {
	@api
	recordId;
	@track
	isActive = false;
	@track
	componentStep = "Carregando dados...";
	@track
	recordProps;
	alreadyRendered = false;

	@wire (hasPermissionSet, { caseId: '$recordId' }) 
	hasPermissionSet ({error, data}){
		if(error){
			console.log('deu erro HasPermission!');
		}
		if(data){
			console.log('isActive -> ', data);
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
		console.log("fillComponentData");
		const data = await getRecordProps({ recordId: this.recordId }).catch((err) => {
			Utils.showToast(this, "error", null, err.body.message);
			this.componentStep = "Erro ao buscar informações";
		});

		console.log("fillComponentData -> ", data);

		if (!data) return;

		if (!data.contractId || !data.recordId) {
			this.componentStep = "Informações indisponíveis para acessar a ficha";
			return;
		}

		if(!data.isCase){
			this.isActive = true;
		}


		//this.isDisabled = false; TU98 (Vinicius Damasceno)
		this.componentStep = "Ir para a ficha financeira";


		/*const cssClass = data.isViewOnly ? "small-button-wrapper" : "button-wrapper";

		this.template.querySelector("div").className = cssClass;
		*/


		this.recordProps = data;
	}
	

	async handleNavigate() {
		console.log("handleNavigate ->");
		console.log("handleNavigate ->", this.recordProps);
		if (!this.recordProps) await this.fillComponentData();

		let componentName = this.recordProps.isViewOnly ? "c:solarResFichaFinanceira" : "c:solarFichaFinanceira";

		let compDetails = {
			componentDef: componentName,
			attributes: this.recordProps
		};
		console.log("handleNavigate compDetails ->", JSON.parse(JSON.stringify(compDetails)));

		let encodedCompDetails = btoa(JSON.stringify(compDetails));

		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: "/one/one.app#" + encodedCompDetails
			}
		});
	}
}