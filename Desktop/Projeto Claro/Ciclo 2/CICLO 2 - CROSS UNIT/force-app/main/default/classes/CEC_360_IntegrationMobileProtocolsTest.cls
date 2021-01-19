@isTest
public class CEC_360_IntegrationMobileProtocolsTest {
    
    
    static testMethod void getProtocolsTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationMobileProtocols.getProtocols('11999999991', '2019-01-01','2019-06-01');
        Test.stopTest();
    }
    
    
    static testMethod void getProtocolsNumberTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationMobileProtocols.getProtocolsNumber('123456789');
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