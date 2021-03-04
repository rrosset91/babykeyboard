@isTest
public class CEC_360_IntegrationOrdersTest {
       static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'WorkOrders';
        csServiceName.ServiceName__c = '/WorkOrders';
        Database.insert(csServiceName);
    }  
    
     static testMethod void testgetOrdersAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Order> obj = CEC_360_IntegrationOrders.getOrders('12345','21455','2019-01-01','2019-01-01');
        Test.stopTest();
    }
    
    static testMethod void testgetOrdersUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.Order> obj = CEC_360_IntegrationOrders.getOrders('12345','21455','2019-01-01','2019-01-01');
        Test.stopTest();
    }
    
    static testMethod void testgetOrderfromNumberAuthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List<CEC_RestObjects.Order> obj = CEC_360_IntegrationOrders.getOrdersNumber('12345','78986');
        Test.stopTest();
    }
    
      static testMethod void testgetOrderfromNumberUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        List<CEC_RestObjects.Order> obj = CEC_360_IntegrationOrders.getOrdersNumber('12345','78986');
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