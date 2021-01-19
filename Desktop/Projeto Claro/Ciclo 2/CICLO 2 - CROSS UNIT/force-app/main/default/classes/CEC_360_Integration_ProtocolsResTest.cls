@isTest
public class CEC_360_Integration_ProtocolsResTest {
  
    static testMethod void testgetProtocolsAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.attendences> attendences = CEC_360_Integration_ProtocolsResidential.getProtocols('003', '123456789', '201-01-10', '2019-01-01');
        Test.stopTest();
    }
    
    static testMethod void testgetProtocolsNumberAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.attendences> attendences = CEC_360_Integration_ProtocolsResidential.getProtocolsNUmber('003', '1234567890123');
        Test.stopTest();
        
    }
    
     static testMethod void testgetProtocolsUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.attendences> attendences = CEC_360_Integration_ProtocolsResidential.getProtocols('003', '123456789', '201-01-10', '2019-01-01');
        Test.stopTest();
    }
    
    
     static testMethod void testgetProtocolsNumberUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.attendences> attendences = CEC_360_Integration_ProtocolsResidential.getProtocolsNUmber('003', '1234567890123');
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
            CEC_RestObjects.Protocols lstProtocols = CEC_360_Integration_ProtocolsResidential.generateMock();
            String body = JSON.serialize(lstProtocols, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
        
    }
}