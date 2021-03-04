/**
 * ---------------------------------------------------------------
 * Data: 13/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions [Ello Serafim/Guilherme Cuencas]
 * Descrição: ANATEL - Fachada para Validação de protocolo (caso)
 * Alteração: 10/11/2020 - Ajuste no response retornando o número do protocolo para code 20 e 21, conforme necessidade da anatel
 * Alterado por: Ello Serafim/Guilherme Cuencas
*/
 
@RestResource(UrlMapping='/validarprotocoloatendimento')
global class CEC_CC_Api_Anatel_Ouvidoria {
    
    @HttpPost
    global static CEC_CC_Anatel_Ouvidoria_ProtocolResponse validarProtocolo(String numero){
        RestResponse restResp = RestContext.response;
        CEC_CC_Anatel_Ouvidoria_ProtocolResponse response = new CEC_CC_Anatel_Ouvidoria_ProtocolResponse();
        if(String.isBlank(numero)){
            response.statusWS = '20'; // Erro Parâmetros não informados
            restResp.statusCode = 400;
            return response;
        }
        if(numero.length() < 8 || numero.length() > 19){
            response.statusWS = '10';
            response.statusProtocolo = '20'; // Erro formato inválido
            response.numero = numero;
            restResp.statusCode = 200;  
            return response;
        }
        try{
            response = CEC_CC_Anatel_Ouvidoria_Controller.validateProtocol(numero);
            restResp.statusCode = 200;
        }catch(Exception ex){
            // Erro desconhecido
            response.numero = numero;
            response.statusWS = '21';
            restResp.statusCode = 500;
        }
        return response;
    }
}