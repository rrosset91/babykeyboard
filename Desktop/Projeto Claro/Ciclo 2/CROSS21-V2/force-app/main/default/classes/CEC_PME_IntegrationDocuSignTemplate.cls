/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Integração para pegar as informações de template
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignTemplate {
    private String bodyResponse; 
    
    public void send(String accountId, String templateId) {        
        HTTPRequest request = new HTTPRequest();
        
        ServiceParameter__c serviceParameter = ServiceParameter__c.getValues('CEC_PME_DocuSignGetTemplate');
		//System.debug('template endpoint ' + serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId));
        //request.setEndpoint(serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId));
        
		String endPointMethod = serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId);        
        request.setEndpoint('callout:DocuSign' + endPointMethod);        
        request.setMethod(serviceParameter.Method__c);
        request.setTimeout(Integer.valueOf(serviceParameter.Timeout__c));
        
        String authorizationHeader = '<DocuSignCredentials><Username>' + '{!$Credential.Username}';
        authorizationHeader = authorizationHeader +'</Username><Password>' + '{!$Credential.Password}';
        authorizationHeader = authorizationHeader + '</Password><IntegratorKey>' + serviceParameter.Token__c;
        authorizationHeader = authorizationHeader +'</IntegratorKey></DocuSignCredentials>';
        
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
        
        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        bodyResponse = response.getBody();
        System.debug('response getStatusCode' + response.getStatusCode());
        System.debug('response getBody' + bodyResponse);
    }
    
    public List<Object> getListSigners() {
        Map<String, Object> mapTemplate = (Map<String, Object>) JSON.deserializeUntyped(bodyResponse);
        
        if(mapTemplate.containsKey('recipients')) {
            Map<String, Object> mapRecipients = (Map<String, Object>) mapTemplate.get('recipients');
            if(mapRecipients.containsKey('signers')) {
                return (List<Object>) mapRecipients.get('signers');
            }
        }
        return new List<Object>();
    }  
    
    public List<CEC_PME_IntegrationDocuSignObjectFactory.Document> getListDocuments() {
        Map<String, Object> mapTemplate = (Map<String, Object>) JSON.deserializeUntyped(bodyResponse);
        if(mapTemplate.containsKey('documents')) {
            return (List<CEC_PME_IntegrationDocuSignObjectFactory.Document>) JSON.deserialize(JSON.serialize(mapTemplate.get('documents')), List<CEC_PME_IntegrationDocuSignObjectFactory.Document>.class);
        }
        return new List<CEC_PME_IntegrationDocuSignObjectFactory.Document>();
    }
}