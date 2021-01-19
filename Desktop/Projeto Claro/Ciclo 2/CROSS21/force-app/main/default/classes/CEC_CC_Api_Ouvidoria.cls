/**
 * ---------------------------------------------------------------
 * Data: 16/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions [Guilherme Cuencas, Ello Oliveira]
 * Descrição: [SOLAR] - [Time: Anatel / Ouvidoria]
 * Ouvidoria - Fachada para Consulta de protocolo 
 * ---------------------------------------------------------------
*/
@RestResource(UrlMapping='/searchProtocol')
global class CEC_CC_Api_Ouvidoria {
    
    @HttpGet
	global static CEC_CC_LegacyProtocolResponse getProtocol()
	{
        RestResponse restResponse = RestContext.response;
        RestRequest request = RestContext.request;
        String prot = request.params.get('protocolNumber');
        String cpf = request.params.get('cpf');
        String companyId = request.params.get('companyId');
        
        CEC_CC_LegacyProtocolResponse legacyProtocol = new CEC_CC_LegacyProtocolResponse();
        
        if(String.isBlank(prot) || String.isBlank(companyId)){
            restResponse.statusCode = 400;
            legacyProtocol.data = null;
            legacyProtocol.error = new CEC_RestObjects.Error();
            legacyProtocol.error.errorCode = 'API-DETAILS-400';
            legacyProtocol.error.httpCode = '400';
            legacyProtocol.error.message = 'Parâmetro Não Informado';
            return legacyProtocol;
        }

        List<String> validCompanyIds = new List<String>{'001', '002', '003'};
        if(!validCompanyIds.contains(companyId) ){
            restResponse.statusCode = 400;
            legacyProtocol.data = null;
            legacyProtocol.error = new CEC_RestObjects.Error();
            legacyProtocol.error.errorCode = 'API-DETAILS-400';
            legacyProtocol.error.httpCode = '400';
            legacyProtocol.error.message = 'Bad request';
            legacyProtocol.error.detailedMessage = 'Parâmetro Inválido';
            return legacyProtocol;
        }

        try{
            legacyProtocol = CEC_CC_OuvidoriaController.getLegacyProtocol(prot, cpf, companyId);
            if(legacyProtocol.error != null){
                if(legacyProtocol.error.httpCode == '404'){
                    restResponse.statusCode = 500;
                    legacyProtocol.error.httpCode = '500';
                    legacyProtocol.error.errorCode = 'API-DETAILS-500';
                    legacyProtocol.error.message= 'Not found';
                    legacyProtocol.error.detailedMessage = 'Protocolo não encontrado';
                }
            }
            if(legacyProtocol.error != null && legacyProtocol.error.httpCode != null){
                restResponse.statusCode = Integer.valueOf(legacyProtocol.error.httpCode);
            }else{
                restResponse.statusCode = 200;
            }
        }catch(Exception ex){
            restResponse.statusCode = 500;
            legacyProtocol.data = null;
            legacyProtocol.error = new CEC_RestObjects.Error();
            legacyProtocol.error.httpCode = '500';
            legacyProtocol.error.errorCode = 'API-DETAILS-500';
            legacyProtocol.error.message= 'Internal Server Error';
            legacyProtocol.error.detailedMessage = ex.getMessage();
        }
        system.debug('legacy Protocol >> ' + legacyProtocol);
        //restResponse.responseBody = legacyProtocol;
        return legacyProtocol;
	}
}