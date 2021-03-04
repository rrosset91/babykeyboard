/**
 * Created by 93668256 on 21/11/2019.
 * Modified by Thayná Morim Barreto 18/12/2020.
 * 
 * Altered: added validation to check if the payment method is 'Boleto' and if the credit analysis thab is true. If the result is positive, it applies the first option available on the API. Linha- 1818
 *
* Modified by Henrique Almeida 28/12/2020.
 * 
 * Altered: Changed DDD reference, instead Account.vlocity_cmt__PremisesId__r.DDD__c now Order.BillingDDD__c.
 *
 */

public class SalesOrderIntegrationDTO {

    public OrderItem orderMain = new OrderItem();
    public List<OrderItem> dependents = new List<OrderItem>();

    public SalesOrderMobileRequest builderRequest(Order orderSalesForce, User user, Profile profile,
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portabilty,
            List<ProductsIntegrationDTO.ProductsResponses> products, SalesManDTO.SalesMen salesMen,
            map<Id,PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> numberReservation, IBGE__c ibge, boolean thab) {
                if(ibge == null) {
                    ibge = new IBGE__c();
                }
        for (OrderItem item : orderSalesForce.orderItems) {
            if (item.Product2.vlocity_cmt__Type__c.equals('Plano')) {
                this.orderMain = item;
            }
            if (item.Product2.vlocity_cmt__Type__c.equals('Dependente')) {
                dependents.add(item);
            }
        }

        Order_z order = new Order_z();


        order.operation = new Operation('2', 'ATIVACAO', null, 
                new Type_Z('ATIVACAO'), orderSalesForce.Description);           // todo select * from gtasatvo.operacao where ds_operacao = 'Ativação Pós - Pre Ativado - SimCard Pré GSM';

        order.status = builderStatus(user, profile);

        List<SalesOrderIntegrationDTO.Status> s = new List<SalesOrderIntegrationDTO.Status>();
        s.add(builderStatus(user, profile));
        order.statusHistory = null;//s; // TODO OBRIGATOR

        order.interaction = new Interaction(orderSalesForce.NumProtocolo__c); //TODO REALMENTE É UMA SERVIÇO A PARTE QUE CONSULTA O SISTEMA DO TELEVENDAS

        order.customer = builderCustomer(orderSalesForce, ibge);

        order.salesman = builderSalesman(user, orderSalesForce, salesMen, ibge, profile);

                List<MarketSegments> t= new List<MarketSegments>();
                t.add(new MarketSegments(orderSalesForce.BillingDDD__c, ibge.UF__c));
        order.targetMarketSegments = t;

        order.pointOfSale = null;//new PointsOfSale();

        order.stockLocation = null;//new SalesOrderIntegrationDTO.Profile_z();

        order.creditAnalysis = null;//builderCreditAnalysis();

        order.addressAnalysis = null;//new AddressAnalysis(null, new Reason(null, null)); // TODO... OBRIGATORIO FAZ PARTE DA ANALISE DE CREDITO (BRSAFE)

        order.billingAccount = builderBillingAccount(orderSalesForce, ibge, thab);

        order.payment = null;//builderPayment(); // TODO OBRIGATORIO?
                
        Reason reason = new Reason();
        Unavailables unavailable = new Unavailables(new List<Tickets>(), reason);
        List<Unavailables> lstUnavailables = new List<Unavailables>();
                
        map<Id, List<Tickets>> mapTickets = createTickets(orderSalesForce.orderItems);        
        List<Availables> lstAvailables = createAvailables(orderSalesForce.orderItems, mapTickets);
            
        order.portability = new Portability(String.valueOf(this.orderMain.Portabilidade__c), lstAvailables, lstUnavailables);

        List<Correlations> correlations = new List<Correlations>();
        Correlations correlation = new Correlations(orderSalesForce.Id, 'CEC_SALES_FORCE');
		correlations.add(correlation);                
        order.correlations = correlations;
		system.debug('mapTickets-RIK: '+mapTickets);
        order.items = builderItems(products, orderSalesForce, numberReservation, credAnalisys, ibge, mapTickets);

        order.authority =null;// builderAuthority(user); // TODO DEPENDE DO PERFIL DE CANAL

        ClaroClub orderClub = new ClaroClub(); 
        orderClub.accessionIndicator = false;
        order.claroClub = orderClub;

        order.consolidatedData = builderConsolidatedData(products, orderSalesForce, credAnalisys); // TODO SIM É OBRIGATORIO

        SalesOrderMobile o = new SalesOrderMobile(order);

        return new SalesOrderMobileRequest(o);
    }

    public class SalesOrderMobileResponse extends CEC_RestObjects.ResponseGen{
        public SalesOrderMobileResponses data;
    }

    public class SalesOrderMobileResponses {
        public OrderResponse order;
    }

    public class OrderResponse {
        public String id;
        public String interaction;
        public List<Interaction> interaction2;
        public List<telephoneDetails> telephonesDetails;

        public OrderResponse(String id, String interaction) {
            this.id = id;
            this.interaction = interaction;
        }
        public OrderResponse(String id, List<Interaction> interaction) {
            this.id = id;
            this.interaction2 = interaction;
        }
    }
    
    public class telephoneDetails 
    {
        public String itemClassification;
        public String productName;
        public SalesOrderIntegrationDTO.TelephoneNumber_Z fones;
    }

    public class SalesOrderMobile {
        public Order_z order;

        public SalesOrderMobile(Order_z order) {
            this.order = order;
        }
    }

    public class SalesOrderMobileRequest {
        public SalesOrderMobile data;

        public SalesOrderMobileRequest(SalesOrderMobile o) {
            this.data = o;
        }
    }

    public class Type_Z {
        public String id;

        public Type_Z() {
        }

        public Type_Z(String id) {
            this.id = id;
        }
    }

    public class CreditLimitAnalysis {
        public String limitExceeded;
        public String limitValueExceeded;
        public String limitPercentExceeded;

        public CreditLimitAnalysis() {
        }

        public CreditLimitAnalysis(String limitExceeded, String limitValueExceeded, String limitPercentExceeded) {
            this.limitExceeded = limitExceeded;
            this.limitValueExceeded = limitValueExceeded;
            this.limitPercentExceeded = limitPercentExceeded;
        }
    }

    public class Customer {
        public String mobileId;
        public MobileType mobileType;
        public MobileSubType mobileSubType;
        public Passport passport;
        public Contacts contact;
        public List<Addresses> addresses;

        public String partyType;
        public String physicalPartyType;
        public Individual individual;
        public CustomerAcceptances customerAcceptances;

        public Customer() {
        }

        public Customer(String mobileId, MobileType mobileType, MobileSubType mobileSubType, Passport passport,
                Contacts contact, List<Addresses> addresses, Individual individual) {
            this.mobileId = mobileId;
            this.mobileType = mobileType;
            this.mobileSubType = mobileSubType;
            this.passport = passport;
            this.contact = contact;
            this.addresses = addresses;
            this.individual = individual;
        }

        public Customer(String partyType, String physicalPartyType) {
            this.partyType = partyType;
            this.physicalPartyType = physicalPartyType;
        }

        public Customer(Individual individual, CustomerAcceptances customerAcceptances) {
            this.individual = individual;
            this.customerAcceptances = customerAcceptances;
        }
    }

    public class TelephoneNumber {
        public String number_Z; // in json: number
        public Mobile mobile;

        public TelephoneNumber() {
        }

        public TelephoneNumber(String number_Z) {
            this.number_Z = number_Z;
            this.mobile = new Mobile(number_Z);
        }

        public TelephoneNumber(String number_Z, Mobile mobile) {
            this.number_Z = number_Z;
            this.mobile = mobile;
        }
    }

    public class Mobile {
        public string number_z;

        public Mobile(string number_z) {
            this.number_z = number_z;
        }
    }

    public class ItemTablePrice_Z {
        public EquipmentPaymentPlan equipmentPaymentPlan;

        public ItemTablePrice_Z() {
        }

        public ItemTablePrice_Z(EquipmentPaymentPlan equipmentPaymentPlan) {
            this.equipmentPaymentPlan = equipmentPaymentPlan;
        }
    }

    public class Result {
        public String id;
        public String date_z;
        public Reason reason;

        public Result() {
        }

        public Result(String id, String date_z, Reason reason) {
            this.id = id;
            this.date_z = date_z;
            this.reason = reason;
        }
    }

    public class Addresses {
        public String addressType;
        public String type_Z; // in json: type
        public String postCode;
        public String streetType;
        public String streetName;
        public String streetNr;
        public String urbanPropertySubAddress;
        public String neighborhood;
        public String ibgeCode;
        public String prefix;
        public String city;
        public String placeId;
        public String boxNr;
        public String areaCode;

        public Addresses() {
        }

        public Addresses(String addressType, String type_Z, String postCode, String streetType, String streetName,
                String streetNr, String urbanPropertySubAddress, String neighborhood, String city,
                String placeId, String boxNr, String areaCode, String ibgeCode, String prefix) {
            this.addressType = addressType;
            this.type_Z = type_Z;
            this.postCode = postCode;
            this.streetType = streetType;
            this.streetName = streetName;
            this.streetNr = streetNr;
            this.urbanPropertySubAddress = urbanPropertySubAddress;
            this.neighborhood = neighborhood;
            this.city = city;
            this.placeId = placeId;
            this.boxNr = boxNr;
            this.areaCode = areaCode;
            this.ibgeCode = ibgeCode;
            this.prefix = prefix;
        }
    }

    public class ItemPaymentMixed {
        public String sequenceNr;
        public Type_Z paymentMethod;

        public ItemPaymentMixed() {
        }

        public ItemPaymentMixed(String sequenceNr, Type_Z paymentMethod) {
            this.sequenceNr = sequenceNr;
            this.paymentMethod = paymentMethod;
        }
    }

    public class TelephoneNumber_Z {
        public String number_Z; // in json: number
        public String temporaryNumber;

        public TelephoneNumber_Z() {
        }

