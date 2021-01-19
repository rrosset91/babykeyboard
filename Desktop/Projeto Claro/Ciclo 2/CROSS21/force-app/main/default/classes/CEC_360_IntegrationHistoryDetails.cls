public class CEC_360_IntegrationHistoryDetails {

public static CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails GetHistoryOrdersDetails(String idOrder) { 
    CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails consents = new CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails();
    
    CEC_LGPD_Parameters__mdt paramsClientAuth = [Select statuses__c,clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigDsar'];
    string service = CEC_360_ServiceName.getServiceName('customersOrdersDetails');

        string parameters = '?language=pt-br';
        
        try {
            HTTPRequest request = new HTTPRequest();
 
            request.setEndpoint('callout:APIGEE_Claro'+ service + parameters);
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', paramsClientAuth.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','id='+idOrder);
            
            request.setTimeout(120000);
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
   
            
            System.debug('RESPONSE: s2 ' + responseBody);
            
           consents = (CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails.class);
            
            //System.debug('consents ++++++' + consents);
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
    System.debug('consents ++++++' + consents);
        return consents;
    }
}