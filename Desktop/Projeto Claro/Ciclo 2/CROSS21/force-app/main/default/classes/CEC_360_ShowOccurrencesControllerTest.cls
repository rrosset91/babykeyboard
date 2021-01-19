@isTest 

public class CEC_360_ShowOccurrencesControllerTest{
    
    static testMethod void getContractNumberBillingAccount(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Test.startTest();
        CEC_360_ShowOccurrencesController.getContractNumberBillingAccount(acc.Id);
        Test.stopTest();
    }
    
    static testMethod void getOrdemsfromData(){
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'NET',
                                  ContractReferenceNumber__c = '004/34933869',
                                  CityCode__c = '003');
        insert acc;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
       //  Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ShowOccurrencesController.getOrdemsfromData('2017-01-01', '2017-06-01', '004/34933869');
        Test.stopTest();
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