        public TelephoneNumber_Z(String number_Z, String temporaryNumber) {
            this.number_Z = number_Z;
            this.temporaryNumber = temporaryNumber;
        }
    }

    public class ProductOffering_Z {
        public String type_Z; // in json: type
        public String subType;

        public ProductOffering_Z() {
        }

        public ProductOffering_Z(String type_Z, String subType) {
            this.type_Z = type_Z;
            this.subType = subType;
        }
    }

    public class User_Z {
        public String id;
        public String name;
        public Type_Z profiles;

        public User_Z() {
        }

        public User_Z(String id, Type_Z profiles) {
            this.id = id;
            this.profiles = profiles;
        }

        public User_Z(String id, Type_Z profiles, String name) {
            this.id = id;
            this.profiles = profiles;
            this.name = name;
        }
    }

    public class User_x {
        public String id;
        public String name;
        public List<Profile_z> profiles;

        public User_x() {
        }

        public User_x(String id, List<Profile_z> profiles) {
            this.id = id;
            this.profiles = profiles;
        }

        public User_x(String id, List<Profile_z> profiles, String name) {
            this.id = id;
            this.profiles = profiles;
            this.name = name;
        }
    }

    public class CustomerAcceptances {
        public Boolean flagAcceptMarketingMessages;
        public Boolean flagAcceptCspClaro;

        public CustomerAcceptances() {
        }

        public CustomerAcceptances(Boolean flagAcceptMarketingMessages, Boolean flagAcceptCspClaro) {
            this.flagAcceptMarketingMessages = flagAcceptMarketingMessages;
            this.flagAcceptCspClaro = flagAcceptCspClaro;
        }
    }

    public class Manufacturer {
        public String id;
        public String name;
        public String typeId;

        public Manufacturer() {
        }

        public Manufacturer(String id, String name, String typeId) {
            this.id = id;
            this.name = name;
            this.typeId = typeId;
        }
    }

    public class Status_Z {
        public String id;
        public String date_z;

        public Status_Z() {
        }

        public Status_Z(String id, String date_z) {
            this.id = id;
            this.date_z = date_z;
        }
    }

    public class Tickets {
        public String id;
        public TelephoneNumber telephoneNumber;
        public Window window;

        public Tickets() {
        }

        public Tickets(String id, TelephoneNumber telephoneNumber) {
            this.id = id;
            this.telephoneNumber = telephoneNumber;
        }
    }

    public class Items {
        public String id;
        public ConsolidatedData consolidatedData;
        public Object sourceProduct;
        public TargetProduct targetProduct;

        public Items() {
        }

        public Items(String id, Object sourceProduct, TargetProduct targetProduct, ConsolidatedData consolidatedData) {
            this.id = id;
            this.sourceProduct = sourceProduct;
            this.consolidatedData = consolidatedData;
            this.targetProduct = targetProduct;
        }
    }

    public class PointsOfSale {
        public String id;
        public String tradingName;

        public PointsOfSale() {
        }

        public PointsOfSale(String id, String tradingName) {
            this.id = id;
            this.tradingName = tradingName;
        }
    }

    public class Status {
        public String id;
        public String description;
        public String date_z;
        public Reason reason;
        public User_x user;
        public Application application;


        public Status() {
        }

        public Status(String id, String description, String date_z, Reason reason, User_x user, Application application) {
            this.id = id;
            this.description = description;
            this.date_z = date_z;
            this.reason = reason;
            this.user = user;
            this.application = application;
        }

        public Status(String id, String description, String date_z, Reason reason, User_x user) {
            this.id = id;
            this.description = description;
            this.date_z = date_z;
            this.reason = reason;
            this.user = user;

        }
    }

    public class Salesman {
        public String id;
        public String name;
        public List<PartyIdentifications> partyIdentifications;
        public List<Contacts> contacts;
        public Status_Z status;
        public String registration;
        public String partyType;
        public String jobPositionId;
        public String jobPositionDescription;
        public User_X user;
        public List<MarketSegments> marketSegments;
        public SalesAgent salesAgent;

        public Salesman() {
        }

        public Salesman(String id, String name, List<PartyIdentifications> partyIdentifications, List<Contacts> contacts,
                Status_Z status, String registration, String partyType, String jobPositionId, String jobPositionDescription,
                User_x user, List<MarketSegments> marketSegments, SalesAgent salesAgent) {
            this.id = id;
            this.name = name;
            this.partyIdentifications = partyIdentifications;
            this.contacts = contacts;
            this.status = status;
            this.registration = registration;
            this.partyType = partyType;
            this.jobPositionId = jobPositionId;
            this.jobPositionDescription = jobPositionDescription;
            this.user = user;
            this.marketSegments = marketSegments;
            this.salesAgent = salesAgent;
        }
    }

    public class Order_z {
        public List<Correlations> correlations;
        public Operation operation;
        public Status status;
        public List<Status> statusHistory;
        public Interaction interaction;
        public Customer customer;
        public Salesman salesman;
        public List<MarketSegments> targetMarketSegments;
        public PointsOfSale pointOfSale;
        public Profile_z stockLocation;
        public CreditAnalysis creditAnalysis;
        public AddressAnalysis addressAnalysis;
        public BillingAccount billingAccount;
        public Payment payment;
        public Portability portability;
        public List<Items> items;
        public List<Authority> authority;
        public ClaroClub claroClub;
        public ConsolidatedData consolidatedData;

        public Order_z() {
            this.claroClub = new ClaroClub();
        }

        public Order_z(List<Correlations> correlations, Operation operation, Status status, List<Status> statusHistory,
                Interaction interaction, Customer customer, Salesman salesman, MarketSegments targetMarketSegment,
                PointsOfSale pointOfSale, Profile_z stockLocation, CreditAnalysis creditAnalysis, AddressAnalysis addressAnalysis,
                BillingAccount billingAccount, Payment payment, Portability portability, List<Items> items, List<Authority> authority,
                ClaroClub claroClub, ConsolidatedData consolidatedData) {
            this.correlations = correlations;
            this.operation = operation;
            this.status = status;
            this.statusHistory = statusHistory;
            this.interaction = interaction;
            this.customer = customer;
            this.salesman = salesman;
            this.targetMarketSegments = targetMarketSegments;
            this.pointOfSale = pointOfSale;
            this.stockLocation = stockLocation;
            this.creditAnalysis = creditAnalysis;
            this.addressAnalysis = addressAnalysis;
            this.billingAccount = billingAccount;
            this.payment = payment;
            this.portability = portability;
            this.items = items;
            this.authority = authority;
            this.claroClub = claroClub;
            this.consolidatedData = consolidatedData;
        }
    }

    public class BillingCycle {
        public String id;
        public String expirationDay;
        public String dueDay;
        public Type_Z status;
        public String description;
        public String mobileCycleId;

        public BillingCycle() {
        }

        public BillingCycle(String id, String expirationDay, String dueDay, Type_Z status, String description,
                String mobileCycleId) {
            this.id = id;
            this.expirationDay = expirationDay;
            this.dueDay = dueDay;
            this.status = status;
            this.description = description;
            this.mobileCycleId = mobileCycleId;
        }
    }

    public class DigitalInvoice {
        public String profile;
        public List<Contacts> contact;

        public DigitalInvoice() {
        }

        public DigitalInvoice(String profile, List<Contacts> contact) {
            this.profile = profile;
            this.contact = contact;
        }
    }

    public class Interaction {
        public String protocolNumber;
        public String protocolNumberChild;
        public String protocolSource;

        public Interaction() {
        }

        public Interaction(String protocolNumber) {
            this.protocolNumber = protocolNumber;
        }

        public Interaction(String protocolNumber, String protocolNumberChild, String protocolSource) {
            this.protocolNumber = protocolNumber;
            this.protocolNumberChild = protocolNumberChild;
            this.protocolSource = protocolSource;
        }
    }

public class ConsolidatedData {
        public Decimal balanceValueCredit ;
        public Decimal creditLimit ;
        public Decimal discountEquipment ;
        public Decimal discountEquipmentCampaign ;
        public Decimal discountEquipmentClaroClub ;
        public Decimal discountsEquipments ;
        public Decimal discountService ;
        public Decimal discountServiceDependent ;
        public Decimal discountServiceHolder ;
        public Decimal discountSimcard ;
        public Decimal equipmentFullPrice ;
        public Decimal equipmentPrice ;
        public Decimal equipmentsFullPrice ;
        public Decimal equipmentsPrice ;
        public Decimal monthlyEquipmentPrice ;
        public Decimal monthlyServicePrice ;
        public Decimal pointsEquipmentClaroClub ;
        public Decimal productOfferingTotalPrice ;
        public Decimal productOfferingTotalPriceDependent ;
        public Decimal productOfferingTotalPriceHolder ;
        public Decimal productOfferingTotalPriceServices ;
        public Decimal productOfferingTotalPriceServicesDependent ;
        public Decimal productOfferingTotalPriceServicesHolder ;
        public Decimal simcardFullPrice ;
        public Decimal simcardPrice ;
        public Decimal usedCreditAmount ;

        public ConsolidatedData() {
        }

