@isTest
public class CEC_360_IntPromotionsBenefitsTest {
    
    
    static testMethod void testgetPromotionBenefitsUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        cec_360_IntegrationPromotionBenefits.getPromotionBenefits('12345678','1234','1234','1234');
        Test.stopTest(); 
    }
    
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.PromotionBenefitsMain lstPrmBenefits = CEC_360_IntegrationPromotionBenefits.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstPrmBenefits, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestVisible class UnauthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }
}