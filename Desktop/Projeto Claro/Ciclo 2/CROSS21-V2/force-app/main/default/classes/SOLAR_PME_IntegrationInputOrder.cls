/*
* @author Diogo Braga - Deloitte
* @description Classe de integração com sistema legado(CPC - RPA)
*/
public with sharing class SOLAR_PME_IntegrationInputOrder {
    public class InputOrderException extends Exception {}
    
    private final String SIGNATURE_TYPE = 'SignatureType';
    private final String SERVICE_NAME = 'CEC_PME_EnvioPedido';
    private final String API_VERSION = '1;2018-12-17';
    private final String TRANSACTION_ID = 'Id-';
    private final String ACCOUNT_MANAGER = 'GERENTE_CONTA';
    private final String PUBLIC_COMPANY = 'Empresa Pública';
    private final String PRIVATE_COMPANY = 'Empresa Privada';
    private final String INTERNATIONAL_CODE = '55';
    private final String BIRTHDATE_TIME = 'T00:00:00.000Z';
    private final String CONTACT_TITLE = 'Prezado';
    private final String MOBILE_PHONE = 'Celular';
    private final String HOME_PHONE = 'Residencial';
    private final String ACTION_ACTIVE = 'ATIVAR';
    private final String BOOL_FALSE = 'false';
    private final String BOOL_TRUE = 'true'; 
    private final String PRODUCT_TYPE_PLUGIN = 'Plug-In';
    private final String TYPE_TRANSFER = 'TT PF/PJ';
    private final String SP = 'sp';
    private final String MONTHS_24 = '24_MESES';
    private final String TYPE_DEVICE = 'Aparelho';
    private final String TYPE_DEVICES = 'Aparelhos';
    private final String TYPE_SERVICE = 'Serviço';
    private final String DETACHED_SIMCARD = 'SimCard Avulso';
    private final String DEVICE_SIMCARD = 'SimCard Aparelho';
    private final String SIM = 'SIM';
    private final String NOT_IS_A_DEVICE = 'NotIsADevice';
    private final String DONT_HAVE_OPT_DEVICES = 'dontHaveOptionalDevices';
    private final String NEW_ORDER = 'Novo';
    private final String MSG_TYPE_NEW = 'novo';
    private final String MSG_ACTION_INCLUDE = 'incluir'; 
    private final String ERRO_INT = 'Erro na integração';
    
    private CEC_PME_FromToUtil fromToUtil;
    private Order order;
    private Map<String, List<OrderItem>> mapOrderItems;
    private List<AccountContactRelation> listAccCttRelation;
    private Map<String, String> mapColorSapId;
    
    public SOLAR_PME_IntegrationInputOrder() {
        this.fromToUtil = new CEC_PME_FromToUtil(SIGNATURE_TYPE);
    }
    
    public CEC_PME_EnvioPedido_Response send(Id orderId) {
        populateSobjects(orderId);
        buildMapOrderItems();
        buildMapColorSapId();
        Object requestBody = buildRequestBody();
        HttpResponse response = new SOLAR_IntegrationREST().sendRequest(SERVICE_NAME, requestBody); 
        
        if(response.getStatusCode()!=200){ 
            throw new InputOrderException(ERRO_INT +'(' + response.getStatusCode() + '):' + response.getStatus());
        }
        return (CEC_PME_EnvioPedido_Response)JSON.deserialize(response.getBody(), CEC_PME_EnvioPedido_Response.class);
    }
    
    private void populateSobjects(Id orderId) {
        if(!Schema.sObjectType.Order.isAccessible()) {
            throw new InputOrderException('User does not have access to the Order sObject');
        }
        if(!Schema.sObjectType.OrderItem.isAccessible()) {
            throw new InputOrderException('User does not have access to the OrderItem sObject');
        }
        
        order = [SELECT Id,
                 AccountId,
                 CreatedById,
                 OrderNumber,
                 Payment_Term__c,
                 DeliveryMethod__c,
                 ReceiverFullName1__c,
                 ReceiverFullName2__c,
                 ReceiverFullName3__c,
                 ReceiverRG1__c,
                 ReceiverRG2__c,
                 ReceiverRG3__c,
                 ReceiverMobile1__c,
                 ReceiverMobile2__c,
                 ReceiverMobile3__c,
                 Related_Contacts__c,
                 LD21__c,
                 Account.Id,
                 Account.Name,
                 Account.StateSubscription__c,
                 Account.MunicipalSubscription__c,
                 Account.DocumentNumber__c,
                 Account.NETClient__c,
                 Account.EmbratelClient__c,
                 Account.NumberOfEmployeesList__c,
                 Account.CompanyClass__c,
                 Account.CommercialSegment__c,
                 Account.Hierarchy__r.Name,
                 Account.ShippingPostalCode,
                 Account.ShippingStreet,
                 Account.ShippingCity,
                 Account.ShippingState,
                 Account.CEC_ShippingNeighborhood__c,
                 Account.CEC_ShippingComplement__c,
                 Account.CEC_ShippingNumber__c,
                 Account.CEC_ShippingAddressType__c,
                 Account.CNAE__c,
                 Account.CNAE2__c,
                 Account.DueDay__c,
                 Account.OwnerId,
                 Account.BillingPostalCode,
                 Account.CEC_BillingAddressType__c,
                 Account.BillingStreet,
                 Account.CEC_BillingNumber__c,
                 Account.CEC_BillingComplement__c,
                 Account.CEC_BillingNeighborhood__c,
                 Account.BillingCity,
                 Account.BillingState,
                 Account.Phone,
                 CreatedBy.Id,
                 CreatedBy.ConsultantCode__c,
                 CreatedBy.Resale__c,
                 CreatedBy.CNPJResale__c,
                 CreatedBy.ResaleCode__c,
                 CreatedBy.FirstName,
                 CreatedBy.LastName,
                 CreatedBy.Channel__c,
                 CreatedBy.Profile.Name,
                 CreatedBy.Name,
                 (SELECT Id,
                  ICCID__c,
                  Quantity,
                  TradeIn__c,
                  vlocity_cmt__RecurringTotal__c,
                  vlocity_cmt__AssetReferenceId__c,
                  TypeOfRequest__c,
                  ParentGroup__c,
                  Group__c,
                  Subgroup__c,
                  ReliesOnReferenceId__c,
                  PortabilityNumber__c,
                  Operator__c,
                  DeviceSecondOptionColor__c,
                  AnotherDeviceColor__c,
                  TotalPrice,
                  IMEI__c,
                  SAP_ID__c,
                  vlocity_cmt__RecurringCharge__c,
                  DonatorName__c,
                  DonatorDocumentNumber__c,
                  DonatorPhone__c,
                  DonatorEmail__c,
                  BonusValue__c,
                  vlocity_cmt__RecurringDiscountPrice__c,
                  vlocity_cmt__JSONAttribute__c,
                  UnitPrice,
                  Product2.Color__c,
                  Product2.SAPID__c,
                  Product2.vlocity_cmt__Type__c,
                  Product2.vlocity_cmt__SubType__c,
                  Product2.ProductCode,
                  Product2.Name,
                  Product2.Model__c,
                  Product2.Manufacturer__c,
                  Product2.vlocity_cmt__JSONAttribute__c,
                  Product2.vlocity_cmt__ObjectTypeId__c,
                  Product2.Family
                  FROM OrderItems)
                 FROM Order
                 WHERE Id = :orderId];
        		
        List<String> listAccCttRelationIds = new List<String>();
        if(String.isNotBlank(order.Related_Contacts__c) && order.Related_Contacts__c.contains(';')) {
            listAccCttRelationIds.addAll(order.Related_Contacts__c.split(';')) ;
        }

        if(!Schema.sObjectType.AccountContactRelation.isAccessible()) {
            throw new InputOrderException('User does not have access to the AccountContactRelation sObject');
        }

        listAccCttRelation = [SELECT Id,
                              AccountId,
                              ContactId,
                              Roles,
                              Email__c,
                              MobilePhone__c,
                              Phone__c,
                              ResponsibleForTheSignature__c,
                              Contact.FirstName,
                              Contact.LastName,
                              Contact.DocumentNumber__c,
                              Contact.Gender__c,
                              Contact.Birthdate,
                              Contact.Name
                              FROM AccountContactRelation
                              WHERE Id IN :listAccCttRelationIds
                              AND AccountId = :order.AccountId];
    }
    
    private void buildMapOrderItems() {
        mapOrderItems = new Map<String, List<OrderItem>>();
        for(OrderItem varOrderItem : order.OrderItems) {
            if(mapOrderItems.containsKey(varOrderItem.ReliesOnReferenceId__c)) {
                mapOrderItems.get(varOrderItem.ReliesOnReferenceId__c).add(varOrderItem);
            } else {
                mapOrderItems.put(varOrderItem.ReliesOnReferenceId__c, new List<OrderItem>{varOrderItem});
            }
        }
    }
    
    private List<OrderItem> getOnMapOrderItems(String key) {
        if(String.isNotBlank(key) && mapOrderItems.containsKey(key)) {
            return mapOrderItems.get(key);
        } else {
            return new List<OrderItem>();
        }
    }
    
    private void buildMapColorSapId() {
        List<String> listManufacturers = new List<String>();
        List<String> listModels = new List<String>();
        for(OrderItem varOrderItem : order.OrderItems) {
            if(TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c)) {
                listManufacturers.add(varOrderItem.Product2.Manufacturer__c);
                listModels.add(varOrderItem.Product2.Model__c);
            }
        }

        if(!Schema.sObjectType.Product2.isAccessible()) {
            throw new InputOrderException('User does not have access to the Product2 sObject');
        }

        List<Product2> listProduct2 = [SELECT Id, 
                                       Manufacturer__c, 
                                       Model__c,
                                       SAPID__c,
                                       Color__c
                                       FROM Product2 
                                       WHERE Manufacturer__c IN :listManufacturers 
                                       AND Model__c IN :listModels];
        
        this.mapColorSapId = new Map<String, String>();
        for(Product2 product2 : listProduct2) {
            this.mapColorSapId.put(product2.Manufacturer__c + product2.Model__c + product2.Color__c, product2.SAPID__c);
        }
    }
    
    @testVisible
    private Object buildRequestBody() {
        SOLAR_PME_IntegrationInputOrderModel.RequestBody requestBody = new SOLAR_PME_IntegrationInputOrderModel.RequestBody();
        requestBody.apiVersion = API_VERSION;
        requestBody.transactionId = TRANSACTION_ID + order.OrderNumber;
        requestBody.data = new SOLAR_PME_IntegrationInputOrderModel.Data();
        requestBody.data.salesOrders = buildSalesOrder();
        return requestBody;
    }
    
    @testVisible
    private List<SOLAR_PME_IntegrationInputOrderModel.SalesOrders> buildSalesOrder() {
        List<SOLAR_PME_IntegrationInputOrderModel.SalesOrders> listSalesOrders = new List<SOLAR_PME_IntegrationInputOrderModel.SalesOrders>();
        SOLAR_PME_IntegrationInputOrderModel.SalesOrders salesOrders = new SOLAR_PME_IntegrationInputOrderModel.SalesOrders();
        salesOrders.salesParty = buildSalesParty();
        salesOrders.customer = buildCustomer();
        salesOrders.equipmentDelivery = buildEquipmentDelivery();
        salesOrders.order = buildOrder();
        salesOrders.summary = buildSummary();
        salesOrders.subscriberAcceptances = getSubscriberAcceptances();
        salesOrders.documents = buildListDocuments();
        salesOrders.message = getMessage(NEW_ORDER);
        listSalesOrders.add(salesOrders);
        return listSalesOrders;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.SalesParty buildSalesParty() {
        SOLAR_PME_IntegrationInputOrderModel.SalesParty salesParty = new SOLAR_PME_IntegrationInputOrderModel.SalesParty();
        salesParty.salesmanId = order.CreatedBy.ConsultantCode__c;
        salesParty.salesmanJobTitle = ACCOUNT_MANAGER;
        salesParty.salesmanName = order.CreatedBy.Name;
        salesParty.companyName = order.CreatedBy.Resale__c;
        salesParty.cnpj =  order.CreatedBy.CNPJResale__c;
        salesParty.vendorId = order.CreatedBy.ResaleCode__c;
        salesParty.salesChannelId = order.CreatedBy.Channel__c;
        salesParty.comercialSegment = order.Account.CommercialSegment__c;
        return salesParty;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Customer buildCustomer() {
        SOLAR_PME_IntegrationInputOrderModel.Customer customer = new SOLAR_PME_IntegrationInputOrderModel.Customer();
        customer.companyName = order.Account.Name;
        customer.tradingName = '';
        customer.stateRegistration = order.Account.StateSubscription__c;
        customer.municipalRegistration = order.Account.MunicipalSubscription__c;
        customer.cnpj = order.Account.DocumentNumber__c;
        customer.flagNetSubscriber = order.Account.NETClient__c;
        customer.flagEmbratelSubscriber = order.Account.EmbratelClient__c;
        customer.customerAccountId = order.Account.Id;
        customer.employeeQuantity = order.Account.NumberOfEmployeesList__c;
        customer.accountSegment = Label.CEC_PME_GGD_Segmento;
        customer.territory = order.Account.Hierarchy__r.Name;
        if(String.isBlank(order.Account.CompanyClass__c)) {
            customer.accountType = PUBLIC_COMPANY;
        } else {
            customer.accountType = PRIVATE_COMPANY;
        }
        customer.cnaes = buildListCnaes();
        customer.contactPhone = buildContactPhone();
        customer.Contacts = buildListContacts();
        customer.addresses = buildListAddresses();
        customer.billingSpec = buildBillingSpec();
        return customer;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Cnaes> buildListCnaes() {
        List<SOLAR_PME_IntegrationInputOrderModel.Cnaes> listCnaes = new List<SOLAR_PME_IntegrationInputOrderModel.Cnaes>();
        if(String.isNotBlank(order.Account.CNAE__c)) {
            listCnaes.add(new SOLAR_PME_IntegrationInputOrderModel.Cnaes(order.Account.CNAE__c));
        }
        if(String.isNotBlank(order.Account.CNAE2__c)) {
            listCnaes.add(new SOLAR_PME_IntegrationInputOrderModel.Cnaes(order.Account.CNAE2__c));
        }
        return listCnaes;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.ContactPhone buildContactPhone() {
        SOLAR_PME_IntegrationInputOrderModel.ContactPhone contactPhone = new SOLAR_PME_IntegrationInputOrderModel.ContactPhone();
        if(order.ReceiverMobile1__c != null) {
            contactPhone.telephoneNumber = String.valueOf(order.ReceiverMobile1__c);
            contactPhone.areaCode = contactPhone.telephoneNumber.mid(0,2);
            contactPhone.telephoneNumber = contactPhone.telephoneNumber.substring(2);
        }
        contactPhone.internationalCode = INTERNATIONAL_CODE;
        contactPhone.contactMediumRole = '';
        return contactPhone;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Contact> buildListContacts() {
        List<SOLAR_PME_IntegrationInputOrderModel.Contact> litContacts = new List<SOLAR_PME_IntegrationInputOrderModel.Contact>();
        for(AccountContactRelation accCttRelation : listAccCttRelation) {
            litContacts.add(buildContact(accCttRelation));
        }
        return litContacts;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.contact buildContact(AccountContactRelation accCttRelation) {
        if(String.isBlank(accCttRelation.Contact.DocumentNumber__c)) {
            return null;
        }
        
        SOLAR_PME_IntegrationInputOrderModel.Contact contact = new SOLAR_PME_IntegrationInputOrderModel.Contact();
        contact.firstName = accCttRelation.Contact.FirstName;
        contact.lastName = accCttRelation.Contact.LastName;
        contact.cpf = accCttRelation.Contact.DocumentNumber__c;
        contact.gender = accCttRelation.Contact.Gender__c;
        contact.emailAddress = accCttRelation.Email__c;
        contact.jobTitle = accCttRelation.roles;
        contact.occupation = accCttRelation.roles;
        if(accCttRelation.Contact.Birthdate != null) {
            contact.birthDate = String.valueOf(accCttRelation.Contact.Birthdate) + BIRTHDATE_TIME;
        }
        contact.isLegalRepresentative = true;
        contact.title = CONTACT_TITLE;
        contact.phones = buildListPhones(accCttRelation);
        return contact;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Phones> buildListPhones(AccountContactRelation accCttRelation) {
        List<SOLAR_PME_IntegrationInputOrderModel.Phones> listPhones = new List<SOLAR_PME_IntegrationInputOrderModel.Phones>();
        SOLAR_PME_IntegrationInputOrderModel.Phones mobilePhone = buildPhone(accCttRelation.MobilePhone__c, MOBILE_PHONE);
        if(mobilePhone != null) {
            listPhones.add(mobilePhone);
        }
        SOLAR_PME_IntegrationInputOrderModel.Phones homePhone = buildPhone(accCttRelation.Phone__c, HOME_PHONE);
        if(homePhone != null) {
            listPhones.add(homePhone);
        }
        return listPhones;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Phones buildPhone(String phoneNumber, String phoneType) {
        Boolean isValidPhoneFormat = String.isNotBlank(phoneType) && String.isNotBlank(phoneNumber);
         if(isValidPhoneFormat){
            isValidPhoneFormat &= phoneNumber.length() > 2;
        }
        if(!isValidPhoneFormat) {
            return null;
        }
        
        SOLAR_PME_IntegrationInputOrderModel.Phones phones = new SOLAR_PME_IntegrationInputOrderModel.Phones();
        phones.telephoneNumber = phoneNumber.substring(2);
        phones.areaCode = phoneNumber.mid(0,2);
        phones.internationalCode = INTERNATIONAL_CODE;
        phones.contactMediumRole = phoneType;
        return phones;
    } 
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Addresses> buildListAddresses() {
        List<SOLAR_PME_IntegrationInputOrderModel.Addresses> listAddresses = new List<SOLAR_PME_IntegrationInputOrderModel.Addresses>();
        SOLAR_PME_IntegrationInputOrderModel.Addresses addresses = new SOLAR_PME_IntegrationInputOrderModel.Addresses();
        addresses.addressType = Label.CEC_PME_RPA_End_Pad;
        addresses.postcode = order.Account.ShippingPostalCode;
        addresses.streetType = order.Account.CEC_ShippingAddressType__c;
        addresses.streetName = order.Account.BillingStreet;
        addresses.streetNr = order.Account.CEC_ShippingNumber__c;
        addresses.complement = order.Account.CEC_ShippingComplement__c;
        addresses.neighborhood = order.Account.CEC_ShippingNeighborhood__c;
        addresses.cityName = order.Account.ShippingCity;
        addresses.stateAbbreviation = order.Account.ShippingState;
        listAddresses.add(addresses);
        return listAddresses;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.BillingSpec buildBillingSpec() {
        SOLAR_PME_IntegrationInputOrderModel.BillingSpec billingSpec = new SOLAR_PME_IntegrationInputOrderModel.BillingSpec();
        billingSpec.paymentDayDue = order.Account.DueDay__c;
        billingSpec.address = buildBillingAddress();
        return billingSpec;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Address buildBillingAddress() {
        SOLAR_PME_IntegrationInputOrderModel.Address address = new SOLAR_PME_IntegrationInputOrderModel.Address();
        address.addressType = Label.CEC_PME_GGD_End_Cob;
        address.postcode = order.Account.BillingPostalCode;
        address.streetType = order.Account.CEC_BillingAddressType__c;
        address.streetName = order.Account.BillingStreet;
        address.streetNr = order.Account.CEC_BillingNumber__c;
        address.complement = order.Account.CEC_BillingComplement__c;
        address.neighborhood = order.Account.CEC_BillingNeighborhood__c;
        address.cityName = order.Account.BillingCity;
        address.stateAbbreviation = order.Account.BillingState;
        return address;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.EquipmentDelivery buildEquipmentDelivery() {
        SOLAR_PME_IntegrationInputOrderModel.EquipmentDelivery equipmentDelivery = new SOLAR_PME_IntegrationInputOrderModel.EquipmentDelivery();
        equipmentDelivery.type = order.DeliveryMethod__c;
        equipmentDelivery.address = buildAddress();
        equipmentDelivery.receivers = buildListReceivers();
        return equipmentDelivery;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Address buildAddress() {
        SOLAR_PME_IntegrationInputOrderModel.Address address = new SOLAR_PME_IntegrationInputOrderModel.Address();
        address.addressType = Label.CEC_PME_RPA_End_Ent;
        address.postcode = order.Account.ShippingPostalCode;
        address.streetType = order.Account.CEC_ShippingAddressType__c;
        address.streetName = order.Account.ShippingStreet;
        address.streetNr = order.Account.CEC_ShippingNumber__c;
        address.complement = order.Account.CEC_ShippingComplement__c;
        address.neighborhood = order.Account.CEC_ShippingNeighborhood__c;
        address.cityName = order.Account.ShippingCity;
        address.stateAbbreviation = order.Account.ShippingState;
        return address;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Receivers> buildListReceivers() {
        List<SOLAR_PME_IntegrationInputOrderModel.Receivers> listReceivers = new List<SOLAR_PME_IntegrationInputOrderModel.Receivers>();
        
        if(String.isNotBlank(order.ReceiverFullName1__c)) {
            listReceivers.add(new SOLAR_PME_IntegrationInputOrderModel.Receivers(order.ReceiverFullName1__c, 
                                                                                 order.ReceiverRG1__c, 
                                                                                 buildReceiverPhones(order.ReceiverMobile1__c)));
        }
        if(String.isNotBlank(order.ReceiverFullName2__c)) {
            listReceivers.add(new SOLAR_PME_IntegrationInputOrderModel.Receivers(order.ReceiverFullName2__c, 
                                                                                 order.ReceiverRG2__c, 
                                                                                 buildReceiverPhones(order.ReceiverMobile2__c)));
        }
        if(String.isNotBlank(order.ReceiverFullName3__c)) {
            listReceivers.add(new SOLAR_PME_IntegrationInputOrderModel.Receivers(order.ReceiverFullName3__c, 
                                                                                 order.ReceiverRG3__c, 
                                                                                 buildReceiverPhones(order.ReceiverMobile3__c)));
        }     
        
        return listReceivers;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Phones buildReceiverPhones(String strPhone) {
        if(String.isBlank(strPhone) || strPhone.length() < 3) {
            return null;
        }
        SOLAR_PME_IntegrationInputOrderModel.Phones phones = new SOLAR_PME_IntegrationInputOrderModel.Phones();
        phones.telephoneNumber = strPhone.substring(2);
        phones.areaCode = strPhone.mid(0,2);
        phones.internationalCode = INTERNATIONAL_CODE;
        phones.contactMediumRole = '';
        return phones;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Order buildOrder() {
        SOLAR_PME_IntegrationInputOrderModel.Order integrationOrder = new SOLAR_PME_IntegrationInputOrderModel.Order();
        integrationOrder.orderId = order.OrderNumber;
        integrationOrder.orderAction = ACTION_ACTIVE;
        integrationOrder.plans = buildListPlans();
        return integrationOrder;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Plans> buildListPlans() {
        List<SOLAR_PME_IntegrationInputOrderModel.Plans> listPlans = new List<SOLAR_PME_IntegrationInputOrderModel.Plans>();
        for(OrderItem varOrderItem : order.OrderItems) {
            listPlans.add(buildPlans(varOrderItem));
        }
        return separatePlansByRegional(listPlans);
    }

    private SOLAR_PME_IntegrationInputOrderModel.Plans buildPlans(OrderItem varOrderItem) { 
        SOLAR_PME_IntegrationInputOrderModel.Plans plans = new SOLAR_PME_IntegrationInputOrderModel.Plans();
        
        Boolean isIndividualPlan = Label.CEC_PME_FRANQ_INDIVIDUAL.equals(varOrderItem.Product2.ProductCode);
        Boolean isSharedPlan = Label.CEC_PME_FRANQ_COMPARTILHADA.equals(varOrderItem.Product2.ProductCode);
        if(isIndividualPlan || isSharedPlan) {
            plans.planId = varOrderItem.vlocity_cmt__AssetReferenceId__c;
            plans.name = varOrderItem.Product2.Name;
             if(order.Account.CommercialSegment__c == 'TOP PME') {
                if(varOrderItem.TradeIn__c != null && varOrderItem.TradeIn__c != 'Não') {
                    plans.tradeIn = varOrderItem.TradeIn__c.substring(0,1) ;
                } else {
                    plans.tradeIn = varOrderItem.TradeIn__c;
                }
            }
        }

        if(isIndividualPlan) {
            plans.flagSharedPlan = BOOL_FALSE;
            plans.groups = buildListGroupsIndividual(varOrderItem);
        } else if(isSharedPlan) {
            plans.flagSharedPlan = BOOL_TRUE;
            plans.groups = buildListGroupsShared(varOrderItem);
        }
        return plans;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildListGroupsIndividual(OrderItem planOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroupsx = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        
        for(OrderItem franchiseOrdItem : getOnMapOrderItems(planOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            listGroups.addAll(buildGroupsIndividual(franchiseOrdItem, planOrdItem));
        }    
        
        return separateGroup(listGroups);
    }

    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildGroupsIndividual(OrderItem franchiseOrdItem, OrderItem planOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        SOLAR_PME_IntegrationInputOrderModel.Groups groups = new SOLAR_PME_IntegrationInputOrderModel.Groups();
        groups.groupId = franchiseOrdItem.vlocity_cmt__AssetReferenceId__c;
        groups.name = franchiseOrdItem.Product2.Name;
        groups.requestType = franchiseOrdItem.TypeOfRequest__c;
        groups.stateAbbreviation = franchiseOrdItem.Group__c;
        groups.areaCode = franchiseOrdItem.Subgroup__c;
        groups.franchise = franchiseOrdItem.Product2.Name;
        groups.overRateValue = ''; 
        groups.contractPeriod = MONTHS_24;
        groups.paymentMethod = order.Payment_Term__c;
        groups.additionalServices = buildListAdditionalServices(franchiseOrdItem);
        groups.includedServices = buildListIncludedServices(franchiseOrdItem, true);
        
        if(SP.equalsIgnoreCase(franchiseOrdItem.Group__c)) {
            groups.regional = franchiseOrdItem.ParentGroup__c;
        } else {
            groups.regional = franchiseOrdItem.Group__c;
        }
        
        if(franchiseOrdItem.vlocity_cmt__RecurringDiscountPrice__c == null) {
            groups.value = String.valueOf(franchiseOrdItem.vlocity_cmt__RecurringCharge__c);
        } else {
            groups.value = String.valueOf(franchiseOrdItem.UnitPrice);
        }
        
        if(fromToUtil.hasTo(planOrdItem.Product2.ProductCode)) {
            groups.plugin = fromToUtil.getTo(planOrdItem.Product2.ProductCode) + ' ' + franchiseOrdItem.Product2.Name;
        }
        
        if(TYPE_TRANSFER.equals(franchiseOrdItem.TypeOfRequest__c)) {
            groups.specialOffer = buildSpecialOffer(franchiseOrdItem, 1);
            listGroups.addAll(buildListGroupsTranfer(groups, franchiseOrdItem));
        } else {
            listGroups.addAll(buildListGroupsNotTranfer(groups, franchiseOrdItem, true));
        }
        
        return listGroups;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildListGroupsNotTranfer(SOLAR_PME_IntegrationInputOrderModel.Groups groups, OrderItem franchiseOrdItem, Boolean isIndividual) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> lineDetailsAvulso = buildListDetailDetached(franchiseOrdItem);
        
        if(lineDetailsAvulso.size() > 0) {
            if(isIndividual) {
                groups.specialOffer = buildSpecialOffer(franchiseOrdItem, lineDetailsAvulso.size());
            }
            SOLAR_PME_IntegrationInputOrderModel.Groups groupsAvulso = groups.clone();
            groupsAvulso.lineDetails = lineDetailsAvulso;
            listGroups.add(groupsAvulso);
        } 
        
        Set<String> setDistinctDevices = buildDistinctDevices(franchiseOrdItem);
        for(String device : setDistinctDevices) {
            List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> lineDetailsLineAparelho = buildListLineDetailDevices(franchiseOrdItem, device);
            if(lineDetailsLineAparelho.size() > 0) {
                if(isIndividual) {
                    groups.specialOffer = buildSpecialOffer(franchiseOrdItem, lineDetailsLineAparelho.size());
                }
                SOLAR_PME_IntegrationInputOrderModel.Groups groupsAparelho = groups.clone();
                groupsAparelho.lineDetails = lineDetailsLineAparelho;
                listGroups.add(groupsAparelho);                                      
            }
        }
        
        return listGroups;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> buildListDetailDetached(OrderItem franchiseOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> listLineDetached = new List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>();
        
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            if(DETACHED_SIMCARD.equals(varOrderItem.Product2.vlocity_cmt__SubType__c)) {
                listLineDetached.add(buildLineDetails(varOrderItem));    
            }
        }
        return listLineDetached;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> buildListLineDetailDevices(OrderItem franchiseOrdItem, String device) {
        List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> listLineDetailDevices = new List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>();
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            if(device.equals(varOrderItem.Product2.Name)) {
                listLineDetailDevices.add(buildLineDetails(varOrderItem));
            }
        }
        return listLineDetailDevices;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.AdditionalServices> buildListAdditionalServices(OrderItem franchiseOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.AdditionalServices> listAdditionalServices = new List<SOLAR_PME_IntegrationInputOrderModel.AdditionalServices>();
        
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            Boolean isNotDevice = !(TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c) || TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c));
            Boolean isNotRecurringZero = varOrderItem.vlocity_cmt__RecurringTotal__c != 0;
            if(isNotDevice && isNotRecurringZero) {
                listAdditionalServices.add(buildAdditionalServices(varOrderItem));
            }
        }
        
        return listAdditionalServices;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.AdditionalServices buildAdditionalServices(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.AdditionalServices additionalServices = new SOLAR_PME_IntegrationInputOrderModel.AdditionalServices();
        additionalServices.name = varOrderItem.Product2.Name;
        additionalServices.value = String.ValueOf(varOrderItem.vlocity_cmt__RecurringCharge__c );
        if(TYPE_SERVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c)){
            additionalServices.type = varOrderItem.Product2.Name;
        } else {
            additionalServices.type = varOrderItem.Product2.vlocity_cmt__Type__c;
        }
        return additionalServices;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.IncludedServices> buildListIncludedServices(OrderItem franchiseOrdItem, Boolean isIndividualPlan) {
        List<SOLAR_PME_IntegrationInputOrderModel.IncludedServices> listIncludedServices = new List<SOLAR_PME_IntegrationInputOrderModel.IncludedServices>();
        Boolean hasGestor = false;
        
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            Boolean isNotDevice = !(TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c) || TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c));
            Boolean isNotRecurringZero = varOrderItem.vlocity_cmt__RecurringTotal__c != 0;
            if(isNotDevice && isNotRecurringZero) {
                listIncludedServices.add(buildIncludedServices(varOrderItem));
                hasGestor |= varOrderItem.Product2.vlocity_cmt__Type__c == Label.CEC_PME_GestorOnline;
            }
        }
        
        if(isIndividualPlan && !hasGestor) {
            listIncludedServices.add(buildGestorOnline());
        }            
        
        return listIncludedServices;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.IncludedServices buildIncludedServices(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.IncludedServices includedServices = new SOLAR_PME_IntegrationInputOrderModel.IncludedServices();
        includedServices.name = varOrderItem.Product2.Name;
        if(TYPE_SERVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c)){
            includedServices.type = varOrderItem.Product2.Name;
        } else {
            includedServices.type = varOrderItem.Product2.vlocity_cmt__Type__c;
        }
        
        return includedServices;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.IncludedServices buildGestorOnline() {
        SOLAR_PME_IntegrationInputOrderModel.IncludedServices includedServices = new SOLAR_PME_IntegrationInputOrderModel.IncludedServices();
        includedServices.name = Label.CEC_PME_GestorOnline;
        includedServices.type = Label.CEC_PME_GestorOnline;
        
        return includedServices;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildListGroupsTranfer(SOLAR_PME_IntegrationInputOrderModel.Groups groups, OrderItem varOrderItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        for(SOLAR_PME_IntegrationInputOrderModel.LineDetails detailTransfer : buildListLinesTransf(varOrderItem)) {
            SOLAR_PME_IntegrationInputOrderModel.Groups groupsTransfer = groups.clone();
            groupsTransfer.lineDetails = new List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>{detailTransfer};
            listGroups.add(groupsTransfer);
        }
        return listGroups;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> buildListLinesTransf(OrderItem franchiseOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> listLineDatailTransfer = new List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>();
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            if(TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c) || DETACHED_SIMCARD.equals(varOrderItem.Product2.vlocity_cmt__SubType__c)){
                listLineDatailTransfer.add(buildLineDetails(varOrderItem));
            }
        }          
        return listLineDatailTransfer;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.LineDetails buildLineDetails(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.LineDetails lineDetails = new SOLAR_PME_IntegrationInputOrderModel.LineDetails();
        lineDetails.telephoneNumber = varOrderItem.PortabilityNumber__c;
        lineDetails.donor = buildDonor(varOrderItem);
        lineDetails.operator = varOrderItem.Operator__c;
        lineDetails.simcard = buildSimcard(varOrderItem);
        if(!DETACHED_SIMCARD.equals(varOrderItem.Product2.vlocity_cmt__SubType__c)) {
            lineDetails.device = buildDevice(varOrderItem);
        }
        return lineDetails;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Donor buildDonor(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Donor donor = new SOLAR_PME_IntegrationInputOrderModel.Donor();
        donor.name = varOrderItem.DonatorName__c;
        donor.cpf = varOrderItem.DonatorDocumentNumber__c;
        donor.Phones = buildDonorPhones(varOrderItem);
        donor.emailAddress  = varOrderItem.DonatorEmail__c;
        return donor;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Phones> buildDonorPhones(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Phones phone = new SOLAR_PME_IntegrationInputOrderModel.Phones();
        phone.contactMediumRole = '';
        phone.telephoneNumber = varOrderItem.DonatorPhone__c;
        if(String.isBlank(varOrderItem.DonatorPhone__c)){
            phone.areaCode = '';    
            phone.internationalCode = '';
        } else {
            phone.areaCode = varOrderItem.DonatorPhone__c.mid(0,2);    
            phone.internationalCode = INTERNATIONAL_CODE;
        }
        return new List<SOLAR_PME_IntegrationInputOrderModel.Phones>{phone};
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Simcard buildSimcard(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Simcard simcard = new SOLAR_PME_IntegrationInputOrderModel.Simcard();
      
        simcard.iccid = varOrderItem.ICCID__c;
        simcard.type = '';
        simcard.sap = buildSap(varOrderItem);
        
        if(varOrderItem.vlocity_cmt__RecurringCharge__c == 0) {
            simcard.value = '1';
        } else {
            simcard.value = String.valueOf(varOrderItem.vlocity_cmt__RecurringCharge__c);
        }
       
        for(OrderItem itemSimcard : getOnMapOrderItems(varOrderItem.vlocity_cmt__AssetReferenceId__c)) {  
            simcard.value = String.valueOf(itemSimcard.vlocity_cmt__RecurringCharge__c);
            simcard.sap = buildSap(itemSimcard);
            
        }
        
        return simcard;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Sap buildSap(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Sap sap = new SOLAR_PME_IntegrationInputOrderModel.Sap();
         
        if(TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c)) { 
            for(OrderItem itemSimCardAparelho : getOnMapOrderItems(varOrderItem.vlocity_cmt__AssetReferenceId__c)){
                sap.id = itemSimCardAparelho.SAP_ID__c; 
            }
        } else {
            sap.id = varOrderItem.SAP_ID__c;    
        }
        return sap;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Device buildDevice(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Device device = new SOLAR_PME_IntegrationInputOrderModel.Device();
        device.manufacturerName = varOrderItem.Product2.Name;
        device.modelName = varOrderItem.Product2.Model__c;
        device.color = varOrderItem.Product2.Color__c;
        device.value = String.valueOf(varOrderItem.vlocity_cmt__RecurringCharge__c);
        device.flagAcceptAnotherColor = varOrderItem.DeviceSecondOptionColor__c == SIM;
        device.chosenDeviceSap = new SOLAR_PME_IntegrationInputOrderModel.ChosenDeviceSap(varOrderItem.Product2.SAPID__c);
        device.optionalDevicesSap = buildListOptionalDevicesSap(varOrderItem);
        device.imei = varOrderItem.IMEI__c;
        return device;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.OptionalDevicesSap> buildListOptionalDevicesSap(OrderItem varOrderItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.OptionalDevicesSap> listOptionalDevicesSap = new List<SOLAR_PME_IntegrationInputOrderModel.OptionalDevicesSap>();
        String chave = varOrderItem.Product2.Manufacturer__c + varOrderItem.Product2.Model__c;
        
        List<String> listChoosenColor = new List<String>();
        if(String.isNotBlank(varOrderItem.AnotherDeviceColor__c)) {
            listChoosenColor = varOrderItem.AnotherDeviceColor__c.split(', ');
        }
        
        for(String choosenColor : listChoosenColor) {
            if(mapColorSapId.containsKey(chave + choosenColor)) {
                listOptionalDevicesSap.add(new SOLAR_PME_IntegrationInputOrderModel.OptionalDevicesSap(mapColorSapId.get(chave + choosenColor)));
            }
        }
        return listOptionalDevicesSap;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.SpecialOffer buildSpecialOffer(OrderItem varOrderItem, Integer lineDetails) {
        SOLAR_PME_IntegrationInputOrderModel.SpecialOffer specialOffer = new SOLAR_PME_IntegrationInputOrderModel.SpecialOffer();
        specialOffer.bonus = buildListBonus(varOrderItem);
        
        if(varOrderItem.vlocity_cmt__RecurringDiscountPrice__c != null) {    
            specialOffer.progressiveDiscount = buildProgressiveDiscount(varOrderItem, lineDetails);  
        }
        return specialOffer;
    } 
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Bonus> buildListBonus(OrderItem franchiseOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Bonus> listBonus = new List<SOLAR_PME_IntegrationInputOrderModel.Bonus>();
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            if(varOrderItem.Product2.vlocity_cmt__Type__c.equals('Bonus')){
                listBonus.add(buildBonus(varOrderItem));
            }            
        }
        return listBonus;
    }
    
    @testVisible
    private SOLAR_PME_IntegrationInputOrderModel.Bonus buildBonus(OrderItem varOrderItem) {
        SOLAR_PME_IntegrationInputOrderModel.Bonus bonus = new SOLAR_PME_IntegrationInputOrderModel.Bonus();
        String value = getOnJSON(varOrderItem.Product2.vlocity_cmt__JSONAttribute__c, 'value__c');
        String period = getOnJSONPeriod(varOrderItem.vlocity_cmt__JSONAttribute__c);
        if(String.isNotBlank(value)) {
            bonus.name = varOrderItem.Product2.Name;
            bonus.productCode = varOrderItem.Product2.ProductCode;
            bonus.value = value;
            bonus.type = varOrderItem.Product2.vlocity_cmt__Type__c;
            
            bonus.objectType = varOrderItem.Product2.vlocity_cmt__ObjectTypeId__c;
            bonus.productFamily = varOrderItem.Product2.Family;
            bonus.period = period;
            if('None'.equals(varOrderItem.Product2.vlocity_cmt__SubType__c)) {
                Boolean isConvergent = order.Account.NETClient__c || order.Account.EmbratelClient__c;
                if(isConvergent) {
                    bonus.subtype = 'Dobro';
                } else {
                    bonus.subtype = 'Específico';
                }
            } else {
                bonus.subtype = varOrderItem.Product2.vlocity_cmt__SubType__c;
            }
        }
        return bonus;
    }
    
    public String getOnJSON(String jsonString, String attribute) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        Map<String, Object> mapObject = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        if(mapObject.containsKey('ATT_CAT_FRANQ')) {
            List<Object> listAttCatFranq = (List<Object>) mapObject.get('ATT_CAT_FRANQ');
            for(Object objAttCatFranq : listAttCatFranq) {
                Map<String, Object> mapAttCatFranq = (Map<String, Object>) objAttCatFranq;
                Boolean isContains = mapAttCatFranq.containsKey('attributeuniquecode__c');
                isContains &= mapAttCatFranq.containsKey(attribute);
                String attributeUniqueCode = (String) mapAttCatFranq.get('attributeuniquecode__c');
                if(isContains && attributeUniqueCode.equalsIgnoreCase('ATT_PME_BonusValue')) {
                    return (String) mapAttCatFranq.get(attribute);
                }
            }
        }
        return null;
    } 
    
    public String getOnJSONPeriod(String jsonString) {
        try{
            Map<String, Object> mapObject = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            if(mapObject.containsKey('ATT_CAT_FRANQ')) {
                List<Object> listAttCatFranq = (List<Object>) mapObject.get('ATT_CAT_FRANQ');
                for(Object objAttCatFranq : listAttCatFranq) {
                    Map<String, Object> mapAttCatFranq = (Map<String, Object>) objAttCatFranq;
                    Boolean isContains = mapAttCatFranq.containsKey('attributeuniquecode__c');
                    isContains &= mapAttCatFranq.containsKey('attributeRunTimeInfo');
                    String attributeUniqueCode = (String) mapAttCatFranq.get('attributeuniquecode__c');
                    if(isContains && attributeUniqueCode.equalsIgnoreCase('ATT_PME_BonusValidity')) {
                        String jsonValidity = JSON.serialize((Object) mapAttCatFranq.get('attributeRunTimeInfo')); 
                        Map<String, Object> bonusvalidity = (Map<String, Object>) JSON.deserializeUntyped(jsonValidity);    
                        return ((String)bonusvalidity.get('value')).replace('meses','').replace(' ','');
                    }
                }
            }
        } catch(Exception e){
        	return '0';    
        }
        return '0';
    } 
    
    private SOLAR_PME_IntegrationInputOrderModel.ProgressiveDiscount buildProgressiveDiscount(OrderItem varOderItem, Integer lineDetails) {
        if(varOderItem.vlocity_cmt__RecurringDiscountPrice__c != null) {
            SOLAR_PME_IntegrationInputOrderModel.ProgressiveDiscount progressiveDiscount = new SOLAR_PME_IntegrationInputOrderModel.ProgressiveDiscount();
            progressiveDiscount.quantity = lineDetails;
            progressiveDiscount.value = varOderItem.vlocity_cmt__RecurringDiscountPrice__c;
            return progressiveDiscount;
        }
        return null;
    } 
    
    private Set<String> buildDistinctDevices(OrderItem franchiseOrdItem) {
        Set<String> setDevices = new Set<String>();
        for(OrderItem varOrderItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
            if(TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c)) {
                setDevices.add(varOrderItem.Product2.Name);
            }
        }
        return setDevices;
    }

    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> separateGroup(List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> separetedListGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        
        for(SOLAR_PME_IntegrationInputOrderModel.Groups oldGroup : listGroups) {
            Map<String, List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>> mapCKeyLstLineDetails = new Map<String, List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>>();
            for(SOLAR_PME_IntegrationInputOrderModel.LineDetails lineDetail : oldGroup.lineDetails) {
                String lineDetailKey = builderLineDetailsKey(lineDetail); 
                if(mapCKeyLstLineDetails.containsKey(lineDetailKey)) {
                    mapCKeyLstLineDetails.get(lineDetailKey).add(lineDetail);
                } else {
                    mapCKeyLstLineDetails.put(lineDetailKey, new List<SOLAR_PME_IntegrationInputOrderModel.LineDetails>{lineDetail});
                }
            }
            for(List<SOLAR_PME_IntegrationInputOrderModel.LineDetails> listLineDetails : mapCKeyLstLineDetails.values()) {
                SOLAR_PME_IntegrationInputOrderModel.Groups newGroup = oldGroup.clone();
                newGroup.lineDetails = listLineDetails;
                separetedListGroups.add(newGroup);
            }
        }           
        
        return separetedListGroups;
    }
    
    @TestVisible
    private String builderLineDetailsKey(SOLAR_PME_IntegrationInputOrderModel.LineDetails lineDetail) {
        String key;
        String operator = '';
        if(!String.isBlank(lineDetail.operator)) {
            operator = lineDetail.operator;
        }
        if(lineDetail.device == null) {
            return NOT_IS_A_DEVICE + operator;
        }
        key = operator + lineDetail.Device.manufacturerName + lineDetail.Device.modelName + lineDetail.Device.color;
        if(lineDetail.Device.optionalDevicesSap == null || lineDetail.Device.optionalDevicesSap.isEmpty()) {
            key = key + DONT_HAVE_OPT_DEVICES;
        } else {
            for(SOLAR_PME_IntegrationInputOrderModel.OptionalDevicesSap optionalDevicesSap : lineDetail.Device.optionalDevicesSap) {
                key = key + optionalDevicesSap.Id;
            }
        }         
        return key;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Plans> separatePlansByRegional(List<SOLAR_PME_IntegrationInputOrderModel.Plans> listOldPlans) {
        List<SOLAR_PME_IntegrationInputOrderModel.Plans> listSeparatedPlans = new List<SOLAR_PME_IntegrationInputOrderModel.Plans>();
        for(SOLAR_PME_IntegrationInputOrderModel.Plans oldPlan : listOldPlans) {
            Map<String, List<SOLAR_PME_IntegrationInputOrderModel.Groups>> mapCKeyLstGroups = new Map<String, List<SOLAR_PME_IntegrationInputOrderModel.Groups>>();
            if(oldPlan.groups != null) {
                for(SOLAR_PME_IntegrationInputOrderModel.Groups varGroup : oldPlan.groups) {
                    if(mapCKeyLstGroups.containsKey(varGroup.Regional)) {
                        mapCKeyLstGroups.get(varGroup.Regional).add(varGroup);
                    } else {
                        mapCKeyLstGroups.put(varGroup.Regional, new List<SOLAR_PME_IntegrationInputOrderModel.Groups>{varGroup});
                    }
                }
            }
            for(List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups : mapCKeyLstGroups.values()) {
                SOLAR_PME_IntegrationInputOrderModel.Plans newPlan = oldPlan.clone();
                newPlan.groups = listGroups;
                listSeparatedPlans.add(newPlan);
            }
        }
        return listSeparatedPlans;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildListGroupsShared(OrderItem varOrderItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        for(OrderItem franchiseOrdItem : getOnMapOrderItems(varOrderItem.vlocity_cmt__AssetReferenceId__c)) {
            for(OrderItem pluginOrdItem : getOnMapOrderItems(franchiseOrdItem.vlocity_cmt__AssetReferenceId__c)) {
                listGroups.addAll(buildListGroupsShared(franchiseOrdItem, pluginOrdItem));
            }
        } 
        return listGroups;
    }

    private List<SOLAR_PME_IntegrationInputOrderModel.Groups> buildListGroupsShared(OrderItem franchiseOrdItem, OrderItem pluginOrdItem) {
        List<SOLAR_PME_IntegrationInputOrderModel.Groups> listGroups = new List<SOLAR_PME_IntegrationInputOrderModel.Groups>();
        if(PRODUCT_TYPE_PLUGIN.equals(pluginOrdItem.Product2.vlocity_cmt__Type__c)) {
            SOLAR_PME_IntegrationInputOrderModel.Groups groups = new SOLAR_PME_IntegrationInputOrderModel.Groups();    
            groups.groupId = franchiseOrdItem.vlocity_cmt__AssetReferenceId__c;
            groups.name = franchiseOrdItem.Product2.Name;
            groups.stateAbbreviation = franchiseOrdItem.Group__c;
            groups.franchise = franchiseOrdItem.Product2.Name;
            groups.value = String.ValueOf(franchiseOrdItem.vlocity_cmt__RecurringCharge__c);
            groups.requestType = pluginOrdItem.TypeOfRequest__c;
            groups.areaCode = pluginOrdItem.Subgroup__c;
            groups.contractPeriod = order.Payment_Term__c;
            groups.paymentMethod = order.Payment_Term__c;
            groups.plugin = '';
            groups.overRateValue = '';
            groups.additionalServices = buildListAdditionalServices(pluginOrdItem);
            groups.additionalServices = buildListAdditionalServices(franchiseOrdItem);
            groups.includedServices = buildListIncludedServices(pluginOrdItem, false);
            
            if(SP.equalsIgnoreCase(franchiseOrdItem.Group__c)) {
                groups.regional = franchiseOrdItem.ParentGroup__c;
            } else {
                groups.regional = franchiseOrdItem.Group__c;
            }
            
            if(fromToUtil.hasTo(pluginOrdItem.Product2.ProductCode)) {
                groups.plugin = fromToUtil.getTo(pluginOrdItem.Product2.ProductCode);
            } 
            
            if(TYPE_TRANSFER.equals(franchiseOrdItem.TypeOfRequest__c)) {
                listGroups.addAll(buildListGroupsTranfer(groups, pluginOrdItem));
            } else {
                listGroups.addAll(buildListGroupsNotTranfer(groups, pluginOrdItem, false));
            }
        }
        return listGroups;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Summary buildSummary() {
        SOLAR_PME_IntegrationInputOrderModel.Summary summary = new SOLAR_PME_IntegrationInputOrderModel.Summary();
        summary.lineQuantity = getLineQuantity();
        summary.deviceQuantity = getDeviceQuantity();
        summary.simcardQuantity = summary.lineQuantity;
        summary.totalValueOfEquipments = getTotalValueOfEquipments();
        summary.totalValueOfServices = getTotalValueOfServices();
        return summary;
    }
    
    private String getLineQuantity() {
        Integer quantity = 0;
        for(OrderItem varOrderItem : order.OrderItems) {   
            Boolean isSimCard = DETACHED_SIMCARD.equals(varOrderItem.Product2.vlocity_cmt__SubType__c);
            isSimCard |= DEVICE_SIMCARD.equals(varOrderItem.Product2.vlocity_cmt__SubType__c);
            if(isSimCard) {
                quantity += Integer.valueOf(varOrderItem.Quantity);
            }
        }     
        return String.valueOf(quantity);
    }
    
    private String getDeviceQuantity() {
        Integer quantity = 0;
        for(OrderItem varOrderItem : order.OrderItems) {
            Boolean isDevice = TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            isDevice |= TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            if(isDevice) {
                quantity += Integer.valueOf(varOrderItem.Quantity);
            }
        }           
        return String.valueOf(quantity);
    }
    
    private String getTotalValueOfEquipments() {
        Decimal total = 0;
        for(OrderItem varOrderItem : order.OrderItems){
            Boolean isDevice = TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            isDevice |= TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            if(isDevice) {
                total += varOrderItem.vlocity_cmt__RecurringTotal__c;
            }
        }

        return String.valueOf(total);
    }
    
    private String getTotalValueOfServices() {
        Decimal total = 0;
        for(OrderItem varOrderItem : order.OrderItems){
            Boolean isDevice = TYPE_DEVICE.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            isDevice |= TYPE_DEVICES.equals(varOrderItem.Product2.vlocity_cmt__Type__c);
            if(isDevice) {
                total += varOrderItem.vlocity_cmt__RecurringTotal__c;
            }
        }   
        return String.valueOf(total);
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.SubscriberAcceptances getSubscriberAcceptances() {
        SOLAR_PME_IntegrationInputOrderModel.SubscriberAcceptances subscriberAcceptances = new SOLAR_PME_IntegrationInputOrderModel.SubscriberAcceptances();
        subscriberAcceptances.flagAcceptSmsPublicity = false; 
        subscriberAcceptances.flagAcceptLD21Manager = SIM.equalsIgnoreCase(order.LD21__c); 
        subscriberAcceptances.flagAuthorizesDataSharing = false;
        return subscriberAcceptances;
    }
    
    private List<SOLAR_PME_IntegrationInputOrderModel.Documents> buildListDocuments() {
        List<SOLAR_PME_IntegrationInputOrderModel.Documents> listDocuments = new List<SOLAR_PME_IntegrationInputOrderModel.Documents>();
        Set<String> setContentLink = new Set<String>();
        for(ContentDocumentLink varContentDocumentLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :order.Id]) {
            setContentLink.add(varContentDocumentLink.ContentDocumentId);
        }

        if(!Schema.sObjectType.ContentVersion.isAccessible()) {
            throw new InputOrderException('User does not have access to the ContentVersion sObject');
        }

        List<ContentVersion> listContentVersions = [SELECT Id, 
                                                    PathOnClient, 
                                                    CEC_Tipo_de_Anexo__c,
                                                    Title
                                                    FROM ContentVersion 
                                                    WHERE ContentDocumentId IN :setContentLink
                                                    AND IsLatest = true];
        
        for(ContentVersion varContentVersion : listContentVersions){
            SOLAR_PME_IntegrationInputOrderModel.Documents documents = new SOLAR_PME_IntegrationInputOrderModel.Documents();
            documents.id = varContentVersion.Id;
            documents.name = varContentVersion.CEC_Tipo_de_Anexo__c;
            documents.fileName = varContentVersion.Title;
            listDocuments.add(documents);
        }
        
        return listDocuments;
    }
    
    private SOLAR_PME_IntegrationInputOrderModel.Message getMessage(String sendType) {
        SOLAR_PME_IntegrationInputOrderModel.Message message = new SOLAR_PME_IntegrationInputOrderModel.Message();
        if(NEW_ORDER.equals(sendType)) {
            message.type = MSG_TYPE_NEW;
            message.action = MSG_ACTION_INCLUDE;
        }          
        return message;
    }
    
    @testVisible
    private Integer stringToInteger(String stringValue) {
        String regex = '[^0-9]+';
        String onlyNumberOnStr = stringValue.replaceAll(regex, '');
        if(String.isBlank(onlyNumberOnStr)) {
            return 0;
        }
        return Integer.valueOf(onlyNumberOnStr);
    }
    
}