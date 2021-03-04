@isTest
global class HttpResponseOcurrencyTest implements HttpCalloutMock{
  
  global HTTPResponse respond(HTTPRequest req)
  {
    System.assertEquals('http://200.169.123.170:9000/corp/contactrecords', req.getEndpoint());
    System.assertEquals('POST', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{'+
                 '"apiVersion": "string",'+
                  '"transactionId": "string",'+
                  '"data": {'+
                    '"contactRecords": ['+
                      '{'+
                        '"user": {'+
                          '"login": "12345678901",'+
                          '"userName": "Maria Maria",'+
                          '"partyId": {'+
                            '"number": "12345678901",'+
                            '"type": "12345678901"'+
                          '},'+
                          '"emailcontact": {'+
                            '"emailAddress": "maria@claro.com.br"'+
                          '},'+
                          '"telephone": {'+
                            '"areaCode": "011",'+
                            '"number": "99999-9999",'+
                            '"extensionNumber": "5432"'+
                          '}'+
                        '},'+
                        '"eventDate": "12345678901",'+
                        '"note": "12345678901",'+
                        '"sourceEvent": "12345678901",'+
                        '"eventType": {'+
                          '"identifier": "349",'+
                          '"description": "12345678901"'+
                        '},'+
                        '"type": {'+
                          '"identifier": "1",'+
                          '"description": "12345678901"'+
                        '},'+
                        '"contact": {'+
                          '"user": {'+
                            '"login": "12345678901",'+
                            '"userName": "Maria Maria",'+
                            '"partyId": {'+
                              '"number": "12345678901",'+
                              '"type": "12345678901"'+
                            '},'+
                            '"emailcontact": {'+
                              '"emailAddress": "maria@claro.com.br"'+
                            '},'+
                            '"telephone": {'+
                              '"areaCode": "011",'+
                              '"number": "99999-9999",'+
                              '"extensionNumber": "5432"'+
                            '}'+
                          '},'+
                          '"contactType": {'+
                            '"identifier": "12345678901",'+
                            '"description": "12345678901"'+
                          '},'+
                          '"name": "12345678901",'+
                          '"interactionNumber": "12345678901",'+
                          '"protocol": "12345678901",'+
                          '"contactMedium": {'+
                            '"telephone": {'+
                              '"areaCode": "011",'+
                              '"number": "99999-9999",'+
                              '"extensionNumber": "5432"'+
                            '},'+
                            '"emailcontact": {'+
                              '"emailAddress": "maria@claro.com.br"'+
                            '},'+
                            '"partyId": {'+
                              '"addressId": "12345678901",'+
                              '"country": "Brasil",'+
                              '"placeId": "SP",'+
                              '"cityId": "09888",'+
                              '"cityName": "São Paulo",'+
                              '"postCode": "99999-999",'+
                              '"neighborhood": "Santa Amaro",'+
                              '"streetType": "Avenida",'+
                              '"streetTypeId": "2",'+
                              '"streetName": "Rua Verbo Divino",'+
                              '"streetNrFirst": "1576",'+
                              '"urbanPropertySubAddress": "Bloco A",'+
                              '"complementarySubAddress": "Esquina com a Farmácia",'+
                              '"boxNr": "324555"'+
                            '}'+
                          '}'+
                        '}'+
                      '}'+
                    ']'+
                  '}'+
                '}');
    // res.setStatus('200');
    res.setStatusCode(200);
    return res;
  }

}