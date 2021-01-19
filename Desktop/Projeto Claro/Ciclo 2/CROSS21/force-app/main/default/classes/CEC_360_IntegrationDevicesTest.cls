/* Autor: Letícia Freitas - Deloitte 
* Criação: 15/02/2018 
* Descrição: Nome do projeto/ID: CEC FASE - Time: SQUAD 360 -
* USS 199 -  Classe de teste CEC_360_IntegrationDevices */

@istest
public class CEC_360_IntegrationDevicesTest {
    
    
    static testMethod void testGetDevices(){
         
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_IntegrationDevices.getDevice('11123451234');
        Test.stopTest(); 
    }
    
     static testMethod void testGetDevicesUnauthorized(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpoint());
        CEC_360_IntegrationDevices.getDevice('11123451234');
        Test.stopTest(); 
    }
    
  
    static testMethod void testFormatData(){
        Test.startTest();
        CEC_RestObjects.subscriberLastDeviceResponse subscriberObj = CEC_360_IntegrationDevices.generateMock();
        CEC_RestObjects.dataDevice dataDevice = subscriberObj.data;
        CEC_RestObjects.Device Device = dataDevice.device;
        device = CEC_360_IntegrationDevices.formatData(device);
        Test.stopTest();
    }
    
    static testMethod void testformatEmptyFields(){
        Test.startTest();
        CEC_RestObjects.Device device = CEC_360_IntegrationDevices.generateMockBlank();
        device = CEC_360_IntegrationDevices.formatEmptyFields(device);
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
    
    @TestVisible class UnauthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }
    
}