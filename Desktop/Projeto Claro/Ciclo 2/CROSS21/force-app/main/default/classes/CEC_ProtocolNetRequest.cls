/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Protocolo Request ]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe  
*/
public class CEC_ProtocolNetRequest {

	public String transactionId 		{ get; set; }
	public Data data					{ get; set; }

	public class Data{
		public String contractNumber 	{ get; set; }
    	public String operatorCode 		{ get; set; }
    	public String protocolNumber 	{ get; set; }
    	public String reasonId 			{ get; set; }	
    	
	}
}