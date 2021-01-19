/* 	Autor: Rennê Silva - Sysmap
   	Criação: 21/08/2020
   	Descrição: Classe controller para o componente Aura CEC_360_LGPDConsentsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
    Alterado por: Guilherme Cuencas 02/09/2020 - 15:11pm
	Time: SQUAD CEC */

    public class CEC_360_IntegrationConsentsHistory {
 
    public static CEC_360_LGPDIntegrationObjects.GetConsentsHistory consentsHistory(String cpf) { 
        CEC_360_LGPDIntegrationObjects.GetConsentsHistory responseConsents = new CEC_360_LGPDIntegrationObjects.GetConsentsHistory();
        
        String clientAuth = '';
        // GET params to authenticate in APIGEE and static parameters from OneTrust
        CEC_LGPD_Parameters__mdt params = [Select clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigConsents'];
        System.debug('params: ' + params);
        if(params != null){
            clientAuth = params.clientAuth__c;
            System.debug('clientAuth: ' + clientAuth);
        }else{
            System.debug('Parâmetros de configuração para chamada do GET de histórico do consentimento não foram cadastrados corretamente.');
            return responseConsents;
        }

		String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('ConsentsHistory');
        }else{
            service = '/dataprivacy/v1/customers/agreements/receipts';
        }
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            System.debug('callout:APIGEE_Claro' + service + '?size=50&page=0');
            request.setEndpoint('callout:APIGEE_Claro'+ service +'?size=50&page=0');
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', clientAuth);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf='+cpf);
            
            request.setTimeout(120000);

            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            responseConsents = (CEC_360_LGPDIntegrationObjects.GetConsentsHistory)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.GetConsentsHistory.class);
            
            /*
            for(CEC_360_LGPDIntegrationObjects.Purpose purpose : responseConsents.purposes){
                if(purpose.consentCreationDate != null ){
                    DateTime orderDate = (DateTime)JSON.deserialize('"'+purpose.consentCreationDate  +'"', DateTime.class);
                    String orderDateStr = orderDate.format('dd/MM/yyyy HH:mm');
                    purpose.consentCreationDate = orderDateStr;
                }
                if (purpose.completionDate != null ){
                    DateTime completionDate = (DateTime)JSON.deserialize('"'+purpose.completionDate +'"', DateTime.class);
                    String completionDateStr = completionDate.format('dd/MM/yyyy HH:mm');
                    purpose.completionDate  = completionDateStr;
                }
            }
			*/
            
            System.debug('response.getStatusCode(): ' + response.getStatusCode());
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return responseConsents;
    }
    
}