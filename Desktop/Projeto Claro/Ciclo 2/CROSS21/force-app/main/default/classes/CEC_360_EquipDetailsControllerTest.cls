@isTest    

public class CEC_360_EquipDetailsControllerTest {
@isTest    
    public static void getDevicesTest  (){
        
        Account acc = new Account(Name = 'AccPrincipal');
        insert acc;
        Asset ast = new Asset(Name = 'AssLokiDown', msisdn__c ='11954434501',
         Accountid = acc.Id);

        insert ast;
        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_EquipDetailsController.getDevices(ast.Id);
        Test.stopTest();

    }

    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.subscriberLastDeviceResponse lstdevice = CEC_360_IntegrationDevices.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstdevice, true));
            res.setStatusCode(200);
            return res;
        }
    }
}