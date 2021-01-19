/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 26/10/2020
   	Descrição: Classe de Teste  para a integração do componente CEC_360_LGPDRightsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest
global class CEC_360_IntegrationOrdersStagesTst  implements HttpCalloutMock {
 
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiVersion": "1;2020-07-18",'
                          + '"transactionId": "045489e1-f575-4f0e-9111-56e6dc7ea890",'
                          + '"data": {'
                          +  '"requestQueueId": "QSL74AYZCM",'
                          +  '"currentStage": "FECHADO",'
                          + '"statusCode": 2}}'  );
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
     public static  void testGetCallout() {
         

        Test.StartTest();
        CEC_360_LGPDIntegrationObjects.PutOrdersStage objectGet = new  CEC_360_LGPDIntegrationObjects.PutOrdersStage();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationOrdersStagesTst()); 
        //objectGet.customerOrders[0].orderType = 'Acesso_Dados_Cadastrais';
        //
        string body =        ' { "data": {'
                            + '"comments": "' + 'COMENTARIO' + '" ,'
                            + '"internalComment": true,'
                            + '"nextstage": "FECHADO",'
                            + '"resolution": "Pedido aprovado" , '
                            +'"requestQueueRefId": "' + 'SL244HWD6D'  +'" , '
                            + '"language": "en-us"'
                            + '} }';
        objectGet = CEC_360_IntegrationOrdersStages.putOrdersStages(body);
        Test.StopTest();
        
        System.assertEquals(objectGet.data.currentStage, 'FECHADO');
    }

}