public with sharing class SolarPFTokenService {
    
    private static String serviceName = 'CEC_SSO_Token';
    private static ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName);
    
    @AuraEnabled(cacheable=true)
    public static String getTokenForUser(){
        String userId = UserInfo.getUserId();
        User usuario;
        if(User.SObjectType.getDescribe().isAccessible()){
            usuario = [ SELECT Name, Claro__c, CEC_SalesAgent__c, CPF__c, Profile.Name , NetServicos__c  FROM User where Id =:userId ];
        }
        SolarPFTokenServiceWrapper.Request requestBody = requestObjectCreate(usuario);
        HttpResponse res = sendReqBody(JSON.serialize(requestBody));
        SolarPFTokenServiceWrapper.Response response = (SolarPFTokenServiceWrapper.Response)JSON.deserialize(res.getBody(), SolarPFTokenServiceWrapper.Response.class);
        if(res.getStatusCode() != 200){
            throw new CalloutException('Sua solicitação não foi executada. Tente novamente, ou abra um chamado informando o código: ' +response.error.errorCode);
        }
        return (String)response.data.token.tokenId;
    }

    public static SolarPFTokenServiceWrapper.Request requestObjectCreate(User usuario){
        try{
            String ip = '1.1.1.1';
            if(!Test.isRunningTest()){
                Map<String,String> currentSessionAttributes = Auth.SessionManagement.getCurrentSession();
                ip = currentSessionAttributes.get('SourceIp');
            }
            SolarPFTokenServiceWrapper.Request requestBody = new SolarPFTokenServiceWrapper.Request();
            requestBody.data = new SolarPFTokenServiceWrapper.RequestData(); 
            requestBody.data.user = usuario.Id; 
            requestBody.data.name = usuario.Name;
            requestBody.data.sourceSystem = 'SOLAR';
            requestBody.data.destinySystem = 'VendasApp';
            requestBody.data.applicationContext = '/';
            requestBody.data.IpAddress = ip;
            requestBody.data.indicatorSession = 'false';
            requestBody.data.properties = new List<SolarPFTokenServiceWrapper.Properties>();
            SolarPFTokenServiceWrapper.Properties sistema = new SolarPFTokenServiceWrapper.Properties();
            sistema.name = 'SISTEMA';
            sistema.value = 'SOLAR';
            requestBody.data.properties.add(sistema);
            SolarPFTokenServiceWrapper.Properties loginAdClaro = new SolarPFTokenServiceWrapper.Properties();
            loginAdClaro.name = 'USUARIO';
            loginAdClaro.value = usuario.Claro__c;
            requestBody.data.properties.add(loginAdClaro);
            SolarPFTokenServiceWrapper.Properties loginAdUnificado = new SolarPFTokenServiceWrapper.Properties();
            loginAdUnificado.name = 'LOGIN_AD_UNIFICADO';
            loginAdUnificado.value = usuario.NetServicos__c;
            requestBody.data.properties.add(loginAdUnificado);
            SolarPFTokenServiceWrapper.Properties perfilAd = new SolarPFTokenServiceWrapper.Properties();
            perfilAd.name = 'PERFIL_AD';
            perfilAd.value = usuario.Profile.Name;
            requestBody.data.properties.add(perfilAd);
            SolarPFTokenServiceWrapper.Properties codigoVendedorIw = new SolarPFTokenServiceWrapper.Properties();
            codigoVendedorIw.name = 'CODIGO_VENDEDOR_IW';
            codigoVendedorIw.value = usuario.CEC_SalesAgent__c;
            requestBody.data.properties.add(codigoVendedorIw);
            SolarPFTokenServiceWrapper.Properties cpf = new SolarPFTokenServiceWrapper.Properties();
            cpf.name = 'CPF';
            cpf.value = null; 
            requestBody.data.properties.add(cpf);
            return requestBody;
        }catch(NullPointerException e){
            throw e;
        }
    }


    public static HttpResponse sendReqBody(String body){
            HttpRequest req = new HttpRequest();
            req.setMethod(param.Method__c);       
            req.setBody(body);
            req.setTimeout((Integer)param.Timeout__c);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');        
            req.setEndpoint('callout:OAGClaroPlanta12' + param.EndPoint__c); 
            Http h = new Http();
            return h.send(req);
    }
   

}