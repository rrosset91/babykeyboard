@isTest
public class MultipleHttpMock implements HttpCalloutMock {
    
    List<HttpResponse> responses = new List<HttpResponse>();
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }
    public HttpResponse respond(HttpRequest request) {
        return responses.remove(0);
    }
}