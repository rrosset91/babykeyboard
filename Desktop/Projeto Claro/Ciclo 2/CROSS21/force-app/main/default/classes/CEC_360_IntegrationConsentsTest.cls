/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 25/03/2020
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

@isTest(SeeAllData=true)
global class CEC_360_IntegrationConsentsTest implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response getConsents
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('X-Client-Auth', 'Basic YUltV2lNbFZwcVdYRzRpeDVCbFNwQld4dGRIUnNjYVo6eldiQTlMY3lrelV5VXZiTg==');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"preferenceCenterId":"string","protocolNumber":"string","purposes":[{"defaultConsentStatus":"string","description":"string","id":"string","label":"string","purposeType":"string","status":"string","agreements":[{"id":"marketing","name":"Marketing direto","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"cookies","name":"Cookies","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"geolocalizacao","name":"Geolocalização","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"compartilhamento_dados","name":"Compartilhamento de dados com terceiros","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"},{"id":"autorizacao","name":"Autorização para uso de dados de menores e adolescentes","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":true}],"required":true,"selectionType":"string"},{"id":"dados_sensiveis","name":"Dados sensíveis","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.","displayAs":"string","options":[{"id":"drsgfsdgfsdgf-sfdsdfdsfsdfsdf-sdfsdf","label":"Sim","checked":true},{"id":"bfdghdfgsd-dfsdfdsfs-dfdsfsdf","label":"Não","checked":false}],"required":true,"selectionType":"string"}]}]}}');
        response.setStatusCode(200);
        return response; 
    } 
   
    @isTest
    public static void testGetCallout() { 
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest()); 
        
        CEC_360_IntegrationConsents.ConsentsData consentsData = new CEC_360_IntegrationConsents.ConsentsData();

        consentsData = CEC_360_IntegrationConsents.getConsents('021032020195');
 
    }
    
    @isTest
    public static void testCloseOcurrency() {
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest());
        
        CEC_Consents_Parameters__c cp = new CEC_Consents_Parameters__c();
        
        cp = [SELECT Id, clientAuth2__c FROM CEC_Consents_Parameters__c LIMIT 1];
        
        cp.clientAuth2__c = 'test';
        
        upsert cp;
        
        CEC_ServiceName__c serviceName = new CEC_ServiceName__c();
            
        serviceName.Name 			= 'interactions';  
		serviceName.ServiceName__c 	= '/dataprivacy/v1/customers/interactions';
        serviceName.targetAPI__c   	= 'SAAS';
        
        upsert serviceName;
            
        String requestBody = '{ '
        +  '  \"protocolNumber\": \"123456789\", '
        +  '  \"status\": \"FECHADO\", '
        +  '  \"details\": \"Codigo de rastreabilidade: 1234\", '
        +  '  \"severity\": \"MINIMA\", '
        +  '  \"situation\": \"NOVO\", '
        +  '  \"slaDueDate\": \"2018-01-12T12:10:30-03:00\", '
        +  '  \"priority\": \"BAIXA\", '
        +  '  \"caseTypeId\": \"12345\", '
        +  '  \"systemRelatedCaseId\": \"SalesForce\", '
        +  ' }';
        
        test.startTest();
        	CEC_360_IntegrationConsents.closeOcurrency( requestBody );
 		test.stopTest();
    }
    
    @isTest
    public static void testPutCallout() { 
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest()); 

        CEC_360_IntegrationConsents.ConsentsData consentsData = new CEC_360_IntegrationConsents.ConsentsData();

        String jsonRequest = '{ '
                +  '  \"protocolNumber\": 123456789, '
                +  '  \"channel\": \"SOLAR\", '
                +  '  \"collectionPointId\": \"da3e61bc-e285-4fc8-abc3-f98d0e1bb800\", '
                +  '  \"purposes\": [ '
                +  '      { '
                +  '          \"agreements\": [ '
                +  '             { '
                +  '                  \"id\": \"089b5e8b-74c9-449a-a109-5027091ba278\", '
                +  '                  \"options\": [ '
                +  '                      { '
                +  '                          \"id\": \"17ab2ae0-4dd3-4949-bc01-0465a67d1c30\" '
                +  '                     } '
                +  '                    ] '
                +  '                } '
                +  '            ], '
                +  '            \"id\": \"f78107d6-8ac2-4615-87df-dfc1ce5f84e5\" '
                +  '        } '
                +  '    ] '
                +  ' }';
        
        String putResponse = CEC_360_IntegrationConsents.putConsents('021032020195', jsonRequest);
        Account acc = [SELECT Id FROM Account limit 1];
        
        String response = CEC_360_LGPDConsentsController.saveConsents(acc.id, jsonRequest);
    }
}