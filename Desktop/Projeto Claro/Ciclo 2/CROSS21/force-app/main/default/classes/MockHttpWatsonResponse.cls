@isTest
public class MockHttpWatsonResponse implements HttpCalloutMock{
    public String body;
    public Integer statusCode;
    
    public MockHttpWatsonResponse(){
        this.body = '{}';
        this.statusCode = 200;
    }
    
    public MockHttpWatsonResponse(String body, Integer statusCode){
        this.body = body;
        this.statusCode = statusCode;
    }
    
	public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(statusCode);
        return res;
    }
}