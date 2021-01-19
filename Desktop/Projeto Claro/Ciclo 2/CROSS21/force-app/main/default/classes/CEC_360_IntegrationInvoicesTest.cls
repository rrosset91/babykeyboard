/* Autor: Danilo Fucuhara - Deloitte 
Criação: 24/04/2018 
Descrição: Classe de teste para CEC_360_IntegrationInvoices.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*/

@isTest
public class CEC_360_IntegrationInvoicesTest {
    
   
    
    static testMethod void getInvoiceResidencialTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoiceResidencial('','','','','');
        Test.stopTest();
    }
    
    static testMethod void getInvoiceResidencialTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoiceResidencial('','','','','');
        Test.stopTest();
    }
    
    static testMethod void getInvoiceMovelTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoiceMovel('','','','');
        Test.stopTest();
    }
    
    static testMethod void getInvoiceMovelTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoiceMovel('','','','');
        Test.stopTest();
    }
    
    static testMethod void getInvoicesURLTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoicesURL('','','');
        Test.stopTest();
    }
    
    static testMethod void getInvoicesURLTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoicesURL('','','');
        Test.stopTest();
    }
    
     
    
      static testMethod void getInvoicesURLResTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationInvoices.getInvoicesURLRes('','','');
        Test.stopTest();
    }
    
    static testMethod void formatStatusTest1() {
        Test.startTest();
        CEC_360_IntegrationInvoices.formatStatus('2020-02-20', 'true', 1, 1);
        Test.stopTest();
    }
    
    static testMethod void formatStatusTest2() {
        Test.startTest();
        CEC_360_IntegrationInvoices.formatStatus('2019-02-20', 'true', 1, 1);
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
            CEC_RestObjects.InvoiceMain invoice = CEC_360_IntegrationInvoices.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(invoice, true));
            res.setStatusCode(200);
            return res;
        }
    }  
    
    
    
    
    
}