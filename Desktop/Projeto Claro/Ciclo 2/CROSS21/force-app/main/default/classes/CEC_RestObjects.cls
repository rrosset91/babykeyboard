/*
* Autor: RLdO
* Data: 29-out-2018
* Descrição: CEC FASE 1 COMERCIAL: Objetos utilizados nas integracoes REST e vlocity
* ----------------------------------------------------------------------------------
* Change.
* Data: 03/05/2019.
* Autor: Letícia Freitas
* Descrição: Merge da classe do ambiente de DEV 360 + ambiente produção.
*/

global without sharing class CEC_RestObjects
{
    global class RestCallException extends Exception {}
    
    global virtual class ResponseGen
    {
        @AuraEnabled global String apiVersion;
        @AuraEnabled global String transactionId;
        @AuraEnabled global Error error;
    }
    
    global class Error
    {
        global String httpCode;
        global String errorCode;
        global String message;
        global String detailedMessage;
        global Link link;
    }
    
    global class Link
    {
        global String rel;
        global String href;
    }
    
    global class BalancesPricePlan
    {
        global String pricePlanIdentification;
        global String pricePlanName;
        global String pricePlanSituation;
        global String pricePlanDateExpirationBenefit;
    }
    
    global class BalancesAccumulators
    {
        global String accumulatorPlatformIdentification;
        global String accumulatorPlatformDescription;
        global String accumulatorBusinessDescription;
        global String accumulatorCategoryIdentification;
        global String accumulatorCategoryDescription;
        global String accumulatorInternalUseIndicator;
        global Decimal accumulatorBalance;
        global String accumulatorDateStartValidity;
        global String accumulatorDateEndValidity;
        global String accumulatorMeasurementUnit;
    }
    
    global class BalancesDedicated
    {
        global String dedicatedPlatformIdentification;
        global String dedicatedPlatformDescription;
        global String dedicatedDescription;
        global String dedicatedCategoryIdentification;
        global String dedicatedCategoryDescription;
        global String dedicatedInternalUseIndicator;
        global Decimal dedicatedBalance;
        global String dedicatedMeasurementUnit;
        global String dedicatedDateEndValidity;
    }
    
    //<-- Balances End -->
    
    global class ResponseInactiveUser
    {
        global list<ResponseUser> user;
    }
    global class ResponseUser
    {
        global String CompanyName;
        global String Email;
        global String FirstName;
        global String LastName;
        global String ProfileId;
        global String UserName;
        global String cpf;
        global String federationId;
        global String log;
    }
    
    global class ResponseTotalLicenses
    {
        global Integer TotalLicenses;
        global Integer UsedLicenses;
    }
    
    global class Customer extends ResponseGen
    {
        global CustomerData data;
    }
    
    global class CustomerData
    {
        global List<CustomerAccounts> customerAccounts;
    }
    
    global class Portability extends ResponseGen
    {
        global PortabilityData data;
    }
    
    global class PortabilityData
    {
        global list<PortabilityPhoneType> phoneType;
        global list<PortabilityPhoneType> validRequests;
    }
    
    global class PortabilityPhoneType
    {
        /**/
        global String phoneLineNumber;
        global MobileCarrier actualMobileCarrier;
        global MobileCarrier previousMobileCarrier;
        global String portabilityIndicator;
        /**/
        global String sourcePortabilityIndicator;
        global String detail;
        global MobileCarrier donorOperator;
        global PortReqTickets requestedTickets;
    }
    
    global class MobileCarrier
    {
        global String carrierName;
        global String name;
        global String routingNumber1Code;
        global String spidCode;
    }
    
    global class PortReqTickets
    {
        global CustomerPhones phoneLineNumberType;
    }
    
    global class WindowsPortability extends ResponseGen
    {
        global WindowsPortabilityData data;
    }
    
    global class WindowsPortabilityData
    {
        global WindowsPortabilityObj windowsPortability;
    }
    
    global class WindowsPortabilityObj
    {
        global List<WindowPortabilityType> windowPortability;
    }
    
    global class WindowPortabilityType
    {
        global String startDate;
        global String startDateFmt { get
        {
            String lStartFmt;
            try {
                lStartFmt = (String.isBlank(this.startDate)) ? null : Datetime.valueOf(this.startDate.replace('T', ' ')).format('dd/MM/yyyy HH:mm');
            }
            catch (Exception ex) {}
            return lStartFmt;
        }
                                   }
        global String availableMobileIndicator;
        global String availableLandlineindicator;
    }
    
    global class CustomerAccounts
    {
        // campos da consulta Prospect residencial
        global String partyId;
        global String firstName;
        global String lastName;
        global String salutation;
        global String companyName;
        global String partyRoleId;
        global String partyIdentificationNumber;
        global String partyIdentificationType;
        global String customerAccountId;
        global String status;
        global String customerTypeName;
        global String customerTypeDescription;
        global String customerSegmentName;
        global String customerSegmentDescription;
        global String customerComboMultiFlag;
        global String involvementIdentificationRole;
        global String emailAddress {
            get {
                list<String> lLstEmail = new list<String>{ this.emailAddress };
                    list<PersonContact> lLstCttE = (this.contacts != null && this.contacts.contact != null) ? this.contacts.contact : new list<PersonContact>();
                for (PersonContact iCttE: lLstCttE) lLstEmail.add(iCttE.emailAddress);
                String lReturn;
                for (String iEmail: lLstEmail)
                {
                    if (String.isNotBlank(iEmail))
                    {
                        lReturn = iEmail;
                        break;
                    }
                }
                return lReturn;
            }
            set {
                this.emailAddress = value;
            }
        }
        global List<CustomerPhones> phones;
        // campos da consulta Prospect movel
        global String name { get; set; }
        global String typeZ;
        global String subType;
        global String segment;
        global String mobileId;
        global String mobileType;
        global String mobileSubType;
        global String mobileBan;
        global String faId;
        global String businessName;
        global String acrmCustomerId;
        global String crmCustomerId;
        global String crmCustomerSubType;
        global Documents documents;
        // campos da consulta RF
        global String personType;
        global String dateOfBirth {
            get { return (String.isBlank(this.dateOfBirth)) ? null : this.dateOfBirth.split('T')[0]; }
            set { this.dateOfBirth = value; }
        }
        global String mothersName;
        global String deceasedIndicator;
        global PersonContacts contacts;
        global PersonComplementAddresses complementAddresses;
        global String fullName {
            get {
                list<String> lLstFullName = new list<String>{ this.fullName, String.join(new String[]{ this.firstName, this.lastName }, ' ').trim(),
                    this.name };
                        String lReturn;
                for (String iName: lLstFullName)
                {
                    if (String.isBlank(iName)) continue;
                    
                    lReturn = iName;
                    break;
                }
                return lReturn;
            }
            set {
                this.fullName = value;
            }
        }
        global String documentNumberCPF {
            get {
                if (this.documents != null && String.isNotBlank(this.documents.cpf)) return this.documents.cpf;
                if (this.documents != null && String.isNotBlank(this.documents.cnpj)) return this.documents.cnpj;
                return (String.isBlank(this.documentNumberCPF)) ? this.partyIdentificationNumber : this.documentNumberCPF;
            }
            set {
                this.documentNumberCPF = value;
            }
        }
        // campos extras para uso na integracao
        global String accId;
        global Boolean receiveSMS;
        private String uf {
            get {
                PersonComplementAddress lAddr = (this.complementAddresses != null && !this.complementAddresses.complementAddress.isEmpty()) ? this.complementAddresses.complementAddress[0] : null;
                return (lAddr != null) ? lAddr.placeId : null;
            }
        }
        private String cidade {
            get {
                PersonComplementAddress lAddr = (this.complementAddresses != null && !this.complementAddresses.complementAddress.isEmpty()) ? this.complementAddresses.complementAddress[0] : null;
                return (lAddr != null) ? lAddr.cityName : null;
            }
        }
        private String endereco {
            get {
                PersonComplementAddress lAddr = (this.complementAddresses != null && !this.complementAddresses.complementAddress.isEmpty()) ? this.complementAddresses.complementAddress[0] : null;
                return (lAddr != null) ? lAddr.streetAddress : null;
            }
        }
        private String cep {
            get {
                PersonComplementAddress lAddr = (this.complementAddresses != null && !this.complementAddresses.complementAddress.isEmpty()) ? this.complementAddresses.complementAddress[0] : null;
                return (lAddr != null) ? lAddr.postalCode : null;
            }
        }
        
        // construtores
        global CustomerAccounts(){ this(null); }
        global CustomerAccounts(Account aAcc)
        {
            if (aAcc == null) return;
            this.accId = aAcc.Id;
            this.fullName = aAcc.Name;
            
            CustomerPhones lPhone = new CustomerPhones();
            if (String.isNotBlank(aAcc.Phone)) lPhone.telephoneNumber = aAcc.Phone.replaceAll('\\D', '');
            this.phones = new list<CustomerPhones>{ lPhone };
                }
        
        global Account getAccount()
        {
            Account lAcc = new Account(Name = this.fullName);
            if (String.isNotBlank(this.accId)) lAcc.Id = this.accId;
            if (String.isNotBlank(this.documentNumberCPF)) lAcc.put('DocumentNumber__c', this.documentNumberCPF);
            if (String.isNotBlank(this.companyName)) lAcc.put('CompanyName1__c', this.companyName);
            if (String.isNotBlank(this.emailAddress)) lAcc.put('Email__c', this.emailAddress);
            if (String.isNotBlank(this.uf)) lAcc.put('ShippingState', this.uf);
            if (String.isNotBlank(this.cidade)) lAcc.put('ShippingCity', this.cidade);
            if (String.isNotBlank(this.endereco)) lAcc.put('ShippingStreet', this.endereco);
            if (String.isNotBlank(this.cep)) lAcc.put('ShippingPostalCode', this.cep);
            if (this.receiveSMS != null) lAcc.put('ReceiveSMS__c', this.receiveSMS);
            if (String.isNotBlank(this.dateOfBirth)) lAcc.put('BirthDate__c', Date.valueOf(this.dateOfBirth));
            if (this.phones != null && !this.phones.isEmpty()) lAcc.put('Phone', this.phones[0].telephoneNumber);
            return lAcc;
        }
    }
    
    global class CustomerPhones
    {
        global String telephoneType;
        global String phoneLineNumber;
        global String telephoneNumber;
        global String areaCode;
        global String internacionalCode;
    }
    
    global class DadosPessoa extends ResponseGen
    {
        global CustomerAccounts data;
    }
    
    global class PersonComplementAddresses
    {
        global List<PersonComplementAddress> complementAddress;
    }
    
    global virtual class GenAddress
    {
        global String postalCode {
            set;
            get { return (String.isBlank(this.postalCode)) ? null : ('0'.repeat(8 - this.postalCode.length()) + this.postalCode); }
        }
    }
    
    global class PersonComplementAddress extends GenAddress
    {
        global String premisesId;
        global String addressIdNet; // V2		
        global String addressIdClaroTv; // V2		
        global String streetAddress;
        global String streetAddressNumber;
        global String complementAddress;
        global String neighborhood;
        global String cityName;
        global String placeId;
        global String areaCode;
        // campos da consulta de endereço VT1
        global String addressId;
        global String country;
        global String cityId;
        global String streetType;
        global String streetId;
	    global String streetIdNet; 				// V2		
        global String streetIdClaroTv; 			// V2		
        global String streetNumber; 			// V2		
        global String streetName;
        global String urbanPropertySubAddress;
		global String complementarySubAddress; 	// V2
        global String sanitized;
        global String boxNr;
        global String streetTitle;
        global String neighborhoodIdNet; 		// V2		
        global String neighborhoodIdClaroTv; 	// V2				
        global String neighborhoodId;
        global String patentTitle;
        global String preposition;
    }
    
    global class PersonContacts
    {
        global List<PersonContact> contact;
    }
    
    global class PersonContact
    {
        global CustomerPhones telephoneNumber;
        global String emailAddress;
    }
    
    global class AllSubscribers extends ResponseGen
    {
        global SubscribersData data;
    }
    
    global class SubscribersData
    {
        global List<Subscribers> subscribers;
    }
    
    global class Subscribers
    {
        global String mobileSubscriberId;
        global String name;
        global String serviceType;
        global String typeZ;
        global String subType;
        global String comboType;
        global String effectiveSinceDate;
        global String cancellationDate;
        global String status;
        global String statusDate;
        global String documentationStatus;
        global String msisdn;
        global String ticketAttendance;
        global String productFamily;
        global String omsSubscriberId;
        global String crmSubscriberId;
        global String titularId;
        global CustomerAccounts customer;
        
        global Account getAccount()
        {
            Account lAcc = (this.customer != null) ? this.customer.getAccount() : new Account();
            if (String.isBlank(lAcc.Name)) lAcc.Name = this.name;
            return lAcc;
        }
    }
    
    global class Documents
    {
        global String cpf;
        global String rg;
        global String passport;
        global String cnpj;
        global String ie;
    }
    
    global class AddressesGED extends ResponseGen
    {
        global AddressesGEDData data;
    }
    
    global class AddressesGEDData
    {
        global Integer totalListCount;
        global GEDAddresses addresses;
    }
    
    global class GEDAddresses
    {
        global List<AddressGED> address;
    }
    
	public class AddressGED {
		public String addressIdNet;
		public Object addressIdClaroTv;
		public String country;
		public String placeId;
		public String cityId;
		public String city;
		public String postalCode;
		public String neighborhood;
		public String streetType;
		public String streetIdNet;
		public Object streetIdClaroTv;
		public String streetName;
		public String streetNr;
		public String neighborhoodIdNet;
		public Object neighborhoodIdClaroTv;
		public String ibgeCode;
		public List<ComplementarySubAddress> complementarySubAddress;
	}
    
    
    global class AddressesGEDDom extends ResponseGen
    {
        global AddressesGEDDomData data;
    }
    
    global class AddressesGEDDomData
    {
        global EdificationsZ edifications;
        global List<Buldings> buldings;
    }
    
    global class EdificationsZ
    {
          global List<Edifications> edifications;
          global List<Edification> edification;
    }
    
    global class Edifications
    {
        global String edificationId;
        global String edificationIdNet; //V2	
        global String edificationIdClaroTv; //V2		
        global String description;
        global String numberOfDomicilesPreview;
        global String numberOfDomicilesRealized;
        global String numberOfInstallPreview;
        global String numberOfInstallRealized;
        global String node;
        global String edificationType;
        global String edificationTypeNet; //V2
        global String edificationTypeClaroTv; //V2		
        global String cablingType;
        global PersonComplementAddress address;
        global List<Domiciles> domiciles;
    }
	global class Edification {
		global Integer edificationIdNet;
		global Integer edificationIdClaroTv;
		global String description;
		global String buildingIdNet;
		global String buildingIdClaroTv;
		global String buildingTypeNet;
		global String buildingTypeClaroTv;
		global List<Properties> properties;
	}
	Global class Buldings {
		Global String buildingIdNet;
		Global String buildingIdClaroTv;
		Global String buildingTypeNet;
		Global String buildingTypeClaroTv;
		Global List<Properties> properties;
	}
    
 	global class Properties {
		global String idNet;
		global String idClaroTv;
		global AddressNew address;
	}
	Global class AddressNew {
		Global Integer addressIdNet;
		Global Integer addressIdClaroTv;
		Global String country;
		Global String placeId;
		Global String cityId;
		Global String city;
		Global String postalCode;
		Global String neighborhood;
		Global String streetType;
		Global String streetIdNet;
		Global String streetIdClaroTv;
		Global String streetName;
		Global String streetNr;
		Global String neighborhoodIdNet;
		Global String neighborhoodIdClaroTv;
		Global String ibgeCode;
		Global List<ComplementarySubAddress> complementarySubAddress;
	}
    global class GeographicLocation extends ResponseGen
    {
        global GeographicDomiciles data;
    }
    
    global class GeographicDomiciles
    {
        global Domiciles domicile;
    }
    
    global virtual class GeographicLocationDataGen
    {
        global String id;
        global String description;
        global String operatorCode;
        global String idNet;	
        global String idClaroTv;		
    }
    
    global class Domiciles extends GeographicLocationDataGen
    {
		public String idNet;
		public String idClaroTv;
        global String numberZ;
        global String domicileType;
        global String node;
        global String noteDomicile;		
        global String tvPointsAmount;
        global String roomsAmount;
        global String installationsAmount;
        global String requestSituation;
	    global String nodeCharacteristic;		
        global String requestSituationDate;
        global List<Availability> availability;
        global List<Locations> locations;
    }
    
    global class Availability
    {
        global String technicalSituation;
        global String commercialSituation;
        global String technicalSituationNote;
        global String commercialSituationNote;
        global BusinessLine businessLine;
    }
    
    global class Locations
    {
        global String id;
        global String situation;
        global String operator;
        global String commonArea;
        global String typeId;
        global String typeZ;
        global List<Equipment> equipment;
        global Manufacturer technology;
    }
    
    global class Equipment
    {
        global String id;
        global String serialNumber;
        global String mainAddressable;
        global String ownerType;
        global String stateId;
        global String stateDescription;
        global String typeId;
        global String typeDescription;
        global Manufacturer manufacturer;
        global Model model;
        global Location location;
    }
    
    global class Manufacturer extends GeographicLocationDataGen {}
    
    global class Model extends GeographicLocationDataGen
    {
        global String technologyId;
        global String technologyDescription;
    }
    
    global class BusinessLine extends GeographicLocationDataGen
    {
        global String technicalSituationNote;
        global String commercialSituationNote;
        global BusinessLineFeatures businessLineFeatures;
    }
    
    global class BusinessLineFeatures extends GeographicLocationDataGen 	    
	{		
        global String description;		
    }
    
    global class Location extends GeographicLocationDataGen
    {
        global String code;
        global String typeId;
        global String typeDescription;
        global ContractIdentification contractIdentification;
    }
    
    global class ContractIdentification
    {
        global String contractNumber;
        global String operatorCode;
        global String cityId;
    }
    
    global class CredAnalysisReq extends ResponseGen
    {
        global CredAnalysisData data;
    }
    
    global class CredAnalysisData
    {
        global String operatorCode;
        global List<CredAnalysisItens> itens;
    }
    
    global class CredAnalysisItens
    {
        global CredAnalysisItem item;
    }
    
    global class CredAnalysisItem
    {
        global String fieldId;
        global String fieldName;
        global String value;
        global String key;
    }
    
    global class CredAnalisysMobileReq extends ResponseGen
    {
        global CredAnalisysMobileData data;
    }
    
    global class CredAnalisysMobileData
    {
        global String type;
        global String operation;
        global Aplication aplication;
        global CredOrder order;
        global RelatedAssessment relatedAssessment;
    }
    
    global class RelatedAssessment
    {
        global String Id;
        global String type;
    }
    
    global class Aplication
    {
        global string id;
        global String type;
        global SalesUser user;
    }
    
    global class CredOrder
    {
        global Client client;
        global SalesUser pointSale;
        global Seller seller;
    }
    
    global class Client
    {
        global String typePerson;
        global String name;
        global String dateOfBirth;
        global String motherName;
        global String gender;
        global String documentNumberCPF;
        global CredAddress address;
    }
    
    global class CredAddress extends GenAddress {}
    
    global class Seller
    {
        global String id;
        global SalesAgent salesAgent;
    }
    
    global class SalesAgent
    {
        global String id;
        global Channel channel;
    }
    
    global class Channel
    {
        global String id;
        global SalesUser regional;
    }
    
    global class SalesUser
    {
        global String id;
    }
    
    global class CredAnalysisResp extends ResponseGen
    {
        global CredAnalysisRespData data;
        
        global CredAnalysisResp() {}
        global CredAnalysisResp(CredAnalisysMobileResp aCredMobile)
        {
            if (aCredMobile == null) return;
            
            this.apiVersion = aCredMobile.apiVersion;
            this.transactionId = aCredMobile.transactionId;
            if (aCredMobile.error != null) this.error = aCredMobile.error;
            if (aCredMobile.data == null) return;
            CredAnalysisRespData lCaData = new CredAnalysisRespData();
            lCaData.creditSituation = new CreditSituation(aCredMobile.data);
            this.data = lCaData;
            this.formatMsg(true);
        }
        
        global void formatMsg(Boolean aMovel)
        {
            if (this.data == null || this.data.creditSituation == null || this.data.creditSituation.messages == null) return;
            for (CreditMessage iCM: this.data.creditSituation.messages)
            {
                if (String.isNotBlank(iCM.note)) iCM.note = iCM.note.replace('APROVADO', 'PRE-APROVADO');
            }
            if (!aMovel) return;
            CreditMessage lCM = new CreditMessage();
            lCM.identifier = '0';
            lCM.note = (String.isNotBlank(this.data.creditSituation.status) && this.data.creditSituation.status.toUpperCase().startsWith('APROV')) ? 'PRÉ-APROVADO' : 'REPROVADO';
            lCM.note += String.join(new String[]{' - Limite: ', this.data.creditSituation.creditLimit }, '');
            this.data.creditSituation.messages = new list<CreditMessage>{ lCM };
                }
        global void formatMsg()
        {
            this.formatMsg(false);
        }
    }
    
    global class CredAnalysisRespData
    {
        global CreditSituation creditSituation;
    }
    
    global class CreditSituation
    {
        global String status;
        global String resultDate;
        global String policy;
        global String reportZ;
        global String typeDecision;
        global String creditLimit;
        global String dataPolicy;
        global list<CreditMessage> messages;
        
        global CreditSituation() {}
        global CreditSituation(CredAnalisysMobileRespData aCredMobile)
        {
            if (aCredMobile == null) return;
            CreditMessage lMsg = new CreditMessage();
            lMsg.note = aCredMobile.reasonResultDescription;
            this.status = aCredMobile.result;
            this.resultDate = aCredMobile.resultDate;
            this.creditLimit = aCredMobile.creditLimit;
            this.messages = new list<CreditMessage>{ lMsg };
                }
    }
    
    global class CreditMessage
    {
        global String identifier;
        global String note;
    }
    
    global class CredAnalisysMobileResp extends ResponseGen
    {
        global CredAnalisysMobileRespData data;
    }
    global class CredAnalisysMobileRespData
    {
        global String resultDate;
        global String creditLimit;
        global String result;
        global String reasonResult;
        global String reasonResultDescription;
    }
    /* funcoes auxiliares */
    
    global static Error mockError(Integer aHttpCode)
    {
        CEC_RestObjects.Link lErrorLink = new CEC_RestObjects.Link();
        lErrorLink.rel = '';
        lErrorLink.href = '';
        
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = String.valueOf(aHttpCode);
        lError.errorCode = String.valueOf(aHttpCode);
        lError.message = 'Unauthorized';
        lError.detailedMessage = 'Unauthorized';
        lError.link = lErrorLink;
        
        return lError;
    }
    
    global static map<String, String> splitQueryParams(URL aURL)
    {
        String lQueryVars = aURL.getQuery();
        map<String, String> lMapArgs = new map<String, String>();
        list<String> lLstParam = (String.isBlank(lQueryVars)) ? new list<String>() : lQueryVars.split('&');
        for (String iPar: lLstParam)
        {
            list<String> lLstVal = iPar.split('=');
            if (lLstVal.size() >= 2) lMapArgs.put(lLstVal[0], lLstVal[1]);
        }
        return lMapArgs;
    }
    
    global class PromotionBenefitsMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataPromotionBenefits data;            
    }
    
    global class Promotion {
        @AuraEnabled public List<Qualification> qualifications;
        @AuraEnabled public List<Benefit> benefitsReceived;
    }
    
    global class DataPromotionBenefits {
        @AuraEnabled public Promotion promotion;
    }    
    
    global class Qualification {
        @AuraEnabled public Integer qualificationId;
        @AuraEnabled public String qualificationDescription;
        @AuraEnabled public Integer qualificationTypeId;
        @AuraEnabled public String qualificationTypeDescription;
        @AuraEnabled public String unitMeasure;
    }
    
    global class Benefit {
        @AuraEnabled public Integer benefitIdNGP;
        @AuraEnabled public String benefitDescription;
        @AuraEnabled public String benefitValue;
        @AuraEnabled public String unitMeasure;
        @AuraEnabled public String minimumLimit;
        @AuraEnabled public String maximumLimit;
        @AuraEnabled public Date concessionEndDate;
        @AuraEnabled public Integer concessionInterval;
        @AuraEnabled public Integer numberInstallments;
        @AuraEnabled public Integer waitingPeriod;
        @AuraEnabled public String indicatorBalanceTransfer;
        @AuraEnabled public Integer expirationDays;
        @AuraEnabled public Decimal multiplyingFactor;
        @AuraEnabled public Decimal percentageDiscount;
        @AuraEnabled public String qualifyingGroup;
    }
    
    global class PromotionsMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataPromotion data;
    }
    
    global class Promotions {
        @AuraEnabled public Integer promotionIdNGP;
        @AuraEnabled public Integer promotionVersionNGP;
        @AuraEnabled public Integer sequentialIdNGP;
        @AuraEnabled public String promotionName;
        @AuraEnabled public String promotionDescription;
        @AuraEnabled public Double valueAccession;
        @AuraEnabled public Integer numberInstallments;
        @AuraEnabled public String effectiveDate;
        @AuraEnabled public String expirationDate;
        @AuraEnabled public String channelName;
        @AuraEnabled public String statusContractedPromotion;
    }
    //<--Histórico de Promoções -->
    
    public class promotionsHistoryResponse{
        public String apiVersion;
        public String transactionId;
        public DataPromo data;
    }
    
    public class PromotionsCategoryType {
        @AuraEnabled public Categories categories;
    }
    
    public class Categories {
		 @AuraEnabled public String promotionCategoryId;
		 @AuraEnabled public String promotionCategoryName;
	}
    
    public class PromotionsHistory {
        @AuraEnabled public String promotionId;
        @AuraEnabled public String promotionName;
        @AuraEnabled public String promotionDesc;
        @AuraEnabled public String ngpPromotionId;
        @AuraEnabled public String ngpPromotionVersion;
        @AuraEnabled public String ngpSequentialId;
        @AuraEnabled public String valueAccession;
        @AuraEnabled public String effectiveDate;
        @AuraEnabled public String effectiveEndDate;
        @AuraEnabled public String promotionAcessionChanelId;
        @AuraEnabled public String promotionAcessionChanelName;
        @AuraEnabled public String promotionStatusHired;
        @AuraEnabled public PromotionsCategoryType promotionsCategoryType;
        @AuraEnabled public String categoryName;
    }
    
    public class DataPromo {
        public List<PromotionsHistory> promotionsHistory;
    }
    
    
    //<---Device Start -->
    
    public class subscriberLastDeviceResponse{
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public dataDevice data;
    }
    
    public class dataDevice {
        @AuraEnabled public Device device;
    }
    
    public class Device {
        @AuraEnabled  public String phoneLineNumber;
        @AuraEnabled  public String iccid;
        @AuraEnabled  public String imei;
        @AuraEnabled  public String modelName;
        @AuraEnabled  public String modelTechnology;
        @AuraEnabled  public List<Frequencies> frequencies;
        @AuraEnabled  public Object manufacturerCode;
        @AuraEnabled  public String manufacturerName;
        @AuraEnabled  public String deviceStatus;
        @AuraEnabled  public String deviceStatusDate;
        @AuraEnabled  public String deviceStatusReason;
        @AuraEnabled  public String serviceOperator;
        @AuraEnabled  public String deviceSoldByClaro;
        @AuraEnabled  public String directSale;
        @AuraEnabled public String frequencymodelGenerationTechnology;
    }
    
    global class Frequencies {
        @AuraEnabled public String modelGenerationTechnology;
        @AuraEnabled public String modelFrequencyGenerationTechnology;
    }
    
    // <-- End  Device -->
    
    global class DataPromotion {
        @AuraEnabled public List<Promotions> promotions;
    }
    
    //<-- Transactions Start -->
    
    global class Transactions {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataTransaction data;
    }
    
    global class Events {
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public String eventId;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String eventCategoryDescription;
        @AuraEnabled public String eventSubCategoryDescription;
        @AuraEnabled public String eventDescription;
        @AuraEnabled public String telephoneNumberOrigin;
        @AuraEnabled public String telephoneNumberDestiny;
        @AuraEnabled public String eventDuration;
        @AuraEnabled public String eventAmount;
        @AuraEnabled public String balancePrincipalBefore;
        @AuraEnabled public String balancePrincipalAfter;
        @AuraEnabled public String areaOrigin;
        @AuraEnabled public String areaDestiny;
        @AuraEnabled public List<PromotionalBalanceTransaction> usagePromotionalBalances;
    }
    
    global class PromotionalBalanceTransaction {
        @AuraEnabled public String descriptionbalancePromotional;
        @AuraEnabled public String balancePromotionalBefore;
        @AuraEnabled public String balancePromotionalAfter;
    }
    
    global class DataTransaction {
        @AuraEnabled public List<Events> events;
    }
    
    //<-- Transactions End -->
    
    //<-- Balances Start -->
    public class BalancesMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataBalance data;
    }
    
    public class PromotionalBalances {
        @AuraEnabled public String platformIdentification;
        @AuraEnabled public String platformDescription;
        @AuraEnabled public String description;
        @AuraEnabled public String categoryIdentification;
        @AuraEnabled public String categoryDescription;
        @AuraEnabled public String internalUseIndicator;
        @AuraEnabled public String balance;
        @AuraEnabled public String measurementUnit;
        @AuraEnabled public String dateEndValidity;
    }
    
    public class Accumulators {
        @AuraEnabled public String accumulatorPlatformIdentification;
        @AuraEnabled public String accumulatorPlatformDescription;
        @AuraEnabled public String accumulatorBusinessDescription;
        @AuraEnabled public String accumulatorCategoryIdentification;
        @AuraEnabled public String accumulatorCategoryDescription;
        @AuraEnabled public String accumulatorInternalUseIndicator;
        @AuraEnabled public String accumulatorBalance;
        @AuraEnabled public DateTime accumulatorDateStartValidity;
        @AuraEnabled public DateTime accumulatorDateEndValidity;
        @AuraEnabled public String accumulatorMeasurementUnit;
        @AuraEnabled public String accumulatorDateAux;
    }
    
    public class Balances {
        @AuraEnabled public String datePlatformActivation;
        @AuraEnabled public String platformSituation;
        @AuraEnabled public String principalBalanceAmount;
        @AuraEnabled public String principalExpirationDateCredit;
        @AuraEnabled public String principalDateBlockingCalls;
        @AuraEnabled public String principalDateExpirationBalance;
        @AuraEnabled public String principalDateExpirationService;
        @AuraEnabled public String principalDateExpirationPhone;
        @AuraEnabled public String phoneLineNumber;
        @AuraEnabled public PricePlan pricePlan;
        @AuraEnabled public List<Accumulators> accumulators;
        @AuraEnabled public List<PromotionalBalances> promotionalBalances;
    }
    
    public class DataBalance {
        @AuraEnabled public Balances balances;
    }
    
    public class PricePlan {
        @AuraEnabled public String pricePlanIdentification;
        @AuraEnabled public String pricePlanName;
        @AuraEnabled public String pricePlanSituation;
        @AuraEnabled public String pricePlanDateExpirationBenefit;
    }
    //<-- Balances End -->
    
    //<-- Invoices Start -->
    public class InvoiceMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataInvoice data;
    }
    
    public class DataInvoice {
        @AuraEnabled public List<Invoice> invoices;
        @AuraEnabled public InvoicePDF invoicePDF;
        @AuraEnabled public invoiceRetrive retrieveZ;
    }
    
    public class InvoicePDF {
        @AuraEnabled public String invoiceURL;
    }
    
    public class invoiceRetrive {
        @AuraEnabled	public String content {get;set;} 
        @AuraEnabled	public String name {get;set;} 
        @AuraEnabled	public String notificationId {get;set;} 
        @AuraEnabled	public String status {get;set;} 
        @AuraEnabled	public String message {get;set;} 
    }
    global class Invoice {
        @AuraEnabled public String referenceMonth;
        @AuraEnabled public String referenceYear;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String issuanceDate;
        @AuraEnabled public String documentNumber;
        @AuraEnabled public String noteFiscalNumber;
        @AuraEnabled public String dueDate;
        @AuraEnabled public String indicatorInvoiceNotPaid;
        @AuraEnabled public String indicatorSuspensionCauses;
        @AuraEnabled public Decimal invoiceAmount;
        @AuraEnabled public Decimal amountPaymentMade;
        @AuraEnabled public Decimal amountAdjustmentMade;
        @AuraEnabled public Decimal amountPreviousBalance;
        @AuraEnabled public Decimal amountAfterBalance;
        @AuraEnabled public Decimal amountPrincipal;
        @AuraEnabled public Decimal amountPrincipalPaymentMade;
        @AuraEnabled public String invoiceId;
        @AuraEnabled public String statusInvoiceId;
        @AuraEnabled public String statusInvoiceDescription;
        @AuraEnabled public String paymentForm;
        @AuraEnabled public String dueDate_aux;
        @AuraEnabled public String invoiceAmount_aux;
    }
    
    //<-- Invoices End -->
    
    //<---Protocolos -->
    
    global class Protocols {
        @AuraEnabled public  String apiVersion;
        @AuraEnabled public  String transactionId;
        @AuraEnabled public  DataProtocols data;
        
    }
    
    global class dataProtocols{
        public List<attendences> attendances;
    }
    
    global class attendences{
        @AuraEnabled public string order;
        @AuraEnabled public string protocolNumber;
        @AuraEnabled public string interactionNumber; 
        @AuraEnabled public string action;
        @AuraEnabled public string solicitationType;
        @AuraEnabled public string solicitationDateOpening;
        @AuraEnabled public string solicitationDateClosing;
        @AuraEnabled public string solicitationStatus;
        @AuraEnabled public string channelRequestId;
        @AuraEnabled public string contactName;
        @AuraEnabled public String situation;
        @AuraEnabled public String reasonCode1;
        @AuraEnabled public String reasonCode2;
        @AuraEnabled public String reasonCode3;
        @AuraEnabled public String reasonCode4;
        @AuraEnabled public String description;
        @AuraEnabled public String slaIndicatorExceeded;
        @AuraEnabled public String reclassificationIndicator;
        @AuraEnabled public String synthesisRanking;
        @AuraEnabled public String interactionSequenceId;
    }
    
    //<--Protocolos End -->
    
    //<-- Subscriber Products -->
    
    public class SubscriberProductsMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataSubscriberProducts data;
    }
    
    public class Usage {
        @AuraEnabled public String unit;
        @AuraEnabled public String amountUsed;
        @AuraEnabled public String exceededAmount;
    }
    
    public class SubscriberProducts {
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public String productType;
        @AuraEnabled public String operatorCode;
        @AuraEnabled public String pricing;
        @AuraEnabled public String pricingWithPromotion;
        @AuraEnabled public String promotionDuration;
        @AuraEnabled public String promotionCode;
        @AuraEnabled public String technologyId;
        @AuraEnabled public String speed;
        @AuraEnabled public Integer lastInvoicePrice;
        @AuraEnabled public List<Usage> usage;
        @AuraEnabled public Boolean isFromAccountHolder;
    }
    
    public class DataSubscriberProducts {
        @AuraEnabled public List<SubscriberProducts> subscriberProducts;
    }
    
    //<-- Subscriber End -->
    
    //<-- Agregadores Start -->
    
    public class SubscriberVasMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataSubscriberVas data;
    }
    
     public class SubscriberVasResponse {
        @AuraEnabled public String serviceName;
        @AuraEnabled public String serviceAggregatorName;
        @AuraEnabled public List<Aggregators> aggregators;
        @AuraEnabled public String aggregatorName;
        @AuraEnabled public String msisdn;
        @AuraEnabled public String serviceTypeId;
        @AuraEnabled public String serviceType;
        @AuraEnabled public String entityTypeId;
        @AuraEnabled public String typeNameService;
        @AuraEnabled public String status;
        @AuraEnabled public String statusDate;
        @AuraEnabled public String statusReasonId;
        @AuraEnabled public String statusReasonDescription;
        @AuraEnabled public String effectiveDate;
        @AuraEnabled public String expirationDate;
        @AuraEnabled public String amount;
        @AuraEnabled public String value;
        @AuraEnabled public String amountType;
        @AuraEnabled public String confirmationDate;
        @AuraEnabled public String confirmationCode;
        @AuraEnabled public String cancellationDate;
        @AuraEnabled public String cancellationCode;
        @AuraEnabled public String lastRateDate;
        @AuraEnabled public String requestTypeId;
        @AuraEnabled public String descRequestType;
        @AuraEnabled public String statusReasonDesc;
        @AuraEnabled public String dateConfirm;
        @AuraEnabled public String confirmCode;
        @AuraEnabled public String cancelCode;
        @AuraEnabled public String lastDateRate;
        @AuraEnabled public String rateCode;
        @AuraEnabled public String id;
        @AuraEnabled public String requestDescription;
        @AuraEnabled public String solicitationSource;
        @AuraEnabled public String solicitationDate;
        @AuraEnabled public String solicitationText;
        @AuraEnabled public String urlConfirmation;
        @AuraEnabled public List<Features> features;
        @AuraEnabled public String aggregatorDateRequest;
        @AuraEnabled public String amountRegisters;
        @AuraEnabled public List<Parameters> parameters;
        @AuraEnabled public String totalRecords;
    }
    
    
    public class Parameters {
        @AuraEnabled public String parameterId;
        @AuraEnabled public String parameterValue;
    }
    
    
    public class Aggregators {
        @AuraEnabled public String name;
    }
    
    public class Features {
        @AuraEnabled public String featuresId;
        @AuraEnabled public String valueFeatures;
    }
    
    public class DataSubscriberVas {
        @AuraEnabled public List<SubscriberVasResponse> subscribersVas;
        @AuraEnabled public String totalRecords;
    }
    
    //<-- Agregadores End -->
    
    //<--Alert Start -->
    public class AlertsMain {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataAlert data;
    }
    
    public class Alert {
        @AuraEnabled public String alert_id;
        @AuraEnabled public String classification_alertaid;
        @AuraEnabled public String notes;
        @AuraEnabled public String value;
    }
    
    public class DataAlert {
        @AuraEnabled public List<Alert> alerts;
    }
    //<--Alert End -->
    //<--Memorandos -->
    
    public class memosMain {
        String apiVersion;
        String transactionId;
        @AuraEnabled public dataMemo data;
    }
    
    public class dataMemo{
        @AuraEnabled public List<memos> memoObj;
    }
    
    public class memos {
        @auraEnabled    public String mobileMemoId;
        @auraEnabled	public String mobileBan;
        @auraEnabled	public String msisdn;
        @auraEnabled	public String subscriberMobileId;
        @auraEnabled	public String mobileClientId;
        @auraEnabled	public String memoType;
        @auraEnabled	public String memoLevel;
        @auraEnabled	public String memoCategoryId;
        @auraEnabled	public String memoCategoryDesc;
        @auraEnabled	public String memoGenerationForm;
        @auraEnabled	public String memoDate;
        @auraEnabled	public String memoUserId;
        @auraEnabled	public String memoText;
    }
    
    //<--Consents Start -->
    public class GetConsents {
        @AuraEnabled public String preferenceCenterId;
        @AuraEnabled public String protocolNumber;
        @AuraEnabled public ConsentError error;
        @AuraEnabled public List<Purpose> purposes;
    }
    
    public class PutConsents {
        @AuraEnabled public String transactionId;
        @AuraEnabled public String consentCreationDate;
        @AuraEnabled public String origin;
        @AuraEnabled public ConsentError error;
        @AuraEnabled public List<Consent> agreements;
    }

    public class Purpose{
        @AuraEnabled public String  id;
        @AuraEnabled public String  status;
        @AuraEnabled public List<Consent> agreements;
    }
    
    public class Consent {
        @AuraEnabled public String  id;
        @AuraEnabled public String  title;
        @AuraEnabled public String  name;
        @AuraEnabled public String  description;
        @AuraEnabled public Boolean checked;
        @AuraEnabled public List<Option> options;
    }
    
    public class Option {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean checked;
    }
    
    public class ConsentError{
        @AuraEnabled public String httpCode;
        @AuraEnabled public String errorCode;
        @AuraEnabled public String message;
        @AuraEnabled public String detailedMessage;
        //@AuraEnabled public Link link;
    }
    //<--Consents End -->
    
    //<--DSAR Start -->
    public class GetDsarByStatus {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public List<DataGetDsarByStatus> customerOrders;
        @AuraEnabled public DsarError error;
    }
    
    public class PostDsar {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataPostDsar data;
        @AuraEnabled public DsarError error;
    }
    
    public class DataGetDsarByStatus {
        @AuraEnabled public String  id;
        @AuraEnabled public String  orderDate;
        @AuraEnabled public String  completionDate;
        @AuraEnabled public String  orderType;
        @AuraEnabled public String  status;
    }
    
    public class DataPostDsar {
        @AuraEnabled public String  requestQueueRefId;
        @AuraEnabled public String  status;
        //@AuraEnabled public List<String> requestTypes;
        //@AuraEnabled public List<String> subjectTypes;
    }
    
    public class DsarError{
        @AuraEnabled public String httpCode;
        @AuraEnabled public String errorCode;
        @AuraEnabled public String message;
        @AuraEnabled public String detailedMessage;
    }
    //<--DSAR End -->
    
    /* funcoes auxiliares */
    
    global static Error mockError() {
        CEC_RestObjects.Link lErrorLink = new CEC_RestObjects.Link();
        lErrorLink.rel = '';
        lErrorLink.href = '';
        
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = '401';
        lError.errorCode = '401';
        lError.message = 'Unauthorized';
        lError.detailedMessage = 'Unauthorized';
        lError.link = lErrorLink;
        
        return lError;
    }    
    //SalesMan 
    global class SalesMan extends ResponseGen{
        global SalesManData data {get;set;}         
    }    
    global class SalesManData {
        global Salesmen salesman {get;set;}    
    }
    global class Salesmen {
        global String id {get;set;} 
        global String name {get;set;} 
        global String registration {get;set;} 
        global String situation {get;set;} 
        global String situationDate {get;set;} 
        global Partyidentification partyidentification {get;set;} 
        global List<ContactSalesMan> contact {get;set;} 
        global SalesManAgent salesAgent {get;set;} 
        global List<MarketArea> marketArea {get;set;} 
        global UserSalesMan user {get;set;}    
    }
    global class Partyidentification {
        global String type {get;set;} // in json: type
        global String numberZ {get;set;} // in json: number
    }
    global class ContactSalesMan {
        global String emailAddress {get;set;} 
        global String telephoneNumbertype {get;set;} 
        global String telephoneNumber {get;set;} 
    }
    global class SalesManAgent {
        global String iwSalesAgentId {get;set;} 
        global String iwTypeId {get;set;} 
        global String description {get;set;} 
        global String channelId {get;set;} 
        global String businessName {get;set;} 
        global String regionalId {get;set;} 
        global String iwRegionalId {get;set;} 
        global Address address {get;set;} 
        global List<PointSale> pointSale {get;set;}    
    }    
    global class Address {
        global String type {get;set;}
        global String placeId {get;set;} 
        global String city {get;set;} 
        global String postalCode {get;set;} 
        global String neighborhood {get;set;} 
        global String streetType {get;set;} 
        global String streetName {get;set;} 
        global String streetNumber {get;set;} 
        global String urbanPropertySubAddress {get;set;} 
        global String boxNr {get;set;}    
    }
    global class UserSalesMan {
        global String userId {get;set;} 
        global String roleId {get;set;} 
        global String description {get;set;} 
        global List<Profiles> profiles {get;set;}    
    }
    global class PointSale {
        global String iwSalesAgentId {get;set;} 
        global String businessName {get;set;} 
    }
    global class MarketArea {
        global Market market {get;set;} 
    }
    global class Market {
        global List<Numeration> numeration {get;set;} 
        
    }
    global class Numeration {
        global String ddd {get;set;} 
    }
    global class Profiles {
        global String profileId {get;set;} 
        global String name {get;set;} 
    }
    
    //Salesman Residential
    global class SalesManRes extends ResponseGen
    {
        global ResData data {get;set;}         
    }
    
    public class ResData 
    {
        public SalesmanResidential salesman;
        public List<Company> company {get;set;} 
    }
    global class SalesmanResidential 
    {
        global String id {get;set;} 
        global String login {get;set;}  
        global String name {get;set;}  
        global Partyidentification partyidentification {get;set;} 
    }
    global class Company 
    {
        global String id {get;set;} 
        global String corporateName {get;set;} 
        global List<SalesChannel> salesChannel {get;set;} 
    }  
    global class SalesChannel 
    {
        global String id {get;set;} 
        global String description {get;set;} 
        global List<SalesTeam> salesTeam {get;set;} 
    }
    global class SalesTeam 
    {
        global String id {get;set;} 
        global String description {get;set;} 
    }
    
    //Integration HistoryProposal
    
    global class HistoryHeader extends ResponseGen
    {
        global Data data;
    }
    public class Data 
    {
        public HistoryProposal historyProposal;
    }
    public class HistoryProposal 
    {
        public List<HistoryChangesStatusProposal> historyChangesStatusProposal;
        public List<HistoryChangesSalesman> historyChangesSalesman;
        public List<HistoryChangesAddress> historyChangesAddress;
        public List<HistoryProtocol> historyProtocol;
    }
    
    public class HistoryChangesStatusProposal
    {
        public String idProposal;
        public String userName;
        public String salesman;
        public String status;
        public String changeDate;
        public String changeTime;
        public String description;
        public String userNewProposal;
    }
    
    public class HistoryChangesSalesman
    {
        public String userName;
        public String login;
        public String salesmanOldProposal;
        public String salesmanNew;
        public String changeDate;
        public String changeTime;
    }
    
    public class HistoryChangesAddress 
    {
        public String idProposal;
        public String userName;
        public String login;
        public String salesman;
        public String changeDate;
        public String changeTime;
        public String description;
    }
    
    public class HistoryProtocol 
    {
        public String protocolNumber;
        public String dateTimeZ;
    }
    
    //Integration Domicile History
    
    global class DomicileHeader extends ResponseGen
    {
        global DomData data;  
    }
    
    global class DomData
    {
        global List<DomicileHistory> domicileHistory {get;set;}  
    }
    global class DomicileHistory 
    {
        public String city {get;set;} 
        public String id {get;set;} 
        public String type_Z {get;set;} // in json: type
        public String status {get;set;} 
        public String name {get;set;} 
        public String telephoneNumber {get;set;} 
        public String installationAddress {get;set;} 
        public String partyIdentificationType {get;set;} 
        public String partyIdentificationNumber {get;set;} 
    }
    
    /* Proposal Request */
    global class ProposalRequest {
        global Prospect prospect {get;set;} 
        global Charge charge {get;set;} 
        global Scheduling scheduling {get;set;} 
        global Offer offer {get;set;} 
        global ProposalAddress address {get;set;} 
        global Discount discount; 
        global Adhesion adhesion; 
        global Hp hp {get;set;} 
        global ProposalAddress billingAddress {get;set;} 
        global String seller {get;set;} 
    }
    global class Products {
		global Internet internet {get;set;} 
		global Internet paytv {get;set;} 
		global Internet phone {get;set;} 
		global Internet mobile {get;set;} 
		global Internet alacarte {get;set;} 
	}
	
	global class Discount {
		global String validity {get;set;} 
	}
	
	global class ProposalAddress {
		global String neighborhood {get;set;} 
		global Integer postalCode {get;set;} 
		global String street {get;set;} 
		global String complements {get;set;} 
		global Integer number_Z {get;set;} // in json: number
	}
    global class Prospect {
        global String name {get;set;} 
        global Birthday birthday {get;set;} 
        global Long cpf {get;set;} 
        global Integer rg {get;set;} 
        global Integer mobileAreaCode {get;set;} 
        global Integer mobileNumber {get;set;} 
        global Integer phoneAreaCode {get;set;} 
        global Integer phoneNumber {get;set;} 
        global String email {get;set;} 
        global String motherName {get;set;} 
        global Integer gender {get;set;} 
        global Integer maritalStatus {get;set;} 
    }
    
    global class Charge {
        global String type_Z {get;set;} 
        global String invoiceShippingEmail {get;set;} 
        global Integer invoiceDay {get;set;} 
        global BankAccount bankAccount {get;set;}     
    }  

	global class Hp {
		global Integer id {get;set;} 
	}
	
	global class Birthday {

	}
    global class BankAccount {
        global Integer bank {get;set;} 
        global String agency {get;set;} 
        global Integer account {get;set;} 
        global Integer digit {get;set;} 
    }  
    
 	global class Scheduling {
    	global String proposalDate {get;set;} 
		global String date_Z {get;set;} // in json: date 
		global String alternativeDate {get;set;}
	}
    
    global class Adhesion {
		global Integer price {get;set;} 
		global Integer period {get;set;} 
	}
	
	
	global class Characteristics {
		global String name {get;set;} 
		global String value {get;set;} 
	}
	
    global class Offer {
        global String type_Z {get;set;} 
        global Products products {get;set;} 
    }  
    
    
    global class Product {
        global String name {get;set;} 
        global Double price {get;set;} 
        global Discount discount {get;set;} 
        global Adhesion adhesion {get;set;} 
        global Additional additional {get;set;} 
        global List<Characteristics> characteristics {get;set;} 
    }
    
    global class Additional {
        global List<Object> internet {get;set;} 
        global List<Object> paytv {get;set;} 
        global List<Object> phone {get;set;} 
        global List<Object> mobile {get;set;} 
        global List<Object> alacarte {get;set;} 
    }     
	
	global class Internet {
		global String name {get;set;} 
		global Double price {get;set;} 
		global Discount discount {get;set;} 
		global Adhesion adhesion {get;set;} 
		global Additional additional {get;set;} 
		global List<Characteristics> characteristics {get;set;} 
	}  

    
    /* Proposal Resp */
    global class ProposalResp extends ResponseGen {
        global String requestId;
        global PropRespDetails proposal;
        global Contract contract;
    }
    
    global class PropRespDetails {
        global Integer id;
        global String created;
        global String scheduled;
        global String status;
        global List<String> telephones;        
        global List<Pendencies> pendencies;
    } 
    
    global class Pendencies {
        global Integer id;
        global String title;
    } 
    
    global class Contract {
        global Integer id;
        global Integer customerId;
    } 
    
    /* ProposalError */
    global class ProposalError {
        global String message;
        global ProposalErrorValues values;
    }
    
    global class ProposalErrorValues {
        global String additionalProp1;
        global String additionalProp2;
        global String additionalProp3;
    }
    
    // GetCity Service
    
    global class AddressesHeader extends ResponseGen
    {
        global AddressData data;
    }
    
    global class Addresses 
    {
        global String addressType {get;set;} 
        global String prefix {get;set;} 
        global String logradouro {get;set;} 
        global Integer numberZ {get;set;}
        global String addressComplement {get;set;} 
        global String neighborhood {get;set;} 
        global Integer mailbox {get;set;} 
        global String city {get;set;} 
        global String state {get;set;} 
        global Integer zipCode {get;set;} 
        global Integer ibgeCityId {get;set;} 
        global Integer IbgeUfId {get;set;} 
        global Integer ddd {get;set;} 
        global String ruralAreaIndicator {get;set;} 
    }
    
    global class AddressData 
    {
        global List<Addresses> address {get;set;} 
        global Integer pageSize {get;set;} 
        global Integer pageNumber {get;set;} 
        global Integer totalCount {get;set;} 
    }
    
    //--Assinantes--//
    
    global class mobileSubscribersHistory{
        public String apiVersion;
        public String transactionId;
        public dataSubscriber data;
    }
    
    global class dataSubscriber {
        public List<mobileSubscribers> subscribers;
    }
    
    public class mobileSubscribers {
        public String mobileSubscriberId {get;set;} 
        public String name {get;set;} 
        public String serviceType {get;set;} 
        public String type_Z {get;set;}
        public String type {get;set;}  
        public String subType {get;set;} 
        public String comboType {get;set;} 
        public String effectiveSinceDate {get;set;} 
        public String cancellationDate {get;set;} 
        public String status {get;set;} 
        public String statusDate {get;set;} 
        public String documentationStatus {get;set;} 
        public String msisdn {get;set;} 
        public String ticketAttendance {get;set;} 
        public String productFamily {get;set;} 
        public mobileCustomer customer {get;set;} 
        public String omsSubscriberId {get;set;} 
        public String crmSubscriberId {get;set;} 
        public String titularId {get;set;} 
    }
    
    public class mobileCustomer {
        public String name {get;set;} 
        public String personType {get;set;} 
        public String type_Z {get;set;} // in json: type
        public String subType {get;set;} 
        public String segment {get;set;} 
        public String mobileId {get;set;} 
        public String mobileType {get;set;} 
        public String mobileSubType {get;set;} 
        public String mobileBan {get;set;} 
        public String faId {get;set;} 
        public String companyName {get;set;} 
        public String businessName {get;set;} 
        public mobileDocuments documents {get;set;} 
        public String acrmCustomerId {get;set;} 
        public String crmCustomerId {get;set;} 
        public String crmCustomerSubType {get;set;} 
    }
    
    public class mobileDocuments {
        public String cpf {get;set;} 
        public String rg {get;set;} 
        public String passport {get;set;} 
        public String cnpj {get;set;} 
        public String ie {get;set;} 
    }
    
    //--Fim dos assinantes --//

    // Create HP
    global class createHP extends ResponseGen{
        global DataHP data;
    }
    global class DataHP {
		global String operatorCode;
		global String user;
		global String neighborhoodId;
		global String streetNr;
        global String streetId;
		global String cityId;
		global String buildingType;
        global String buildingId;
		global String propertyId;
		global List<ComplementarySubAddress> complementarySubAddress;
	}
    global class ComplementarySubAddress {
		global String name;
		global String description;
    }   
    
    // Create HP Analysis
    global class CreateHPAnalysis extends ResponseGen {
        global DataHPAnalysis data;
    }
    global class DataHPAnalysis {
		global String buildingId;
		global String proposalId;
        global DataHPAnalysisProperties properties;
        global DataHPAnalysisClient client;
        global DataHPAnalysisSalesman salesman;
	}
    global class DataHPAnalysisProperties {
		global String id;
		global PropertiesAddress address;
    } 
    global class DataHPAnalysisClient {
		global String name;
		global ClientContact contact;
    } 
    global class DataHPAnalysisSalesman {
		global String name;
		global String login;
		global List<SalesmanCompany> company;
    } 
    global class PropertiesAddress {
		global String placeId;
        global String cityId;
        global String city;
        global String neighborhood;
        global String postalCode;
        global String streetName;
        global String streetNr;
        global String note;
        global String complementaryNumber;
        global List<ComplementarySubAddress> complementarySubAddress;
    } 
    global class ClientContact {
		global List<Object> telephoneNumbers;
    } 
    global class SalesmanCompany {
		global String corporateName;
		global SalesmanCompanySalesChannel salesChannel;
    } 
    global class SalesmanCompanySalesChannel {
		global String description;
		global SalesChannelSalesTeam salesTeam;
    } 
    global class SalesChannelSalesTeam {
		global String description;
    } 
    
    //--Consumo Móvel --//
    public class mobileUsage {
        
        public String apiVersion;
        public String transactionId;
        @AuraEnabled public mobileUsageData data;
    }
    
    public class mobileUsageData{
        @AuraEnabled public List <usageDetail> usages;
    }
    
    public class usageDetail {
        @AuraEnabled public String descriptionUsage;
        @AuraEnabled public String franchiseAmount;
        @AuraEnabled public String consumedAmount;
        @AuraEnabled public String excessAmount;
        @AuraEnabled public String unitMeasure;
        @AuraEnabled public String usageDateStart;  
        @AuraEnabled public String usageDateEnd;
        @AuraEnabled public Decimal percentage;
        @AuraEnabled public String franchiseAmountGB;
        @AuraEnabled public String consumedAmountGB;
    }
    
    //----------------------- Ordens de Serviço -------------------//
    
    public class serviceOrder {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public ServiceOrderData data;
    }
    
    public class ServiceOrderData {
      @AuraEnabled public List<Order> orders;
    }
    
    public class Order {
        @AuraEnabled public String orderType;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String description;
        @AuraEnabled public String note;
        @AuraEnabled public String typeId;
        @AuraEnabled public String typeDescription;
        @AuraEnabled public String status;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String cityId;
        @AuraEnabled public String orderId;
        @AuraEnabled public String terminationDate;
        @AuraEnabled public String attendenceDate;
        @AuraEnabled public String isExempt;
        @AuraEnabled public Boolean showDetails;
    }
    // --- Ocorrências ---------- //
    
    public class occurrencesResponse {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public ocurrencesData data;
        
    }
    
    public class ocurrencesData {
        public List<ocurrencesObj> data;    
    }
    
    public class ocurrencesObj {
        @AuraEnabled public String customerAccountId ;
        @AuraEnabled public String number_Z ;
        @AuraEnabled public String loginOpening ;
        @AuraEnabled public String loginClosing;
        @AuraEnabled public String creationDate ; 
        @AuraEnabled public String resolutionDate ;
        @AuraEnabled public String returnDate ;
        @AuraEnabled public String name ;
        @AuraEnabled public String phoneLineNumber;
        @AuraEnabled public String originId ;
        @AuraEnabled public String areaOrigin ;
        @AuraEnabled public String groupTypeId ;
        @AuraEnabled public String groupTypeDescription;
        @AuraEnabled public String typeId ;
        @AuraEnabled public String typeDescription ;
        @AuraEnabled public String status ;
        @AuraEnabled public String note ;
        @AuraEnabled public String attendanceNumber ;
        @AuraEnabled public String description ;
        @AuraEnabled public String protocolNumber;
        @AuraEnabled public String resolutionTypeId;
    }
 // -- Ocorrências fim -- //
 
    
 //--- Classe wrapper para arvore de produtos --//
    public class treeProducts{
        @AuraEnabled public String Id;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String street;
        @AuraEnabled public String numberAd;
        @AuraEnabled public String complement;
        @AuraEnabled public String name;
        @AuraEnabled public String city;
        @AuraEnabled public String status;
        @AuraEnabled public Boolean isExpandable;
        @AuraEnabled public String msisdn;
        @AuraEnabled public Boolean hasRecords;
     }
    
    public class subTreeProduct{
        @AuraEnabled public String Id;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String city;
        @AuraEnabled public String complement;
        @AuraEnabled public String street;
        @AuraEnabled public String Name;
        @AuraEnabled public String msisdn;
		@AuraEnabled public Decimal Preco;
        @AuraEnabled public String spotid;
        @AuraEnabled public String status;
        @AuraEnabled public String bu;
        @AuraEnabled public String addres;
        @AuraEnabled public String dateMod;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String record;
        @AuraEnabled public Boolean isExpandable;
        @AuraEnabled public Integer line;
        
        
    }
 //Proposal NET SALES AWS
    public class ProductsProposal {
        public InternetProposal internet {get;set;} 
        public InternetProposal paytv {get;set;} 
        public InternetProposal phone {get;set;} 
        public InternetProposal mobile {get;set;} 
        public InternetProposal alacarte {get;set;} 
    }  
    public class DiscountProposal {
        public Integer validity {get;set;} 
    }
    public class DataProposal extends ResponseGen{  
        public ProspectProposal prospect {get;set;} 
        public Map<String,Object> charge {get;set;} 
        public Map<String,String> scheduling {get;set;} 
        public Map<String,Object> offer {get;set;} 
        //public Addres address {get;set;} 
        public HpProposal hp {get;set;} 
       // public Map<String,String> billingAddress {get;set;} 
        public String seller {get;set;} 
        public String salesForceID {get;set;} 
    }
    public class AddressProposal {
        public String neighborhood {get;set;} 
        public String postalCode {get;set;} 
        public String street {get;set;} 
        public String complements {get;set;} 
        public String number_Z {get;set;} // in json: number    
    }
    public class TransitionsProposal {
        
    }
    public class ChargeProposal {
        public BankAccountProposal bankAccount {get;set;} 
        public String type_Z {get;set;} // in json: type
        public String invoiceShippingEmail {get;set;} 
        public String invoiceDay {get;set;} 
    }
    public class HpProposal {
        public Integer id {get;set;} 
    }
    public class BankAccountProposal {
        public Integer bank {get;set;} 
        public String agency {get;set;} 
        public String account {get;set;} 
        public String digit {get;set;} 
    }
    public class SchedulingProposal {
        public String date_Z {get;set;} // in json: type 
        public String alternativeDate {get;set;} 
    }
    public class RulesProposal {
        public Boolean fixedOffset {get;set;} 
        public List<TransitionsProposal> transitions {get;set;} 
        public List<TransitionsProposal> transitionRules {get;set;} 
    }	
    public class AdhesionProposal {
        public Integer price {get;set;} 
        public Integer period {get;set;} 
    }
    public class DateZ {
        public OffsetProposal offset {get;set;} 
        public Integer dayOfYear {get;set;} 
        public String dayOfWeek {get;set;} 
        public String month {get;set;} 
        public Integer dayOfMonth {get;set;} 
        public Integer year {get;set;} 
        public Integer monthValue {get;set;} 
        public Integer nano {get;set;} 
        public Integer hour {get;set;} 
        public Integer minute {get;set;} 
        public Integer second {get;set;} 
    }
    public class OffsetProposal {
        public Integer totalSeconds {get;set;} 
        public String id {get;set;} 
        public RulesProposal rules {get;set;} 
    }
    public class AdditionalProposal {
        public List<Object> internet {get;set;} 
        public List<Object> paytv {get;set;} 
        public List<Object> phone {get;set;} 
        public List<Object> mobile {get;set;} 
        public List<Object> alacarte {get;set;} 
    }
    public class CharacteristicsProposal {
        public String name {get;set;} 
        public String value {get;set;} 
    }
    public class OfferProposal {
        public String type_Z {get;set;} // in json: type
        public ProductsProposal products {get;set;} 
    }
    public class ProspectProposal {
        public String name {get;set;} 
        public String birthday {get;set;} 
        public String cpf {get;set;} 
        public String rg {get;set;} 
        public String mobileAreaCode {get;set;} 
        public String mobileNumber {get;set;} 
        public String phoneAreaCode {get;set;} 
        public String phoneNumber {get;set;} 
        public String email {get;set;} 
        public String motherName {get;set;} 
        public Integer gender {get;set;} 
        public Integer maritalStatus {get;set;} 
    }
    public class InternetProposal {
        public String name {get;set;} 
        public Double price {get;set;} 
        public DiscountProposal discount {get;set;} 
        public AdhesionProposal adhesion {get;set;} 
        public AdditionalProposal additional {get;set;} 
        public List<CharacteristicsProposal> characteristics {get;set;} 
    }
    //Response
    public class PendenciesProposal {
        public Integer id;
        public String title;
    }
    public class ProposalData extends ResponseGen{
		 public ProposalResponse data;
    }
    public class ProposalResponse{
        public String requestId;
        public Proposal proposal;
        public Contract contract;
    }
    public class ContractProposal {
        public Integer id;
        public Integer customerId;
    }
    public class Proposal {
        public Integer id;
        public String created;
        public String scheduled;
        public List<String> telephones;
        public String status;
        public List<Pendencies> pendencies;
    }
}