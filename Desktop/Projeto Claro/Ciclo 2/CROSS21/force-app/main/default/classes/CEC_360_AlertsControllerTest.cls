/* 	Autor: Danilo Fucuhara - Deloitte
   	Criação: 19/06/2019
   	Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

@isTest
private class CEC_360_AlertsControllerTest { 
        
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
    
    static testMethod void testGetAlerts() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_AlertsController.getAlerts(ast.Id);
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
}