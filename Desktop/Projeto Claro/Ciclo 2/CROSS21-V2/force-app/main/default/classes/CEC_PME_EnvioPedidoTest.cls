/*
* Autor: Marcos Silva - Deloitte
* Data: 09/01/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe CEC_PME_EnvioPedido_Service
*/
@isTest
private class CEC_PME_EnvioPedidoTest {
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */     
    @testSetup static void setup() {
        ServiceParameter__c srvP = CEC_PME_OrderTestMethods.createParameter('CEC_PME_EnvioPedido');
        insert srvP;
        CEC_PME_OrderTestMethods.generateAllData();
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do envio de um pedido ao RPA
    */     
    @isTest static void main() {
        Order ord = [SELECT Id FROM Order];
        Test.startTest();
        CEC_PME_EnvioPedido_Response res = CEC_PME_EnvioPedido_Service.enviarPedido(ord.Id);
        Test.stopTest();
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da montagem de um request
    */      
    @isTest static void testRequest() {
        CEC_PME_EnvioPedidoRequest.Data varData = new CEC_PME_EnvioPedidoRequest.Data();
        varData.salesOrders = null;
        
        CEC_PME_EnvioPedidoRequest.SalesOrders varSalesOrders = new CEC_PME_EnvioPedidoRequest.SalesOrders();
        varSalesOrders.salesParty = null;
        varSalesOrders.customer = null;
        varSalesOrders.equipmentDelivery = null;
        varSalesOrders.order = null;
        varSalesOrders.summary = null;
        varSalesOrders.subscriberAcceptances = null;
        varSalesOrders.documents = null;
        varSalesOrders.message = null;
        
        CEC_PME_EnvioPedidoRequest.SalesParty varSalesParty = new CEC_PME_EnvioPedidoRequest.SalesParty();
        varSalesParty.salesmanId = null;
        varSalesParty.salesmanJobTitle = null;
        varSalesParty.salesmanName = null;
        varSalesParty.companyName = null;
        varSalesParty.cnpj = null;
        varSalesParty.vendorId = null;
        varSalesParty.salesChannelId = null;
        varSalesParty.comercialSegment = null;
        
        CEC_PME_EnvioPedidoRequest.customer varcustomer = new CEC_PME_EnvioPedidoRequest.customer();
        varcustomer.companyName = null;
        varcustomer.tradingName = null;
        varcustomer.stateRegistration = null;
        varcustomer.municipalRegistration = null;
        varcustomer.cnaes = null;
        varcustomer.cnpj = null;
        varcustomer.flagNetSubscriber = null;
        varcustomer.flagEmbratelSubscriber = null;
        varcustomer.customerAccountId = null;
        varcustomer.contactPhone = null;
        varcustomer.employeeQuantity = null;
        varcustomer.accountType = null;
        varcustomer.accountSegment = null;
        varcustomer.territory = null;
        varcustomer.contacts = null;
        varcustomer.addresses = null;
        varcustomer.billingSpec = null;   
        
        CEC_PME_EnvioPedidoRequest.CNAES varCNAES = new CEC_PME_EnvioPedidoRequest.CNAES();
        varCNAES.type = null;
        varCNAES.code = null;
        varCNAES.description = null;
        
        CEC_PME_EnvioPedidoRequest.ContactPhone varContactPhone = new CEC_PME_EnvioPedidoRequest.ContactPhone();
        varContactPhone.telephoneNumber = null;
        varContactPhone.areaCode = null;
        varContactPhone.internationalCode = null;
        varContactPhone.contactMediumRole = null;
        
        CEC_PME_EnvioPedidoRequest.Contacts varContacts = new CEC_PME_EnvioPedidoRequest.Contacts();
        varContacts.title = null;
        varContacts.firstName = null;
        varContacts.lastName = null;
        varContacts.cpf = null;
        varContacts.gender = null;
        varContacts.birthDate = null;
        varContacts.phones = null;
        varContacts.emailAddress = null;
        varContacts.isLegalRepresentative = null;
        varContacts.jobTitle = null;
        varContacts.occupation = null;
        
        CEC_PME_EnvioPedidoRequest.Phones varPhones = new CEC_PME_EnvioPedidoRequest.Phones();
        varPhones.telephoneNumber = null;
        varPhones.areaCode = null;
        varPhones.internationalCode = null;
        varPhones.contactMediumRole = null;
        
        CEC_PME_EnvioPedidoRequest.Addresses varAddresses = new CEC_PME_EnvioPedidoRequest.Addresses();
        varAddresses.addressType = null;
        varAddresses.postcode = null;
        varAddresses.streetType = null;
        varAddresses.streetName = null;
        varAddresses.streetNr = null;
        varAddresses.complement = null;
        varAddresses.neighborhood = null;
        varAddresses.cityName = null;
        varAddresses.stateAbbreviation = null;
        
        CEC_PME_EnvioPedidoRequest.CommercialReferences varCommercialReferences = new CEC_PME_EnvioPedidoRequest.CommercialReferences();
        varCommercialReferences.companyName = null;
        varCommercialReferences.cnpj = null;
        varCommercialReferences.contactName = null;
        varCommercialReferences.contactPhone = null;
        
        CEC_PME_EnvioPedidoRequest.BillingSpec varBillingSpec = new CEC_PME_EnvioPedidoRequest.BillingSpec();
        varBillingSpec.paymentDayDue = null;
        varBillingSpec.address = null;
        
        CEC_PME_EnvioPedidoRequest.Address varAddress = new CEC_PME_EnvioPedidoRequest.Address();
        varAddress.addressType = null;
        varAddress.postcode = null;
        varAddress.streetType = null;
        varAddress.streetName = null;
        varAddress.streetNr = null;
        varAddress.complement = null;
        varAddress.neighborhood = null;
        varAddress.cityName = null;
        varAddress.stateAbbreviation = null;
        
        CEC_PME_EnvioPedidoRequest.EquipmentDelivery varEquipmentDelivery = new CEC_PME_EnvioPedidoRequest.EquipmentDelivery();
        varEquipmentDelivery.type = null;
        varEquipmentDelivery.address = null;
        varEquipmentDelivery.receivers = null;
        
        CEC_PME_EnvioPedidoRequest.Receivers varReceivers = new CEC_PME_EnvioPedidoRequest.Receivers();
        varReceivers.name = null;
        varReceivers.rg = null;
        varReceivers.phone = null;
        
        CEC_PME_EnvioPedidoRequest.Order varOrder = new CEC_PME_EnvioPedidoRequest.Order();
        varOrder.orderId = null;
        varOrder.orderAction = null;
        varOrder.plans = null;
        
        CEC_PME_EnvioPedidoRequest.Plans varPlans = new CEC_PME_EnvioPedidoRequest.Plans();
        varPlans.planId = null;
        varPlans.name = null;
        varPlans.flagSharedPlan = null;
        varPlans.tradeIn = null;
        varPlans.groups = null;
        
        CEC_PME_EnvioPedidoRequest.Groups varGroups = new CEC_PME_EnvioPedidoRequest.Groups();
        varGroups.groupId = null;
        varGroups.name = null;
        varGroups.requestType = null;
        varGroups.regional = null;
        varGroups.stateAbbreviation = null;
        varGroups.areaCode = null;
        varGroups.franchise = null;
        varGroups.value = null;
        varGroups.overRateValue = null;
        varGroups.contractPeriod = null;
        varGroups.lineAmount = null;
        varGroups.paymentMethod = null;
        varGroups.additionalServices = null;
        varGroups.includedServices = null;
        varGroups.lineDetails = null;
        
        CEC_PME_EnvioPedidoRequest.AdditionalServices varAdditionalServices = new CEC_PME_EnvioPedidoRequest.AdditionalServices();
        varAdditionalServices.name = null;
        varAdditionalServices.value = null;
        varAdditionalServices.type = null;
        
        CEC_PME_EnvioPedidoRequest.IncludedServices varIncludedServices = new CEC_PME_EnvioPedidoRequest.IncludedServices();
        varIncludedServices.name = null;
        varIncludedServices.type = null;
        
        CEC_PME_EnvioPedidoRequest.LineDetails varLineDetails = new CEC_PME_EnvioPedidoRequest.LineDetails();
        varLineDetails.telephoneNumber = null;
        varLineDetails.donor = null;
        varLineDetails.operator = null;
        varLineDetails.simcard = null;
        varLineDetails.device = null;
        
        CEC_PME_EnvioPedidoRequest.Donor varDonor = new CEC_PME_EnvioPedidoRequest.Donor();
        varDonor.name = null;
        varDonor.cpf = null;
        varDonor.Phones = null;
        varDonor.emailAddress = null;
        varDonor.address = null;
        
        CEC_PME_EnvioPedidoRequest.Simcard varSimcard = new CEC_PME_EnvioPedidoRequest.Simcard();
        varSimcard.sap = null;
        varSimcard.iccid = null;
        varSimcard.type = null;
        varSimcard.value = null;
        
        CEC_PME_EnvioPedidoRequest.Sap varSap = new CEC_PME_EnvioPedidoRequest.Sap();
        varSap.id = null;
        
        CEC_PME_EnvioPedidoRequest.Device varDevice = new CEC_PME_EnvioPedidoRequest.Device();
        varDevice.manufacturerName = null;
        varDevice.modelName = null;
        varDevice.color = null;
        varDevice.value = null;
        varDevice.flagAcceptAnotherColor = null;
        varDevice.chosenDeviceSap = null;
        varDevice.optionalDevicesSap = null;
        varDevice.imei = null;
        
        CEC_PME_EnvioPedidoRequest.ChosenDeviceSap varChosenDeviceSap = new CEC_PME_EnvioPedidoRequest.ChosenDeviceSap();
        varChosenDeviceSap.id = null;
        
        CEC_PME_EnvioPedidoRequest.OptionalDevicesSap varOptionalDevicesSap = new CEC_PME_EnvioPedidoRequest.OptionalDevicesSap();
        varOptionalDevicesSap.id = null;
        
        CEC_PME_EnvioPedidoRequest.Summary varSummary = new CEC_PME_EnvioPedidoRequest.Summary();
        varSummary.lineQuantity = null;
        varSummary.deviceQuantity = null;
        varSummary.simcardQuantity = null;
        varSummary.totalValueOfEquipments = null;
        varSummary.totalValueOfServices = null;
        
        CEC_PME_EnvioPedidoRequest.SubscriberAcceptances varSubscriberAcceptances = new CEC_PME_EnvioPedidoRequest.SubscriberAcceptances();
        varSubscriberAcceptances.flagAcceptSmsPublicity = null;
        varSubscriberAcceptances.flagAcceptLD21Manager = null;
        varSubscriberAcceptances.flagAuthorizesDataSharing = null;
               
        CEC_PME_EnvioPedidoRequest.Documents varDocuments = new CEC_PME_EnvioPedidoRequest.Documents();
        varDocuments.id = null;
        varDocuments.name = null;
        varDocuments.fileName = null;
        
        CEC_PME_EnvioPedidoRequest.Message varMessage = new CEC_PME_EnvioPedidoRequest.Message();
        varMessage.type = null;
        varMessage.action = null;
        
        CEC_PME_EnvioPedidoRequest req = new CEC_PME_EnvioPedidoRequest();
        CEC_PME_EnvioPedidoRequest.SalesOrders[] soList = new List<CEC_PME_EnvioPedidoRequest.SalesOrders>();
        CEC_PME_EnvioPedidoRequest.SalesOrders so = new CEC_PME_EnvioPedidoRequest.SalesOrders();
        soList.add(null);
        req.data = new CEC_PME_EnvioPedidoRequest.Data();
        req.data.salesOrders = new CEC_PME_EnvioPedidoRequest.SalesOrders[2];
    }
}