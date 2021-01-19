public with sharing class OcurrencyNet_Request {
    public String application					{ get; set; }
	public String transactionId 				{ get; set; }
	public Data data 							{ get; set; }
	
	public class Data{
		public String login 					{ get; set; }
      	public String note 						{ get; set; }
        public String sourceEvent 				{ get; set; }
        public String identifier 				{ get; set; }
        public String identifierType 			{ get; set; }
      	public String description 				{ get; set; }
      	public String name 						{ get; set; }
      	public String areaCode 					{ get; set; }
      	public String telephoneNumber 			{ get; set; }
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
	}
	 
}