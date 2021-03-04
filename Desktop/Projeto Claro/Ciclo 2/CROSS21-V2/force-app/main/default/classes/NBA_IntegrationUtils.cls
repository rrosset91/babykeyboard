/*--------------------------------------------------------------------------------------------
--- Company: Accenture Brasil
--- Creation Date: 06/03/2019
--- Author: Dylan Santos
--- Description: Classe com métodos utéis para os serviços de NBA
----------------------------------------------------------------------------------------------*/
public with sharing class NBA_IntegrationUtils {

    public enum HttpCalloutsMethod { GET, PUT, POST, PATCH, DEL }
	private static final Id recordTypeIdNBAOffer = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();

    public class GeneralException extends Exception { }

    public class HttpResponseModel {
        public Boolean success;
        public Integer statusCode;
        public String status;
        public String body;
        public Object bodyObject; 

        public HttpResponseModel(){
            this.success = false;
        } 
    }

    public static HttpResponseModel sendRequest(NBA_Integration_Definitions__mdt configuracao, Object bodyObject) {

        HttpResponse httpResponse = sendCallout(configuracao, bodyObject);

        return getResponseTreated(httpResponse);
    }

    public static HttpResponse sendCallout(NBA_Integration_Definitions__mdt configuracao, Object bodyObject) {
        String bodyMessage = '';
        String endpointParam = '';
        
        Http httpProtocol = new Http();
        HttpRequest request = getBasicRequest(configuracao);
        
        if (request.getMethod() == HttpCalloutsMethod.GET.name()) {
			
            if(bodyObject != null) {
                endpointParam = formatEndPointToGetCallout(request.getEndpoint(), bodyObject);
            }

            request.setEndPoint(endpointParam);
        }

        else if (bodyObject != null) { 

            bodyMessage = JSON.serialize(bodyObject);
            request.setBody(bodyMessage);
            System.debug('bodyObject >> ' + bodyMessage);
        }
            
		System.debug('Request >> ' + request);
        return httpProtocol.send(request);
    }

    public static HttpResponseModel getResponseTreated(HttpResponse httpResponse){
        
        HttpResponseModel responseTreated = new HttpResponseModel();
        responseTreated.success = false;

        if(httpResponse != null) {
            responseTreated.statusCode = httpResponse.getStatusCode();
            responseTreated.status = httpResponse.getStatus();
            responseTreated.body = httpResponse.getBody();
            
            if (responseTreated.statusCode == 200 || responseTreated.statusCode == 201 || responseTreated.statusCode == 202) {
                responseTreated.success = true;
            }
        }

        if(responseTreated.statusCode == null){
            throw new GeneralException('IntegrationUtils getResponseTreated ERRO - Houve um erro na resposta do serviço - responseTreated: ' + responseTreated);
        }
        
		System.debug('getResponseTreated: ' + responseTreated.body);

        return responseTreated;
    }

    public static HttpRequest getBasicRequest(NBA_Integration_Definitions__mdt configuracao) {
        HttpRequest request = new HttpRequest();
        
		request.setMethod(configuracao.NBA_HttpMethod__c);
        request.setTimeout(configuracao.NBA_Timeout__c.intValue());
		request.setHeader('Content-Type', configuracao.NBA_Content_Type__c);
		request.setHeader('Accept',  configuracao.NBA_Content_Type__c);
        if(String.isNotBlank(configuracao.NBA_Accept_Language__c))
            request.setHeader('Accept-Language',  configuracao.NBA_Accept_Language__c);

		if(configuracao.NBA_InProduction__c){
			request.setEndpoint('callout:' + configuracao.NBA_NamedCredentials__c + configuracao.NBA_Endpoint__c);
            if(configuracao.NBA_X_Client_Auth__c)
                request.setHeader('x-client-auth', 'Basic {!$Credential.AuthorizationHeaderValue}');
        }
        else {
			request.setEndpoint(configuracao.NBA_Domain__c + configuracao.NBA_Endpoint__c);
			Blob headerValue = Blob.valueOf(configuracao.NBA_Username__c + ':' + configuracao.NBA_Password__c);
			Map<String, String> headers = new Map<String, String> {'Authorization' => ('Basic ' + EncodingUtil.base64Encode(headerValue))};
			for( String header : headers.keySet() )
				request.setHeader( header , headers.get( header ) );
            if(configuracao.NBA_X_Client_Auth__c)
                request.setHeader('x-client-auth', 'Basic ' + EncodingUtil.base64Encode(headerValue));
		}
		System.debug('requestUTILS>>>'+request);
        return request;
    }
    
    private static String formatEndPointToGetCallout(String endpointParam, Object bodyObject) {
        String queryString = '';
        
        if (bodyObject != null) {
            Map<String,Object> results = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(bodyObject));
            
            for(String key : results.keySet()){
                String valor = String.valueOf(results.get(key));
               
			    if(String.isBlank(queryString)){
					if(String.isNotBlank(valor)){
						queryString = '?' + key + '=' + EncodingUtil.urlEncode(valor, 'UTF-8');
					}
                } else {
					if(String.isNotBlank(valor)){
						queryString += '&' + key + '=' + EncodingUtil.urlEncode(valor, 'UTF-8');
					}
                }
            }
        }

        if(String.isNotBlank(queryString)){
           return endpointParam + queryString;
        } else {
            return endpointParam;
        }
    }

    public static NBA_Integration_Definitions__mdt getConfiguracaoDeIntegracao(String nomeConfiguracao){

        List<NBA_Integration_Definitions__mdt> configuracoesDeIntegracao = [SELECT	Id, 
																					NBA_Endpoint__c, 
																					NBA_Username__c, 
																					NBA_Password__c, 
																					NBA_NumeroOfertas__c, 
																					NBA_InProduction__c, 
																					NBA_Domain__c, 
																					NBA_HttpMethod__c, 
																					NBA_Timeout__c,
																					NBA_Content_Type__c,
																					NBA_NamedCredentials__c,
                                                                                    DeveloperName,
                                                                                    NBA_Accept_Language__c,
                                                                                    NBA_X_Client_Auth__c
																			FROM 	NBA_Integration_Definitions__mdt
																			WHERE	DeveloperName = :nomeConfiguracao];
        
        if(configuracoesDeIntegracao.isEmpty()){
			throw new DadosInvalidosException('Não existe custom metadata criado!'); 
		}

		return configuracoesDeIntegracao[0];
    }

    public static NBA_IntegrationModels.SearchOffersResponse searchMock(String mockName) { 
        NBA_IntegrationModels.SearchOffersResponse response = new NBA_IntegrationModels.SearchOffersResponse();
		String mock 	= getMock(mockName);
		if(mock != null && String.isNotBlank(mock))
			response	= (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(getMock(mockName), NBA_IntegrationModels.SearchOffersResponse.class);
        return response;
    }

    public static NBA_IntegrationModels.SearchOffersResponse searchMockOfertas(String mockName) { 
        NBA_IntegrationModels.SearchOffersResponse response = new NBA_IntegrationModels.SearchOffersResponse();
		String mock 	= getMock(mockName);
		if(mock != null && String.isNotBlank(mock))
			response	= (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(getMock(mockName), NBA_IntegrationModels.SearchOffersResponse.class);
        return response;
    }
    public static String getMock(String mockName){
		String retorno 		= '';
		StaticResource sr 	= [SELECT Id, Body FROM StaticResource WHERE Name = :mockName];
		retorno 			= sr.body.toString();
		return retorno;
	}
	
	public class DadosInvalidosException extends Exception { }
}