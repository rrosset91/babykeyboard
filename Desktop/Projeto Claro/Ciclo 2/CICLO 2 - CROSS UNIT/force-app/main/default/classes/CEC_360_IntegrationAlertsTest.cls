/* 	Autor: Danilo Fucuhara - Deloitte
   	Criação: 19/06/2019
   	Nome do projeto/ID: CEC FASE - Time: SQUAD 360. 
* [19/07] - Danilo Fucuhara - Ajuste para utilizar credenciais nomeadas.
*/

@isTest
public class CEC_360_IntegrationAlertsTest {
        
    static ServiceParameter__c invService;
    static CEC_ServiceName__c servName;
    
    static {
        servName = new CEC_ServiceName__c();
        servName.Name = 'Alerts';
        servName.ServiceName__c = '/salesalertslist';
        insert servName;
        
        invService = new ServiceParameter__c();
        invService.Name = 'Alerts';
        invService.Method__c = 'GET';
        invService.User__c = 'USER';
        invService.Password__c = 'PASS';
        invService.EndPoint__c = '/alerts';
        insert invService;
    }    
    
    static testMethod void testGetAlerts1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationAlerts.getAlerts('999999999', '44444444444', 'CEC');
        Test.stopTest();
    }
    
    static testMethod void testGetAlerts2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationAlerts.getAlerts('999999999', '44444444444', 'CEC');
        Test.stopTest();
    }
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.AlertsMain main = CEC_360_IntegrationAlerts.generateMock();
            String body = JSON.serialize(main, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(main, true));
            res.setStatusCode(200);
            return res;
            
        }
     }
    
    @TestVisible class UnauthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }
    
}