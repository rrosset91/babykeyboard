/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe de teste para a classe de ntegração CEC_360_IntegreationMemos.apxc.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*/

@isTest
public class CEC_360_IntegrationMemosTest {
    
     
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Memos';
        csServiceName.ServiceName__c = '/memos';
        Database.insert(csServiceName);
    }    
    
    static testMethod void getMemosAuthorized(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationMemos.getMemos('11999999991','2010-01-01','2019-02-02');
        Test.stopTest();
    }
    
    static testMethod void getMemosUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint ());
        CEC_360_IntegrationMemos.getMemos('','','');
        Test.stopTest();
    }
    
     static testMethod void getContractAuthorized(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationMemos.getMemosContract('11999999991','2010-01-01','2019-02-02');
        Test.stopTest();
    }
    
      static testMethod void getContractUnauthorized(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationMemos.getMemosContract('11999999991','2010-01-01','2019-02-02');
        Test.stopTest();
    }

      @TestVisible class UnauthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.memosMain memos = CEC_360_IntegrationMemos.generateMockMemosAssinante();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(memos, true));
            res.setStatusCode(200);
            return res;
        }
    }  
}