import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class SolarTechnicalBasicInfo extends OminiscriptBaseMixin(LightningElement) {

    @api recordId;
    apiVersion;
    idData;
    authData;

    connectedCallback(){
        const params = {
            input: '{"idKey": "'+ this.recordId + '", "authorizationKey": "CustomerContracts"}',
            sClassName: `vlocity_cmt.IntegrationProcedureService`,
            sMethodName: 'VIPSolarTechnical_getCustomerContracts',
            options: '{}',            
        };
        this.omniRemoteCall(params, true).then(response =>{
            window.console.log(response, 'response');
            //this.apiVersion = response.result.IPResult.responseApi.apiVersion;
            this.idData = response.result.IPResult.responseGetId;
            this.authData = response.result.IPResult.responseGetAuthorization;
        }).catch(error => {
            window.console.log(error, 'error');
        });
    }

    
}