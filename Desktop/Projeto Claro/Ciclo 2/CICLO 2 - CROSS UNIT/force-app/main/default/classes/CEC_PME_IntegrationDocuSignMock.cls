global with sharing class CEC_PME_IntegrationDocuSignMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        if(request.getEndpoint().endsWith('envelopes') && request.getMethod().equalsIgnoreCase('POST')) {
            return generateDocuSignCreateEnvelope(); //CEC_PME_DocuSignCreateEnvelope
        } else if(request.getEndpoint().endsWith('recipients') && request.getMethod().equalsIgnoreCase('DELETE')) {
            return generateDocuSignDeleteRecipients(); //CEC_PME_DocuSignDeleteRecipients
        } else if(request.getEndpoint().endsWith('recipient') && request.getMethod().equalsIgnoreCase('POST')) { 	
            return generateDocuSignEmbedded(); //CEC_PME_DocuSignEmbedded
        } else if(request.getEndpoint().contains('/documents/') && request.getMethod().equalsIgnoreCase('GET')) {
            return generateDocuSignGetDocument(); //CEC_PME_DocuSignGetDocument
        } else if(request.getEndpoint().contains('/templates/') && request.getMethod().equalsIgnoreCase('GET')) {
            return generateDocuSignGetTemplate(); //CEC_PME_DocuSignGetTemplate
        } else { 	
        	return generateDocuSignListRecipient(); //CEC_PME_DocuSignListRecipient
        }
    }
    
    private HttpResponse generateDocuSignCreateEnvelope() {
        HttpResponse response = new HttpResponse();
        
        response.setBody(getBobyByName('DocuSignCreateEnvelopeMock'));
        
        response.setStatusCode(201);
        
        return response;
    }
    
    private HttpResponse generateDocuSignDeleteRecipients() {
        HttpResponse response = new HttpResponse();
        
        response.setBody(getBobyByName('DocuSignDeleteRecipientMock'));

        response.setStatusCode(200);
        
        return response;
    }
    
    private HttpResponse generateDocuSignEmbedded() {
        HttpResponse response = new HttpResponse();
        response.setBody(getBobyByName('DocuSignEmbeddedMock'));

        response.setStatusCode(201);
        
        return response;
    }
    
    private HttpResponse generateDocuSignGetDocument() {
        HttpResponse response = new HttpResponse();
        String bodyStr = 'test';
        Blob bodyBlob = EncodingUtil.base64Decode(bodyStr);
        response.setBodyAsBlob(bodyBlob);

        response.setStatusCode(200);
        
        return response;
    }
    
    private HttpResponse generateDocuSignGetTemplate() {
        HttpResponse response = new HttpResponse();
        
        response.setBody(getBobyByName('DocuSignGetTemplateMock'));
        
        response.setStatusCode(200);
        
        return response;
    }

    private HttpResponse generateDocuSignListRecipient() {
        HttpResponse response = new HttpResponse();
        
        response.setBody(getBobyByName('DocuSignListRecipientMock'));

        response.setStatusCode(200);
        
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