        public ConsolidatedData(Decimal balanceValueCredit, Decimal creditLimit, Decimal discountEquipment, Decimal discountEquipmentCampaign,
                Decimal discountEquipmentClaroClub, Decimal discountsEquipments, Decimal discountService, Decimal discountServiceDependent,
                Decimal discountServiceHolder, Decimal discountSimcard, Decimal equipmentFullPrice, Decimal equipmentPrice,
                Decimal equipmentsFullPrice, Decimal equipmentsPrice, Decimal monthlyEquipmentPrice, Decimal monthlyServicePrice,
                Decimal pointsEquipmentClaroClub, Decimal productOfferingTotalPrice, Decimal productOfferingTotalPriceDependent,
                Decimal productOfferingTotalPriceHolder, Decimal productOfferingTotalPriceServices, Decimal productOfferingTotalPriceServicesDependent,
                Decimal productOfferingTotalPriceServicesHolder, Decimal simcardFullPrice, Decimal simcardPrice, Decimal usedCreditAmount) {
            this.balanceValueCredit = balanceValueCredit;
            this.creditLimit = creditLimit;
            this.discountEquipment = discountEquipment;
            this.discountEquipmentCampaign = discountEquipmentCampaign;
            this.discountEquipmentClaroClub = discountEquipmentClaroClub;
            this.discountsEquipments = discountsEquipments;
            this.discountService = discountService;
            this.discountServiceDependent = discountServiceDependent;
            this.discountServiceHolder = discountServiceHolder;
            this.discountSimcard = discountSimcard;
            this.equipmentFullPrice = equipmentFullPrice;
            this.equipmentPrice = equipmentPrice;
            this.equipmentsFullPrice = equipmentsFullPrice;
            this.equipmentsPrice = equipmentsPrice;
            this.monthlyEquipmentPrice = monthlyEquipmentPrice;
            this.monthlyServicePrice = monthlyServicePrice;
            this.pointsEquipmentClaroClub = pointsEquipmentClaroClub;
            this.productOfferingTotalPrice = productOfferingTotalPrice;
            this.productOfferingTotalPriceDependent = productOfferingTotalPriceDependent;
            this.productOfferingTotalPriceHolder = productOfferingTotalPriceHolder;
            this.productOfferingTotalPriceServices = productOfferingTotalPriceServices;
            this.productOfferingTotalPriceServicesDependent = productOfferingTotalPriceServicesDependent;
            this.productOfferingTotalPriceServicesHolder = productOfferingTotalPriceServicesHolder;
            this.simcardFullPrice = simcardFullPrice;
            this.simcardPrice = simcardPrice;
            this.usedCreditAmount = usedCreditAmount;
        }
    }


    public class ClaroClub {
        public Boolean accessionIndicator = false;

        public ClaroClub() {
            accessionIndicator = false;
        }
    }

    public class CreditAnalysis {
        public String transactionId;
        public Boolean indicatorDocumentationSuspicion;
        public String creditLimit;
        public Integer limitLine;
        public Boolean indicatorRequestAuthority;
        public Result result;
        public List<PaymentPlanAuthorized> paymentPlanAuthorized;

        public CreditAnalysis() {
        }

        public CreditAnalysis(String transactionId, Boolean indicatorDocumentationSuspicion, String creditLimit,
                Boolean indicatorRequestAuthority, Result result, List<PaymentPlanAuthorized> paymentPlanAuthorized,
                Integer limitLine) {
            this.transactionId = transactionId;
            this.indicatorDocumentationSuspicion = indicatorDocumentationSuspicion;
            this.creditLimit = creditLimit;
            this.indicatorRequestAuthority = indicatorRequestAuthority;
            this.limitLine = limitLine;
            this.result = result;
            this.paymentPlanAuthorized = paymentPlanAuthorized;
        }
    }

    public class Portability {
        public String portabilityIndicator;
        public List<Availables> availables;
        public List<Unavailables> unavailables;
        public Tickets tickets;

        public Portability() {
        }
        
         public Portability(String portabilityIndicator) {
             this.portabilityIndicator = portabilityIndicator;
        }

        public Portability(String portabilityIndicator, List<Availables> availables, List<Unavailables> unavailables) {
            this.portabilityIndicator = portabilityIndicator;
            this.availables = availables;
            this.unavailables = unavailables;
        }
    }

    public class Availables {
        public String portabilityIndicatorSource;
        public String detail;
        public String donorOperator;
        public List<Tickets> tickets;

        public Availables() {
        }

        public Availables(String portabilityIndicatorSource, String detail, String donorOperator,
                List<Tickets> tickets) {
            this.portabilityIndicatorSource = 'false';
            this.detail = detail;
            this.donorOperator = donorOperator;
            this.tickets = tickets;
        }
    }

    public class BankingAccount {
        public String accountNumber;
        public String branchNumber;
        public String bankNumber;

        public BankingAccount() {
        }

        public BankingAccount(String accountNumber, String branchNumber, String bankNumber) {
            this.accountNumber = accountNumber;
            this.branchNumber = branchNumber;
            this.bankNumber = bankNumber;
        }
    }

    public class Payment {
        public PaymentPlan paymentPlan;

        public Payment() {
        }

        public Payment(PaymentPlan paymentPlan) {
            this.paymentPlan = paymentPlan;
        }
    }

    public class AddressAnalysis {
        public String transactionId;
        public Reason result;

        public AddressAnalysis() {
        }

        public AddressAnalysis(String transactionId, Reason result) {
            this.transactionId = transactionId;
            this.result = result;
        }
    }

    public class Campaign {
        public String id;
        public String name;
        public String offerRecommendationIndicator;
        public Type_Z category;
        public Equimpment equimpment;
        public List<SubCampaign> subCampaign;

        public Campaign() {
        }

        public Campaign(String id, String name, String offerRecommendationIndicator, Type_Z category, Equimpment equimpment,
                List<SubCampaign> subCampaign) {
            this.id = id;
            this.name = name;
            this.offerRecommendationIndicator = offerRecommendationIndicator;
            this.category = category;
            this.equimpment = equimpment;
            this.subCampaign = subCampaign;
        }
    }

    public class Correlations {
        public String id;
        public String sourceSystemId;

        public Correlations() {
        }

        public Correlations(String id, String sourceSystemId) {
            this.id = id;
            this.sourceSystemId = sourceSystemId;
        }
    }

    public class Individual {
        public String partyType;
        public String maritalStatus;
        public String name;
        public String dateOfBirth;
        public String motherName;
        public String nationality;
        public String gender;
        public List<PartyIdentifications> partyIdentifications;
        public FiscalProfile fiscalProfile;
        public Employment employment;
        public List<Contacts> contacts;
        public List<Addresses> addresses;

        public Individual() {
        }

        public Individual(String partyType, String maritalStatus, String name, String dateOfBirth, String motherName,
                String gender, List<PartyIdentifications> partyIdentifications, FiscalProfile fiscalProfile,
                Employment employment, List<Contacts> contacts, List<Addresses> addresses) {
            this.partyType = partyType;
            this.maritalStatus = maritalStatus;
            this.name = name;
            this.dateOfBirth = dateOfBirth;
            this.motherName = motherName;
            this.gender = gender;
            this.partyIdentifications = partyIdentifications;
            this.fiscalProfile = fiscalProfile;
            this.employment = employment;
            this.contacts = contacts;
            this.addresses = addresses;
        }

        public Individual(String partyType, String maritalStatus, String name, String dateOfBirth, String motherName,
                String gender, List<PartyIdentifications> partyIdentifications) {
            this.partyType = partyType;
            this.maritalStatus = maritalStatus;
            this.name = name;
            this.dateOfBirth = dateOfBirth;
            this.motherName = motherName;
            this.gender = gender;
            this.partyIdentifications = partyIdentifications;
        }
    }

    public class PaymentPlan {
        public String id;
        public Boolean indicatorAdvancePayment;
        public Type_Z paymentMethod;
        public List<ItemPaymentMixed> itemPaymentMixed;
        public Installment installment;

        public PaymentPlan() {
        }

        public PaymentPlan(String id, Boolean indicatorAdvancePayment, Type_Z paymentMethod,
                List<ItemPaymentMixed> itemPaymentMixed, Installment installment) {
            this.id = id;
            this.indicatorAdvancePayment = indicatorAdvancePayment;
            this.paymentMethod = paymentMethod;
            this.itemPaymentMixed = itemPaymentMixed;
            this.installment = installment;
        }
    }

    public class GracePeriod
    {
        public String effectiveDate;
        public String expirationDate;
        public Integer quantity;
        public String unitOfMeasure;

        public GracePeriod() {
        }

        public GracePeriod(String effectiveDate, String expirationDate, Integer quantity, String unitOfMeasure) {
            this.effectiveDate = effectiveDate;
            this.expirationDate = expirationDate;
            this.quantity = quantity;
            this.unitOfMeasure = unitOfMeasure;
        }
    }

    public class ApplicationOperation
    {
        public String id;
        public String description;

        public ApplicationOperation() {
        }

        public ApplicationOperation(String id, String description) {
            this.id = id;
            this.description = description;
        }
    }

    public class Penalty
    {
        public String amount;
        public String type_Z;
        public String description;
        public ApplicationOperation applicationOperation;

        public Penalty() {
        }

        public Penalty(String amount, String type_z, String description, ApplicationOperation applicationOperation) {
            this.amount = amount;
            this.type_z = type_z;
            this.description = description;
            this.applicationOperation = applicationOperation;
        }
    }

    public class Loyalty
    {
        public boolean gracePeriodIndicator;
        public GracePeriod gracePeriod;
        public Penalty penalty;

        public Loyalty() {
            gracePeriodIndicator=false;
        }

        public Loyalty(boolean gracePeriodIndicator, GracePeriod gracePeriod, Penalty penalty) {
            this.gracePeriodIndicator = true;
            this.gracePeriod = gracePeriod;
            this.penalty = penalty;
        }
    }

    public class SubCampaign {
        public String id;
        public String name;
        public Equimpment equimpment;

        public SubCampaign() {
        }

        public SubCampaign(Equimpment equimpment) {
            this.equimpment = equimpment;
        }

        public SubCampaign(String id, String name, Equimpment equimpment) {
            this.id = id;
            this.name = name;
            this.equimpment = equimpment;
        }
    }

    public class Application {
        public String id;
        public String identificationKey;
        public String name;
        public String version = '2.37.10';
        public List<Type_z> types;
        public SalesOrderIntegrationDTO.Session session;
        public List<Channel> channels;
        public User_X user;

        public Application() {
        }

        public Application(String id, String name, String version, List<Type_z> types, List<Channel> channels, User_X user) {
            this.id = id;
            this.identificationKey = identificationKey;
            this.name = name;
            this.version = version;
            this.types = types;
            this.session = session;
            this.channels = channels;
            this.user = user;
        }

        public Application(String id, String identificationKey, String name, String version,
                List<Type_z> types, SalesOrderIntegrationDTO.Session session, List<Channel> channels, User_X user) {
            this.id = id;
            this.identificationKey = identificationKey;
            this.name = name;
            this.version = version;
            this.types = types;
            this.session = session;
            this.channels = channels;
            this.user = user;
        }
    }

