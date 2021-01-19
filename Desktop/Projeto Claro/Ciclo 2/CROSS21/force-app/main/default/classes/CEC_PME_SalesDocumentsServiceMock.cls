global with sharing class CEC_PME_SalesDocumentsServiceMock implements HttpCalloutMock {
    
	global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        
        response.setBody(getBobyByName('SalesDocumentsMock'));
        response.setStatusCode(202);
        
        return response;
    }
     
    public String getBobyByName(String staticResourceName) {
        StaticResource staticResource = [SELECT Id, 
                                         body
                                         FROM StaticResource 
                                         WHERE Name = :staticResourceName];

        return staticResource.body.toString();
    }
}