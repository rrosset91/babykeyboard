@isTest
public class InvoiceRefundMock implements HttpCalloutMock{

   protected String body;
   protected Integer setStatusCode; 
    
   public InvoiceRefundMock(String body, Integer setStatusCode) {
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