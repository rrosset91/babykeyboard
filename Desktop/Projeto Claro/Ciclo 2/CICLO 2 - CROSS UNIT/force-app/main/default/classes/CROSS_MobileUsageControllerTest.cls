/**
* @author: Gustavo Rodrigues
* @company: IBM - Bluewolf
* @description: Classe de teste para a controladora "CROSS_MobileUsageController"
*/


@isTest
public class CROSS_MobileUsageControllerTest {
    
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
        
        Case cs = new Case();
		cs = CEC_SobjectFactory.getCase(acc);
        cs.Contract__c = '999/999999999';
        cs.BusinessUnit__c = 'NET';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Backoffice').getRecordTypeId();
        
        insert cs;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointMobileUsage());
        CEC_RestObjects.mobileUsage response = CROSS_MobileUsageController.getMobileUsage(cs.Id);
        Test.stopTest();
        System.assert(response != null);
    }
    
    static testMethod void testGetgetMobileUsageError(){
        
        String message = '';
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointMobileUsage());
        try{
            CROSS_MobileUsageController.getMobileUsage(ast.Id);
        }catch(Exception e){
            message = e.getMessage();
        }
        Test.stopTest();
        System.assert(message.contains('Script'));
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