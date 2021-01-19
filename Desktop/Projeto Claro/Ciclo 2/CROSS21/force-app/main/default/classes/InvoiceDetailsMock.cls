@isTest
public class InvoiceDetailsMock implements HttpCalloutMock{

   protected String body;
   protected Integer setStatusCode; 
    
   public InvoiceDetailsMock(String body, Integer setStatusCode) {
   	this.body = body;
    this.setStatusCode = setStatusCode;
   }
    
   public HTTPResponse respond(HTTPRequest req) {
   	HttpResponse res = new HttpResponse();
    res.setBody(this.body);
    res.setStatusCode(this.setStatusCode);
    return res;
   }
}