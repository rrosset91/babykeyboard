@isTest
public class SOLAR_IntegrationRESTTest {
    public class StdRestMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            return response;
        }
    }
    @TestSetup
    static void testSetup(){
        ServiceParameter__c newServiceParameter = constructServiceParameter();
        insert newServiceParameter;
    }
    private static ServiceParameter__c constructServiceParameter(){
        ServiceParameter__c newServiceParameter = new ServiceParameter__c();
        
        newServiceParameter.ContentType__c = 'Test';
        newServiceParameter.Method__c = 'GET';
        newServiceParameter.NamedCredential__c = 'OAGClaro';
        newServiceParameter.Timeout__c = 120000;
        newServiceParameter.EndPoint__c = '/{!parameter}';
        newServiceParameter.Name = 'testServiceName';
        return newServiceParameter;
    }
    @isTest
    public static void sendRequest(){
        Test.setMock(HttpCalloutMock.class,new StdRestMock());
        Test.startTest();
        SOLAR_IntegrationREST integrationRest = new SOLAR_IntegrationREST();
        HttpResponse response = integrationRest.sendRequest('testServiceName', '', new Map<String, String>{'{!parameter}'=> 'Test'});
        System.assert(response.getStatusCode() == 200, 'O status de retorno deve ser igual 200.');
        Test.stopTest();
    }
}