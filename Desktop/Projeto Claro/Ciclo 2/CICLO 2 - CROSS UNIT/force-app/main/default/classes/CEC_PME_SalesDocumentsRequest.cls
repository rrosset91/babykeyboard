/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para inicialização do objetos utilizados na integração do GGD.
*/

public class CEC_PME_SalesDocumentsRequest 
{
    public String apiVersion										{ get; set; }
    public String transactionId 									{ get; set; }
    public Data data 												{ get; set; }
    
    public class Data
    {
        public List<SalesDocuments> salesDocuments 					{ get; set; }
    }
    
    public class SalesDocuments
    {
        public SalesParty salesParty 								{ get; set; }
        public Customer customer 									{ get; set; }
        public List<EquipmentReceivers> equipmentReceivers 			{ get; set; }
        public List<Plans> plans 									{ get; set; }
        public Summary summary 										{ get; set; }
        public SubscriberAcceptances subscriberAcceptances 			{ get; set; }
    }
    
    public class SalesParty
    {
        public String salesmanId 									{ get; set; }
        public String salesmanName 									{ get; set; }
        public String companyName 									{ get; set; }
        public String cnpj 											{ get; set; }
        public String vendorId	 									{ get; set; }
        public String salesChannelId 								{ get; set; }
        public String segment 										{ get; set; }
    }
    
    public class Customer
    {
        public String companyName 									{ get; set; }
        public String stateRegistration 							{ get; set; }
        public String municipalRegistration 						{ get; set; }
        public String primaryCNAE 									{ get; set; }
        public String secondaryCNAE 								{ get; set; }
        public String cnpj 											{ get; set; }
        public Boolean flagNetSubscriber 							{ get; set; }
        public Boolean flagEmbratelSubscriber 						{ get; set; }
        public String customerAccountId 							{ get; set; }
        public ContactPhone contactPhone 							{ get; set; } 
        public Integer employeeQuantity								{ get; set; }
        public List<Administrators> administrators	 				{ get; set; }
        public List<Addresses> addresses 							{ get; set; }
        public List<CommercialReferences> commercialReferences 	    { get; set; }
        public BillingSpec billingSpec	 						    { get; set; }       
    }

	public class ContactPhone
    {
        public String telephoneNumber 								{ get; set; }
        public String areaCode	 									{ get; set; }
        public String internationalCode 							{ get; set; }
        public String contactMediumRole 							{ get; set; }
    }

	public class Administrators
    {  
    	public String name 											{ get; set; }
        public String cpf 											{ get; set; }
        public List<Phones> phones 									{ get; set; }
        public String emailAddress 									{ get; set; }
        public Boolean isLegalRepresentative						{ get; set; }
        public String jobTitle	 									{ get; set; }
	}

    public class Phones
    {
    	public String telephoneNumber 								{ get; set; }
        public String areaCode	 									{ get; set; }
        public String internationalCode 							{ get; set; }
        public String contactMediumRole 							{ get; set; }
    }

	public class Addresses
    {
        public String addressType 									{ get; set; }
        public String postcode 										{ get; set; }
        public String streetType 									{ get; set; }
        public String streetName									{ get; set; }
        public String streetNr 										{ get; set; }
        public String complement 									{ get; set; }
        public String neighborhood 									{ get; set; }
        public String cityName 										{ get; set; }
        public String stateAbbreviation 							{ get; set; }
	}

	public class CommercialReferences
    {
        public String companyName 									{ get; set; }
        public String cnpj 											{ get; set; }
        public String contactName 									{ get; set; }
        public ContactPhone contactPhone 							{ get; set; }
    }
    
    public class BillingSpec
    {
        public String paymentDayDue 								{ get; set; }
        public BankingDetails bankingDetails 						{ get; set; }
    }
    
    public class BankingDetails
    {
        public String bankId 										{ get; set; }
        public String bankName	 									{ get; set; }
        public String agency 										{ get; set; }
        public String accountNumber 								{ get; set; }
        public String contactName 									{ get; set; }
        public ContactPhone contactPhone 							{ get; set; }
    }
    
