global without sharing class CEC_IntegrationGetToken {
	private static ServiceParameter__c param;
    static {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(
            Name = 'APIGEEToken', Method__c = 'POST',
            Endpoint__c = 'https://api-test.claro.com.br/oauth2/v1/token', User__c = 'lNFDXhOtuSUqDLAgUibDiLu37BvoIkh0', 
            Password__c = 'YfRlybhqogLkHUWf', Timeout__c = 50000, IsActive__c = true);

        param = ServiceParameter__c.getInstance('APIGEEToken');
        param = (param != null) ? param : lParamAlt; 
    }

    // Método responsável por verificar se existe um token ativo 
	global static String checkToken() {
		String cacheToken = getGlobalToken();
		if (cacheToken == null || cacheToken == '') {
			getToken();
			cacheToken = getGlobalToken();
		}
		return cacheToken;
    }

	// Método responsável por realizar chamada oa serviço que retorna o token
	global static void getToken() {
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();

		req.setEndpoint(param.Endpoint__c);
		req.setMethod(param.Method__c);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('x-client-auth', 'Basic ' + EncodingUtil.base64Encode(Blob.valueof(param.User__c + ':' + param.Password__c)));
		req.setBody('grant_type=client_credentials');

		try {
            if (test.isRunningTest()) {
                req.setEndpoint('https://test.getToken.com');
            }

			res = http.send(req);
			savetoken(res.getBody());

		} catch(System.CalloutException e) {
			System.debug('Callout error: ' + e);
		}
    }
    
	// Método responsável por armazenar o token na cache do salesforce
    private static void saveToken(String bodyResponse) {
        try{
            CEC_IntegrationGetToken.TokenInfo tokenInfo = new CEC_IntegrationGetToken.TokenInfo();
            tokenInfo = (CEC_IntegrationGetToken.tokenInfo) JSON.deserialize(bodyResponse, CEC_IntegrationGetToken.tokenInfo.class);
            
            System.debug('tokenInfo: ' + tokenInfo);
            Cache.Org.put('local.APIGEEToken.globalToken', tokenInfo.access_token, Integer.valueOf(tokenInfo.expires_in), Cache.Visibility.ALL, true);            
        
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }        
	}	
    
    // Método responsável por recuperar da cache o token caso ele exista
	private static String getGlobalToken() {

		Object obj = Cache.Org.get('local.APIGEEToken.globalToken');
		String token = String.valueOf(obj);
		return token;
    }

    global static TokenInfo generateMock(String aURL, Integer aHttpCode){
        return generateMock(new URL(aURL), aHttpCode);
    }

    global static TokenInfo generateMock(URL aURL, Integer aHttpCode){
        TokenInfo token = new TokenInfo();
        token.access_token = '1BlJQgBunfmUFIv0A9l9GTubJSn4';
        token.token_type = 'BearerToken';   
        token.expires_in = '0';     
        return token;
    }
    
    global class TokenInfo {
        public String access_token  = '';
        public String token_type  = '';
        public String expires_in  = '';
    }
}