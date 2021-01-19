/*-----------------------------------------------------------------------------------------------------
	--- Company: Hitss do Brasil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela integração com a API contactrecords  
	--- que chama o serviço de listagem de ocorrência do NETSMS. 
	---	Created: 08/10/2020
-------------------------------------------------------------------------------------------------------*/
public class CEC_GetOcurrencyNetService {
    
    public static string getOcurrency(String idContract, String idOperator, String protocolo)
    {
        System.debug('>> CEC_GetOcurrencyNetService.getOcorrencia');

        String paramURL = 'operatorCode=' + idOperator + '&contractNumber=' + idContract; 
        HttpResponse response = CEC_HttpReq.sendReqGet('CEC_OAG_NET_GetOcurrency', paramURL);

        system.debug('CEC_GetOcurrencyNetService.response: ' + response);

        return getOcurrencyParseResponse(response, protocolo);        
    }
    
    private static String getOcurrencyParseResponse(HttpResponse response, String protocolo){
        String idOcorrencia;
        system.debug('response.getBody(): '+response.getBody());
		Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        system.debug('meta: '+meta);
        if (response.getStatusCode() == 200){
            Map<String, Object> myMapObjects = (Map<String, Object>) meta.get('data');
            List<Object> lstObjects = (List<Object>) myMapObjects.get('data');
            for (Object obj : lstObjects){
                Map<String, Object> mapResponse = (Map<String, Object>) obj;
                if (mapResponse.get('protocolNumber') == protocolo){
                    idOcorrencia = (String) mapResponse.get('number');    
                }
            }
        }else{
            Map<String, Object> mapObjects = (Map<String, Object>) meta.get('error');
            system.debug('detailedMessage: '+mapObjects.get('detailedMessage'));
            String mensagem; 
            if (mapObjects.get('message') == null){
                mensagem = (String) mapObjects.get('httpCode');
            }else{
             	mensagem = (String) mapObjects.get('message');
            } 
            system.debug('mensagem: '+mensagem);
            CEC_IntegrationException customEx = new CEC_IntegrationException(mensagem);
            for (String chave : mapObjects.KeySet()){               
                if ('message' == chave)                
                	customEx.errorMessage = (String) mapObjects.get(chave);
               	if ('errorCode' == chave)
            		customEx.errorCode    = (String) mapObjects.get(chave);
            	if ('httpCode' == chave)
            		customEx.httpCode     = (String) mapObjects.get(chave);
            	throw customEx;
                
            }
        }
        return idOcorrencia;
    }
}