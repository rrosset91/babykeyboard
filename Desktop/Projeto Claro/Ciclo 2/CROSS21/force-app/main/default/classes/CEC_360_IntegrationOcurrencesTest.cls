/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [03/10/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 13] +
* [Classe apex para a chamada via integração de objetos.]
*--------------------------------------------------------------------------------*
*/

@isTest
public class CEC_360_IntegrationOcurrencesTest {
 
     static testMethod void testgetOcurrencesAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.ocurrencesObj> obj = CEC_360_IntegrationOcurrences.getOcurrences('123467891','003','2019-01-01','2019-06-01');
        Test.stopTest();
    }
    
    static testMethod void testgetOcurrencesUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.ocurrencesObj> obj = CEC_360_IntegrationOcurrences.getOcurrences('123467891','003','2019-01-01','2019-06-01');
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
            CEC_RestObjects.occurrencesResponse lstOcurrences = CEC_360_IntegrationOcurrences.generateMock();
            String body = JSON.serialize(lstOcurrences, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
        
    }

}