public class OcurrencyNet_Response {
	public String apiVersion 							{ get; set; }
	public String transactionId 						{ get; set; }
	public Data data 									{ get; set; }
    public Error error 									{ get; set; }
	
	/*Bad Response*/
	public String message								{ get; set; }
    public String detailedMessage						{ get; set; }
    public Link link									{ get; set; }
    
	public class Data{
		public List<ContactRecords> contactRecords 		{ get; set; }
        public ContactRecords lContactRecords           { get; set; }
	}
	
	public class ContactRecords{
		public User user 								{ get; set; }
		public String eventDate 						{ get; set; }
		public String note 								{ get; set; }
	 	public String sourceEvent 						{ get; set; }
	 	public EventType eventType 						{ get; set; }
	 	public Type type 								{ get; set; }
	 	public Contact contact 							{ get; set; }
		
	}
	
	public class User{
		public String login 							{ get; set; }
		public String userName 							{ get; set; }
		public PartyId partyId 							{ get; set; }
		public Emailcontact emailcontact 				{ get; set; }
		public Telephone telephone 						{ get; set; }
	}
	
	public class PartyId{
		//public String number 							{ get; set; } //Number é palavra reservada, verificar a possibilidade de alterar a tag no response
		public String type 								{ get; set; }
		public String addressId 						{ get; set; }
        public String country 							{ get; set; }
        public String placeId 							{ get; set; }
        public String cityId 							{ get; set; }
        public String cityName 							{ get; set; }
        public String postCode 							{ get; set; }
        public String neighborhood 						{ get; set; }
        public String streetType 						{ get; set; }
        public String streetTypeId 						{ get; set; }
        public String streetName 						{ get; set; }
        public String streetNrFirst 					{ get; set; }
        public String urbanPropertySubAddress 			{ get; set; }
        public String complementarySubAddress 			{ get; set; }
        public String boxNr 							{ get; set; }
	}
	
	public class Emailcontact{
		public String emailAddress 						{ get; set; }
	}
	
	public class Telephone{
		public String areaCode 							{ get; set; }
		//public String number							{ get; set; } //Number é palavra reservada, verificar a possibilidade de alterar a tag no response
		public String extensionNumber 					{ get; set; }
	}
	
	public class EventType{
		public String identifier 						{ get; set; }
		public String description 						{ get; set; }
	}
	
	public class Type{
		public String identifier 						{ get; set; }
		public String description 						{ get; set; }
	}
	
	public class Contact{
		public User user 								{ get; set; }
		public ContactType contactType 					{ get; set; }
		public ContactMedium contactMedium 				{ get; set; }
	}
	
	public class ContactType{
		public String identifier 						{ get; set; }
		public String description 						{ get; set; }
		public String name 								{ get; set; }
		public String interactionNumber 				{ get; set; }
		public String protocol 							{ get; set; }
	}
	
	public class ContactMedium{
		public Telephone telephone 						{ get; set; }
		public Emailcontact emailcontact 				{ get; set; }
		public PartyId partyId 							{ get; set; }
	}
	
	public class Link {
		public String rel								{ get; set; }
      	public String href								{ get; set; }
	
	}
    
    public class Error{
    	public String httpCode							{ get; set; }
        public String errorCode							{ get; set; }
    	public String message							{ get; set; }
    	public String detailedMessage 					{ get; set; }		
		public Link link 								{ get; set; }
	}
}