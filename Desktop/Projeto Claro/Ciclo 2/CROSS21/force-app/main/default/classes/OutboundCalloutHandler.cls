/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: Classe para manipular parâmetros/condicionais para realizar chamadas a serviços/api externos
*/
public class OutboundCalloutHandler {

	/*
	* @description: Método de entrada que realiza a chamada a serviços com header customizado
	*/
    public static Map<String, String> sendRequest(String body, Map<String, String> queryParams, Map<String, String> additionalHeaders, String settingName){
		return performRequest(body, queryParams, additionalHeaders, settingName);
	}

    /*
	* @description: Método de entrada que realiza a chamada a serviços sem header customizado
	*/
    public static Map<String, String> sendRequest(String body, Map<String, String> queryParams, String settingName){
        return performRequest(body, queryParams, new Map<String, String>(), settingName);
	}

	private static Map<String, String> performRequest(String body, Map<String, String> queryParams, Map<String, String> additionalHeaders, String settingName){
		Map<String, String> returnMap = new Map<String, String>();
        if(String.isEmpty(settingName)){
            throw new OutboundCalloutHandlerException('Por favor, preencher os valores no construtor dessa classe (OutboundCalloutHandler)');
        }else{
			ServiceParameter__c params = ServiceParameter__c.getInstance(settingName);
			System.debug('OutboundCalloutHandler - Params: ' + params);
			
            if(params == null){
                throw new OutboundCalloutHandlerException('Não foi encontrado a configuração personalizada/metadado pelo nome escolhido');
            }else{

                System.debug('settingName: '+ settingName);
				if(params.ReturnMock__c){
                    System.debug('getMock: '+ settingName);
					return new MockService(queryParams, params.Method__c).getMock(settingName);
                }

                HttpRequest request = new HttpRequest();
                request.setEndpoint(params.EndPoint__c + setParams(queryParams));
                request.setMethod(params.Method__c);
                System.debug('OutboundCalloutHandler ::  FULLURL'+ request.getEndpoint());
                System.debug('OutboundCalloutHandler ::  Method__c'+ params.Method__c);
                if((params.Method__c == 'POST' || params.Method__c == 'PUT') && String.isEmpty(body)){
                    throw new OutboundCalloutHandlerException('O Método de envio escolhido exige dados no corpo da solicitação - Empty Body');
                }else{
                    if(params.Method__c != 'GET'){
                        request.setBody(body); 
                    }
				}
                
                System.debug('OutboundCalloutHandler ::  BODY'+ request.getBody());
				if(additionalHeaders != null && !additionalHeaders.isEmpty()){
					for(String key : additionalHeaders.keySet()){
						String value = additionalHeaders.get(key);
						
						if(value == null || String.isEmpty(value)){
							System.debug('Key: ' + key + ' não tem um valor definido. Parâmetro ignorado.');
							continue;
						}

						request.setHeader(key, value);
					}
				}

				request.setTimeout(Integer.valueOf(params.Timeout__c));

				System.debug('OutboundCalloutHandler :: request: '+ request );
				Http http = new Http();
                HTTPResponse response = http.send(request);
				System.debug('OutboundCalloutHandler :: response: '+response);
                returnMap.put('statusCode', String.valueOf(response.getStatusCode()));
                returnMap.put('response', response.getBody());
            }
		}
		
        return returnMap;
	}
	
    /*
	* @description: Sub-classe para exceções customizadas
	*/
   private static String setParams(Map<String, String> params){
		if(params.isEmpty())
			return '';

        String urlParams = '?';
        if(params.keySet().size() > 0){
            List<String> keySet = new List<String>(params.keySet());
            for(Integer i = 0; i < keySet.size(); i++){
                if(i > 0){
                    urlParams += '&';
                }
                urlParams += keySet.get(i) + '=' + params.get(keySet.get(i));
            }
        }
        System.debug('urlParams: ' + urlParams);
        return urlParams;
    }
    
    /*
	* @description: Sub-classe para exceções customizadas
	*/
   public class OutboundCalloutHandlerException extends Exception {}
    
}