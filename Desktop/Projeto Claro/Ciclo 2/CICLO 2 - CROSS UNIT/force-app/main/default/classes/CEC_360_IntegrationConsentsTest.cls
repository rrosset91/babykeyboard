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
        list<string> selectedDelList;
        CEC_RestObjects.GetConsents objetosGet = new  CEC_RestObjects.GetConsents();
        List<CEC_RestObjects.Purpose> lstCharacReq = new List<CEC_RestObjects.Purpose>();
        objetosGet.preferenceCenterId = 'id12356';
        objetosGet.protocolNumber = 'protocolo1235125';
        objetosGet.Purposes = lstCharacReq;
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest()); 
        
        objetosGet = CEC_360_IntegrationConsents.getConsents('021032020195');
 
    }
    
    @isTest
    public static void testPutCallout() {
        CEC_RestObjects.PutConsents ObjectsPut = new  CEC_RestObjects.PutConsents();
        List<CEC_RestObjects.Consent> consents = new List<CEC_RestObjects.Consent>();
        ObjectsPut.origin = 'CEC';
        ObjectsPut.agreements = consents;
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest()); 
        
        ObjectsPut = CEC_360_IntegrationConsents.putConsents('021032020195','JSON','purposeId');
        Account acc = [SELECT Id FROM Account limit 1];
        
        ObjectsPut = CEC_360_LGPDConsentsController.saveConsents(acc.id,'JSON','purposeId');
    }
}