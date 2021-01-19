@istest
global class CEC_HttpResponseCloseNetSmsSucessTest implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req)
  {
   // System.assertEquals('http://200.169.123.170:9000/sdp/interactions', req.getEndpoint());
   // System.assertEquals('GET', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{'+
                '"apiVersion": "string",'+
                '"transactionId": "string",'+
                '"data": {'+
                    '"data" : [{'+
                        '"protocolNumber": "076123123123123",'+
                        '"number": "123123123"'+
                    '}],'+
                '"message" : "Success"' +
                '}'+
                '}');
     //res.setStatus('200');
     res.setStatusCode(200);
    return res;
  }
}