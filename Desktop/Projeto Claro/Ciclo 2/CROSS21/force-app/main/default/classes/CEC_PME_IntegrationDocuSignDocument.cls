/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Integração para pegar os arquivos 
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignDocument {
    public class CEC_PME_IntegrationDocuSignDocumentException extends Exception {}

    public String send(String templateId, String documentId, String accountId) {
        
        HTTPRequest request = new HTTPRequest();
        ServiceParameter__c serviceParameter = ServiceParameter__c.getValues('CEC_PME_DocuSignGetDocument');
        
        //System.debug('Document endpoint ' + serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId).replace('{!documentId}', documentId));
        //request.setEndpoint(serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId).replace('{!documentId}', documentId));
		String endPointMethod = serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!templateId}', templateId).replace('{!documentId}', documentId);        
        request.setEndpoint('callout:DocuSign' + endPointMethod);
        
        String authorizationHeader = '<DocuSignCredentials><Username>' + '{!$Credential.Username}';
        authorizationHeader = authorizationHeader +'</Username><Password>' + '{!$Credential.Password}';
        authorizationHeader = authorizationHeader + '</Password><IntegratorKey>' + serviceParameter.Token__c;
        authorizationHeader = authorizationHeader +'</IntegratorKey></DocuSignCredentials>';        
        
        request.setMethod(serviceParameter.Method__c);
        request.setTimeout(Integer.valueOf(serviceParameter.Timeout__c));
        
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
       
        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        System.debug('Document64 ' + EncodingUtil.base64Encode(response.getBodyAsBlob()));
        System.debug('response getStatusCode' + response.getStatusCode());
        if(response.getStatusCode() != 200) {
            throw new CEC_PME_IntegrationDocuSignDocumentException('Erro da integração de DocuSign Document. Mensagem: ' + response.getBody());
        }
        return EncodingUtil.base64Encode(response.getBodyAsBlob());
    } 
}