    public class Channel {
        public String id;

        public Channel(String id) {
            this.id = id;
        }
    }

    public class Session {
        public String id;
        public String startDate;
        public Boolean startIndicator;

        public Session() {
        }

        public Session(String id, String startDate, Boolean startIndicator) {
            this.id = id;
            this.startDate = startDate;
            this.startIndicator = startIndicator;
        }
    }

    public class PaymentPlanAuthorized {
        public Type_Z paymentMethod;
        public ItemPaymentMixed itemPaymentMixed;

        public PaymentPlanAuthorized() {
        }

        public PaymentPlanAuthorized(Type_Z paymentMethod, ItemPaymentMixed itemPaymentMixed) {
            this.paymentMethod = paymentMethod;
            this.itemPaymentMixed = itemPaymentMixed;
        }
    }

    public class Authority {
        public Operation_Z operation;

        public Authority() {
        }

        public Authority(Operation_Z operation) {
            this.operation = operation;
        }
    }

    public class Operation_Z {
        public Type_Z category;
        public User_Z user;
        public Type_Z status;

        public Operation_Z() {
        }

        public Operation_Z(Type_Z category, User_Z user, Type_Z status) {
            this.category = category;
            this.user = user;
            this.status = status;
        }
    }

    public class TelephoneNumberResource {
        public String id;
        public String name;
        public String iccid;
        public TelephoneNumber_Z telephoneNumber;
        public Portability portability;
        public Equipment equimpment;

        public TelephoneNumberResource() {
        }
        public TelephoneNumberResource(TelephoneNumber_Z telephoneNumber) {
            this.telephoneNumber = telephoneNumber;
        }
        
         public TelephoneNumberResource(String iccid, TelephoneNumber_Z telephoneNumber) {
            this.iccid = iccid;
             this.telephoneNumber = telephoneNumber;
             this.portability = portability;

        }

    }

    public class Operation {
        public String id;
        public String name;
        public String description;
        public Type_Z type_Z; // in json: type
        public Type_Z category;

        public Operation() {
        }

        public Operation(String id, String name, Type_Z type_Z, Type_Z category, String description) {
            this.id = id;
            this.name = name;
            this.type_Z = type_Z;
            this.description = description;
            this.category = category;
        }
    }

    public class ItemTablePrice {
        public Model productOffering;
        public List<EquipmentPaymentPlan> equipmentPaymentPlan;

        public ItemTablePrice() {
        }

        public ItemTablePrice(Model productOffering, List<EquipmentPaymentPlan> equipmentPaymentPlan) {
            this.productOffering = productOffering;
            this.equipmentPaymentPlan = equipmentPaymentPlan;
        }
    }

    public class Promotion {
        public String id;
        public String name;
        public String description;
        public String discount;
        public String expirationDate;
        public String expirationPeriod;
        public String productOfferingPrice;
        public String promotionalPrice;
        public List<Type_Z> category;

        public Promotion() {
        }

