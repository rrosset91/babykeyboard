/* 	Autor: Rennê Silva - Sysmap
   	Criação: 07/07/2020
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD LGPD */

@isTest
global class CEC_360_IntegrationdsarTest implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiversion":"1; 2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","customerOrders":[{"id":"SL244HWD6D","orderDate":"2019-08-09T12:49:47.983Z","completionDate":"2019-08-09T12:49:47.983Z","orderType":"Atualização de dados","status":"Aberto"}]}]}}');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
    public static void testGetCallout() {
        CEC_360_LGPDIntegrationObjects.GetDsarByStatus objectGet = new CEC_360_LGPDIntegrationObjects.GetDsarByStatus();
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationdsarTest()); 
        
        objectGet = CEC_360_Integrationdsar.getDsarByTypeAndStatusNotClosed('11111111111','Tratamento_Dados');
        System.debug('Id response get: ' + objectGet.customerOrders[0].Id);
        System.assertEquals(objectGet.customerOrders[0].Id, 'SL244HWD6D');
    }
    
    @isTest
    public static void testPostCallout() {
        CEC_360_LGPDIntegrationObjects.PostDsar ObjectPost = new CEC_360_LGPDIntegrationObjects.PostDsar();
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_LGPDdsarControllerTest()); 
        
        ObjectPost = CEC_360_Integrationdsar.postDsar('{"data":{"language":"en-us","subjectTypes":["Cliente"],"requestTypes":["Tratamento_Dados"],"email":"teste2@teste.com","name":"","cpf":"11111111111","webFormData":{"requestDetails":"observação","formField29":"canal"}}}');
        System.debug('Id response post: ' + ObjectPost.data.requestQueueRefId);
        System.assertEquals(ObjectPost.data.requestQueueRefId, '9G52T9LV2F');
    }
    
}