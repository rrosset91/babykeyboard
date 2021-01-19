/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Integração para pegar a url de assinatura embarcada
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignEmbedded {
    public class RequestEmbedded {
        public RequestEmbedded(String email, String userName) {
            this.authenticationMethod = 'Email';
            this.clientUserId = '1';
            this.email = email;
            this.returnUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/CEC_PME_DocusignSuccessMessage';
            this.userName = userName;
            this.recipientId = '1';
        }
        
        public String authenticationMethod {get;set;}
        public String clientUserId {get;set;}
        public String email {get;set;}
        public String returnUrl {get;set;}
        public String userName {get;set;}
        public String recipientId {get;set;}
    }
    
    public class ResponseEmbedded {
        public String url {get;set;}
    }
    
    public String send(String accountId, String envelopeId, AccountContactRelation embeddedAccContRel) {
        
        ServiceParameter__c serviceParameter = ServiceParameter__c.getValues('CEC_PME_DocuSignEmbedded');
        
        HTTPRequest request = new HTTPRequest();
        
        //request.setEndpoint(serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!envelopeId}', envelopeId));
		String endPointMethod = serviceParameter.EndPoint__c.replace('{!accountId}', accountId).replace('{!envelopeId}', envelopeId);        
        request.setEndpoint('callout:DocuSign' + endPointMethod);
        
        String authorizationHeader = '<DocuSignCredentials><Username>' + '{!$Credential.Username}';
        authorizationHeader = authorizationHeader +'</Username><Password>' + '{!$Credential.Password}';
        authorizationHeader = authorizationHeader + '</Password><IntegratorKey>' + serviceParameter.Token__c;
        authorizationHeader = authorizationHeader +'</IntegratorKey></DocuSignCredentials>';        
        
        request.setMethod(serviceParameter.Method__c);
        request.setTimeout(Integer.valueOf(serviceParameter.Timeout__c));
        
        request.setBody(JSON.serialize(new RequestEmbedded(embeddedAccContRel.Email__c,  embeddedAccContRel.Contact.Name)));
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        system.debug('response ' + response.getStatusCode() + ' ' + response.getBody());
        
        return ((ResponseEmbedded) JSON.deserialize(response.getBody(), ResponseEmbedded.class)).url;
    }        
}