    public class EquipmentReceivers
    {
    	public String name  										{ get; set; }
        public String rg  											{ get; set; }
        public Phones phones 									{ get; set; }
    }
    
    public class Plans
    {
        public String name	 										{ get; set; }
        public Boolean flagSharedPlan 								{ get; set; }
		public String tradeIn 										{ get; set; }        
        public List<Groups> groups									{ get; set; }
    }
    
    public class Groups
    {
    	public String name	 										{ get; set; }
        public String requestType 									{ get; set; }
        public String regional 										{ get; set; }
        public String stateAbbreviation 							{ get; set; }
        public String areaCode 										{ get; set; }
        public String franchise 									{ get; set; }
        public Decimal value 										{ get; set; }
        public String lineAmount 									{ get; set; }
        //public String tradeIn 										{ get; set; }
        public String paymentMethod 								{ get; set; }
        public String bonus											{ get; set; }
        public Decimal progressiveDiscount							{ get; set; }
        public Decimal valueDiscount								{ get; set; }
        public String kit											{ get; set; }
        public List<Plugin> plugins  								{ get; set; }
        public List<AdditionalServices> additionalServices  		{ get; set; }
        public List<IncludedServices> includedServices  			{ get; set; }
        public List<LineDetails> lineDetails 						{ get; set; }                
    }

	public class Plugin
    {
        public String type 											{ get; set; }
        public String id 											{ get; set; }
        public Decimal value 										{ get; set; }
        public String areaCode 										{ get; set; }
	}

	public class AdditionalServices
    {
        public String name	 										{ get; set; }
        public Decimal value 										{ get; set; }
	}

	public class IncludedServices
    {
        public String name	 										{ get; set; }
	}
    
    public class LineDetails
    {
        public String telephoneNumber 								{ get; set; }
        public Donor donor 											{ get; set; }
        public String operator 										{ get; set; }
        public Simcard simcard 										{ get; set; }
        public Device device 										{ get; set; }
    }
    
    public class Donor
    {
    	public String name 											{ get; set; }
        public String cpf 											{ get; set; }
        public List<Phones> phones 									{ get; set; }
        public String emailAddress 									{ get; set; }
        public Address address 										{ get; set; }
    }

	public class Address
    {
        public String addressType 									{ get; set; }
        public String postcode 										{ get; set; }
        public String streetType 									{ get; set; }
        public String streetName 									{ get; set; }
        public String streetNr 										{ get; set; }
        public String complement 									{ get; set; }
        public String neighborhood 									{ get; set; }
        public String cityName 										{ get; set; }
        public String stateAbbreviation 							{ get; set; }
    }
    
    public class Simcard
    {
    	public String iccid 										{ get; set; }
        public String type 											{ get; set; }
        public Decimal value 										{ get; set; }
        public Decimal baseValue 									{ get; set; }
    }
    
    public class Device
    {
    	public String manufacturerName	 							{ get; set; }
        public String modelName 									{ get; set; }
        public String color 										{ get; set; }
        public Boolean flagAcceptAnotherColor 						{ get; set; }
        public Decimal value 										{ get; set; }
        public Integer score 										{ get; set; }
        public String range 										{ get; set; }
        public Decimal baseValue 									{ get; set; }
    }
    
    public class Summary
    {
    	public String lineQuantity 									{ get; set; }
        public String deviceQuantity 								{ get; set; }
        public Decimal totalValueOfEquipments 						{ get; set; }
        public String totalValueOfServices 							{ get; set; }
        public List<SimcardDetails> simcards						{ get; set; }
        public String paymentMethod									{ get; set; }
    }
    
    public class SubscriberAcceptances
    {
        public Boolean flagAcceptSmsPublicity 						{ get; set; }
        public Boolean flagAcceptLD21Manager 						{ get; set; }
        public Boolean flagAuthorizesDataSharing 					{ get; set; }
    }
    
    public class SimcardDetails
    {
        public String type 											{ get; set; }
        public Decimal quantity 									{ get; set; }
    }    
}