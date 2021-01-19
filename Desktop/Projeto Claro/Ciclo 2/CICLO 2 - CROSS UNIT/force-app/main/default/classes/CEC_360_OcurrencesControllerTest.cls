@isTest
public class CEC_360_OcurrencesControllerTest {
    
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
        CEC_360_OcurrencesController.getContracts(accT.id);
        Test.stopTest();
        
    }
    
    static testMethod void getOcurrencesfromDataTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_OcurrencesController.getOrdemsfromData('2019-01-01','2019-01-01', '123/123456789');
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