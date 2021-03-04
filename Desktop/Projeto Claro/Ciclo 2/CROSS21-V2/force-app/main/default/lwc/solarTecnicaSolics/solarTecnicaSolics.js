import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const columns = [
    { label: 'NÚMERO', fieldName: 'requestID'},
    { label: 'TIPO', fieldName: 'requestTypeDescription'},
    { label: 'STATUS', fieldName: 'statusDescription' },
    { label: 'DATA EXECUÇÃO', fieldName: 'closedDate'}
];

export default class SolarTecnicaSolics extends OmniscriptBaseMixin(LightningElement) {

    columns = columns;
    solics = [];

    SOLIC_SERVICE_PARAMETER = 'GetSubscriberRequests';
    page = 1;
    limit = 1000;
    hasError = false;
    isEmpty = false;
    showSolicsContent = false;
    message;

    @api callSolicsService(caseId) {
        const params = {
            input: '{"caseId":"' +  caseId + '", "serviceParameterName":"' 
            + this.SOLIC_SERVICE_PARAMETER + '", "page":' + this.page + ', "limit":' + this.limit + '}',
            sClassName: `vlocity_cmt.IntegrationProcedureService`,
            sMethodName: 'technicalAttendance_getSolics',
            options: '{}',
        };

        this.omniRemoteCall(params, true).then(response => {
            window.console.log(response, 'response');
            let vipResult = response.result.IPResult;
            
            this.isEmpty = vipResult.isEmpty;
            this.hasError = vipResult.hasError;
            this.showSolicsContent = !vipResult.hasError && !vipResult.isEmpty;
            if(this.showSolicsContent) {
                this.solics = vipResult.solics.requests;
                
            }

        }).catch(error => {
            window.console.log(error, 'error');
            this.hasError = true;
        });
    }
}