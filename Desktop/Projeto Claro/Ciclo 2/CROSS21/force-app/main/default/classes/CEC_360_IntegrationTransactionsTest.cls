/*
* Autor: Danilo Fucuhara (Deloitte)
* Data: 07/01/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 07-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Criado os metodos de teste, implantado o httpmockcallout para utilização nos testes.
*/

@isTest
public class CEC_360_IntegrationTransactionsTest { 
    
    static CEC_ServiceName__c csServiceName;
    
    static { 
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Transactions';
        csServiceName.ServiceName__c = '/transactions';
        Database.insert(csServiceName);
    }     
    
    static testMethod void testGetTransactionsLast1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsLast('11123451234'));
        System.assertEquals(1, transactions.size());
        Test.stopTest(); 
    }
    
    static testMethod void testGetTransactionsLast2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsLast('11123451234'));
        System.assertEquals(1, transactions.size());
        Test.stopTest(); 
    }
    
    static testMethod void testGetTransactionsPeriod1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsPeriod('11123451234', '2019-01-23', '2019-02-23', 'Recargas', 'Recarga'));
        System.assertEquals(1, transactions.size());
        Test.stopTest(); 
    }
    
    static testMethod void testGetTransactionsPeriod2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsPeriod('11123451234', '2019-01-23', '2019-02-23', 'Recargas', null));
        System.assertEquals(1, transactions.size());
        Test.stopTest(); 
    }
    
    static testMethod void testGetTransactionsPeriod3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsPeriod('11123451234', '2019-01-23', '2019-02-23', null, null));
        System.assertEquals(1, transactions.size());
        Test.stopTest(); 
    }
    
    static testMethod void testGetTransactionsPeriod4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.Transactions> transactions = new List<CEC_RestObjects.Transactions>();
        transactions.add(CEC_360_IntegrationTransactions.getTransactionsPeriod('11123451234', '2019-01-23', '2019-02-23', null, null));
        System.assertEquals(1, transactions.size());
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
            CEC_RestObjects.Transactions lstBalances = CEC_360_IntegrationTransactions.generateMock();
            String body = JSON.serialize(lstBalances, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}