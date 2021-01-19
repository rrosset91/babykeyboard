/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe responsável por montar o HttpRequest das integrações com o AOG.
A lista das classes que possuem dependencia com esta classe pode ser obtida
na custom setting ServiceParameter__c. 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public with sharing class CEC_PME_HttpReq {
    private CEC_PME_HttpReq(){}

/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Método obsoleto, utilizar o sendReq(String serviceName, String endPointMethod) no lugar.
*/    
	public static HttpResponse sendReq(String serviceName, Object body) {
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(param.EndPoint__c);
        req.setMethod(param.Method__c);
        //req.setBody(JSON.Serialize(body));
        
        Http h = new Http();
        return h.send(req);
    }    

    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
    serviceName: Nome contido na custom setting ServiceParameter__c, necessário para obter os valores correspondentes
					dos parametros utilizados no método.
	endPointMethod: complemento da URL que contém o nome do serviço e os parametros a seren enviados no serviço.
    */        
    public static HttpResponse sendReq(String serviceName, String endPointMethod) {
        Organization org = [SELECT IsSandbox FROM Organization];
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
        HttpRequest req = new HttpRequest();
        System.Debug('EndPoint: ' + param.EndPoint__c + endPointMethod);
        req.setMethod(param.Method__c);
        req.setTimeout(20000);
        
        /*if(org.IsSandbox){
            req.setEndpoint(param.EndPoint__c + endPointMethod);
            if(String.isNotBlank(param.User__c)){
                Blob headerValue = Blob.valueOf(param.User__c + ':' + param.Password__c);
                String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);               
            }                       
        } else {*/
            req.setEndpoint('callout:OAGClaro' + endPointMethod);
        //}      
        
        Http h = new Http();
        return h.send(req);
    }
    
    public static HttpResponse sendReqBody(String serviceName, String endPointMethod, Object body) {
        Organization org = [SELECT IsSandbox FROM Organization];
        
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
        HttpRequest req = new HttpRequest();

        req.setMethod(param.Method__c);       
        req.setBody(JSON.Serialize(body));
        req.setTimeout(120000);
        
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');        
        
		/*if(org.IsSandbox){
        	req.setEndpoint(param.EndPoint__c + endPointMethod);
            if(String.isNotBlank(param.User__c)){
                Blob headerValue = Blob.valueOf(param.User__c + ':' + param.Password__c);
                String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);                  
            }
        } else {*/
            req.setEndpoint('callout:OAGClaro' + endPointMethod);
        //}      
        
		System.Debug('req body>> '+req.getBody());
        Http h = new Http();
        return h.send(req);
    }
}