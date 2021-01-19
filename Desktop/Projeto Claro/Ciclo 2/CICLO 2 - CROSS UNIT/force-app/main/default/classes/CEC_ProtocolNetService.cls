/*-----------------------------------------------------------------------------------------------------
	--- Company: Deloitte Brazil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela integração com a API Interactions 
	--- que chama o serviço de protocolo do NETSMS. 
	---	Created: 18/09/2018
-------------------------------------------------------------------------------------------------------*/

public class CEC_ProtocolNetService 
{
    //Squad ME
    private static final Boolean IS_SANDBOX = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    //class constructor
    public CEC_ProtocolNetService()
    {
        
    }
    //Squad ME
    public static CEC_ProtocolNetResponse getResponse(String contractNumber, String operatorCode)
    {
		CEC_ProtocolNetRequest request = new CEC_ProtocolNetRequest();
		CEC_ProtocolNetRequest.Data data = new CEC_ProtocolNetRequest.Data();
        data.contractNumber = contractNumber;
        data.operatorCode = operatorCode;
        data.reasonId = '25';
        request.data = data;
      	HttpResponse response;
        if(IS_SANDBOX){
            response = CEC_HttpReq.sendReqSandbox('ProtocolNet', request);
        }else{
            response = CEC_HttpReq.sendReq('CEC_OAG_NET_Protocol', request);
        }
        CEC_ProtocolNetResponse protResponse = parseResponse(response);
        return protResponse;
    }

    /*-----------------------------------------------------------------------------------------------------
	--- Company: Deloitte Brazil
	--- Squad: Canais Críticos 
	--- Description: Método responsável pelo getResponse. 
	---	Created: 12/09/2018
	-------------------------------------------------------------------------------------------------------*/
	public static CEC_ProtocolNetResponse getResponse(Case caso)
    {
		CEC_ProtocolNetRequest request = new CEC_ProtocolNetRequest();
		CEC_ProtocolNetRequest.Data data = new CEC_ProtocolNetRequest.Data();
            data.contractNumber = caso.ContractMSISDN__c.substringAfter('/').trim();
        data.operatorCode = caso.ContractMSISDN__c.substringBefore('/').trim();
        data.reasonId = '1';
        request.data = data;
        system.debug('request: ' + request);
        HttpResponse response = CEC_HttpReq.sendReq('CEC_OAG_NET_Protocol', request);
        return parseResponse(response);
	}
    
    private static CEC_ProtocolNetResponse parseResponse(HttpResponse varResponse)
    {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_ProtocolNetResponse response = (CEC_ProtocolNetResponse) parser.readValueAs(CEC_ProtocolNetResponse.class);
        if(varResponse.getStatusCode() == 200)
        {            
            return response;
        }else
        {
            throw new CEC_IntegrationException(response.error.detailedMessage);
        }
    }
/*-----------------------------------------------------------------------------------------------------
	--- Company: Sysmap Solutions
	--- Squad: LGPD
	--- Description: Método responsável pelo getResponseLGPD. 
	---	Created: 22/07/2020
    --- Author: Guilherme Cuencas
	-------------------------------------------------------------------------------------------------------*/
	public static CEC_ProtocolNetResponse getResponseLGPD(Case caso)
    {
		CEC_ProtocolNetRequest request = new CEC_ProtocolNetRequest();
		CEC_ProtocolNetRequest.Data data = new CEC_ProtocolNetRequest.Data();
            data.contractNumber = caso.ContractMSISDN__c.substringAfter('/').trim();
        data.operatorCode = caso.ContractMSISDN__c.substringBefore('/').trim();
        data.reasonId = '1';
        request.data = data;
        system.debug('request: ' + request);
        HttpResponse response = CEC_HttpReq.sendReq('CEC_OAG_NET_Protocol', request); //Custom Settings - ServiceParameter
        return parseResponse(response);
	}
    
}