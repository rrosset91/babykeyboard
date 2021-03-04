public with sharing class HttpReq {
	public static HttpResponse sendReq(String serviceName, Object body) {
        system.debug('SERVICE NAME >> ' + serviceName);
        
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
        
        system.debug('param >> ' +  param);
        
		Blob headerValue = Blob.valueOf(param.User__c + ':' + param.Password__c);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(JSON.Serialize(body));
        
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
        
    }    
}