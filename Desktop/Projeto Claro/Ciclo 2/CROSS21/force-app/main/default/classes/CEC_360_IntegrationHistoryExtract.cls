/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 25/08/2020
   	Descrição: Integração  para a coluna extrato do historico de direitos .
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_IntegrationHistoryExtract {
    
    
    public static CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract getHistoryExtract (String id) { 
        CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract extract = new CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract();
        CEC_LGPD_Parameters__mdt paramsClientAuth = [Select statuses__c,clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigDsar'];
        string service = CEC_360_ServiceName.getServiceName('CustomersOrdersExtract');
        
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:APIGEE_Claro' + service );
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');
            request.setHeader('X-Client-Auth', paramsClientAuth.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','id='+id);
            
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            
            
            
            extract = (CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract.class);
            

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
        return extract;
    }
}