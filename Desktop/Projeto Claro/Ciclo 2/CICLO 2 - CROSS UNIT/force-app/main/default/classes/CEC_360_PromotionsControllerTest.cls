/* Autor: Danilo Fucuhara - Deloitte 
Criação: 22/03/2019
Descrição:Classe de teste para CEC_360_PromotionsControllerTest.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

@isTest
private class CEC_360_PromotionsControllerTest {
    
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'PromotionsHistory';
        csServiceName.ServiceName__c = '/promotionshistory';
        Database.insert(csServiceName);
        
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Promotions';
        csServiceName.ServiceName__c = '/promotions';
        Database.insert(csServiceName);
    }     
    
    
    static testMethod void testGetPromotions() {
        
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointPromotions());
        CEC_360_PromotionsController.getPromotions(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetPromotionsHistory() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;   
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointPromotionsHistory());
        CEC_360_PromotionsController.getHistoryPromotion(ast.id,'2019-01-01','2019-01-01');
        Test.stopTest();
        
    }
    
    
    @TestVisible class AuthorizedEndpointPromotions implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.PromotionsMain lstPromotion = CEC_360_IntegrationPromotions.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstPromotion, true));
            res.setStatusCode(200);
            return res;
        }
    }
    @TestVisible class AuthorizedEndpointPromotionsHistory implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.promotionsHistoryResponse lstPromotion = CEC_360_IntegrationPromotions.generateMockHistory();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstPromotion, true));
            res.setStatusCode(200);
            return res;
        }
    }
}