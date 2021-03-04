@isTest
global class MockHttpCallIntegrationProtocol implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"transactionId":"13213213","data":{"protocolNumber":"2132132131","interactionNumber":"6366452534"},"apiVersion":"2132131"}');
        res.setStatusCode(200);
        return res;
    }
}