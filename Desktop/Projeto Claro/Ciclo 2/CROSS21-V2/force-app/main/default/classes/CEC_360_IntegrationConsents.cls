/* 	Autor: Rennê Silva - Sysmap
   	Criação: 03/04/2020
   	Descrição: Classe de conexão com as APIs de consentimento da OneTrust.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_IntegrationConsents {
    
    public static ConsentsData getConsents(String cpf) { 
        
        CEC_RestObjects.GetConsents consents = new CEC_RestObjects.GetConsents(); 

        ServiceParameter__c sp = [ SELECT Id, Name, clientAuth__c, clientAuth2__c, closeInPS8__c, 
                                          collectionPointId__c, preferenceId__c 
                                     FROM ServiceParameter__c 
                                    WHERE Name = 'Consents_Parameters' LIMIT 1 ]; 

        ConsentsData consentsData = new ConsentsData();
        
        try {
            HTTPRequest request = new HTTPRequest(); 
            
            request.setEndpoint('callout:APIGEE_Claro' + CEC_ServiceName__c.getValues('Consents').ServiceName__c + '?' + 'preferenceId=' + sp.preferenceId__c );
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding', 'keep-alive');
            request.setHeader('Connection', 'gzip, deflate, br');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', sp.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf=' + cpf); 
            
            request.setTimeout(120000);
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody   = response.getBody();

            responseBody.replace('-', '_');
            
            consentsData.getConsents = (CEC_360_LGPDIntegrationObjects.GetConsents)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.GetConsents.class);
            consentsData.putConsents = (CEC_360_LGPDIntegrationObjects.PutConsents)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.PutConsents.class); 
            
            consentsData.putConsents.channel            = 'SOLAR'; 
            consentsData.putConsents.collectionPointId  = sp.collectionPointId__c; 

            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return consentsData;
    }
    
    public static String putConsents(String cpf, String consents ){
        
        ServiceParameter__c sp = [ SELECT Id, Name, clientAuth__c, clientAuth2__c, closeInPS8__c, 
                                          collectionPointId__c, preferenceId__c 
                                     FROM ServiceParameter__c 
                                    WHERE Name = 'Consents_Parameters' LIMIT 1 ];  

        String responseBody = '';
        
        try {

            CEC_ServiceName__c serviceName = [ SELECT Id, Name, ServiceName__c FROM CEC_ServiceName__c WHERE Name = 'Consents' LIMIT 1 ];

            HTTPRequest request = new HTTPRequest();     
            request.setEndpoint('callout:APIGEE_Claro' + serviceName.ServiceName__c );
 
            request.setMethod('POST'); 
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', sp.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf=' + cpf);
            
            sYSTEM.debug('consents >>> ' + consents);
            
            request.setBody(consents);
            request.setTimeout(120000);
  
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            responseBody = response.getBody(); 
            
            responseBody.replace('-', '_');

            System.debug( 'responseBody putConsents ====> ' + responseBody );
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return responseBody;
    } 

    public static HTTPResponse closeOcurrency( String jsonBody ){ 
         
        HTTPResponse response; 

        try {

            ServiceParameter__c sp = [ SELECT Id, Name, clientAuth__c, clientAuth2__c, closeInPS8__c, 
                                              collectionPointId__c, preferenceId__c 
                                         FROM ServiceParameter__c 
                                        WHERE Name = 'Consents_Parameters' LIMIT 1 ];  


            CEC_ServiceName__c serviceName = [ SELECT Id, Name, ServiceName__c, targetAPI__c 
                                                 FROM CEC_ServiceName__c 
                                                WHERE Name = 'interactions' LIMIT 1 ];  


            HTTPRequest request = new HTTPRequest(); 

            if( serviceName.targetAPI__c != null && serviceName.ServiceName__c != null && sp.clientAuth2__c != null){

                if( serviceName.targetAPI__c  == 'SAAS'){                    
                    request.setEndpoint('callout:APIGEE_Claro' + serviceName.ServiceName__c);
                    System.debug('callout:APIGEE_Claro');
                }else{
                    request.setEndpoint('callout:APIGEE_OPDK_Claro_CAS' + serviceName.ServiceName__c);
                    System.debug('callout:APIGEE_Claro_OPDK');
                }  

                request.setMethod('PUT');  
                request.setHeader('x-client-auth', sp.clientAuth2__c);
                request.setHeader('Content-Type', 'application/json'); 
                
                request.setBody(jsonBody);
                request.setTimeout(120000);
    
                HTTP http = new HTTP();
                
                if(!test.isRunningTest()){
                    response = http.send(request);
                }
            }

            if( response != null ){
                response.getBody().replace('-', '_');  

                System.debug( ' response close PS8 ====> ' + response );
                
                if(response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug('closeOcurrency => ' + response.getBody());
                }
            }
            
        }catch(Exception ex) {
            System.debug('ERROR: ' + ex );
        }
        return response;
    }

    public class ConsentsData {
        @AuraEnabled public CEC_360_LGPDIntegrationObjects.GetConsents getConsents; 
        @AuraEnabled public CEC_360_LGPDIntegrationObjects.PutConsents putConsents; 
    } 
    
}