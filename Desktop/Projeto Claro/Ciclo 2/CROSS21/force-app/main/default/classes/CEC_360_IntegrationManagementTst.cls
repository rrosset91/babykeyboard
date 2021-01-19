/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 26/10/2020
   	Descrição: Classe de Teste  para a integração do componente CEC_360_LGPDRightsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest
global class CEC_360_IntegrationManagementTst  implements HttpCalloutMock {
 
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "apiVersion": "1;2020-09-22", "transactionId": "e7cbf629-6444-4f77-adaf-fc35e283679e", "data": { "message": "SUCCESS"}} ');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
     public static  void testGetCallout() {
         

        Test.StartTest();
        CEC_360_LGPDIntegrationObjects.PutManagement objectGet = new  CEC_360_LGPDIntegrationObjects.PutManagement();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationManagementTst()); 
        //objectGet.customerOrders[0].orderType = 'Acesso_Dados_Cadastrais';
        //
     string bodyManagement = ' { "data": {' 
                                 + '"requestId": "'+ 'QSL74AYZCM' + '" , '
                                 + '"comment":  "' + 'comentario' +'" , '
                                 + '"internal": true'
                                 + ' } }';
        objectGet = CEC_360_IntegrationManagement.PutManagement(bodyManagement);
        Test.StopTest();
        
        System.assertEquals(objectGet.data.message, 'SUCCESS');
    }

}