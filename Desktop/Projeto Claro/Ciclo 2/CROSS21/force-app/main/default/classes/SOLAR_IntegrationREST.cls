public with sharing class SOLAR_IntegrationREST {
    public class IntegrationRestException extends Exception {}
    
    private final String STANDARD_ERROR_MESSAGE = 'Ocorreu um erro inesperado na integração, entre em contato com o suporte';
    private String protocol;
        
    public HttpResponse sendRequest(String serviceName, Object body) {
        return sendRequest(serviceName, body, null);
    }
    
    public HttpResponse sendRequest(String serviceName, String strBody) {
        return sendRequest(serviceName, strBody, null);
    }
    
    public HttpResponse sendRequest(String serviceName, Object body, Map<String,String> mapEndpointParam) {
        return sendRequest(serviceName, JSON.serialize(body), null);
    }
        
    public HttpResponse sendRequest(String serviceName, String strBody, Map<String,String> mapEndpointParam) {
        system.debug('SOLAR_IntegrationREST.sendRequest');
        HttpRequest request = new HttpRequest();
        HttpResponse reponse;
        validateReqParam('serviceName', serviceName);
        
        ServiceParameter__c seviceParameter = getServiceParameter(serviceName);
        
        request.setHeader('Content-Type', seviceParameter.ContentType__c);
        request.setMethod(seviceParameter.Method__c);
        request.setTimeout(Integer.valueOf(seviceParameter.Timeout__c));
        
        String endpointWithParams = buildEndpointWithParams(seviceParameter.EndPoint__c, mapEndpointParam);
        request.setEndpoint('callout:' + seviceParameter.NamedCredential__c + endpointWithParams);
        
        request.setBody(strBody);    
        
        reponse = new Http().send(request);
        
        return reponse;
    }
    
    private String buildEndpointWithParams(String endPointMethod, Map<String,String> mapEndpointParam) {
        Boolean isMapNotNull = mapEndpointParam != null;
        Boolean isMapNotEmpty = isMapNotNull && !mapEndpointParam.isEmpty();
        
        if(isMapNotEmpty) {
            for(String key : mapEndpointParam.keySet()) {
                endPointMethod = endpointParamReplace(endPointMethod, key, mapEndpointParam.get(key));
            }
        }
        
        return endPointMethod;
    }
    
    private String endpointParamReplace(String endPointMethod, String key, String value) {
        Boolean isKeyNotBlank = !String.isBlank(key);
        Boolean containsKeyToReplace = isKeyNotBlank && endPointMethod.contains(key);
        
        if(containsKeyToReplace) {
            endPointMethod = endPointMethod.replace(key, value);
        }
        
        return endPointMethod;
    }
    
    private void validateReqParam(String paramName, String param) {
        if(String.isBlank(param)) {
            throw new IntegrationRestException('Requered parameter not found: ' + paramName);
        }
    }
    
    private ServiceParameter__c getServiceParameter(String serviceName) {
        ServiceParameter__c seviceParameter = ServiceParameter__c.getInstance(serviceName); 
        
        if(seviceParameter == null) {
            throw new IntegrationRestException('ServiceParameter not found: ' + serviceName);
        }
            
        validateReqParam('ServiceParameter.contentType', seviceParameter.ContentType__c);
        validateReqParam('ServiceParameter.method', seviceParameter.Method__c);
        validateReqParam('ServiceParameter.namedCredential', seviceParameter.NamedCredential__c);
        validateReqParam('ServiceParameter.timeout', String.valueOf(seviceParameter.Timeout__c));
        
        if(!seviceParameter.IsActive__c) {
            throw new IntegrationRestException('integration is inactive');
        }
        
        return seviceParameter;
    }
}