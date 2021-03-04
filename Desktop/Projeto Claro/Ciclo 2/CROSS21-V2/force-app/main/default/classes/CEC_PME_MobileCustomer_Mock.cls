/*
* Autor: Marcos Aurelio - Deloitte
* Data: 27/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 8]
* Mock utilizado pela classe de teste PME_ValidateCNPJ_Test.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: João Rodrigues
* Data: 02/06/2020
* Alterações: Mocks específicos para testes da PME_ValidateCNPJ_Test
*/

public class CEC_PME_MobileCustomer_Mock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = '{}';
        if(req.getEndpoint().contains('05438120000199')) {
            body = '{ "apiVersion" : "1;2019-01-09", "transactionId" : "Id-ebb5d65e35ef596858144ecb", "data" : null }';
        }
        else {
            body = '{"data":{"mobileCustomers":[{"customerIdentifier":"PJ","socialName":"CASA LILAS LTDA","documentNumberCNPJ":"48021502000125"}]},"ParametroInvalidoFault":{"mensagem":"classe teste"},"TechnicalFault":{"mensagem":"classe teste"}}';
        }
        
        res.setBody(body);
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
}