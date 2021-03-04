/*
* Autor: Henrique Almeida - Deloitte
* Data: 18-jan-2021
* Descrição: - Serviço de geração de Token do OPDK
*/  
global without sharing class SOLAR_IntegrationGetTokenOPDK {
    private static ServiceParameter__c param;
    static {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(
            Name = 'APIGEETokenOPDK', Method__c = 'POST',
            Endpoint__c = 'https://api-test.claro.com.br/oauth2/v1/token', User__c = 'lNFDXhOtuSUqDLAgUibDiLu37BvoIkh0', 
            Password__c = 'YfRlybhqogLkHUWf', Timeout__c = 50000, IsActive__c = true);

        param = ServiceParameter__c.getInstance('APIGEETokenOPDK');
        param = (param != null) ? param : lParamAlt; 
    }

	// Método responsável por realizar chamada oa serviço que retorna o token
	global static String getToken() {
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
                req.setEndpoint('https://test.TokenOPDK.com');
            }
			res = http.send(req);
            CEC_IntegrationGetToken.TokenInfo tokenInfo = new CEC_IntegrationGetToken.TokenInfo();
            tokenInfo = (CEC_IntegrationGetToken.tokenInfo) JSON.deserialize(res.getBody(), CEC_IntegrationGetToken.tokenInfo.class);
            return String.valueOf(tokenInfo.access_token);
            
		} catch(System.CalloutException e) {
			System.debug('Callout error: ' + e);
            return String.valueOf(e.getMessage());
		}
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