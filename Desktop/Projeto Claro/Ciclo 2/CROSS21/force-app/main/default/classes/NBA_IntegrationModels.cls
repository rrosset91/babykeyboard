/*--------------------------------------------------------------------------------------------
--- Company: Accenture Brasil
--- Creation Date: 25/01/2018 
--- Author: Vladson Araujo
--- Description: Classe que guarda a modelagem das requisições dos serviços de NBA
----------------------------------------------------------------------------------------------
--- Company: Claro Brasil
--- Modify Date: 09/03/2020 
--- Author: André Salgado
--- Description: Inclusão do nó mobileDiscounts no retorno da API de extras
----------------------------------------------------------------------------------------------*/

public with sharing class NBA_IntegrationModels {
public abstract class Request {}

	public abstract class Response {
		public String status;
		public String message;
	}
    
    public class SearchOffersRequest extends Request {
        public String operatorId;
        public String contractNumber;
        public String documentNumber;
        public String attendantProfile;
        public String eventType;
        public String reason;
        public String subreason;
        public String offerId;
        public String caseId;
        public String serviceProvider;
        public String channel;
        public String quantity;
    }
    
    public class SearchOffersResponse extends Response {
		public String status;
        public String apiVersion;
        public String transactionId;
        @AuraEnabled public SearchOffersData data;
    }

	public class SearchOffersData{
        @AuraEnabled public Current current;
        @AuraEnabled public CurrentProductData currentProduct;
        @AuraEnabled public List<Recommendation> recommendations;
		@AuraEnabled public String attendantProfile;				// Perfil de operador do usuário que está atendendo
		@AuraEnabled public String channelDetail;					// Canal de atendimento do usuário que está atendendo
		@AuraEnabled public String mobileAttendantProfile;			// Perfil de operador do usuário que está atendendo sobre o produto móvel
		@AuraEnabled public String mobileChannelDetail;				// Canal de atendimento do usuário que está atendendo sobre o produto móvel
		@AuraEnabled public String subscriberCityCode;				// Código da Cidade (NETSMS) - 5 digitos - necessário para agendamento
		@AuraEnabled public String subscriberIbgeCode;				// Código da Cidade (NETSMS e WAWM) - 8 digitos
		@AuraEnabled public String salesTeam;						// Sprint 15 CLAR-47 - Diego Silva - CLAR-47
		@AuraEnabled public String callReason;						// BUG - Kleverton Fortunato - CLAR-179
		@AuraEnabled public String enterpriseId;					// Sprint 15 CLAR-47 - Diego Silva - CLAR-47
		@AuraEnabled public string salesmanId;		
    }

	public class Current {
		@AuraEnabled public List<Products> products;
		@AuraEnabled public Boolean hasDiscount;					//desconto de Debito automatico e Fatura digital (Alexandre Amaro - 04/04/2019)
	}

	public class Product{
		@AuraEnabled public String id;
		@AuraEnabled public String baseId;
		@AuraEnabled public String name;
		@AuraEnabled public Decimal price;
		@AuraEnabled public String type;
		@AuraEnabled public String detail;
		@AuraEnabled public String technology;
		@AuraEnabled public Decimal proposedValue;
		@AuraEnabled public Discount discount;
	}

	public class Recommendation {
		@AuraEnabled public String id;								// Identificador da oferta
		@AuraEnabled public String type;							// Campo para segmentação da oferta(Blindagem, Exclusivo e etc)
		@AuraEnabled public String profile;							// Campo para classificação da oferta(Single, Double, Triple, Combo Multi)
		@AuraEnabled public String priority;						// Campo para priorização da oferta (Top 1, Top 2 e Top 3)
		@AuraEnabled public String oldPriority;						// Campo para priorização da oferta (Top 1, Top 2 e Top 3)
		@AuraEnabled public String rewardPoints;					// Atributo que representa pontos de recompensa. Utilizado para incentivo ao operador
		@AuraEnabled public String actionTv;						// Atributo que representa o movimento de TV em relação a posse atual do cliente
		@AuraEnabled public String actionPhone;						// Atributo que representa o movimento de FX em relação a posse atual do cliente
		@AuraEnabled public String actionBroadband;					// Atributo que representa o movimento de BL em relação a posse atual do cliente
		@AuraEnabled public String actionMobile;					// Atributo que representa o movimento de MV em relação a posse atual do cliente
		@AuraEnabled public List<NboTv> nboTv = new List<NboTv>();
		@AuraEnabled public NboPhone nboPhone;
		@AuraEnabled public NboBroadband nboBroadband;
		@AuraEnabled public List<NboMobile> nboMobile = new List<NboMobile>();              // Troca de nboMobile por List<nboMobile> Alexandre Amaro 29-07-19
		@AuraEnabled public List<Extras> extras;
		@AuraEnabled public String baseId;
		@AuraEnabled public List<MobileDiscount> mobileDiscounts2 = new List<MobileDiscount>();	

	}

	public class Products {
		@AuraEnabled public String id;
		@AuraEnabled public String baseId;
		@AuraEnabled public String name;
		@AuraEnabled public String category;
		@AuraEnabled public Decimal price;
		@AuraEnabled public Promotion promotion;
		@AuraEnabled public Date installDate;
	}

	public class Promotion {
		@AuraEnabled public String name;
		@AuraEnabled public String startDate;
		@AuraEnabled public Integer validFor;
		@AuraEnabled public Decimal discount;		
	}
	
	public class NboTv {
		@AuraEnabled public String id;								// ID do produto de TV
		@AuraEnabled public String baseId;							// ID da base do produto de TV
		@AuraEnabled public String name;							// Nome do produto de TV
		@AuraEnabled public Decimal price;							// Valor do produto de TV
		@AuraEnabled public String offerType;						// Tipo de oferta de
		@AuraEnabled public String familyName;						// Identificação da família do produto
		@AuraEnabled public String solicitationType;
		@AuraEnabled public String catalogName;							// Para efeito de aprovisionamento NETSMS ou NET PHONE  Nome de catálogo do produto 
		@AuraEnabled public String comboProfile;
		@AuraEnabled public String technologyId;
		@AuraEnabled public ProductPromotion promotion;
		@AuraEnabled public Integer validFor;						// Tempo de degrau do produto de TV
		@AuraEnabled public Integer experimentalFor;				// Tempo de degustação do produto de TV
		@AuraEnabled public Fee fee;								// Valor da adesão / movimentação de TV
		@AuraEnabled public String hasFidelity;						// Indicador se possui fidelidade
		@AuraEnabled public Fee earlyTerminationFee;				// Valor da multa
		@AuraEnabled public String technologyTypeName;
		@AuraEnabled public String technologyType;				//Foi retirado da estrutura
		@AuraEnabled public String technologyName;				// Para efeito de aprovisionamento NETSMS ou NET PHONE 
		@AuraEnabled public String optionalPointsPricing;		//Valor dos adicionais de Ponto Opcional, considerado na oferta para exibição do SFDC
		@AuraEnabled public String aLaCartePricing;				//Valor dos adicionais de A la Carte, considerado na oferta para exibição do SFDC
		@AuraEnabled public String offerReferenceId;				//Identificador de ofertas similares com tecnologias diferentes										
	}
	
	public class NboPhone {
        @AuraEnabled public String id;								// ID do produto de Fixo
        @AuraEnabled public String baseId;							// ID da base do produto de Fixo
        @AuraEnabled public String name;							// Nome do produto de Fixo
        @AuraEnabled public Decimal price;							// Valor do produto de Fixo
        @AuraEnabled public String offerType;						// Tipo de oferta de fixo
		@AuraEnabled public String familyName;						// Identificação da família do produto
		@AuraEnabled public String solicitationType;
		@AuraEnabled public String catalogName;							// Para efeito de aprovisionamento NETSMS ou NET PHONE  Nome de catálogo do produto 
		@AuraEnabled public String comboProfile;
		@AuraEnabled public String technologyId;
		@AuraEnabled public ProductPromotion promotion;
        @AuraEnabled public Integer validFor;						// Tempo de degrau do produto de Fixo
        @AuraEnabled public Integer experimentalFor;				// Tempo de degustação do produto de Fixo
        @AuraEnabled public Fee fee;								// Valor da Adesão / Movimentação  (FX)
		@AuraEnabled public String hasFidelity;					// Indicador se possui fidelidade
        @AuraEnabled public Fee earlyTerminationFee;				// Valor da multa
    }
	
	public class NboBroadband {
		@AuraEnabled public String id;								// ID do produto de Banda Larga
		@AuraEnabled public String baseId;							// ID da base do produto de Banda Larga
		@AuraEnabled public String name;							// Nome do produto de Banda Larga
		@AuraEnabled public Decimal price;							// Valor do produto de Banda Larga
		@AuraEnabled public String offerType;						// Tipo de oferta de
		@AuraEnabled public String familyName;						// Identificação da família do produto
		@AuraEnabled public String solicitationType;
		@AuraEnabled public String catalogName;							// Para efeito de aprovisionamento NETSMS ou NET PHONE  Nome de catálogo do produto 
		@AuraEnabled public String comboProfile;
		@AuraEnabled public String technologyId;
		@AuraEnabled public ProductPromotion promotion;
		@AuraEnabled public Integer validFor;						// Tempo de degrau do produto de Banda Larga
		@AuraEnabled public Integer experimentalFor;				// Tempo de degustação do produto de Banda Larga
		@AuraEnabled public Fee fee;								// Valor da Adesão / Movimentação  (BL)
		@AuraEnabled public String hasFidelity;					// Indicador se possui fidelidade
        @AuraEnabled public Fee earlyTerminationFee;				// Valor da multa
		@AuraEnabled public String speed;							// Velocidade do plano de Banda Larga
		@AuraEnabled public String additionalsTotalPricing;			// Preço total dos adicionais de banda-larga (sva, etc)
	}

	public class NboMobile {
		@AuraEnabled public String id = '';								// ID do produto de Móvel
		@AuraEnabled public String baseId = '';							// ID da base do produto de Móvel
		@AuraEnabled public String name = '';							// Nome do produto de Móvel
		@AuraEnabled public Decimal price;							// Valor do produto de Móvel
		@AuraEnabled public String offerType = '';						// Tipo de oferta de
		@AuraEnabled public String familyName = '';						// Identificação da família do produto
		@AuraEnabled public String solicitationType = '';
		@AuraEnabled public String catalogName = '';					// Para efeito de aprovisionamento NETSMS ou NET PHONE  Nome de catálogo do produto 
		@AuraEnabled public String comboProfile = '';
		@AuraEnabled public String technologyId = '';
		@AuraEnabled public ProductPromotion promotion = new ProductPromotion();
		@AuraEnabled public Integer validFor;							// Tempo de degrau do produto de Móvel
		@AuraEnabled public Integer experimentalFor;					// Tempo de degustação do produto de Móvel
		@AuraEnabled public Fee fee = new Fee();									// Valor da Adesão / Movimentação  (MV)
		@AuraEnabled public String hasFidelity = '';					// Indicador se possui fidelidade
        @AuraEnabled public Fee earlyTerminationFee;					// Valor da multa
		@AuraEnabled public String speed = '';							// Velocidade do plano movel
		@AuraEnabled public String svas = '';                            // Sprint 15 CLAR-47 - Alexandre Amaro 29-07-19
		@AuraEnabled public String offerName = '';                       // Sprint 15 - Alexandre Amaro 29-07-19 - CLAR-47
		@AuraEnabled public String benefitOffer = '';                    // Sprint 15 CLAR-47 - Diego Silva - CLAR-47
		@AuraEnabled public String netsmsProductName = '' ;              // Sprint 15 CLAR-47 - Alexandre Amaro 29-07-19
		@AuraEnabled public String portabilityRequestType = '';          // Sprint 15 CLAR-47 - Alexandre Amaro 29-07-19
		@AuraEnabled public String benefitType = '';                     // Alexandre Amaro 29-07-19
		@AuraEnabled public String subscriberType = '';                  // Alexandre Amaro 29-07-19	
		@AuraEnabled public String dependentType = '';                   // Sprint 15 CLAR-48 - Alexandre Amaro 29-07-19
		@AuraEnabled public String priority = '';      // Alexandre Amaro
		@AuraEnabled public String dependentAmount;
		@AuraEnabled public String netsalesProductName = '';
		@AuraEnabled public String feeValue = '';
		@AuraEnabled public List<MobileDiscount> mobileDiscounts = new List<MobileDiscount>();		
		@AuraEnabled public String additionalsTotalPricing;				// Preço total dos adicionais de móvel (dependente, vas, etc)
	}

	public class MobileDiscount{
		
		@AuraEnabled public String offerId = '';
		@AuraEnabled public String offerSequence = '';
        @AuraEnabled public String offerCode = '';
        @AuraEnabled public String offerName = '';
        @AuraEnabled public String feeValue = '';
        @AuraEnabled public String offerType = '';
        @AuraEnabled public String pointType = '';
        @AuraEnabled public String monthsStayNumber = '';
        @AuraEnabled public String offerDescription =  '';
        @AuraEnabled public String benefitOffer = '';


	}

	public class Discount{
		@AuraEnabled public Decimal value;				// Desconto
		@AuraEnabled public Integer validFor;
		@AuraEnabled public String startDate;
	}

	public class ProductPromotion {
		@AuraEnabled public String id;					// Id da promoção
		@AuraEnabled public String name;				// Nome da promoção
		@AuraEnabled public String description;			// Descrição da promoção
		@AuraEnabled public Discount discount;			// Desconto
		@AuraEnabled public String validFor;			// Tempo de degrau do produto de TV
		@AuraEnabled public String experimentalFor;		// Tempo de degustação do produto de TV
		@AuraEnabled public String relatedOffer;		// Sprint 15 CLAR-47 / CLAR-48 - Diego Silva
	}

	public class Fee {
		@AuraEnabled public String paymentMethod;		// Forma de pagamento da taxa (isento,avista,3x,6x)
		@AuraEnabled public String price;				// Valor da Adesão / Movimentação
	}

	public class Extras {
		@AuraEnabled public String id;					// Codigo do produto
		@AuraEnabled public String baseId;				// Codigo da base
		@AuraEnabled public String name;				// Nome produto adicional
		@AuraEnabled public String price;				// Valor do produto adicional
		@AuraEnabled public String familyName;			// Identificação da família do produto
		@AuraEnabled public String productName;
		@AuraEnabled public String catalogName;
		@AuraEnabled public String solicitationType;	// Tipo de solicitação. Serve como base para quando a oferta descer para o RPA caso seja aceita
		@AuraEnabled public String technologyType;
		@AuraEnabled public AdditionalPoint additionalPoints; // Pontos adicionais
		@AuraEnabled public ProductPromotion promotion;
		@AuraEnabled public String type;				// Tipo produto adicional
		@AuraEnabled public String detail;				// Descrição
		@AuraEnabled public String experimentalFor;		// Tempo de degustação
		@AuraEnabled public String isAlreadyIncluded;	// Tecnologia adicional
	//	@AuraEnabled public String feePaymentMethod;	// Forma de pagamento da taxa (isento,avista,3x,6x)  (Será removido e sera add o objeto Fee - Alexandre Amaro - 03/06/19)
		@AuraEnabled public Fee Fee;                    //(Alexandre Amaro - 03/06/19)
		@AuraEnabled public String pointId;
	}

	public class AdditionalPoint {
		@AuraEnabled public String amount;				// Quantidade de pontos opcionais com preço cheio
		@AuraEnabled public String pricing;			// Valor para ponto opcional diferente do valor do catálogo
	}

	/////////////////////////////////////////////////////////////
	/////	 Models do serviço de Posse Atual do cliente	/////
	/////////////////////////////////////////////////////////////
	public class CurrentProductRequest {
		public String operatorId;
		public String contractNumber;
	}

	public class CurrentProductResponse {
		@AuraEnabled public String apiVersion;
		@AuraEnabled public String transactionId;
		@AuraEnabled public CurrentProductData data;
	}

	public class CurrentProductData {
		@AuraEnabled public Boolean hasDiscount;
		@AuraEnabled public List<ContractProduct> contractProducts;
	}

	public class ContractProduct {
		@AuraEnabled public String productId;					// Código de identificação do produto
		@AuraEnabled public String productName;					// Descrição do produto do contrato
		@AuraEnabled public String catalogName;					// Nome do produto no catálogo
		@AuraEnabled public String productType;					// Identificação do tipo de produto 
		@AuraEnabled public String productDetail;				// Definição de Produto (Ex. Digital(TV), Internet, VOIP, Analógico(TV) e Digitalizado(TV)
		@AuraEnabled public Decimal pricing;					// Valor do contrato
		@AuraEnabled public Decimal deducedPrice;				// Valor do produto com desconto
		@AuraEnabled public ContractProductDiscount discount;	
		@AuraEnabled public String directDebitDiscount;			// Desconto por débito em conta corrente
		@AuraEnabled public String digitalBillDiscount;			// Desconto por fatura digital
		@AuraEnabled public String promotionName;				// Nome da promoção
		@AuraEnabled public String promotionCode;				// Identificador da promoção
		@AuraEnabled public String pointId;						// Identificador do ponto de instalação
		@AuraEnabled public String pointTypeId;					// Id do tipo de ponto
		@AuraEnabled public String hasFidelity;					// Flag para indicar se o produto de posse atual possui ou não fidelidade
		@AuraEnabled public String dependentAmount;				// Indica a quantidade de dependentes relacionada ao NTC informado. É calculado pelo motor do SAS
		@AuraEnabled public String msisdn;						// NTC do assinante
		@AuraEnabled public String isComboMulti;				// Flag que indica se o NTC em questão é/faz parte do combo multi
		@AuraEnabled public String mobileOfferName;				// Sprint 15 CLAR-49 - Diego Silva
		@AuraEnabled public Boolean newExtra = true;
		@AuraEnabled public String solicitationType;
		@AuraEnabled public String detail;
		@AuraEnabled public Decimal descontoPG;
		@AuraEnabled public Decimal descontoBL;
		
	}

	public class ContractProductDiscount {
		@AuraEnabled public Integer duration;					// Quantidade de meses de Desconto
		@AuraEnabled public String startDate;					// Data de inicio do produto
	}

	/////////////////////////////////////////////////////////////
	/////	 Models do serviço de Validação de Oferta     	/////
	/////////////////////////////////////////////////////////////
	
	public class OfferValidationRequest {
		public OfferValidationContract contract;
		public OfferValidationCustomerProducts offer;
		public String seller;
		
		public OfferValidationRequest(){
			contract = new OfferValidationContract();
			offer = new OfferValidationCustomerProducts();
		}
	}
	
	public class OfferValidationContract {
		public Integer id;
		public Integer customerId;
	}
	
	public class OfferValidationCustomerProducts {
		public List<OfferValidationCustomerProduct> paytv;
		public List<OfferValidationCustomerProduct> internet;
		public List<OfferValidationCustomerProduct> phone;
		public List<OfferValidationCustomerProduct> mobile;
		public List<OfferValidationCustomerProduct> alacarte;		
	}
	
	public class OfferValidationCustomerProduct {
		public Integer point;
		public OfferValidationProduct product;
		
		public OfferValidationCustomerProduct(){
			product = new OfferValidationProduct();
		}
	}
	
	public class OfferValidationProduct {
		public String Name;
		public Decimal price;
		public OfferValidationDiscount discount;
		public OfferValidationAdhesion adhesion;
		public OfferValidationAdditionalProducts additional;
		public List<OfferValidationCharacteristic> characteristics;
		
		public OfferValidationProduct(){
			discount = new OfferValidationDiscount();
			adhesion = new OfferValidationAdhesion();
		}
	}
	
	public class OfferValidationDiscount {
		public Integer validity;
	}
	
	public class OfferValidationAdhesion {
		public Decimal price;
		public Integer period;
	}
	
	public class OfferValidationAdditionalProducts {
		public List<OfferValidationProduct> paytv;
		public List<OfferValidationProduct> internet;
		public List<OfferValidationProduct> phone;
		public List<OfferValidationProduct> mobile;
		public List<OfferValidationProduct> alacarte;		
	}
	
	public class OfferValidationCharacteristic {
		public String name;
		public String value;
	}
	
	public class OfferValidationResponse{
		public Boolean validationNeeded;
		public Boolean ValidationSuccess = true;
		public Integer statusCode;
		public Map<String, object> request;
		public OfferValidationResponseContent response;
	}	
	public class OfferValidationResponseContent{
		public String apiVersion;
		public String transactionId;
		public OfferValidationResponseData data;
		public OfferValidationResponseError error;
	}
	public class OfferValidationResponseData{
		public Boolean scheduling;
	}	
	public class OfferValidationResponseError{
		public String detailedMessage;
		public List<String> textMessages = new List<String>();
	}	

	public class OfferValidationErrorObj{
		public List<OfferValidationError> errors;
	}
	public class OfferValidationError{
		public String message;
	}
	
	/////////////////////////////////////////////////////////////////////
	/////	 Models do serviço de Agendamento de Visita do cliente	/////
	/////////////////////////////////////////////////////////////////////

	//Objeto de negócio contendo os dados retornados pela API caso existam.
	public class AgendamentoResponse{
		@AuraEnabled public String apiVersion;
		@AuraEnabled public String transactionId;
		@AuraEnabled public AgendamentoData data;
        @AuraEnabled public AgendamentoError error;
	}

	public class AgendamentoData {
		@AuraEnabled public List<AgendamentoSchedule> schedule = new List<AgendamentoSchedule>();
	}
    
    public class AgendamentoError {
		@AuraEnabled public String httpCode;
	}

	public class AgendamentoSchedule{
		@AuraEnabled public String fieldSchedule; //Lembrar de usar o Replace - Agenda de área.
		@AuraEnabled public String classSchedule; //Lembrar de usar o Replace - Agenda classe.
		@AuraEnabled public String requiredMinutes; //minutos requeridos.
		@AuraEnabled public List<AgendamentoPeriods> periods = new List<AgendamentoPeriods>();
	}
	
	public class AgendamentoPeriods{
		@AuraEnabled public String description; //Descrição do periodo de agendamento.
		@AuraEnabled public String availableMinutes; //Minutos disponíveis.
		@AuraEnabled public String startHour; //Hora de início.
		@AuraEnabled public String endHour; //Hora de término.
		@AuraEnabled public Date dateSchedule; //Lembrar de usar o Replace - Data disponível do serviço técnico.
		@AuraEnabled public String periodTypeId; //Identificador tipo período.
		@AuraEnabled public String emergency; //Serviço Emergencial.
		@AuraEnabled public String isCapacityRegistration; //Se cadastrada a capacidade técnica
	}

	/////////////////////////////////////////////////////////////////////
	/////	 Models do serviço de Envio das solics ao RPA       	/////
	/////////////////////////////////////////////////////////////////////
	public class RPA_Data {
		public RPA_DT data = new RPA_DT();
	}

	public class RPA_DT {
		public String orderId;
		public String operationType				= '';
		public String operatorCode				= '';
		public String schedulingDate			= '';
		public String schedulingPeriod			= '';
		public RPA_exemption exemption		= new RPA_exemption();
		public RPA_contact contact			= new RPA_contact();
		public String accountHolder				= '';
		public String telephoneNumber			= '';
		public String motherName				= '';
		public String rg						= '';
		public String cpf						= '';
		public String salesmanName				= '';
		public String supervisorId				= '';
		public String serviceProvider			= '';		
		public List<String> surveyProductTypes	= new List<String>();
		public RPA_customer customer		= new RPA_customer();
		public List<RPA_tasks> tasks		= new List<RPA_tasks>();
		//CLAR178 - Kleverton Fortunato - 13/09/19
		//public String origin = NBA_Constants.RPA_SALESFORCE;
		public String penaltyPrice;
		public String salesmanId = '';
		public String salesTeam = '';
		public String serviceProviderId = '';
		public String toComboMulti = '';		
		public String subscriberId = '';
		public Map<String, Object> promotionValidationPayload;
	}

	public class RPA_exemption {
		public String type	= '';
		public String value	= '';
	}

	public class RPA_contact {
		public String reason	= '';
		public String subreason	= '';
		public String result    = '';
	}

	public class RPA_customer {
		public String contractNumber	= '';
		public String profile			= '';
		public String status			= '';		
		//CLAR178 - Kleverton Fortunato - 13/09/19
		public String birthDate = '';
		public RPA_BillingAddress billingAddress = new RPA_BillingAddress();
		public String hasMobileProduct = '';
		public String isComboMulti = '';
		public String mobileDependentAmount = '';
		public String nationality = '';
		public String rgIssueDate = '';
		public String rgIssuer = '';
		public String pointsQuantity = '';
	}

	//CLAR178 - Kleverton Fortunato - 13/09/19
	public class RPA_BillingAddress {
		public String postcode = '';
		public String streetType = '';
		public String streetName = '';
		public String streetNr = '';
		public String complement = '';
		public String neighborhood = '';
		public String cityName = '';
		public String stateAbbreviation = '';
	}

	public class RPA_tasks {
		public String taskId					 = '';
		public String solicitationType			 = '';
		public String action					 = '';
		public String city						 = '';
		public String salesmanUser				 = '';
		public String saleTypeId				 = '';
		public String campaignId				 = '';
		public String acquisitionType			 = '';
		public String revokeType				 = '';
		public String revokeReason				 = '';
		public String paymentMethod				 = '';
		public String channel					 = '';
		public String notes						 = '';
		public String result                     = '';
		public String resultReason               = '';
		public String resultNotes                = '';
		public String fidelityPenaltyPrice       = '';
		public String hasFidelity                = '';
		public String flagFidelityRenewal        = '';
		public RPA_Fee fee						 = new RPA_Fee();
		public RPA_targetProduct targetProduct	 = new RPA_targetProduct();
	}

	public class RPA_targetProduct {
		public String type			          = '';
		public String name			          = '';
		public String pricing		          = '';
		public String profile		          = '';
		public String point			          = '';
		public String serialNumber            = '';
		public String technologyId            = '';
		public String pointType               = '';
		public String fidelityRenewalDate     = '';
		public String fidelityExpirationDate  = '';
		public String telephoneNumber         = '';
		//CLAR178 - Kleverton Fortunato - 13/09/19
		public String currentMobileSubscriptionType = '';
		public String discountValue           = '';
		public String discountDuration        = '';
		public String isPortabilityRequest = '';
		public String mobileAdditionalServiceName = '';
		public String mobileAdditionalServiceType = '';
		public String mobileAppliedDiscount = '';
		public String mobileDataPlan = '';
		public String mobileDependentAmountToAdd = '';
		public String mobileOfferType = '';
		public String mobilePlanName = '';
		public String mobilePromotionalOffer = '';
		public String newMobileSubscriptionType = '';
		public String msisdn = '';
		public Set<RPA_MobileDependent> mobileDependent = new Set<RPA_MobileDependent>();
		public String pointId = '';
		
	}

	//CLAR178 - Kleverton Fortunato - 13/09/19
	public class RPA_MobileDependent{
		public String action = null;
		public String appliedDiscount = '';
		public String isPortabilityRequest = null;
		public String msisdn = null;
		public String offerType = '';
		public String profile = null;
		public Boolean equals(Object obj) {
			if (obj instanceOf RPA_MobileDependent)
				return this.action+this.msisdn == ((RPA_MobileDependent)obj).action+((RPA_MobileDependent)obj).msisdn;
			return false;
		}
		
		public String hashCode() {
			return action+msisdn;
		}

	}

	public class RPA_Fee {
		public String type  = '';
		public String price	= '';
	}

	////////////////////////////////////////////////////////////////
	//////////////////// Modelo API de Adcionais //////////////////
	//////////////////////////////////////////////////////////////


	public class NewExtrasResponse{
		public String status;
        public String apiVersion;
        public String transactionId;
		public Data data;
	}

	public class Data{
		public NewExtra extras = new NewExtra();
	} 

	public class NewExtra {
		public List<TvTechnologies> tvTechnologies = new List<TvTechnologies>();
		public List<Extras> all;// = new List<Extras>();
		public List<MobileOffers> mobileOffers;
		public List<MobileDiscount> mobileDiscounts = new List<MobileDiscount>();	
	}

	public class TvTechnologies{
		@AuraEnabled public String id; // id da nova tv
		@AuraEnabled public String name; // nome da nova tv
		@AuraEnabled public Decimal price; // preço tv
		@AuraEnabled public String familyName;
		@AuraEnabled public String solicitationType;
		@AuraEnabled public ProductPromotion promotion ; 
		@AuraEnabled public string catalog;
		@AuraEnabled public String comboProfile; 
		@AuraEnabled public String technologyId;
		@AuraEnabled public String validFor;
		@AuraEnabled public String experimentalFor;
		@AuraEnabled public Fee fee ;
		@AuraEnabled public String hasFidelity;
		@AuraEnabled public String technologyTypeName;
		@AuraEnabled public String technologyName;

	}

	public class MobileOffers{
		@AuraEnabled public String id; 
		@AuraEnabled public String name; 
		@AuraEnabled public Decimal price; 
		@AuraEnabled public String familyName;
		@AuraEnabled public String solicitationType;
		@AuraEnabled public ProductPromotion promotion ; 
		@AuraEnabled public string catalog;
		@AuraEnabled public String comboProfile; 
		@AuraEnabled public String technologyId;
		@AuraEnabled public String validFor;
		@AuraEnabled public String experimentalFor;
		@AuraEnabled public Fee membershipFee ;
		@AuraEnabled public String hasFidelity;
		@AuraEnabled public String technologyTypeName;
		@AuraEnabled public String technologyName;
		@AuraEnabled public String speed;
		@AuraEnabled public String offerName;
		@AuraEnabled public String portabilityRequestType; 
		@AuraEnabled public String benefitType; 
		@AuraEnabled public String subscriberType;
		@AuraEnabled public String dependentType;
		@AuraEnabled public List<MobileDiscount> mobileDiscounts = new List<MobileDiscount>();		
	}

	/////////////////////////////////////////////////////////////////////
	/////		 Models do serviço de Envio de Oferta aceita	   	/////
	/////////////////////////////////////////////////////////////////////

	public class Offer_Accepted {
		public String caseId				= '';
		public String endDate				= '';
		public String origin				= '';
		public String acceptedOfferPriority = '';
		public String acceptedOfferValue	= '';
		public String totalSpent			= '';
		public String finalResult			= '';
		public List<Offer_Result> results				= new List<Offer_Result>();
		public Offer_TvProduct tvProduct				= new Offer_TvProduct();
		public Offer_PhoneProduct phoneProduct			= new Offer_PhoneProduct();
		public Offer_BroadBandProduct broadbandProduct	= new Offer_BroadBandProduct();
		public Offer_MobileProduct mobileProduct		= new Offer_MobileProduct();
	}

	public class Offer_TvProduct {
		public String id							= '';
		public String name							= '';
		public String catalogName					= '';
		public String price							= '';
		public Boolean hasCinema					= false;
		public Boolean hasMovies					= false;
		public Boolean hasFox						= false;
		public Boolean hasPtvSoccer					= false;
		public Boolean hasHbo						= false;
		public Boolean hasTelecine					= false;
		public Boolean hasSeries					= false;
		public String additionalPointsAmount		= '';
		public String additionalPointsPrice			= '';
		public String extrasTotalPrice				= '';
		public Offer_Promotion promotion			= new Offer_Promotion();
		public List<String> otherExtras				= new List<String>();
	}

	public class Offer_PhoneProduct {
		public String id				 = '';
		public String name				 = '';
		public String catalogName		 = '';
		public String price				 = '';
		public Offer_Promotion promotion = new Offer_Promotion();
	}

	public class Offer_BroadBandProduct {
		public String id				 = '';
		public String name				 = '';
		public String catalogName		 = '';
		public String price				 = '';
		public String extrasTotalPrice	 = '';
		public Offer_Promotion promotion = new Offer_Promotion();
	}

	public class Offer_MobileProduct {
		public String id				 = '';
		public String name				 = '';
		public String catalogName		 = '';
		public String price				 = '';
		public Integer dependentAmount	 = 0;
		public String dependentsPrice	 = '';
		public Offer_Promotion promotion = new Offer_Promotion();
		public List<String>	extras		 = new List<String>();
	}

	public class Offer_Promotion {
		public String id				= '';
		public String duration			= '';
		public String discountValue		= '';
	}

	public class Offer_OtherExtras {
		public String extra = '';
	}

	public class Offer_Extras {
		public String extra = '';
	}

	public class Offer_Result {
		public Integer level		= 0;
		public String productType	= '';
		public String result		= '';
	}

	public class RespostaContratoResidencial{
		public ContratoResidencialData data;
	}
	public class ContratoResidencialData{
		public List<ContratoResidencialContrato> contracts;
	}
	public class ContratoResidencialContrato{
		public String partyRoleId;
		public String status;
		public String propertyHpId;
		public String cdBase;

	}

	public class RespostaContratoMovel{
		public ContratoMovelData data;
	}
	public class ContratoMovelData{
		public List<ContratoMovelSubscriber> subscribers;

	}
	public class ContratoMovelSubscriber{
		public String productStatus;
		public String reason;
	}

	/////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////// VIABILIDADE TECNICA  ///////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////	
	
	public class ViabilidadeResponse{
		public string apiVersion;
		public String transactionId;
		public ViabilidadeData data;
	
	}

	public class ViabilidadeData{
		public List<Domiciles> domiciles = new List<Domiciles>() ;
	}

	public class Domiciles{
		public String id;
		public String description;
		public String noteDomicile;
		public String nodeCharacteristic;
		//public String number;
		public String domicileType;
		public String domicileTypeDescription;
		public List<Availability> availability;
		public string node;
	}

	public class Availability{
		public String technicalSituation;
		public String commercialSituation;
		public String technicalSituationNote;
		public String commercialSituationNote;
		public BusinessLine businessLine;
	}

	public class BusinessLine{
		public string id;
		public string description;
		public BusinessLineFeatures businessLineFeatures;
	}

	public class BusinessLineFeatures{
		public string description;   
	}   

	public class GestorCreditoResponse {
		@AuraEnabled public Boolean analiseError = false;
		public DataCredito data ;
	}

	public class DataCredito {
		public CreditSituation  creditSituation ;
	}
	
	public class CreditSituation{
		@AuraEnabled public string status;
		@AuraEnabled public string policy;
		@AuraEnabled public string typeDecision;
		@AuraEnabled public string dataPolicy;
	}

	public class GestorCreditoRequest {
		public String operatorCode;
		public List<Itens> itens;
	}

	public class	 DataGestorCreditoRequest {
		public GestorCreditoRequest data = new GestorCreditoRequest();
	}

	public class Itens {
		public Item item;
	}

	public class Item {
		public String value;
		public String key;
		public String fieldName;
		public String fieldId;
	}
	
	public class retainedObject {
		public String application;
		public retainedObjectData data;
	}

	public class retainedObjectData {
		public String login;
		public String note;
		public String sourceEvent;
		public String identifierType;
		public String description;
		public String name;
		public String areaCode;
		public String telephoneNumber;
		public String contractNumber;
		public String operatorCode;
	}

	public class retainedObjectPatch {
		public String operatorCode;
		public String occurrenceId;
		public String source;
		public String userLogin;
		public retainedObjectPatchRes resolution;
	}

	public class retainedObjectPatchRes {
		public String id;
		public String notes;		
	}

	public class SalesmanResponse {
		public String apiVersion;
		public String transactionId;
		public SalesmanData data;
	}

	public class SalesmanData {
		public Salesman salesman;
		public List<SalesmanCompany> company;
	}

	public class Salesman {
		public String id;
		public String name;
		public String registration;
		public String situation;
		public String situationDate;
		public String partyidentification;
		public String contact;
		public String salesAgent;
		public String marketArea;
		public SalesmanUser user;
	}

	public class SalesmanUser {
		public String userId;
		public String roleId;
		public String description;
		public List<SalesmanProfile> profiles;
	}

	public class SalesmanProfile {
		public String profileId;
		public String name;
	}

	public class SalesmanCompany {
		public String id;
		public String corporateName;
		public List<SalesChannel> salesChannel;
	}

	public class SalesChannel {
		public String id;
		public String description;
		public List<SalesTeam> salesTeam;
	}

	public class SalesTeam {
		public String id;
		public String description;
	}
}