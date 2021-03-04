/*
* Autor: Danilo Fucuhara (Deloitte)
* Data: 12/02/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360] Classe de teste para a CEC_360_IntegrationPromotions.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 12-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Criado o método testGetPromotions1(), testGetPromotions2(), testFormatPromotions, AuthorizedEndpoint e UnauthorizedEndpoint.
*---------------------------------------------------------------
* Data: 06-06-2019  
* Autor:Letícia Freitas
* Alterações: Alterado para credencial nomeada.
*---------------------------------------------------------------
* Data: 11-06-2019  
* Autor: Letícia Freitas
* Alterações: Adicionado métodos para busca de histórico de promoções.
*/

@isTest
public class CEC_360_IntegrationPromotionsTest {
    
   
    
    static testMethod void testGetPromotions1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationPromotions.getPromotions('11123451234');
        Test.stopTest(); 
    }
    
    static testMethod void testGetPromotions2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationPromotions.getPromotions('11123451234');
        Test.stopTest(); 
    }
    
    static testMethod void testFormatPromotions() {
        Test.startTest();
        CEC_RestObjects.PromotionsMain promotions = CEC_360_IntegrationPromotions.generateMock();
        promotions = CEC_360_IntegrationPromotions.formatPromotions(promotions);
        Test.stopTest(); 
    }
    
    
    static testMethod void testHistoryPromotions() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointHistory());
        CEC_360_IntegrationPromotions.getPromotionsHistory('11900000000','2019-01-01','2019-01-01');
        Test.stopTest(); 
    }
    
     @TestVisible class AuthorizedEndpointHistory implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.promotionsHistoryResponse main = CEC_360_IntegrationPromotions.generateMockHistory();
            String body = JSON.serialize(main, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(main, true));
            res.setStatusCode(200);
            return res;
            
        }
     }
    
    
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.PromotionsMain lstPromotions = CEC_360_IntegrationPromotions.generateMock();
            String body = JSON.serialize(lstPromotions, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstPromotions, true));
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