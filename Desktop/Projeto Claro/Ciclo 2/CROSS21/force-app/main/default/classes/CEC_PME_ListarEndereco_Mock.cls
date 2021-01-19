/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Mock utilizado pela classe de teste CEC_PME_ListarEndereco_Test.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public class CEC_PME_ListarEndereco_Mock  implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
	    res.setHeader('Content-Type', 'application/json');
	    String body = '{"apiVersion":"1;2017-11-16","transactionId":"Id-ae84e45be78bced01a4fbad7","data":{"address":[{"addressType":"LOGRADOURO","prefix":"R","logradouro":"AUGUSTOFRANCODESOUSA","number":null,"addressComplement":null,"neighborhood":"VILASANTISTA","mailbox":null,"city":"SAOPAULO","state":"SP","zipCode":"02560060","ibgeCityId":"3550308","ibgeUfId":"35","ddd":"11","ruralAreaIndicator":"false"}]},"error":{"message":"error message"}}';
	    res.setBody(body);
	    res.setStatus('OK');
	    res.setStatusCode(200);
	    return res;
	}   
}