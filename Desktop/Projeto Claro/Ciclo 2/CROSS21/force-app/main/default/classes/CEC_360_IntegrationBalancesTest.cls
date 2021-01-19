/*
* Autor: Magno da Cruz (Deloitte)
* Data: 07/01/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360]
*/

@isTest
private class CEC_360_IntegrationBalancesTest { 
     
    
    static testMethod void testGetBalance(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.BalancesMain> balances = new List<CEC_RestObjects.BalancesMain>();
        balances.add(CEC_360_IntegrationBalances.getBalance('11123451234'));
        System.assertEquals(1, balances.size());
        test.stopTest();
    }
    
    static testMethod void testGetBalance2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndPoint());
		List<CEC_RestObjects.BalancesMain> balances = new List<CEC_RestObjects.BalancesMain>();        
        balances.add(CEC_360_IntegrationBalances.getBalance('11123451234'));
        System.assertEquals(1, balances.size());
        test.stopTest();
    }
    
    static testMethod void testGetOtherBalances(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());        
        List<CEC_RestObjects.Accumulators> accumulators = new List<CEC_RestObjects.Accumulators>();
        accumulators = CEC_360_IntegrationBalances.getOtherBalances('11123451234');
        System.assertEquals(4, accumulators.size());
        test.stopTest();
        
    }
    
    static testMethod void testGetOtherBalances2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndPoint());        
        List<CEC_RestObjects.Accumulators> accumulators = new List<CEC_RestObjects.Accumulators>();
        accumulators = CEC_360_IntegrationBalances.getOtherBalances('11123451234');
        System.assertEquals(accumulators, CEC_360_IntegrationBalances.getOtherBalances('11123451234'));
        test.stopTest();
     }
    
    static testMethod void testGetOtherBalancesPromotional(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());        
        List<CEC_RestObjects.PromotionalBalances> promotionals = CEC_360_IntegrationBalances.getOtherBalancesPromotional('11123451234');
        System.assertEquals(1, promotionals.size());
        test.stopTest();
    }
    
    static testMethod void testGetOtherBalancesPromotional2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndPoint());        
        List<CEC_RestObjects.PromotionalBalances> promotionals = new List<CEC_RestObjects.PromotionalBalances>();
        promotionals = CEC_360_IntegrationBalances.getOtherBalancesPromotional('11123451234');
        System.assertEquals(promotionals, CEC_360_IntegrationBalances.getOtherBalancesPromotional('11123451234'));
        test.stopTest();
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
            CEC_RestObjects.BalancesMain lstBalances = CEC_360_IntegrationBalances.generateMock();
            String body = JSON.serialize(lstBalances, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
}