        public Promotion(String id, String name, String description, String discount, String expirationDate,
                String expirationPeriod, String productOfferingPrice, String promotionalPrice, List<Type_Z> category) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.discount = discount;
            this.expirationDate = expirationDate;
            this.expirationPeriod = expirationPeriod;
            this.productOfferingPrice = productOfferingPrice;
            this.promotionalPrice = promotionalPrice;
            this.category = category;
        }
    }

    public class EquipmentPaymentPlan {
        public String tableAmount;
        public String cashAmount;
        public String discountAmount ;
        public String installmentNr;
        public String installmentAmount;
        public String balanceAmount;
        public String totalAmountInterest;
        public String percentAmountInterest;
        public String percentUnitOfMeasure;

        public EquipmentPaymentPlan() {
        }

        public EquipmentPaymentPlan(String tableAmount, String cashAmount, String discountAmount, String installmentNr,
                String installmentAmount, String balanceAmount, String totalAmountInterest,
                String percentAmountInterest, String percentUnitOfMeasure) {
            this.tableAmount = tableAmount;
            this.cashAmount = cashAmount;
            this.discountAmount = discountAmount;
            this.installmentNr = installmentNr;
            this.installmentAmount = installmentAmount;
            this.balanceAmount = balanceAmount;
            this.totalAmountInterest = totalAmountInterest;
            this.percentAmountInterest = percentAmountInterest;
            this.percentUnitOfMeasure = percentUnitOfMeasure;
        }
    }

    public class Reason {
        public String id;
        public String description;

        public Reason() {
        }

        public Reason(String id, String description) {
            this.id = id;
            this.description = description;
        }
    }

    public class Profile_z {
        public String id;
        public String name;

        public Profile_z() {
        }

        public Profile_z(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    public class MarketSegments {
        public String areaCode;
        public String placeId;

        public MarketSegments() {
        }

        public MarketSegments(String areaCode, String placeId) {
            this.areaCode = areaCode;
            this.placeId = placeId;
        }
    }

    public class Equimpment {
        public List<ItemTablePrice_Z> itemTablePrice;

        public Equimpment() {
        }

        public Equimpment(List<ItemTablePrice_Z> itemTablePrice) {
            this.itemTablePrice = itemTablePrice;
        }
    }

    public class Employment {
        public String salaryRangeId;
        public String occupation;

        public Employment() {
        }

        public Employment(String salaryRangeId, String occupation) {
            this.salaryRangeId = salaryRangeId;
            this.occupation = occupation;
        }
    }

    public class BillingAccount_z {
        public Customer customer;

        public BillingAccount_z(Customer customer) {
            this.customer = customer;
        }
    }

    public class BillingAccount {
        public String indicatorPaymentCreditCardPM;
        public String paymentMethodRequest;
        public String invoiceAvailabilityMethod;
        public String gatewayPaymentAccountId;
        public String gatewayPaymentId;
        public BillingCycle billingCycle;
        public BillingAccount_z billingAccount;
        public BankingAccount bankingAccount;
        public Addresses billingAddress;
        public DigitalInvoice digitalInvoice;
        public Customer customer;

        public BillingAccount() {
        }

        public BillingAccount(String indicatorPaymentCreditCardPM, String paymentMethodRequest, String invoiceAvailabilityMethod,
                String gatewayPaymentAccountId, String gatewayPaymentId, BillingCycle billingCycle, BankingAccount bankingAccount,
                Addresses billingAddress, DigitalInvoice digitalInvoice, BillingAccount_z billingAccount) {
            this.indicatorPaymentCreditCardPM = indicatorPaymentCreditCardPM;
            this.paymentMethodRequest = paymentMethodRequest;
            this.invoiceAvailabilityMethod = invoiceAvailabilityMethod;
            this.gatewayPaymentAccountId = gatewayPaymentAccountId;
            this.gatewayPaymentId = gatewayPaymentId;
            this.billingCycle = billingCycle;
            this.bankingAccount = bankingAccount;
            this.billingAddress = billingAddress;
            this.digitalInvoice = digitalInvoice;
            this.billingAccount = billingAccount;
        }
    }

    public class Tickets_Z {
        public Window window;

        public Tickets_Z() {
        }

        public Tickets_Z(Window window) {
            this.window = window;
        }
    }

    public class PartyIdentifications {
        public String number_Z;
        public String type_Z;
        public String issuer;
        public String issueDate;

        public PartyIdentifications(String number_Z, String type_Z, String issuer, String issueDate) {
            this.number_Z = number_Z;
            this.type_Z = type_Z;
            this.issuer = issuer;
            this.issueDate = issueDate;
        }

        public PartyIdentifications(String number_Z, String type_Z) {
            this.number_Z = number_Z;
            this.type_Z = type_Z;
        }

        public PartyIdentifications() {
        }
    }

    public class Window {
        //public String requestDate;
        public String nextDateAvailable;

        public Window() {
        }

        public Window(String requestDate, String nextDateAvailable) {
            //this.requestDate = requestDate;
            this.nextDateAvailable = nextDateAvailable;
        }
    }

    public class Installment {
        public Boolean eligibleOptionIndicator;
        public String installmentNr;
        public String amount;

        public Installment(Boolean eligibleOptionIndicator, String installmentNr, String amount) {
            this.eligibleOptionIndicator = eligibleOptionIndicator;
            this.installmentNr = installmentNr;
            this.amount = amount;
        }

        public Installment() {
        }
    }

    public class ProductBundle {
        public String id;
        public String name;
        public String description;
        public String dependentsQuantity;
        public List<Profile_z> offer;
        public List<ProductSpecification> productSpecification;

        public ProductBundle() {
        }

        public ProductBundle(String id, String name, String description, String dependentsQuantity, List<Profile_z> offer,
                List<ProductSpecification> productSpecification) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.dependentsQuantity = dependentsQuantity;
            this.offer = offer;
            this.productSpecification = productSpecification;
        }
    }

    public class Service {
        public String id;
        public String name;
        public String price;
        public Profile_z category;

        public Service() {
        }

        public Service(String id, String name, String price, Profile_z category) {
            this.id = id;
            this.name = name;
            this.price = price;
            this.category = category;
        }
    }

    public class SalesAgent {
        public String id;
        public String partyType;
        public String tradingName;
        public List<Addresses> addresses;
        public String typeId;
        public String typeDescription;
        public String channel;
        public String regional;
        public String regionalIwId;
        public List<PointsOfSale> pointsOfSale;

        public SalesAgent() {
        }

        public SalesAgent(String id, String partyType, String tradingName, List<Addresses> addresses, String typeId,
                String typeDescription, String channel, String regionalIwId, String regional, List<PointsOfSale> pointsOfSale) {
            this.id = id;
            this.partyType = partyType;
            this.tradingName = tradingName;
            this.addresses = addresses;
            this.typeId = typeId;
            this.typeDescription = typeDescription;
            this.channel = channel;
            this.regional = regional;
            this.pointsOfSale = pointsOfSale;
            this.regionalIwId = regionalIwId;
        }
    }

    public class FiscalProfile {
        public String classification;
        public Boolean incomeTaxPayerIndicator;
        public Boolean fomeZeroContributorIndicator;
        public Boolean povertyReliefContributorIndicator;

        public FiscalProfile() {
        }

        public FiscalProfile(String classification, Boolean incomeTaxPayerIndicator, Boolean fomeZeroContributorIndicator,
                Boolean povertyReliefContributorIndicator) {
            this.classification = classification;
            this.incomeTaxPayerIndicator = incomeTaxPayerIndicator;
            this.fomeZeroContributorIndicator = fomeZeroContributorIndicator;
            this.povertyReliefContributorIndicator = povertyReliefContributorIndicator;
        }
    }

    public class ProductSpecification {
        public String name;
        public String type_Z; // in json: type
        public String subType;
        public String sharedProductIndicator;
        public ProductOffering_Z productOffering;

        public ProductSpecification() {
        }

        public ProductSpecification(String name, String type_Z, String subType, String sharedProductIndicator,
                ProductOffering_Z productOffering) {
            this.name = name;
            this.type_Z = type_Z;
            this.subType = subType;
            this.sharedProductIndicator = sharedProductIndicator;
            this.productOffering = productOffering;
        }
    }

    public class Unavailables {
        public List<Tickets> tickets;
        public Reason reason;

        public Unavailables() {
        }

        public Unavailables(List<Tickets> tickets, Reason reason) {
            this.tickets = tickets;
            this.reason = reason;
        }
    }

    public class Contacts {
        public String name;
        public String emailAddress;
        public TelephoneNumber telephoneNumber;

        public Contacts() {
        }

        public Contacts(String name, TelephoneNumber telephoneNumber, String emailAddress) {
            this.name = name;
            this.telephoneNumber = telephoneNumber;
            this.emailAddress = emailAddress;
        }

        public Contacts(String emailAddress, TelephoneNumber telephoneNumber) {
            this.emailAddress = emailAddress;
            this.telephoneNumber = telephoneNumber;
        }
    }

    public class Equipment {
        public String id;
        public String stockAvailability;
        public String typeId;
        public String imei;
        public String eligible;
        public String color;
        public Model model;
        public Manufacturer manufacturer;
        public List<ItemTablePrice> itemTablePrice;

        public Equipment(String id, String stockAvailability, String imei, String eligible, String color, Model model,
                List<ItemTablePrice> itemTablePrice, Manufacturer manufacturer, String typeId) {
            this.id = id;
            this.stockAvailability = stockAvailability;
            this.imei = imei;
            this.eligible = eligible;
            this.color = color;
            this.model = model;
            this.itemTablePrice = itemTablePrice;
            this.manufacturer = manufacturer;
            this.typeId = typeId;
        }

        public Equipment() {
        }
    }

    public class Portability_Z {
        public Tickets_Z tickets;

        public Portability_Z(Tickets_Z tickets) {
            this.tickets = tickets;
        }

        public Portability_Z() {
        }
    }

    public class ProductOffering {
        public String id;
        public String name;
        public String nickname;
        public String description;
        public String expirationDate;
        public String extensionIndicator;
        public String offerRecommendationIndicator;
        public String price;
        public String type_Z; // in json: type
        public String subType;
        public String characteristicId;
        public CreditLimitAnalysis creditLimitAnalysis;
        public Promotion promotion;
        public String maxDependent;

        public ProductOffering() {
        }

        public ProductOffering(String id, String name, String nickname, String description, String expirationDate,
                String extensionIndicator, String offerRecommendationIndicator, String price, String type_Z,
                String subType, String characteristicId, CreditLimitAnalysis creditLimitAnalysis, boolean sharedOffer) {
            this.id = id;
            this.name = name;
            this.nickname = nickname;
            this.description = description;
            this.expirationDate = expirationDate;
            this.extensionIndicator = extensionIndicator;
            this.offerRecommendationIndicator = offerRecommendationIndicator;
            this.price = price;
            this.type_Z = type_Z;
            this.subType = subType;
            this.characteristicId = characteristicId;
            this.creditLimitAnalysis = creditLimitAnalysis;
        }
    }

    public class Model {
        public String id;
        public String name ;
        public String description;

        public Model() {
        }

        public Model(String id, String name, String description) {
            this.id = id;
            this.name = name;
            this.description = description;
        }
    }

    public class Contract {
        public BillingAccount billingAccount;
        public Customer customer;
        public String id;

        public Contract() {
        }

        public Contract(BillingAccount billingAccount, Customer customer, String id) {
            this.billingAccount = billingAccount;
            this.customer = customer;
            this.id = id;
        }
    }

    public class MobileSubType {
        public String id;

        public MobileSubType(String id) {
            this.id = id;
        }
    }

    public class MobileType {
        public String id;

        public MobileType(String id) {
            this.id = id;
        }
    }

    public class Passport {
        public String number_z;

        public Passport(String number_z) {
            this.number_z = number_z;
        }
    }

    public class TargetProduct {
        public String id ;
        public String name;
        public String type_Z; // in json: type
        public String subType;
        public String transmissionMethod;
        public String compositionType;
        public Boolean isMainProduct;
        public Contract contract;
        public Loyalty loyalty;
        public ProductOffering productOffering;
        public ProductBundle productBundle;
        public List<Equipment> equipment;
        public List<Campaign> campaign;
        public TelephoneNumberResource telephoneNumberResource;
        public List<Service> service;
        public Promotion promotion;
        public String sharedOffer;
        public boolean sharedIndicator;
        public String categoryAllowedSharing;
        public String categoryDependentProduct;

        public TargetProduct() {
        }

        public TargetProduct(String id, String name, String type_Z, String subType, String transmissionMethod,
                String compositionType, Boolean isMainProduct, Contract contract, Loyalty loyalty,
                ProductOffering productOffering, ProductBundle productBundle, List<Equipment> equipment,
                List<Campaign> campaign, TelephoneNumberResource telephoneNumberResource, List<Service> service,
                Promotion promotion, String sharedOffer, String categoryAllowedSharing, String categoryDependentProduct, boolean sharedIndicator) {
            this.id = id;
            this.name = name;
            this.type_Z = type_Z;
            this.subType = subType;
            this.transmissionMethod = transmissionMethod;
            this.compositionType = compositionType;
            this.isMainProduct = isMainProduct;
            this.contract = contract;
            this.loyalty = loyalty;
            this.productOffering = productOffering;
            this.productBundle = productBundle;
            this.equipment = equipment;
            this.campaign = campaign;
            this.telephoneNumberResource = telephoneNumberResource;
            this.service = service;
            this.promotion = promotion;
            this.categoryAllowedSharing = categoryAllowedSharing;
            this.categoryDependentProduct = categoryDependentProduct;
            this.sharedOffer = sharedOffer;
            this.sharedIndicator = sharedIndicator;
        }
    }

//================================================== LOYALTY ===========================================================

    private SalesOrderIntegrationDTO.Loyalty builderLoyalty(ProductsIntegrationDTO.ProductsResponses productsResponse) {
        String today = CEC_Utils.normalizeDate(string.valueof(Date.today()));
        String expiration = CEC_Utils.normalizeDate(string.valueof(Date.today().addMonths(12)));

        return new Loyalty(productsResponse.havePenality(),
                new GracePeriod(today, expiration, 12, 'MESES'),
                new Penalty(productsResponse.getAmountPenality(), 'SERVICO', productsResponse.descriptionPenality,
                    new ApplicationOperation('ISNPE', 'A multa de permanência será isentada.')));
    }

//================================================== CREDIT ============================================================

    /*private SalesOrderIntegrationDTO.CreditAnalysis builderCreditAnalysis() {
        List<PaymentPlanAuthorized> plans = new List<PaymentPlanAuthorized>();
        plans.add(new PaymentPlanAuthorized(new Type_z(null), new ItemPaymentMixed(null,new Type_z(null))));

       return new CreditAnalysis(null, null, null, null, new Result(null, null,
                        new Reason(null, null)), plans, null);
    }*/

//================================================== COSTUMER ==========================================================

    private SalesOrderIntegrationDTO.Customer builderCustomer(Order order, IBGE__c ibge) {
        if(ibge == null) {
            ibge = new IBGE__c();
        }
        List<SalesOrderIntegrationDTO.PartyIdentifications> p = new List<SalesOrderIntegrationDTO.PartyIdentifications>();
        p.add(new SalesOrderIntegrationDTO.PartyIdentifications(order.Account.DocumentNumber__c, 'CPF'));
        p.add(new SalesOrderIntegrationDTO.PartyIdentifications(order.Account.RG__c, 'RG', order.Account.RGEmitter__c, null)); 

        SalesOrderIntegrationDTO.FiscalProfile fiscalProfile = new SalesOrderIntegrationDTO.FiscalProfile('PESSOA_FISICA',
                false, false, false);           //TODO PODE SER TUDO FALSE?

        /*SalesOrderIntegrationDTO.Employment employment = new SalesOrderIntegrationDTO.Employment(order.Account.SalaryRange__c, order.Account.Occupation__c);*/
        SalesOrderIntegrationDTO.Employment employment = new SalesOrderIntegrationDTO.Employment('1','1');
        List<SalesOrderIntegrationDTO.Contacts> c = new List<SalesOrderIntegrationDTO.Contacts>();
        c.add(new SalesOrderIntegrationDTO.Contacts(order.Account.Email__c, new SalesOrderIntegrationDTO.telephoneNumber(order.Account.Phone,
                new SalesOrderIntegrationDTO.Mobile(order.Account.Phone))));

        List<SalesOrderIntegrationDTO.Addresses> a = new List<SalesOrderIntegrationDTO.Addresses>();
        a.add(new SalesOrderIntegrationDTO.Addresses('LOGRADOURO', 'LOGRADOURO',
                order.BillingPostalCode != null ? order.BillingPostalCode : '', 'R',
                order.BillingStreet != null ? order.BillingStreet : '',
                order.BillingNumber__c !=null ? order.BillingNumber__c : '',
                order.BillingComplement__c != null ? order.BillingComplement__c : '',
                order.BillingNeighborhood__c != null ? order.BillingNeighborhood__c : null,
                order.BillingCity, ibge.UF__c, ibge.UF__c,
                order.BillingDDD__c, ibge.IBGECode__c, 'R'));

        SalesOrderIntegrationDTO.CustomerAcceptances customerAcceptances =
                new SalesOrderIntegrationDTO.CustomerAcceptances(order.Account.ReceiveSMS__c, null);

        /*SalesOrderIntegrationDTO.Individual i = new SalesOrderIntegrationDTO.Individual('PF',
                order.Account.MaritalStatus__c, order.Account.Name, string.valueof(order.Account.BirthDate__c),
                order.Account.MothersName__c, order.Account.Gender__c.substring(0, 1), p, fiscalProfile, employment, c, a);*/

        SalesOrderIntegrationDTO.Individual i = new SalesOrderIntegrationDTO.Individual('PF',
                '1', order.Account.Name, string.valueof(order.Account.BirthDate__c),
                order.Account.MothersName__c, order.Account.Gender__c.substring(0, 1), p, fiscalProfile, employment, c, a);
        
        return new SalesOrderIntegrationDTO.Customer(i, customerAcceptances);
    }

//================================================== SALESMAN ==========================================================

    private SalesOrderIntegrationDTO.Salesman builderSalesman(User user, Order order, SalesManDTO.SalesMen salesmen, IBGE__c ibge, Profile profile) {
        if(ibge == null) {
            ibge = new IBGE__c();
        }
        List<SalesOrderIntegrationDTO.PartyIdentifications> p = new List<SalesOrderIntegrationDTO.PartyIdentifications>();
        p.add(new SalesOrderIntegrationDTO.PartyIdentifications(user.CPF__c, 'CPF'));

        List<SalesOrderIntegrationDTO.Contacts> c = new List<SalesOrderIntegrationDTO.Contacts>();
        c.add(new SalesOrderIntegrationDTO.Contacts(User.Email, new SalesOrderIntegrationDTO.telephoneNumber(User.Phone)));

        List<SalesOrderIntegrationDTO.Addresses> a = new List<SalesOrderIntegrationDTO.Addresses>();
        a.add(new SalesOrderIntegrationDTO.Addresses('LOGRADOURO', 'LOGRADOURO', salesmen.salesAgent.address.postalCode, 'R',
                salesmen.salesAgent.address.streetName, salesmen.salesAgent.address.streetNumber,order.BillingComplement__c, 
                salesmen.salesAgent.address.neighborhood, salesmen.salesAgent.address.city, ibge.UF__c, ibge.UF__c,
                 order.BillingDDD__c, ibge.IBGECode__c, 'R'));

        List<SalesOrderIntegrationDTO.MarketSegments> market = new List<SalesOrderIntegrationDTO.MarketSegments>();
        
        system.debug('DDD: '+order.BillingDDD__c);
        system.debug('UF: '+ibge.UF__c);
        market.add(new SalesOrderIntegrationDTO.MarketSegments(order.BillingDDD__c, ibge.UF__c));

        List<SalesOrderIntegrationDTO.PointsOfSale> point = new List<SalesOrderIntegrationDTO.PointsOfSale>();
        for (SalesManDTO.PointSale s : salesmen.salesAgent.pointSale)
            point.add(new SalesOrderIntegrationDTO.PointsOfSale(s.iwSalesAgentId, s.businessName));

        SalesOrderIntegrationDTO.SalesAgent salesAgent = new SalesOrderIntegrationDTO.SalesAgent(salesmen.salesAgent.iwSalesAgentId, 'PJ',
                user.CompanyName, null, salesmen.salesAgent.iwTypeId, salesmen.salesAgent.description,
                'AA_TELEVENDAS', salesmen.salesAgent.iwRegionalId, user.CEC_Regional__c, point);
        
        return new SalesOrderIntegrationDTO.Salesman(salesmen.id, user.Name, p, c,
                new SalesOrderIntegrationDTO.Status_Z(user.IsActive ? 'ATIVO' : 'BLOQUEADO', 
                CEC_Utils.normalizeDate(string.valueof(user.LastModifiedDate))),
                user.ProfileId, 'PF', null, null,
                new SalesOrderIntegrationDTO.User_X(user.Claro__c, 
                SalesManDTO.convertProfile2SalerOrderProfile(profile),
                user.Name), null, salesAgent);   // TODO JOBPOSTION OBRIGATORIO?
    }

//================================================== BILLINGACCOUNT ====================================================

    private SalesOrderIntegrationDTO.BillingAccount builderBillingAccount(Order order, IBGE__c ibge, boolean thab ) {
        List<SalesOrderIntegrationDTO.Contacts> c = new List<SalesOrderIntegrationDTO.Contacts>();
        c.add(new SalesOrderIntegrationDTO.Contacts(order.Account.Email__c, new SalesOrderIntegrationDTO.telephoneNumber(order.Account.Phone,
                new SalesOrderIntegrationDTO.Mobile(order.Account.Phone))));

        SalesOrderIntegrationDTO.BillingCycle billingCycle = new SalesOrderIntegrationDTO.BillingCycle();
        SalesOrderIntegrationDTO.BankingAccount bankingAccount = new SalesOrderIntegrationDTO.BankingAccount();

        SalesOrderIntegrationDTO.Addresses addresses = new SalesOrderIntegrationDTO.Addresses('LOGRADOURO',
                'LOGRADOURO', order.BillingPostalCode, 'R', order.BillingStreet, order.BillingNumber__c,
                order.BillingComplement__c, order.BillingNeighborhood__c, order.BillingCity, order.BillingState,
                order.BillingState, order.BillingDDD__c, ibge.IBGECode__c, 'R');

        if (order.Forma_de_Pagamento__c.equals('Débito automático')) {
            bankingAccount = new SalesOrderIntegrationDTO.BankingAccount(order.NumeroConta__c, order.Agencia__c, order.Banco__c);
        }

        //Se forma de pagamento for boleto e o a analise de crédito for Thab, buscar primeira data disponivel para vencimento do boleto.
        if((order.Forma_de_Pagamento__c.equals('Boleto')) && thab)
        {
            CEC_IntegrationBillingCycles.BillingCyclesResponse integration = new CEC_IntegrationBillingCycles.BillingCyclesResponse();
            integration = CEC_IntegrationBillingCycles.consultar();
            order.BillingId__c = integration.data.billingCycles[0].code;
            order.BillingDescription__c = integration.data.billingCycles[0].description;
            order.DiaVencimento__c = integration.data.billingCycles[0].dueDay;
        }
              
        billingCycle = new SalesOrderIntegrationDTO.BillingCycle(order.BillingId__c,
                string.valueof(order.vlocity_cmt__ExpirationDate__C),
                string.valueof(order.vlocity_cmt__DueDate__C),
                new SalesOrderIntegrationDTO.Type_Z(order.BillingStatus__c),
                order.BillingDescription__c,
                order.BillingId__c
        );

        return new SalesOrderIntegrationDTO.BillingAccount(null, 
                order.Forma_de_Pagamento__c.equals('Débito automático')? 'DEBITO_AUTOMATICO':'BOLETO_ARRECADACAO',
                order.TipoFatura__c.equals('Email') ? 'FATURA_DIGITAL' : 'IMPRESSA', null,
                null, billingCycle, bankingAccount, addresses,
                new SalesOrderIntegrationDTO.DigitalInvoice(order.TipoFatura__c.equals('Email') ? 'INTEGRAL' : 'PARCIAL', c),
                new SalesOrderIntegrationDTO.BillingAccount_z(new Customer('PF', 'PESSOA_FISICA')));
    }

//================================================== ITENS =============================================================

    private List<SalesOrderIntegrationDTO.Items> builderItems(List<ProductsIntegrationDTO.ProductsResponses> products, Order order,
            map<Id,PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> numberReservation,
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys, IBGE__c ibge, map<Id, List<Tickets>> mapTickets) {

                system.debug('PROD_ITEMS: '+json.serialize(products));  
                
                List<SalesOrderIntegrationDTO.Items> items = new List<SalesOrderIntegrationDTO.Items>();
                
                for(OrderItem ordItem : order.OrderItems)
                {
                    for (ProductsIntegrationDTO.ProductsResponses p : products) 
                    {
                        if(ordItem.Id == p.itemId)
                        {
                            system.debug('numberReservation-DTO: '+numberReservation);
                            TelephoneNumberResource telephoneResource = new TelephoneNumberResource();
                            List<SalesOrderIntegrationDTO.Type_Z> t = new List<SalesOrderIntegrationDTO.Type_Z>();
                            t.add(new SalesOrderIntegrationDTO.Type_Z(p.data.product.promotion.category.id));
                            
                            if(numberReservation.get(p.itemId).data.telephoneNumbers.size() == 2)
                            {
                                telephoneResource = new TelephoneNumberResource(null, new TelephoneNumber_Z(numberReservation.get(p.itemId).data.telephoneNumbers[1].number_z, numberReservation.get(p.itemId).data.telephoneNumbers[0].number_z));
                            }
                            else if(numberReservation.get(p.itemId).data.telephoneNumbers.size() == 1)
                            {
                                if(!ordItem.Portabilidade__c)
                                {
                                    telephoneResource = new TelephoneNumberResource(null, new TelephoneNumber_Z(numberReservation.get(p.itemId).data.telephoneNumbers[0].number_z, null));
                                }
                                else if(ordItem.Portabilidade__c && !ordItem.NumeroProvisorio__c)
                                {
                                    telephoneResource = new TelephoneNumberResource(null, new TelephoneNumber_Z(numberReservation.get(p.itemId).data.telephoneNumbers[0].number_z, null));
                                }
                            }
                            Portability portability = new portability();
                            if(ordItem.Portabilidade__c)
                            {
                                portability.tickets = mapTickets.get(ordItem.Id)[0];
                            }
                            portability.portabilityIndicator = String.valueOf(ordItem.Portabilidade__c);
                            telephoneResource.portability = portability;
                            
                            
                            
                            Boolean sharedIndicator = Boolean.valueOf(p.data.product.sharedProductIndicator == null || p.data.product.sharedProductIndicator == 'true' ? true : false);
                            system.debug('sharedIndicator-VALUE: '+sharedIndicator);
                            system.debug('sharedIndicator-VALUE!: '+!sharedIndicator);
                            system.debug('NAME: '+p.data.product.promotion.name);
                            
                            SalesOrderIntegrationDTO.TargetProduct targetProduct = new SalesOrderIntegrationDTO.targetProduct(
                                (p.type_z.equals('Controle') ? '3' : '1'), 
                                p.data.product.productOffering.name, 'VOZ',
                                'MOVEL', 'REDE_CELULAR', (order.Unidade__c.equals('Móvel') ? 'INDIVIDUAL' : 'COMBO'),
                                true, 
                                null,//builderContract(order, ibge), 
                                p.havePenality() ? builderLoyalty(p) : null,
                                builderProductOffering(p.data,p.type_z, sharedIndicator),
                                null,
                                null,
                                null,
                                telephoneResource,
                                !p.data.product.services.isEmpty() ? builderService(p.data) : null,
                                new SalesOrderIntegrationDTO.Promotion(p.data.product.promotion.id, p.data.product.promotion.name,
                                                                       p.data.product.promotion.description, p.data.product.promotion.discount,
                                                                       p.data.product.promotion.expirationDate, '0', p.data.product.productOffering.price,
                                                                       p.data.product.offer.price, t),
                                p.title == 'TITULAR' || (p.title.contains('DEP') && !sharedIndicator) ? null : p.data.product.promotion.id, //sharedOffer
                                p.title == 'TITULAR' || (p.title.contains('DEP') && !p.type_z.equals('Controle') && !sharedIndicator) ? null :  p.type_z.equals('Controle') ? 'SOMENTE_INDIVIDUAL' : 'SOMENTE_COMPARTILHADO', //categoryAllowedSharing
                                p.title == 'TITULAR' || (p.title.contains('DEP') && !p.type_z.equals('Controle') && !sharedIndicator) ? null : ordItem.Portabilidade__c ? 'PORTADO' : 'NOVO', //categoryDependentProduct  
                                p.title == 'TITULAR' || (p.title.contains('DEP') && !p.type_z.equals('Controle') && !sharedIndicator) ? null : sharedIndicator); //sharedIndicator
                            
                            items.add(new SalesOrderIntegrationDTO.Items(p.title, null, targetProduct,
                                                                         builderConsolidatedDataSimple(p, order, credAnalisys)));
                        }
                    }
                }
                return items;
            }

//================================================== CONSOLIDATEDATA ===================================================

    private SalesOrderIntegrationDTO.ConsolidatedData builderConsolidatedDataSimple(ProductsIntegrationDTO.ProductsResponses product, Order order,
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys) {
                if(credAnalisys == null) {
                    credAnalisys = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp();
                }
                if(credAnalisys.data == null) {
                    credAnalisys.data = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData();
                }
                if(credAnalisys.data.creditLimit == null) {
                    credAnalisys.data.creditLimit = '0';
                }
                if(product.orderprice == null) {
                    product.orderprice = '0';
                }
                
        return new ConsolidatedData(
                Decimal.valueOf(credAnalisys.data.creditLimit) - Decimal.valueOf(product.orderprice),
                0, //Decimal.valueOf(credAnalisys.data.creditLimit),
                0,
                0,
                0,
                34.90,
                0,
                0,
                0,
                34.90,
                0,
                0,
                0,
                Decimal.valueOf(product.orderPrice),
                34.90,
                Decimal.valueOf(product.orderPrice),
                0, 
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                34.90,
                order.TotalAmount);
    }

    private SalesOrderIntegrationDTO.ConsolidatedData builderConsolidatedData(List<ProductsIntegrationDTO.ProductsResponses> products, Order order,
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys) {
                if(credAnalisys == null) {
                    credAnalisys = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp();
                }
                if(credAnalisys.data == null) {
                    credAnalisys.data = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData();
                }
                if(credAnalisys.data.creditLimit == null) {
                    credAnalisys.data.creditLimit = '0';
                }
             system.debug('CREDIT_BUILDER: '+json.serializePretty(credAnalisys));   
                
        	decimal totalSelled = 0;
			for(ProductsIntegrationDTO.ProductsResponses product : products)
            {
                totalSelled += Decimal.valueOf(product.orderPrice);
            }


        return new ConsolidatedData(
                Decimal.valueOf(credAnalisys.data.creditLimit)-totalSelled,
                Decimal.valueOf(credAnalisys.data.creditLimit),
                0,
                0,
                0,
                products.size() * 34.90,
                0,
                0,
                0,
                products.size() * 34.90,
                0,
                0,
                0,
                totalSelled,
                products.size() * 34.90,
                0,
                0,
                totalSelled,
                0,
                0, 
                0,
                0,
                0,
                0,
                products.size() * 34.90,
                totalSelled);
    }

//================================================== PORTABILITY =======================================================

    /*private SalesOrderIntegrationDTO.Portability builderPortability(PortabilitiesPreAnalysisDTO.PortabilityPre portabilty) {
        List<SalesOrderIntegrationDTO.Tickets> ticketsAvailables = new List<SalesOrderIntegrationDTO.Tickets>();
        List<SalesOrderIntegrationDTO.Availables> availables = new List<SalesOrderIntegrationDTO.Availables>();
        List<SalesOrderIntegrationDTO.Unavailables> unavailables = new List<SalesOrderIntegrationDTO.Unavailables>();

        if (portabilty.portabilty != null && portabilty.portabilty.availables != null) {
            for (PortabilitiesPreAnalysisDTO.Tickets t : portabilty.portabilty.availables.tickets)
                ticketsAvailables.add(new SalesOrderIntegrationDTO.Tickets(t.id, new SalesOrderIntegrationDTO.TelephoneNumber(t.telephoneNumber.number_Z)));

            availables.add(new SalesOrderIntegrationDTO.Availables(portabilty.portabilty.availables.portabilityIndicatorSource,
                    portabilty.portabilty.availables.detail, portabilty.portabilty.availables.name,ticketsAvailables));
        }
        List<SalesOrderIntegrationDTO.Tickets> ticketsUnavailables = new List<SalesOrderIntegrationDTO.Tickets>();
        if (portabilty.portabilty != null && portabilty.portabilty.unavailables != null) {
            for (PortabilitiesPreAnalysisDTO.Tickets t : portabilty.portabilty.unavailables.tickets)
                ticketsUnavailables.add(new SalesOrderIntegrationDTO.Tickets(t.id, new SalesOrderIntegrationDTO.TelephoneNumber(t.telephoneNumber.number_Z)));
            unavailables.add(new SalesOrderIntegrationDTO.Unavailables(ticketsUnavailables,
                    new SalesOrderIntegrationDTO.Reason(portabilty.portabilty.unavailables.reasonId, portabilty.portabilty.unavailables.detail)));
        }

        return new SalesOrderIntegrationDTO.Portability(portabilty.portabilty !=null  && portabilty.portabilty.availables != null ?
                portabilty.portabilty.availables.portabilityIndicatorSource : null, availables, unavailables);
    }*/

//================================================== CAMPAIGN ==========================================================

    /*private List<SalesOrderIntegrationDTO.Campaign> builderCampaign(ProductsIntegrationDTO.ProductsResponse productsResponse) {
        SalesOrderIntegrationDTO.EquipmentPaymentPlan equip = new SalesOrderIntegrationDTO.EquipmentPaymentPlan();

        List<SalesOrderIntegrationDTO.ItemTablePrice_Z> item = new List<SalesOrderIntegrationDTO.ItemTablePrice_Z>();
        item.add(new SalesOrderIntegrationDTO.ItemTablePrice_Z(equip));

        SalesOrderIntegrationDTO.Equimpment equimpment = new SalesOrderIntegrationDTO.Equimpment(item);

        List<SalesOrderIntegrationDTO.SubCampaign> sub = new List<SalesOrderIntegrationDTO.SubCampaign>();
        sub.add(new SalesOrderIntegrationDTO.SubCampaign(new SalesOrderIntegrationDTO.Equimpment()));

        List<SalesOrderIntegrationDTO.Campaign> c = new List<SalesOrderIntegrationDTO.Campaign>();

        c.add(new SalesOrderIntegrationDTO.Campaign(productsResponse.product.promotion.id, productsResponse.product.promotion.name,
                productsResponse.product.sharedProductIndicator, new SalesOrderIntegrationDTO.Type_Z(productsResponse.product.promotion.category.id),
                new SalesOrderIntegrationDTO.Equimpment(), sub));

        return c;
    }*/

//================================================== STATUS ============================================================

    private SalesOrderIntegrationDTO.Status builderStatus(User user, Profile profile) {
        List<SalesOrderIntegrationDTO.Profile_z> p = new List<SalesOrderIntegrationDTO.Profile_z>();
        p.add(new SalesOrderIntegrationDTO.Profile_z(profile.Id, profile.Name));

        return new SalesOrderIntegrationDTO.Status('PEDIDO_VENDA_INICIADO', 'Pedido de venda iniciado', string.valueof(Date.today()),
                new SalesOrderIntegrationDTO.Reason(), new SalesOrderIntegrationDTO.User_X(user.Claro__c, p, user.Name),
                builderApplication(user, profile));
    }

//================================================== APPLICATION =======================================================

    private SalesOrderIntegrationDTO.Application builderApplication(User user, Profile profile) {
        List<SalesOrderIntegrationDTO.Profile_z> p = new List<SalesOrderIntegrationDTO.Profile_z>();
        p.add(new SalesOrderIntegrationDTO.Profile_z(profile.Id, profile.Name));

        List<SalesOrderIntegrationDTO.Type_z> t = new List<SalesOrderIntegrationDTO.Type_z>();
        t.add(new SalesOrderIntegrationDTO.Type_Z('WEB'));

        List<SalesOrderIntegrationDTO.Channel> c = new List<SalesOrderIntegrationDTO.Channel>();
        c.add(new SalesOrderIntegrationDTO.Channel('VENDAS'));

        return new SalesOrderIntegrationDTO.Application('VendasApp', 'CEC', '2.37.10', t, c,
                new SalesOrderIntegrationDTO.User_X(user.Claro__c, p, user.Name));
    }

//================================================== STATUSHISTORY =====================================================

    /*private List<SalesOrderIntegrationDTO.Status> builderStatusHistory(User user, Profile profile) {
        List<SalesOrderIntegrationDTO.Profile_z> p = new List<SalesOrderIntegrationDTO.Profile_z>();
        p.add(new SalesOrderIntegrationDTO.Profile_z(profile.Id, profile.Name));

        List<SalesOrderIntegrationDTO.Status> s = new List<SalesOrderIntegrationDTO.Status>();
        return s;
    }*/

//================================================== AUTHORITY =========================================================

    /*private List<SalesOrderIntegrationDTO.Authority> builderAuthority(User user) { // não obrigatorio
        List<SalesOrderIntegrationDTO.Authority> auths = new List<SalesOrderIntegrationDTO.Authority>();
        auths.add(
                new SalesOrderIntegrationDTO.Authority(
                        new SalesOrderIntegrationDTO.Operation_Z(
                                new SalesOrderIntegrationDTO.Type_Z(null),

                                new SalesOrderIntegrationDTO.User_Z(
                                        user.Claro__c,
                                        new SalesOrderIntegrationDTO.Type_Z(null)
                                ),
                                new SalesOrderIntegrationDTO.Type_Z(null)
                        )
                )
        );
        return auths;
    }*/

//================================================== EQUIPMENT =========================================================

    /*private List<SalesOrderIntegrationDTO.Equipment> builderEquipment() {
        List<SalesOrderIntegrationDTO.EquipmentPaymentPlan> equips = new List<SalesOrderIntegrationDTO.EquipmentPaymentPlan>();
        equips.add(new SalesOrderIntegrationDTO.EquipmentPaymentPlan());

        List<SalesOrderIntegrationDTO.ItemTablePrice> item = new List<SalesOrderIntegrationDTO.ItemTablePrice>();
        item.add(new SalesOrderIntegrationDTO.ItemTablePrice());

        List<SalesOrderIntegrationDTO.Equipment> es = new List<SalesOrderIntegrationDTO.Equipment>();
        es.add(new SalesOrderIntegrationDTO.Equipment());

        return es;
    }*/

//================================================== CONTRACT ==========================================================

   /* private SalesOrderIntegrationDTO.Contract builderContract(Order order, IBGE__c ibge) {
        BillingAccount billingAccount = builderBillingAccount(order,ibge);
        List<SalesOrderIntegrationDTO.PartyIdentifications> p = new List<SalesOrderIntegrationDTO.PartyIdentifications>();
        p.add(new SalesOrderIntegrationDTO.PartyIdentifications('', 'CPF'));
        List<SalesOrderIntegrationDTO.Addresses> addresses = new List<SalesOrderIntegrationDTO.Addresses>();
        addresses.add(new SalesOrderIntegrationDTO.Addresses('COBRANCA', 'LOGRADOURO', order.BillingPostalCode, 'R',
                order.BillingStreet, order.BillingNumber__c, order.BillingComplement__c, order.BillingNeighborhood__c,
                order.BillingCity, order.BillingState, order.BillingState, this.orderMain.DDD__c, ibge.IBGECode__c, 'R'));

        SalesOrderIntegrationDTO.Individual i = new SalesOrderIntegrationDTO.Individual('PF',
                order.Account.MaritalStatus__c, order.Account.Name, string.valueof(order.Account.BirthDate__c),
                order.Account.MothersName__c, order.Account.Gender__c.substring(0, 1), p);


        addresses.add(
                new SalesOrderIntegrationDTO.Addresses('COBRANCA',
                        'LOGRADOURO', order.BillingPostalCode, 'R', order.BillingStreet, order.BillingNumber__c,
                        order.BillingComplement__c, order.BillingNeighborhood__c, order.BillingCity, order.BillingState,
                        order.BillingState, this.orderMain.DDD__c, ibge.IBGECode__c, 'R')
        );

        Customer customer = new Customer('120667588', new MobileType('I'), new MobileSubType('NORMAL'),
                new Passport('BRA'), new Contacts(order.vlocity_cmt__BillingName__c, new TelephoneNumber(order.Account.Phone), null),
                addresses,i
        );


        return new Contract(billingAccount, customer, order.ContractId);
    }*/

//=============================================== PRODUCTOFFERING ======================================================
//1 pos - 3 controle
    private SalesOrderIntegrationDTO.ProductOffering builderProductOffering(ProductsIntegrationDTO.ProductsResponse productsResponse, String typeOffer, boolean sharedOffer) {
        system.debug('TYPEOFFER: '+typeOffer);
        List<SalesOrderIntegrationDTO.Type_Z> t = new List<SalesOrderIntegrationDTO.Type_Z>();
        t.add(new SalesOrderIntegrationDTO.Type_Z(productsResponse.product.productOffering.type_z));
        
        system.debug('OFFERING_ID: '+productsResponse.product.productOffering.id);
        system.debug('OFFERING_NAME: '+productsResponse.product.productOffering.name);
        
        return new SalesOrderIntegrationDTO.ProductOffering(productsResponse.product.productOffering.id,
                productsResponse.product.productOffering.name, productsResponse.product.productOffering.nickname,
                productsResponse.product.productOffering.description, productsResponse.product.productOffering.expirationDate,
                null, null, productsResponse.product.productOffering.price, // chumbar?
                typeOffer.equals('Controle') ? typeOffer.toUpperCase() : 'POS_PAGO', null,
                '', new SalesOrderIntegrationDTO.CreditLimitAnalysis(), sharedOffer);
    }

//================================================== SERVICE ==========================================================

    private List<SalesOrderIntegrationDTO.Service> builderService(ProductsIntegrationDTO.ProductsResponse productsResponse) {
        List<SalesOrderIntegrationDTO.Service> ss = new List<SalesOrderIntegrationDTO.Service>();
        for (ProductsIntegrationDTO.Service service : productsResponse.product.services)
            ss.add(new SalesOrderIntegrationDTO.Service(service.id, service.name,
                    null,
                    new SalesOrderIntegrationDTO.Profile_z(service.category.id, service.category.name)));

        return ss;
    }
    
//================================================== CREATE TICKETS ==========================================================

    private map<Id,List<Tickets>> createTickets (List<OrderItem> lstItems)
    {
        Window window = new Window();
        window.nextDateAvailable = 'false';
        map<Id,List<Tickets>> mapTickets = new map<Id,List<Tickets>>();
        for(OrderItem item : lstItems)
        {
            List<Tickets> lstTickets = new List<Tickets>();
            if (item.Product2.vlocity_cmt__Type__c.equals('Plano') || item.Product2.vlocity_cmt__Type__c.equals('Dependente'))
            {
                telephoneNumber foneNumber = new telephoneNumber();
                if(!String.isBlank(item.Order.BillingDDD__c) && !String.isBlank(item.vlocity_cmt__SerialNumber__c))
                {
                    system.debug('PORTABILTY_YES');
                    foneNumber = new TelephoneNumber(item.Order.BillingDDD__c + item.vlocity_cmt__SerialNumber__c);
                    
                    Tickets ticket = new Tickets('838784639', foneNumber);
                    ticket.window = window;
                    lstTickets.add(ticket);
                }
                else
                {
                    system.debug('PORTABILTY_NO');
                    foneNumber = null;
                }
                mapTickets.put(item.Id, lstTickets);
            }
        }
        return mapTickets;
    }
    //================================================== CREATE AVAILABLES ==========================================================

    private List<Availables> createAvailables (List<OrderItem> lstItems, map<Id, List<Tickets>> mapTickets)
    {
        List<Availables> lstAvailables = new List<Availables>();
        for(OrderItem item : lstItems)
        {
            if (item.Product2.vlocity_cmt__Type__c.equals('Plano') || item.Product2.vlocity_cmt__Type__c.equals('Dependente'))
            {
                if(!mapTickets.get(item.Id).isEmpty())
                {
                    Availables available = new Availables(String.valueOf(item.Portabilidade__c), 'Telefones agrupados por Doadora, DDD e Código EOT: 10', item.Operator__c, mapTickets.get(item.Id));
                    lstAvailables.add(available);
                }
            }
        }
        return lstAvailables;
    }
    

//==================================================== PRODUCTBUNDLE ===================================================

    /*private SalesOrderIntegrationDTO.ProductBundle builderProductBundle(ProductsIntegrationDTO.ProductsResponse productsResponse) {
        List<SalesOrderIntegrationDTO.Profile_z> p = new List<SalesOrderIntegrationDTO.Profile_z>();

        p.add(new SalesOrderIntegrationDTO.Profile_z(productsResponse.product.productOffering.id, productsResponse.product.productOffering.name));

        List<SalesOrderIntegrationDTO.ProductSpecification> ps = new List<SalesOrderIntegrationDTO.ProductSpecification>();

        ps.add(new SalesOrderIntegrationDTO.ProductSpecification(null, productsResponse.product.type_Z, // chumbar?
                productsResponse.product.subType, productsResponse.product.sharedProductIndicator,
                new SalesOrderIntegrationDTO.ProductOffering_Z(productsResponse.product.productOffering.type_Z, null)));

        return new SalesOrderIntegrationDTO.ProductBundle(null, null, // chumbar?
                null, null, p, ps);                                                             // chumbar?
    }*/

//==================================================== PAYMENTEBUNDLE ===================================================

    /*private SalesOrderIntegrationDTO.Payment builderPayment() {
        List<ItemPaymentMixed> mixed = new List<ItemPaymentMixed> ();
        mixed.add(new ItemPaymentMixed(null, new Type_Z(null)));
        return new Payment(
                new PaymentPlan(null, null, new Type_Z(null), mixed,  //  ?
                        new Installment(null, null, null)));
    }*/

}