global class CEC_HttpResponseCloseNetSmsTest implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req)
  {

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{'+
                    '"apiVersion": "1;2019-09-12",'+
                    '"transactionId": "Id-8f0e865f7f5600d9a4a0b750",'+
                    '"error": {'+
                                '"httpCode" : "422",'+
                                '"errorCode": "API-CONTACT-RECORDS-008",'+
                                '"message": "Unprocessable Entity",'+
                				'"detailedMessage": null,'+
                				'"link": {'+
                                            '"rel": "related",'+
                                            '"href": "https://oag.claro.com.br/docs/error_codes.html"'+
                						'}' +               
                                '}'+
                '}' 
               );
     res.setStatusCode(422);
    return res;
  }
}