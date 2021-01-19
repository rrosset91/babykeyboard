@isTest
public class CEC_360_ProtocolsMobileControllerTest {
    
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Interactions';
        csServiceName.ServiceName__c = '/Interactions';
        Database.insert(csServiceName);
        
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Subscriber';
        csServiceName.ServiceName__c = '/mobileSubscriber';
        Database.insert(csServiceName);
    }  
    
    static testMethod void getAssetsTest (){
        Account acc = new Account();
        acc.Name = 	'teste';
        insert acc;
        
        Asset ast = new Asset();
        ast.name = 'testeAst';
        ast.MSISDN__c = '1199999999';
        ast.AccountId = acc.id;
        insert ast;
        
        Test.startTest();
         CEC_360_ProtocolsMobileController.getAssets(acc.id);
        Test.stopTest();
    }
    
    static testMethod void getProtocolsNumberTestAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ProtocolsMobileController.getProtocolsNumber('123456789');
        Test.stopTest();
    }
    
     static testMethod void getProtocolsDataTestAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ProtocolsMobileController.getProtocolsData('1199999999', '2019-01-01','2019-01-01');
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
            CEC_RestObjects.Protocols objProtocols = CEC_360_IntegrationMobileProtocols.generateMock();
            String body = JSON.serialize(objProtocols, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
        
    }
    
   
}