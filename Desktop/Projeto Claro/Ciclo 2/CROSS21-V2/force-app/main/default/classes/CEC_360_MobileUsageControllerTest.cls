/*
* Autor:Letícia Freitas.
* Data: 26/06/2019
* [Claro Visão 360] [Time: SQUAD 360]
* Descrição: [USS 202 - Sprint 8] - Classe test para a controller CEC_360_MobileUsage.
* 
*/

@isTest
public class CEC_360_MobileUsageControllerTest {
   
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'UsageMobiles';
        csServiceName.ServiceName__c = '/mobileusage';
        Database.insert(csServiceName);
    }   
    
    static testMethod void testGetgetMobileUsage(){
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointMobileUsage());
        CEC_360_MobileUsageController.getMobileUsage(ast.Id);
        Test.stopTest();
      }
    
       
    
      @TestVisible class AuthorizedEndpointMobileUsage implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.mobileUsage objMobileUsage = CEC_360_IntegrationsMobileUsage.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(objMobileUsage, true));
            res.setStatusCode(200);
            return res;
        }
    }
           
    
       
}