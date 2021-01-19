@isTest
global class HttpResponseErrorTest implements HttpCalloutMock{
  
  global HTTPResponse respond(HTTPRequest req)
  {
    System.assertEquals('http://200.169.123.170:9000/corp/contactrecords', req.getEndpoint());
    System.assertEquals('POST', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{'+
                 '"apiVersion": "string",'+
                  '"transactionId": "string",'+
                  '"error": {'+
                  '"httpCode": "500",'+
                  '"errorCode": "API-CONTACTRECORDS-011",'+
                  '"message": "Error",'+
                  '"detailedMessage": "null",'+
                  '"link": {'+
                  '"rel": "related",'+
                  '"href": "https://xpto.com.br"'+ 
                  '}'+
                  '}'+
                '}');
     res.setStatus('500');
    //res.setStatusCode(200);
    return res;
  }

}