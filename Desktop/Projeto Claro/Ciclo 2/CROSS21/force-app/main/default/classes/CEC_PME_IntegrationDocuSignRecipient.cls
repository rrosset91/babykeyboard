/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Integração para listagem e remoção de signers da docusign
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignRecipient {
    public class CEC_PME_IntegrationDocuSignRecipientException extends Exception{}
    private String accountId;
    private String envelopeId;
    
    public CEC_PME_IntegrationDocuSignRecipient(String accountId, String envelopeId) {
        this.accountId = accountId;
        this.envelopeId = envelopeId;
    }
    
    public CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients deleteRecipients(CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients recipients) {
        HttpResponse response = send(ServiceParameter__c.getValues('CEC_PME_DocuSignDeleteRecipients'), JSON.serialize(recipients));
        
        return (CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients) JSON.deserialize(response.getBody(), CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients.class);
    }
    
    public CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients listRecipients() {
        HttpResponse response = send(ServiceParameter__c.getValues('CEC_PME_DocuSignListRecipient'), null);
        
        return (CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients) JSON.deserialize(response.getBody() , CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients.class);
    }
    
    public void updateRecipients(CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients recipients) {
        HttpResponse response = send(ServiceParameter__c.getValues('CEC_PME_DocuSignUpdateRecipients'), JSON.serialize(recipients));
    }
    
    private HTTPResponse send(ServiceParameter__c serviceParameter, String bodyJson) {
        String endPointMethod = serviceParameter.EndPoint__c.replace('{!accountId}', this.accountId).replace('{!envelopeId}', this.envelopeId);

        HTTPRequest request = new HTTPRequest();
               
        request.setMethod(serviceParameter.Method__c);       
        request.setTimeout(Integer.valueOf(serviceParameter.Timeout__c));
        
        request.setEndpoint('callout:DocuSign' + endPointMethod);
        
        String authorizationHeader = '<DocuSignCredentials><Username>'+ '{!$Credential.Username}';
        authorizationHeader = authorizationHeader +'</Username><Password>' + '{!$Credential.Password}';
        authorizationHeader = authorizationHeader + '</Password><IntegratorKey>' + serviceParameter.Token__c;
        authorizationHeader = authorizationHeader +'</IntegratorKey></DocuSignCredentials>';
        
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);        
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
       
        if(String.isNotBlank(bodyJson)) {
            request.setBody(bodyJson);
			//system.debug('restRequest getBody ' + request.getBody());                    
        }
		
        
        HTTP http = new HTTP();
        HttpResponse httpResponse = http.send(request);
       
        if(httpResponse.getStatusCode() > 300 || httpResponse.getStatusCode() < 200) {
            System.debug('TYUMI -> Entrou no erro');
            throw new CEC_PME_IntegrationDocuSignRecipientException('Erro na integração(' + httpResponse.getStatusCode() + '):' + httpResponse.getStatus());
        }
        system.debug('restResponse getStatusCode ' + httpResponse.getStatusCode());
        system.debug('restResponse getStatus ' + httpResponse.getStatus());
        system.debug('restResponse getBody ' + httpResponse.getBody());
        return httpResponse;
    }
}