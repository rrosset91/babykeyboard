/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe de teste para a classe de Integração CEC_360_IntegrationsSubscriberHistory.apxc.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
* [19/07] - Danilo Fucuhara - Ajuste para utilizar credenciais nomeadas.
*/

@isTest
public class CEC_360_IntegrationsSubscriberHisTest {
    
    static ServiceParameter__c invService;
    static CEC_ServiceName__c servName;
    
    static {
        servName = new CEC_ServiceName__c();
        servName.Name = 'UsageMobiles';
        servName.ServiceName__c = '/usageMobiles';
        insert servName;
        
        servName = new CEC_ServiceName__c();
        servName.Name = 'Subscriber';
        servName.ServiceName__c = '/mobilesubscribershistory';
        insert servName;
    }   
    
    static testMethod void getMobileIdAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationsSubscriberHistory.getMobileId('1199999999');
        Test.stopTest(); 
    }
    
    static testMethod void getMobileIdUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationsSubscriberHistory.getMobileId('');
        Test.stopTest(); 
    }
    
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.mobileSubscribersHistory mobileSubs = CEC_360_IntegrationsSubscriberHistory.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(mobileSubs, true));
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