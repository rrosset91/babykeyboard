/* 	Autor: Rennê Silva - Sysmap
   	Criação: 03/04/2020
   	Descrição: Classe de conexão com as APIs de consentimento da OneTrust.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_IntegrationConsents {
    
    public static CEC_RestObjects.GetConsents getConsents(String cpf) { 
        CEC_RestObjects.GetConsents consents = new CEC_RestObjects.GetConsents();
        String preferenceId = CEC_Consents_Parameters__c.getOrgDefaults().preferenceId__c;
        String clientAuth = CEC_Consents_Parameters__c.getOrgDefaults().clientAuth__c;
        //System.debug('preferenceId: ' + preferenceId);
        //System.debug('clientAuth: ' + clientAuth);
        
        try {
            HTTPRequest request = new HTTPRequest();
            
           System.debug('callout:APIGEE_Claro' + CEC_ServiceName__c.getValues('Consents').ServiceName__c + '?' + 
                                'preferenceId=' + preferenceId );
            
            request.setEndpoint('callout:APIGEE_Claro' + CEC_ServiceName__c.getValues('Consents').ServiceName__c + '?' 
                              + 'preferenceId=' + preferenceId );
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding', 'keep-alive');
            request.setHeader('Connection', 'gzip, deflate, br');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', clientAuth);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf='+cpf);
            
            request.setTimeout(120000);
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            //testeTU1
            //responseBody = '{"preferenceCenterId":"string","protocolNumber":"string","purposes":[{"defaultConsentStatus":"string","description":"string","id":"string","label":"string","purposeType":"string","status":"string","agreements":[{"id":"marketing","name":"Marketing direto","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"cookies","name":"Cookies","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"geolocalizacao","name":"Geolocalização","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"compartilhamento_dados","name":"Compartilhamento de dados com terceiros","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"autorizacao","name":"Autorização para uso de dados de menores e adolescentes","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"dados_sensiveis","name":"Dados sensíveis","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"}]}]}}';
        
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            consents = (CEC_RestObjects.GetConsents)JSON.deserialize(responseBody, CEC_RestObjects.GetConsents.class);
            
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
        return consents;
    }
    
    public static CEC_RestObjects.PutConsents putConsents(String cpf,String jsonBody,String purposeId){
        CEC_RestObjects.PutConsents putResponse = new CEC_RestObjects.PutConsents();
        String preferenceId = CEC_Consents_Parameters__c.getOrgDefaults().preferenceId__c;
        String clientAuth = CEC_Consents_Parameters__c.getOrgDefaults().clientAuth__c;
        System.debug('preferenceId: ' + preferenceId);
        System.debug('clientAuth: ' + clientAuth);
        
        try {

            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:APIGEE_Claro' + CEC_ServiceName__c.getValues('Consents').ServiceName__c + '?' + 
                                'preferenceId=' + preferenceId + '&purposeId=' + purposeId ); 
          
            request.setMethod('PUT');
            //request.setHeader('Accept-Encoding', 'keep-alive');
            //request.setHeader('Connection', 'gzip, deflate, br');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', clientAuth);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf='+cpf);
            
            request.setBody(jsonBody);
            request.setTimeout(120000);
  
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            putResponse = (CEC_RestObjects.PutConsents)JSON.deserialize(responseBody, CEC_RestObjects.PutConsents.class);
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return putResponse;
    }
    
    /*public static CEC_RestObjects.GetConsents generateMock() { 
        CEC_RestObjects.GetConsents consents = new CEC_RestObjects.GetConsents();
        // complete JSON
        consents = (CEC_RestObjects.GetConsents)JSON.deserialize('{"preferenceCenterId":"string","protocolNumber":"string","purposes":[{"defaultConsentStatus":"string","description":"string","id":"string","label":"string","purposeType":"string","status":"string","agreements":[{"id":"marketing","name":"Marketing direto","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"cookies","name":"Cookies","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"geolocalizacao","name":"Geolocalização","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"compartilhamento_dados","name":"Compartilhamento de dados com terceiros","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"autorizacao","name":"Autorização para uso de dados de menores e adolescentes","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"dados_sensiveis","name":"Dados sensíveis","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"}]}]}}', CEC_RestObjects.GetConsents.class);
        
        // no agreements
        //consents = (CEC_RestObjects.GetConsents)JSON.deserialize('{"preferenceCenterId":"string","protocolNumber":"string","purposes":[{"defaultConsentStatus":"string","description":"string","id":"string","label":"string","purposeType":"string","status":"string","agreements":[]}]}', CEC_RestObjects.GetConsents.class);
        
        return consents;
    }
    
    public static CEC_RestObjects.PutConsents generateMockPut() { 
        CEC_RestObjects.PutConsents putConsents = new CEC_RestObjects.PutConsents();
        putConsents = (CEC_RestObjects.PutConsents)JSON.deserialize('{"notes":"ABC-9990001","origin":"Sistema interno de atendimento","agreements":[{"id":"5dfaac86-dff2-43b3-ba74-24e0ced2a6da","options":[{"id":"d8e4911f-c68a-466d-aa99-7e3391b820ad"}]}]}', CEC_RestObjects.PutConsents.class);
        return putConsents;
    }*/
    
}