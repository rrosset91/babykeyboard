/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Protocolo Response ]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe 
*/

public class CEC_ProtocolNetResponse {
    
    public String apiVersion 			{ get; set; }
    public String transactionId			{ get; set; }
    public Data data 					{ get; set; }
    public Error error 					{ get; set; }
    
    public class Data{
        public String protocolNumber 	{ get; set; }
        public String interactionNumber	{ get; set; }
    }
    
    public class Error{
        public String httpCode				{ get; set; }
        public String errorCode				{ get; set; }
        public String message				{ get; set; }
        public String detailedMessage 		{ get; set; }		
        public Link link 					{ get; set; }
    }
    
    public class Link{
        public String rel 					{ get; set; }
        public String href 					{ get; set; }
    }
}