/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Description: Classe responsável por chamada rest API
--- Date: 18/09/2018
-------------------------------------------------------------------------------------------------------*/
public with sharing class CEC_HttpReq {

    public CEC_HttpReq() {
    }

    public static HttpRequest genHttpReq(ServiceParameter__c aParam, String aArgs) {
        HttpRequest request = new HttpRequest();
        if (aParam == null) {
            request.setMethod('GET');
            request.setTimeout(20000);
            return request;
        }

        String sAuth = CEC_IntegrationHelper.getBasicAuth(new String[]{
                aParam.User__c, aParam.Password__c
        });
        request.setEndpoint(aParam.Endpoint__c + aArgs);
        request.setMethod((String.isNotBlank(aParam.Method__c)) ? aParam.Method__c : 'GET');
        request.setTimeout((aParam.Timeout__c == null) ? 10000 : Integer.valueOf(aParam.Timeout__c));
        if (!aParam.Endpoint__c.startsWith('callout:')) request.setHeader('Authorization', sAuth);
        return request;
    }

    public static HttpResponse sendReq(String serviceName, String method, Object body) {
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName);
        HttpRequest request = genHttpReq(param, '');
        if (String.isNotBlank(method)) {
            request.setEndpoint('callout:' + serviceName);
            request.setMethod(method);
        }
        return sendReq(request, body);
    }

    public static HttpResponse sendReq(HttpRequest aReq, Object aBody) {
        if (aBody != null) aReq.setHeader('Content-Type', 'application/json');
        if (aBody != null) aReq.setBody(JSON.serialize(aBody, true));

        Http h = new Http();
        HttpResponse response = new HttpResponse();
        try {
            system.debug('EndPoint>>>>'+aReq.getEndpoint());
            system.debug('RequestBody>>>>'+aReq.getBody());
            response = h.send(aReq);
            system.debug('Response>>>>'+response.getBody());
        } catch (Exception ex) {
            system.debug('Exception: ' + ex);
        }
        return response;
    }

    public static HttpResponse sendReq(HttpRequest aReq, Object aBody, boolean removerIssoDaqui) {
        if (aBody != null) aReq.setHeader('Content-Type', 'application/json');
        if (aBody != null) {
            String request = CEC_Utils.normalizeJson(aBody);

            aReq.setBody(request);
        }

        Http h = new Http();
        HttpResponse response = new HttpResponse();
        try {
            system.debug('EndPoint>>>>'+aReq.getEndpoint());
            system.debug('RequestBody>>>>'+aReq.getBody());
            response = h.send(aReq);
            system.debug('Response>>>>'+response.getBody());
        } catch (Exception ex) {
            system.debug('Exception: ' + ex);
        }
        return response;
    }

    public static HttpResponse sendReqByJson(HttpRequest aReq) {

        String json = '{\"data\":{\"product\":{\"type\":\"VOZ\",\"subType\":\"MOVEL\",\"productOffering\":{\"type\":\"Controle\",\"offer\":[{\"type\":\"OPCIONAL\",\"id\":\"414409110\"},{\"type\":\"OPCIONAL\",\"id\":\"414409111\"},{\"type\":\"OPCIONAL\",\"id\":\"380523526\"},{\"type\":\"OPCIONAL\",\"id\":\"414409130\"},{\"type\":\"Promoção\",\"id\":\"414395917\"}]}},\"marketSegments\":{\"areaCode\":\"11\"}}}';
        //String json = ' {\"data\":{\"product\":{\"type\":\"VOZ\",\"subType\":\"MOVEL\",\"productOffering\":{\"type\":\"Controle\",\"offer\":[{\"type\":\"OPCIONAL\",\"id\":\"414409110\"},{\"type\":\"OPCIONAL\",\"id\":\"414409111\"},{\"type\":\"OPCIONAL\",\"id\":\"380523526\"}]}},\"marketSegments\":{\"areaCode\":\"11\"}}}';
        aReq.setHeader('Content-Type', 'application/json');
        aReq.setBody(json);
        Http h = new Http();
        HttpResponse response = new HttpResponse();
        try {
            system.debug('EndPoint>>>>'+aReq.getEndpoint());
            system.debug('RequestBody>>>>'+aReq.getBody());
            response = h.send(aReq);
            system.debug('Response>>>>'+response.getBody());
        } catch (Exception ex) {
            system.debug('Exception: ' + ex);
        }
        return response;
    }

    public static HttpResponse sendReq(String serviceName, Object body) {
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName);

        Blob headerValue = Blob.valueOf('{!$Credential.Username}' + ':' + '{!$Credential.Password}');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:' + param.NamedCredential__c + param.EndPoint__c);
        request.setMethod(param.Method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(JSON.Serialize(body));

        Http h = new Http();
        system.debug('EndPoint>>>>'+request.getEndpoint());
        system.debug('RequestBody>>>>'+request.getBody());
        HttpResponse response = h.send(request);
        system.debug('Response>>>>'+response.getBody());
        return response;
    }
    // Squad ME 
    public static HttpResponse sendReqSandbox(String serviceName, Object body) {
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName);
        Blob headerValue = Blob.valueOf(param.User__c + ':' + param.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(JSON.Serialize(body));

        Http h = new Http();
        system.debug('EndPoint>>>>'+request.getEndpoint());
        system.debug('RequestBody>>>>'+request.getBody());
        HttpResponse response = h.send(request);
        system.debug('Response>>>>'+response.getBody());
        return response;
    }
}