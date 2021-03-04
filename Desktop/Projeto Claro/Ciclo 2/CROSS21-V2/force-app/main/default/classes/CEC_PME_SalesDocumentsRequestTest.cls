/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe CEC_PME_SalesDocumentsRequest.
*/
@isTest
public class CEC_PME_SalesDocumentsRequestTest 
{
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da inicialização da estrutura que será enviada ao GGD.
    */      
	@isTest
    public static void testRequest()
    {
        Test.startTest();
		
        CEC_PME_SalesDocumentsRequest.Device varDevice = new CEC_PME_SalesDocumentsRequest.Device();
        varDevice.manufacturerName = '';
        varDevice.modelName = '';
        varDevice.color = '';
        varDevice.flagAcceptAnotherColor = true;
        varDevice.value = 2.0;
        varDevice.score = 1;
        varDevice.range = '';
        varDevice.baseValue = 1.0;
        
        CEC_PME_SalesDocumentsRequest.Simcard varSimcard = new CEC_PME_SalesDocumentsRequest.Simcard();
        varSimcard.iccid = '';
        varSimcard.type = '';
        varSimcard.value = 2.0;
        varSimcard.baseValue = 1.0;
        String formattedIccidSimcard = varSimcard.formattedIccid;
        String formattedValueSimcard = varSimcard.formattedValue;
        
        CEC_PME_SalesDocumentsRequest.Address varAddress = new CEC_PME_SalesDocumentsRequest.Address();
        varAddress.addressType = '';
        varAddress.postcode = '';
        varAddress.streetType = '';
        varAddress.streetName = '';
        varAddress.streetNr = '';
        varAddress.complement = '';
        varAddress.neighborhood = '';
        varAddress.cityName = '';
        varAddress.stateAbbreviation = '';
        
        List<CEC_PME_SalesDocumentsRequest.Phones> lstPhones = new List<CEC_PME_SalesDocumentsRequest.Phones>();
        CEC_PME_SalesDocumentsRequest.Phones varPhone = new CEC_PME_SalesDocumentsRequest.Phones();
        varPhone.areaCode = '';
		varPhone.contactMediumRole = '';
		varPhone.internationalCode = '55';
        varPhone.telephoneNumber = '';
        String formattedNumber = varPhone.formattedNumber;
        varPhone.telephoneNumber = '43214321';
        formattedNumber = varPhone.formattedNumber;
        varPhone.telephoneNumber = '543214321';
        formattedNumber = varPhone.formattedNumber;
        varPhone.telephoneNumber = '54321-4321';
        formattedNumber = varPhone.formattedNumber;
        lstPhones.add(varPhone);
        
        CEC_PME_SalesDocumentsRequest.Donor varDonor = new CEC_PME_SalesDocumentsRequest.Donor();
        varDonor.name = '';
        varDonor.cpf = '';
        varDonor.emailAddress = '';
        varDonor.phones = lstPhones;
        varDonor.address = varAddress;
        String formattedCpfDonor = varDonor.formattedCpf;
        
        List<CEC_PME_SalesDocumentsRequest.LineDetails> lstLineDetails = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
        CEC_PME_SalesDocumentsRequest.LineDetails varLineDetail = new CEC_PME_SalesDocumentsRequest.LineDetails();
        varLineDetail.telephoneNumber = '';
        varLineDetail.operator = '';
        varLineDetail.donor = varDonor;
        varLineDetail.simCard = varSimCard;
        varLineDetail.device = varDevice;
        String formattedOperator = varLineDetail.formattedOperator;
        String formattedTelephoneNumber = varLineDetail.formattedTelephoneNumber;
        
        List<CEC_PME_SalesDocumentsRequest.IncludedServices> lstIncludedServices = new List<CEC_PME_SalesDocumentsRequest.IncludedServices>();
        CEC_PME_SalesDocumentsRequest.IncludedServices varIncludedService = new CEC_PME_SalesDocumentsRequest.IncludedServices();
        varIncludedService.name = '';
        lstIncludedServices.add(varIncludedService);
        
        List<CEC_PME_SalesDocumentsRequest.AdditionalServices> lstAdditionalServices = new List<CEC_PME_SalesDocumentsRequest.AdditionalServices>();
        CEC_PME_SalesDocumentsRequest.AdditionalServices varAdditionalService = new CEC_PME_SalesDocumentsRequest.AdditionalServices();
        varAdditionalService.name = '';
        varAdditionalService.value = 1.0;
        String formattedValueAdditionalService = varAdditionalService.formattedValue;
        lstAdditionalServices.add(varAdditionalService);
        
        CEC_PME_SalesDocumentsRequest.Plugin varPlugin = new CEC_PME_SalesDocumentsRequest.Plugin();
        varPlugin.type = '';
        varPlugin.id = '';
        varPlugin.value = 1.0;
        varPlugin.areacode = '';
        String PluginFormattedValue = varPlugin.formattedValue;
        
        List<CEC_PME_SalesDocumentsRequest.Plugin> lstPlugin = new List<CEC_PME_SalesDocumentsRequest.Plugin>();
        lstPlugin.add(varPlugin);
        
        CEC_PME_SalesDocumentsRequest.Bonus bonus = new CEC_PME_SalesDocumentsRequest.Bonus();
        bonus.name = 'test';
        bonus.productCode = 'test';
        bonus.value = 'test';
        bonus.type = 'test';
        bonus.subtype = 'test';
        bonus.objectType = 'test';
        bonus.productFamily = 'test';
        bonus.period = 'test';
        List<CEC_PME_SalesDocumentsRequest.Bonus> listBonus = new List<CEC_PME_SalesDocumentsRequest.Bonus>();
        listBonus.add(bonus);
        
        List<CEC_PME_SalesDocumentsRequest.Groups> lstGroups = new List<CEC_PME_SalesDocumentsRequest.Groups>();
        CEC_PME_SalesDocumentsRequest.Groups varGroup = new CEC_PME_SalesDocumentsRequest.Groups();
        varGroup.name = '';
        varGroup.requestType = '';
        varGroup.regional = '';
        varGroup.stateAbbreviation = '';
        varGroup.areaCode = '';
        varGroup.franchise = '';
        varGroup.value = 1.0;
        varGroup.lineAmount = '';
        varGroup.paymentMethod = '';
        varGroup.listBonus = listBonus;
        varGroup.progressiveDiscount = 1.0;
        varGroup.valueDiscount = 1.0;
        varGroup.additionalServices = lstAdditionalServices;
        varGroup.includedServices = lstIncludedServices;
        varGroup.lineDetails = lstLineDetails;
        varGroup.plugins = lstPlugin;  
        varGroup.kit = '';
        String formattedValue = varGroup.formattedValue;
        String formattedProgressiveDiscount = varGroup.formattedProgressiveDiscount;
        String formattedValueDiscount = varGroup.formattedValueDiscount;
        String formattedKit = varGroup.formattedKit;
        lstGroups.add(varGroup);
        
        List<CEC_PME_SalesDocumentsRequest.Plans> lstPlans = new List<CEC_PME_SalesDocumentsRequest.Plans>();
        CEC_PME_SalesDocumentsRequest.Plans varPlan = new CEC_PME_SalesDocumentsRequest.Plans();
        varPlan.name = '';
        String formattedName = varPlan.formattedName;
        varPlan.name = 'Plano Claro Total Compartilhado';
        formattedName = varPlan.formattedName;
        varPlan.name = 'Plano Claro Total Individual';
        formattedName = varPlan.formattedName;
        varPlan.name = 'outro';
        formattedName = varPlan.formattedName;
        varPlan.flagSharedPlan = true;
        varPlan.tradeIn = '';        
        varPlan.groups = lstGroups;
        
        List<CEC_PME_SalesDocumentsRequest.Administrators> lstAdministrators = new List<CEC_PME_SalesDocumentsRequest.Administrators>();
        CEC_PME_SalesDocumentsRequest.Administrators varAdministrators = new CEC_PME_SalesDocumentsRequest.Administrators();
        varAdministrators.name = '';
        varAdministrators.cpf = '32132132121';
        varAdministrators.emailAddress = '';
        varAdministrators.jobTitle = '';
        varAdministrators.isLegalRepresentative = true;
        varAdministrators.phones = lstPhones;
        String formattedCpf = varAdministrators.formattedCpf;
        lstAdministrators.add(varAdministrators);
        
        CEC_PME_SalesDocumentsRequest.ContactPhone varContactPhone = new CEC_PME_SalesDocumentsRequest.ContactPhone();
        varContactPhone.telephoneNumber = '';
        varContactPhone.areaCode = '';
        varContactPhone.internationalCode = '';
        varContactPhone.contactMediumRole = '';
        
        CEC_PME_SalesDocumentsRequest.BankingDetails varBankingDetails = new CEC_PME_SalesDocumentsRequest.BankingDetails();
        varBankingDetails.bankId = '';
        varBankingDetails.bankName = '';
        varBankingDetails.agency = '';
        varBankingDetails.accountNumber = '';
        varBankingDetails.contactName = '';
        varBankingDetails.contactPhone = varContactPhone;
        
        CEC_PME_SalesDocumentsRequest.BillingSpec varBillingSpec = new CEC_PME_SalesDocumentsRequest.BillingSpec();
        varBillingSpec.paymentDayDue = '';
        varBillingSpec.bankingDetails = varBankingDetails;
        
        List<CEC_PME_SalesDocumentsRequest.CommercialReferences> lstCommercial = new List<CEC_PME_SalesDocumentsRequest.CommercialReferences>();
        CEC_PME_SalesDocumentsRequest.CommercialReferences varCommercial = new CEC_PME_SalesDocumentsRequest.CommercialReferences();
        varCommercial.companyName = '';
        varCommercial.cnpj = '';
        varCommercial.contactName = '';
        varCommercial.contactPhone = varContactPhone;
        lstCommercial.add(varCommercial);
        
        List<CEC_PME_SalesDocumentsRequest.Addresses> lstAddresses = new List<CEC_PME_SalesDocumentsRequest.Addresses>();
        CEC_PME_SalesDocumentsRequest.Addresses varAddresses = new CEC_PME_SalesDocumentsRequest.Addresses();
        varAddresses.addressType = '';
        varAddresses.cityName = '';
        varAddresses.complement = '';
        varAddresses.neighborhood = '';
        varAddresses.postcode = '';
        varAddresses.stateAbbreviation = '';
        varAddresses.streetName = '';
        varAddresses.streetNr = '';
        varAddresses.streetType = '';
        lstAddresses.add(varAddresses);
        
        CEC_PME_SalesDocumentsRequest.Customer varCustomer = new CEC_PME_SalesDocumentsRequest.Customer();
        varCustomer.cnpj = '';
        varCustomer.companyName = '';
        varCustomer.customerAccountId = '';
        varCustomer.employeeQuantity = 1;
        varCustomer.flagEmbratelSubscriber = true;
        varCustomer.municipalRegistration = '';
        varCustomer.flagNetSubscriber = true;
        varCustomer.primaryCNAE = '';
        varCustomer.secondaryCNAE = '';
        varCustomer.stateRegistration = '';
        varCustomer.addresses = lstAddresses;
        varCustomer.contactPhone = varContactPhone;
        varCustomer.administrators = lstAdministrators;
        varCustomer.commercialReferences = lstCommercial;
        varCustomer.billingSpec = varBillingSpec;
        
        List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers> lstEquipment = new List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers>();
        CEC_PME_SalesDocumentsRequest.EquipmentReceivers varEquipment = new CEC_PME_SalesDocumentsRequest.EquipmentReceivers();
		varEquipment.name = '';
        varEquipment.rg = '';
        varEquipment.phones = varPhone;
        lstEquipment.add(varEquipment);
        
        CEC_PME_SalesDocumentsRequest.SubscriberAcceptances varSubscriber = new CEC_PME_SalesDocumentsRequest.SubscriberAcceptances();
        varSubscriber.flagAcceptLD21Manager = true;
        varSubscriber.flagAcceptSmsPublicity = true;
        varSubscriber.flagAuthorizesDataSharing = true;
        
        CEC_PME_SalesDocumentsRequest.SalesParty varSalesParty = new CEC_PME_SalesDocumentsRequest.SalesParty();
        varSalesParty.salesmanId = '';
        varSalesParty.salesmanName = '';
        varSalesParty.companyName = '';
        varSalesParty.cnpj = '';
        varSalesParty.vendorId = '';
        varSalesParty.salesChannelId = '';
        varSalesParty.segment = '';
        
        CEC_PME_SalesDocumentsRequest.SimcardDetails simcardDetails = new CEC_PME_SalesDocumentsRequest.SimcardDetails();
        simcardDetails.type = '';
        simcardDetails.quantity = 1; 
        
        List<CEC_PME_SalesDocumentsRequest.SimcardDetails> lstSimcardDetails = new List<CEC_PME_SalesDocumentsRequest.SimcardDetails>();
        lstSimcardDetails.add(simcardDetails);
        
        CEC_PME_SalesDocumentsRequest.Summary varSummary = new CEC_PME_SalesDocumentsRequest.Summary();
        varSummary.deviceQuantity = '';
        varSummary.lineQuantity = '';
        varSummary.totalValueOfEquipments = 1.0;
        varSummary.totalValueOfServices = '';
        varSummary.paymentMethod = '';
        varSummary.simcards = lstSimcardDetails;        
        
        List<CEC_PME_SalesDocumentsRequest.SalesDocuments> lstSalesDocuments = new List<CEC_PME_SalesDocumentsRequest.SalesDocuments>();
        CEC_PME_SalesDocumentsRequest.SalesDocuments varSalesDocuments = new CEC_PME_SalesDocumentsRequest.SalesDocuments();
        varSalesDocuments.salesParty = varSalesParty;
        varSalesDocuments.summary = varSummary;
        varSalesDocuments.subscriberAcceptances = varSubscriber;
        varSalesDocuments.equipmentReceivers = lstEquipment;
        varSalesDocuments.plans = lstPlans;
        varSalesDocuments.customer = varCustomer;
        
        lstSalesDocuments.add(varSalesDocuments);
        
        CEC_PME_SalesDocumentsRequest.Data data = new CEC_PME_SalesDocumentsRequest.Data();
        data.salesDocuments = lstSalesDocuments;  
        
        CEC_PME_SalesDocumentsRequest request = new CEC_PME_SalesDocumentsRequest();
        request.apiVersion = '';
        request.transactionId = '';
        request.data = data;
        
        Test.stopTest();
    }
}