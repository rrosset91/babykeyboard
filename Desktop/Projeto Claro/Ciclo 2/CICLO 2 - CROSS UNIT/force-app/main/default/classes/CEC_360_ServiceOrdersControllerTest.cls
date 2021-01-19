/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [06/09/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 11] +
* [Classe teste para a classe apex CEC_360_ServiceOrdersController]
*----------------------------------------------------------------------------------*
*/
@isTest
public class CEC_360_ServiceOrdersControllerTest {

    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'WorkOrders';
        csServiceName.ServiceName__c = '/WorkOrders';
        Database.insert(csServiceName);
    }  
    
     @TestVisible
    static testMethod void getContracts(){
        
         Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Account accT = new Account();
        accT.name = 'parentId';
        insert accT;
        
        Account acc = new Account();
        acc.name = 'son1';
        acc.RecordTypeId = recTypeBillingAccount;
        acc.ParentId = accT.id;
        acc.ContractReferenceNumber__c = '12345';
        acc.CityCode__c = '003';
        insert acc;
        
        Test.startTest();
        CEC_360_ServiceOrdersController.getContracts(accT.id);
        Test.stopTest();
        
    }
    
    static testMethod void getOrdemsfromDataTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ServiceOrdersController.getOrdemsfromData('2019-01-01','2019-01-01', '123/123456789');
        Test.stopTest();
    }
    
     static testMethod void getOrdemsfromNumberTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ServiceOrdersController.getOrdemsfromProtocol('12345688', '123/123456');
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
            CEC_RestObjects.ServiceOrder lstOrder = CEC_360_IntegrationOrders.generateMock();
            String body = JSON.serialize(lstOrder, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
        
    }
    
    
}