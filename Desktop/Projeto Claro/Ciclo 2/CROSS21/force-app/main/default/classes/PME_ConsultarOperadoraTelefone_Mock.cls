/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Mock utilizado pela classe de teste PME_ConsultarOperadoraTelefone_Test.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

@isTest
global class PME_ConsultarOperadoraTelefone_Mock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
	    res.setHeader('Content-Type', 'application/json');
	    //String body = '{"data":{"validRequests":[{"donorOperator":{"name":"VIVO S.A."},"requestedTickets":{"phoneLineNumberType":{"phoneLineNumber":"11975278987"}}}],"rejectedRequests":[{"detail":"Prefixos não cadastrados no SAPN da Anatel.","requestedTickets":{"phoneLineNumberType":{"phoneLineNumber":"11000000001"}}},{"detail":"Telefones não podem ser portados pois já estão na Claro.","requestedTickets":{"phoneLineNumberType":{"phoneLineNumber":"11945867706"}}}]}}';
	    String body = '{ "data":{"validRequests":[ {"donorOperator":{ "name":"VIVO S.A."},"requestedTickets":[{ "phoneLineNumberType":{"phoneLineNumber":"11975278987" }}] }],"rejectedRequests":[ {"detail":"Prefixos não cadastrados no SAPN da Anatel.",			"rejectionReason":{"reasonId":""},"requestedTickets":[{ "phoneLineNumberType":{"phoneLineNumber":"11000000001" }}] }, {"detail":"Telefones não podem ser portados pois já estão na Claro.",			"rejectionReason":{"reasonId":""},"requestedTickets":[{ "phoneLineNumberType":{"phoneLineNumber":"11945867706" }}] }] }}';
        res.setBody(body);
	    res.setStatus('OK');
	    res.setStatusCode(200);
	    return res;
	}
}