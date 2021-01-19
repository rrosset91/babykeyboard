/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 25/08/2020
   	Descrição: Classe de teste Integração  para a coluna extrato do historico de direitos .
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest
global class CEC_360_IntegrationHistoryExtractTst  implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiVersion":"1;2020-07-31","transactionId":"78776915-3bf1-4b2c-b03e-d871c14e78da","data":{"groupName":"BIGID","groupId":"a7b72bcb-a3ca-4348-aa4d-6dfb94b442f8","dataDiscoveryResultsV2Dtos":{"content":[{"id":"728127a1-06f9-4853-a591-60df6295420d","fieldName":"CPF","value":"17376291865","system":null},{"id":"8e2dcd8b-3173-4990-a376-3ca4c25e0f42","fieldName":"ASS_CLAROCLUBE","value":"1","system":null},{"id":"5701af7a-a488-4843-94e8-063540e365f5","fieldName":"ASS_CLAROFIXO","value":"0","system":null},{"id":"cd903ce5-17a5-4d2d-9b6f-9e5154daa331","fieldName":"ASS_CLAROTV","value":"0","system":null},{"id":"e8d4b544-913f-460a-bb32-4b7601d6fb2a","fieldName":"CPF","value":"17376291865","system":null}],"pageable":{"sort":{"sorted":false,"unsorted":true,"empty":true},"pageNumber":0,"pageSize":20,"offset":0,"paged":true,"unpaged":false},"totalPages":2,"totalElements":28,"last":false,"first":true,"sort":{"sorted":false,"unsorted":true,"empty":true},"numberOfElements":20,"size":20,"number":0,"empty":false}}}');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
    public static void testGetCallout() {
        CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract objectGet = new  CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract();
       
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationHistoryExtractTst()); 
        objectGet = CEC_360_IntegrationHistoryExtract.getHistoryExtract('11111111');
        Test.StopTest ();
     //   System.debug('Id response get: ' + objectGet.customerOrders[0].Id);
       System.assertEquals(objectGet.data.dataDiscoveryResultsV2Dtos.content[0].fieldName, 'CPF');
        System.assertEquals(objectGet.data.dataDiscoveryResultsV2Dtos.content[0].value, '17376291865');
    }

}