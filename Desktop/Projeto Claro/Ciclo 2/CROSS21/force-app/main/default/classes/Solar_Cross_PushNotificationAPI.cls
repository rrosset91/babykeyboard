/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe que faz integração com a API communication (Envio de Push)
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-12-23      Jean Sganzerla          class created 
**************************************************************************************************************/
public class Solar_Cross_PushNotificationAPI {

    //método que faz a chamada da API de communication
    public static ComponentReturnWrapper communicationAPI(CommunicationAPIPayloadWrapper aBodyWrapper){
        ServiceParameter__c lServParam = ServiceParameter__c.getValues('CommunicationPush');
        
        HttpRequest lReq = new HttpRequest();
        HttpResponse lRes = new HttpResponse();
        Http lHttp = new Http();
        
        String lEndpoint = String.isBlank(lServParam.NamedCredential__c) ? lServParam.Endpoint__c : 'callout:'+ lServParam.NamedCredential__c + '' + lServParam.Endpoint__c;
        lReq.setEndpoint(lEndpoint);
        
        ComponentReturnWrapper lToken = new ComponentReturnWrapper();
        lToken = getToken();
        if(!lToken.success){ // significa que houve erro na integração que busca o TOKEN
            return lToken;
        }

        String authorizationHeader = 'Bearer ' + EncodingUtil.urlEncode(lToken.message,'UTF-8');     
        lReq.setHeader('x-client-auth', authorizationHeader);
        lReq.setHeader('Content-Type', 'application/json');   
        lReq.setTimeout(Integer.valueOf(lServParam.Timeout__c));
        lReq.setMethod(lServParam.Method__c);

        String lPayload = JSON.serialize(aBodyWrapper);        
        lReq.setBody(lPayload);

        system.debug('Payload ----------------------------> ' + lPayload);	
        system.debug('lReq.getEndpoint() ------> ' + lReq.getEndpoint());	

        ComponentReturnWrapper lReturn = new ComponentReturnWrapper();

        try {
            if (test.isRunningTest()) {
                lReq.setEndpoint('/Solar_Cross_CommunicationPush');
            }
            lRes = lHttp.send(lReq);            
            
            system.debug('Communication API StatusCode ------> ' + lRes.getStatusCode());		
            
            CommunicationResponseWrapper lResponse = (CommunicationResponseWrapper) System.JSON.deserialize(lRes.getBody(), CommunicationResponseWrapper.class);
            system.debug('Communication API lResponse ------> ' + lResponse);		

            lReturn.message = lRes.getStatusCode() == 200 || lRes.getStatusCode() == 201 ? lResponse.data.status + ' -- ' + lResponse.data.message : 'Communications API error: ' + lResponse.error.httpCode + ' -- ' +  lResponse.error.message + ' -- ' + lResponse.error.detailedMessage + ' -- ' + lReq.getEndpoint();
            lReturn.success = lRes.getStatusCode() == 200 || lRes.getStatusCode() == 201 ? true : false;
            lReturn.statusCode = lRes.getStatusCode();
            
            return lReturn;
        } 
        catch(System.Exception  e) {
            System.debug('Communication API Callout error: ' + e);

            lReturn.message = 'Communication API Callout error: ' + e;
            lReturn.success = false;
            lReturn.statusCode = null;

            return lReturn;
		}
    }

