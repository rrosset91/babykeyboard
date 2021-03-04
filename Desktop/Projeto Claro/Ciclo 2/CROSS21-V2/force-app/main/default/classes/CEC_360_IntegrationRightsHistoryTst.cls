/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 09/07/2020
   	Descrição: Classe de Teste  para a integração do componente CEC_360_LGPDRightsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest
global class CEC_360_IntegrationRightsHistoryTst  implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiversion":"1; 2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","customerOrders":[{"id":"SL244HWD6D","orderDate":"2019-08-09T12:49:47.983Z","completionDate":"2019-08-09T12:49:47.983Z","orderType":"Atualização de dados","status":"Aberto","email": "teste@test.com.br"}]}]}}');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
     public static  void testGetCallout() {
         

        Test.StartTest();
        CEC_360_LGPDIntegrationObjects.getRightsHistory objectGet = new  CEC_360_LGPDIntegrationObjects.getRightsHistory();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationRightsHistoryTst()); 
        //objectGet.customerOrders[0].orderType = 'Acesso_Dados_Cadastrais';
        objectGet = CEC_360_IntegrationRightsHistory.OrdersRightsHistory('02608537804');
        Test.StopTest();
        System.debug('Id response get: ' + objectGet.customerOrders[0].Id);
        System.assertEquals(objectGet.customerOrders[0].Id, 'SL244HWD6D');
    }

}