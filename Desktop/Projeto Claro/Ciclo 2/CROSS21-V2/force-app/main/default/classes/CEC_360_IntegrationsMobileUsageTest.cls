/*
* Autor:Letícia Freitas.
* Data: 26/06/2019
* [Claro Visão 360] [Time: SQUAD 360]
* Descrição: [USS 202 - Sprint 8] - Classe de teste para CEC_360_IntegrationMobileUsageTest.
* 
*/

@Istest
public class CEC_360_IntegrationsMobileUsageTest {
    
    static CEC_ServiceName__c servName;
    static {
        servName = new CEC_ServiceName__c();
        servName.Name = 'UsageMobiles';
        servName.ServiceName__c = '/usageMobiles';
        insert servName;
    }
    
    static testMethod void testGetgetMobileUsage(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointMobileUsage());
        CEC_360_IntegrationsMobileUsage.getMobileUsage('11999999999');
        Test.stopTest();
    }
    
    static testMethod void testGetgetMobileUsageUnauthorized(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointMobileUsage());
        CEC_360_IntegrationsMobileUsage.getMobileUsage('11999999999');
        Test.stopTest();
    }
    
    @TestVisible class AuthorizedEndpointMobileUsage implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.mobileUsage objMobileUsage = CEC_360_IntegrationsMobileUsage.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(objMobileUsage, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestVisible class UnauthorizedEndpointMobileUsage implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }
    
}