    //método que busca o Token que será utilizado na API de comunications
    private static ComponentReturnWrapper getToken(){
        ServiceParameter__c lServParam = ServiceParameter__c.getValues('PushNotificationToken');

        HttpRequest lReq = new HttpRequest();
		HttpResponse lRes = new HttpResponse();
		Http lHttp = new Http();
        String lEndpoint = String.isBlank(lServParam.NamedCredential__c) ? lServParam.Endpoint__c : 'callout:'+ lServParam.NamedCredential__c + '' + lServParam.Endpoint__c;

		lReq.setEndpoint(lEndpoint);
		lReq.setMethod(lServParam.Method__c);
        lReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        lReq.setTimeout(Integer.valueOf(lServParam.Timeout__c));
        // Blob headerValue = Blob.valueOf(lServParam.Token__c);
        // String authorizationHeader = 'Basic ' +
        // EncodingUtil.base64Encode(headerValue);
        // lReq.setHeader('x-client-auth', authorizationHeader);

        lReq.setHeader('x-client-auth', 'Basic ' + lServParam.Token__c);
        lReq.setBody('grant_type=client_credentials');
        
        ComponentReturnWrapper lReturn = new ComponentReturnWrapper();

		try {
            if (test.isRunningTest()) {
                lReq.setEndpoint('/Solar_Cross_PushNotificationAPIToken');
            }
            lRes = lHttp.send(lReq);            
            TokenWrapper lToken = (TokenWrapper) System.JSON.deserialize(lRes.getBody(), TokenWrapper.class);
            
            system.debug('PushNotificationAPI Token (getToken) ------> ' + lToken);		
            system.debug('PushNotificationAPI StatusCode (getToken) ------> ' + lRes.getStatusCode());		

            
            lReturn.message = lRes.getStatusCode() == 200 || lRes.getStatusCode() == 201 ? lToken.access_token :'Communication API (getToken) Callout error: ' + lToken.error.httpCode + ' -- ' +  lToken.error.message + ' -- ' + lToken.error.detailedMessage + ' -- ' + lReq.getEndpoint();
            lReturn.success = lRes.getStatusCode() == 200 || lRes.getStatusCode() == 201 ? true : false;
            lReturn.statusCode = lRes.getStatusCode();
            
            return lReturn;

		} catch(System.Exception e) {
            System.debug('Communication API (getToken) Callout error: ' + e);

            lReturn.message = 'Communication API (getToken) Callout error: ' + e;
            lReturn.success = false;
            lReturn.statusCode = null;

            return lReturn;
		}
    }

    //Wrapper com o retorno do Token
    public class TokenWrapper {      

        public String refresh_token_expires_in;
        public String api_product_list;
        public List<String> api_product_list_json;
        public String organization_name;
        public String token_type;
        public String issued_at;
        public String client_id;
        public String access_token;
        public String application_name;
        public String scope;
        public String expires_in;
        public String refresh_count;
        public String status;
        public CommunicationResponseErrorWrapper error;

        public TokenWrapper(){
            this.error = new CommunicationResponseErrorWrapper();
        }
    }

    //Wrapper para montar o Payload (Body) da requisição da Communications API
    public class CommunicationAPIPayloadWrapper{
        public CommunicationAPIFieldsWrapper data;
        
        public CommunicationAPIPayloadWrapper(){
            this.data = new CommunicationAPIFieldsWrapper();
        }
    }
    
    //Campos da tag 'data' do objeto usado para montar o Payload da requisição da Communications API
    public class CommunicationAPIFieldsWrapper{

        public String campaign;
        public String channel;
        public String destination;
        public String message;
        public String templateCode;
        public String templateData;
        public String layout;
        public String customization;
        public String mobileClient;
        public String project;
        public String validator;
        public String telephoneNumber;

        public CommunicationAPIFieldsWrapper(){
            this.campaign = '';
            this.channel = '';
            this.destination = '';
            this.message = '';
            this.templateCode = '';
            this.templateData = '';
            this.layout = '';
            this.customization = '';
            this.mobileClient = '';
            this.project = '';
            this.validator = '';
            this.telephoneNumber = '';
        }
    }

    //Wrapper que monta o Body do Response da Communications API
    public class CommunicationResponseWrapper{

        public String apiVersion;
        public String transactionId;
        public String startTimestamp;
        public String endTimestamp;
        public CommunicationResponseErrorWrapper error;        
        public CommunicationResponseDataWrapper data;

        public CommunicationResponseWrapper(){
            this.data = new CommunicationResponseDataWrapper();
            this.error = new CommunicationResponseErrorWrapper();
        }
    }

    //Campos da tag 'data' do objeto usado para montar o Body do Response da requisição da Communications API
    public class CommunicationResponseDataWrapper{
        
        public String statusCode;
        public String status;
        public String message;
        public String trackingNumber;
        public String campaign;
        public String channel;
        public String destination;
        public String sendDate;
        public String httpCode;
        public String errorCode;
    }

    //Campos da tag 'error' dos objetos de Response da requisição da Communications API e da Requisição do Token
    public class CommunicationResponseErrorWrapper{

        public Integer httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
    }

    //Wrapper utilizado no retorno tanto do TOKEN quanto da Communications API
    public class ComponentReturnWrapper {

		@AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Integer statusCode;
    }
}