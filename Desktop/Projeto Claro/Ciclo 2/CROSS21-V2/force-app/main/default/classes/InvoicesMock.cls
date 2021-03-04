@isTest
public class InvoicesMock implements HttpCalloutMock{

  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setBody('{ "apiVersion": "1", "transactionId": "32132131", "data": }');
    res.setStatusCode(200);
    return res;
  }
}