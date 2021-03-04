/*-----------------------------------------------------------------------------------------------------
	--- Company: Sysmap Solutions
	--- Squad: LGPD
	--- Description: Classe responsável pela integração com a API contactrecords  
	--- que chama o serviço de geração de ocorrência do NETSMS. 
	---	Created: 31/07/2020
    --- Author: Guilherme Cuencas
-------------------------------------------------------------------------------------------------------*/

public class CEC_LGPD_OccurrencyNetService {
       
    public static CEC_OcurrencyNetResponse getResponse(OcurrencyWrapper ocurrencyInfo)
    {
        System.debug('>> CEC_LGPD_OccurrencyNetService.getResponse');
        System.debug(ocurrencyInfo.serviceName);
        ServiceParameter__c param = ServiceParameter__c.getInstance(ocurrencyInfo.serviceName);
        System.debug('CEC_LGPD_OccurrencyNetService param >> ');
        System.debug(param);
        CEC_OcurrencyNetRequest request = new CEC_OcurrencyNetRequest();
        CEC_OcurrencyNetRequest.Data data = new CEC_OcurrencyNetRequest.Data();
        ocurrencyInfo.typeOcurrency = ocurrencyInfo.ocurrenceSetting.Type__c;
        ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';        
        
        request.application = 'OTHER';
        
        data.sourceEvent = 'INTERNET';
        data.identifier = '1';
        data.identifierType = ocurrencyInfo.ocurrenceSetting.TypeId__c;
        data.note = 'Foi criada uma solicitação ' + ocurrencyInfo.caso.Subject + ' vinculada a um caso no Salesforce';
        data.description = ocurrencyInfo.typeOcurrency;
        data.interactionNumber = ocurrencyInfo.interactionNumber;
        User u = [SELECT NetServicos__c FROM User where Id = :UserInfo.getUserId() LIMIT 1];
        data.login = u.NetServicos__c;
        data.name = '';// TODO name do account
        data.contractNumber = ocurrencyInfo.caso.Contract__c.substringAfter('/').trim();
        data.operatorCode = ocurrencyInfo.caso.Contract__c.substringBefore('/').trim();     
        data.protocol = ocurrencyInfo.caso.ProtocolNumber__c;
        request.data = data;
        
        system.debug('CEC_LGPD_OccurrencyNetService.request: ' + request);
        
        HttpResponse response = CEC_HttpReq.sendReq(ocurrencyInfo.serviceName, request);
        
        system.debug('CEC_LGPD_OccurrencyNetService.response: ' + response);
        
        CEC_OcurrencyNetResponse responseNet = parseResponse(response);

        return responseNet;        
    }
    
    public static CEC_OcurrencyNetResponse parseResponse(HttpResponse varResponse)
    {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_OcurrencyNetResponse response = (CEC_OcurrencyNetResponse) parser.readValueAs(CEC_OcurrencyNetResponse.class);
        
        System.debug('CEC_LGPD_OccurrencyNetService.RESPONSE: ' + response);
        
        if(varResponse.getStatusCode() == 200){            
            return response;
        }
        else {  
            CEC_IntegrationException customEx = new CEC_IntegrationException(response.error.detailedMessage);    
            customEx.errorMessage = response.error.message;
            customEx.errorCode    = response.error.errorCode;
            customEx.httpCode     = response.error.httpCode;
            throw customEx;
        }
    } 
    
    public class OcurrencyWrapper 
    {
        public Case caso {get;set;}
        public String typeOcurrency {get;set;} 
        public String serviceName {get;set;} 
        public String name {get;set;}
        public CEC_ME_OccurrenceSettings__mdt ocurrenceSetting {get;set;}
        public String interactionNumber {get;set;} 
    }
}