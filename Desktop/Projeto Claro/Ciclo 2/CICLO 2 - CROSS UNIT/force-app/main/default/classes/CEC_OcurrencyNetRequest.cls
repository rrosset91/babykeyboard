/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Ocorrência Request]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe 
*/

public with sharing class CEC_OcurrencyNetRequest {
    public String application					{ get; set; }
	public String transactionId 				{ get; set; }
	public Data data 							{ get; set; }
	
	public class Data{
        public String emailAddress 				{ get; set; }
		public String login 					{ get; set; }
      	public String note 						{ get; set; }
        public String sourceEvent 				{ get; set; }
        public String identifier 				{ get; set; }
        public String identifierType 			{ get; set; }
      	public String description 				{ get; set; }
      	public String name 						{ get; set; }
      	public String areaCode 					{ get; set; }
      	public String telephoneNumber 			{ get; set; } //number
      	public String extensionNumber			{ get; set; }
      	public String telephoneType 			{ get; set; }
      	public String contractNumber 			{ get; set; }
      	public String operatorCode 				{ get; set; }
      	public String cityId 					{ get; set; }
      	public String MACAddress 				{ get; set; }
      	public String AliasDatabase 			{ get; set; }
      	public String protocol 					{ get; set; }
      	public String interactionNumber 		{ get; set; }
		public String contractName				{ get; set; }
		public String reasonId					{ get; set; }
	}
	 
}