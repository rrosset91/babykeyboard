public class CEC_360_IntegrationManagement {
    
    
    public static CEC_360_LGPDIntegrationObjects.PutManagement PutManagement(string body) { 

        CEC_360_LGPDIntegrationObjects.PutManagement management = new CEC_360_LGPDIntegrationObjects.PutManagement();

        CEC_LGPD_Parameters__mdt paramsClientAuth = [SELECT statuses__c, clientAuth__c 
                                                       FROM CEC_LGPD_Parameters__mdt 
                                                      WHERE DeveloperName = 'ConfigDsar'];

        String service = CEC_360_ServiceName.getServiceName('OrdersManagement');
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:APIGEE_Claro'+ service );
            
            request.setMethod('PUT');
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', paramsClientAuth.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
           
            request.setTimeout(120000);
            request.setBody(body); 
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            System.debug( 'rodolfo' + request);
            String responseBody = response.getBody(); 
      
            management = (CEC_360_LGPDIntegrationObjects.PutManagement)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.PutManagement.class);
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return management;
    }
}