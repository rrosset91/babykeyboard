public class CEC_PME_EnvioPedido_Mock implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = '{"Ticket_RPA":"xpto"}';
        CEC_PME_EnvioPedido_Response reponse = new CEC_PME_EnvioPedido_Response();
        reponse.apiVersion = '';
        reponse.transactionId = '';
        reponse.data = new CEC_PME_EnvioPedido_Response.Data();
        reponse.data.salesOrder = new CEC_PME_EnvioPedido_Response.SalesOrder();
        reponse.data.salesOrder.orderId = 'test';
        CEC_PME_EnvioPedido_Response.Error error = new CEC_PME_EnvioPedido_Response.Error();
        error.httpCode = '';
        error.errorCode = '';
     	error.message = '';
     	error.detailedMessage = '';
        error.link = new CEC_PME_EnvioPedido_Response.Link();
        error.link.rel = '';
        error.link.href = '';
	    res.setBody(JSON.serialize(reponse));
	    res.setStatus('OK');
	    res.setStatusCode(200);
	    return res;
	}
}