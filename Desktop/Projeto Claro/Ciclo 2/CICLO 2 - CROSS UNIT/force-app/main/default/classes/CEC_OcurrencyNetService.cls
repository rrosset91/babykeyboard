/*-----------------------------------------------------------------------------------------------------
	--- Company: Deloitte Brazil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela integração com a API contactrecords  
	--- que chama o serviço de geração de ocorrência do NETSMS. 
	---	Created: 18/09/2018
-------------------------------------------------------------------------------------------------------*/
public class CEC_OcurrencyNetService {
    
    public CEC_OcurrencyNetService()
    {
        
    }
    
    public static CEC_OcurrencyNetResponse getResponse(OcurrencyWrapper ocurrencyInfo)
    {
        System.debug('>> CEC_OcurrencyNetService.getResponse');
        
        ServiceParameter__c param = ServiceParameter__c.getInstance(ocurrencyInfo.serviceName); 
        
        CEC_OcurrencyNetRequest request = new CEC_OcurrencyNetRequest();
        CEC_OcurrencyNetRequest.Data data = new CEC_OcurrencyNetRequest.Data();
        
        request.application = 'ATLAS';
        data.sourceEvent = 'INTERNET';
        data.identifier = '1';
        
        data.login = param.User__c;
        
        System.debug('>> ocurrencyInfo: '+ocurrencyInfo);
        
        if(ocurrencyInfo.typeOcurrency == 'Open'){
            data.note = 'Foi gerada uma manifestação '+ ocurrencyInfo.caso.Channel__c + ' .' + ocurrencyInfo.caso.description; 
            data.description = 'OV4 - ANALISE E RETORNO PARA CLIENTE'; 
            data.identifierType = '717';
        }   
        else if(ocurrencyInfo.typeOcurrency == 'Resolution'){
            data.note = ocurrencyInfo.caso.Resolution__c;
            
            data.identifierType = '794';
            data.description = 'OV1 - OV5 - OUVIDORIA NIVEL I';
        }
        
        System.debug('>> Ocurrencia: '+data);
        
        data.contractNumber = ocurrencyInfo.caso.ContractMSISDN__c.substringAfter('/').trim();
        data.operatorCode = ocurrencyInfo.caso.ContractMSISDN__c.substringBefore('/').trim();     
        data.protocol = ocurrencyInfo.caso.LegacyProtocol__c;
        data.interactionNumber = ocurrencyInfo.caso.InteractionNumber__c;    
        request.data = data;       
        
        system.debug('CEC_OcurrencyNetService.request: ' + request);
        
        HttpResponse response = CEC_HttpReq.sendReq(ocurrencyInfo.serviceName, request);
        
        system.debug('CEC_OcurrencyNetService.response: ' + response);
        
        CEC_OcurrencyNetResponse responseNet = parseResponse(response);

        return responseNet;        
    }
    
    private static CEC_OcurrencyNetResponse parseResponse(HttpResponse varResponse)
    {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_OcurrencyNetResponse response = (CEC_OcurrencyNetResponse) parser.readValueAs(CEC_OcurrencyNetResponse.class);
        
        System.debug('CEC_OcurrencyNetService.RESPONSE: ' + response);
        
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
    }
}