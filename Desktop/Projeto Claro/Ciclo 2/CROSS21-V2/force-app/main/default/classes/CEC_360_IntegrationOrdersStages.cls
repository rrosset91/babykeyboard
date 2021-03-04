public class CEC_360_IntegrationOrdersStages {
   
    
    public static CEC_360_LGPDIntegrationObjects.PutOrdersStage putOrdersStages(String body) { 

        CEC_360_LGPDIntegrationObjects.PutOrdersStage ordersStage = new CEC_360_LGPDIntegrationObjects.PutOrdersStage();

        CEC_LGPD_Parameters__mdt paramsClientAuth = [SELECT statuses__c, clientAuth__c 
                                                       FROM CEC_LGPD_Parameters__mdt 
                                                      WHERE DeveloperName = 'ConfigDsar' ];

        string service = CEC_360_ServiceName.getServiceName('OrdersStages');
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:APIGEE_Claro'+  service );
            
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
            String responseBody = response.getBody();
           
            ordersStage = (CEC_360_LGPDIntegrationObjects.PutOrdersStage)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.PutOrdersStage.class);
   
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return ordersStage;
    }
}