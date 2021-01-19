@isTest
public class CEC_SalesOrder_IntegrationTest {
	@testSetup
    public static void testSetup()
    {
		Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        varAccount.Gender__c = 'Masculino';
        update varAccount;
        
        User varUser = new User();
        varUser.FirstName = 'Omae'; 
        varUser.LastName = 'Inshidiro';
        varUser.Email = 'test@testing.com';
        varUser.Alias = 'NANI';
        varUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Vendedor Televendas' LIMIT 1].Id;
        varUser.Username = 'logical@mytologichal.com';
        varUser.Channel__c = 'TELEVENDAS';
        varUser.SalesTeamNET__c = 'CRN NACIONAL';
        varUser.NetServicos__c = '92037524';
        varUser.TimeZoneSidKey = 'GMT';
        varUser.LanguageLocaleKey = 'en_US';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.LocaleSidKey = 'en_US';
        varUser.CPF__c = '00000000000';
        insert varUser;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
        
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        insert varProduct;
        
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.TV_Grupo__c = 'G1A'; 
        varOrder.Fone_Grupo__c = 'G1';
        varOrder.Internet_Grupo__c = 'G1B';
        varOrder.TipoFatura__c = 'Email';
        varOrder.Unidade__c = 'Móvel';
        insert varOrder;
        
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        insert varEntryStd;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        insert varEntry;
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.Fidelidade__c = false;
        insert varItem;
        
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'SalesOrdersMobile';        
        serviceParameter.User__c = 'APP_TESTE';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '';  
        serviceParameter.EndPoint__c = 'http://200.169.123.170:9000/corp/salesorders/mobile';
        serviceParameter.Method__c = 'POST';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter;        
    }    
    
    @isTest static void testSalesOrderIntegration() {
		Order order = [SELECT Id, BillingPostalCode, BillingStreet, BillingNumber__c, BillingComplement__c, BillingNeighborhood__c, BillingCity, BillingState, 
                       Forma_de_Pagamento__c, NumeroConta__c, Agencia__c, Banco__c, vlocity_cmt__ExpirationDate__C, vlocity_cmt__DueDate__C, BillingStatus__c, BillingDescription__c, BillingId__c, Description,
                       TipoFatura__c, Unidade__c, TotalAmount, 
                       Account.Name, Account.DocumentNumber__c, Account.Email__c, Account.Phone, Account.RG__c, Account.RGEmitter__c, Account.ReceiveSMS__c,
                       Account.BirthDate__c, Account.MothersName__c, Account.Gender__c,NumProtocolo__c,
                       (SELECT DDD__c, id, Product2.vlocity_cmt__Type__c FROM OrderItems) 
                       FROM Order];
        User user = [SELECT Id, Name, CompanyName, CEC_Regional__c, CPF__c, Email, Phone, Claro__c, IsActive, LastModifiedDate, ProfileId FROM User WHERE Username = 'logical@mytologichal.com' LIMIT 1];
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'Vendedor Televendas' LIMIT 1];
        IBGE__c ibge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portability = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis();

        /*SalesMan*/
		SalesManDTO.Partyidentification identification = new SalesManDTO.Partyidentification();
        identification.numberZ = '2';
        identification.type = '23';

        SalesManDTO.Address address = new SalesManDTO.Address();
        address.boxNr = '2';
        address.city = 'SP';
        address.neighborhood = 'Morumbi';
        address.placeId = '4341';
        address.postalCode = '06783-342';
        address.streetName = 'Rua Henri Dunant';
        address.streetNumber = '800';
        address.streetType = 'Rua';
        address.type = 'normal';
        address.urbanPropertySubAddress = 'teste';

        SalesManDTO.SalesManAgent salesAgent = new SalesManDTO.SalesManAgent();
        salesAgent.channelId = 'LOJA_PROPRIA';
        salesAgent.pointSale = new List<SalesManDTO.PointSale>();
        salesAgent.regionalId = 'CLARO_SP1';
        salesAgent.iwTypeId = '1234';
        salesAgent.description = 'Teste de verdade';
        salesAgent.businessName = 'Claro';
        salesAgent.iwRegionalId = 'CLARO_SP1';
        salesAgent.iwSalesAgentId = '65632';
        salesAgent.address = address;

        SalesManDTO.ContactSalesMan contact = new SalesManDTO.ContactSalesMan();
        contact.emailAddress = 'teste@deloitte.com';
        contact.telephoneNumber = '5186-6000';
        contact.telephoneNumbertype = 'FIXO';

        SalesManDTO.Salesmen salesMen = new SalesManDTO.Salesmen();
        salesMen.id = 'XXXXX';
        salesMen.name = 'TESTE1';
        salesMen.registration = 'TESTE1';
        salesMen.situation = 'TESTE1';
        salesMen.situationDate = 'teste';
        salesMen.salesAgent = salesAgent;
        salesMen.partyidentification = identification;
        salesMen.contact = new List<SalesManDTO.ContactSalesMan>();
        salesMen.contact.add(contact);    
        
        /*Products*/
		ProductsIntegrationDTO.Category newCategory = new ProductsIntegrationDTO.Category('test', 'test'); 
        
        ProductsIntegrationDTO.Promotion newPromotion = new ProductsIntegrationDTO.Promotion('test', 'test', 'test', 'test', 'test',
            newCategory, newCategory);
		newPromotion.category = newCategory;  
        
        ProductsIntegrationDTO.ProductOffering newProductOffering = new ProductsIntegrationDTO.ProductOffering('test', new List<ProductsIntegrationDTO.Offer>());        
        newProductOffering.price = '10';

		ProductsIntegrationDTO.Service newService = new ProductsIntegrationDTO.Service('test', 'test', 'test', new ProductsIntegrationDTO.Category());        
        List<ProductsIntegrationDTO.Service> lstService = new List<ProductsIntegrationDTO.Service>();
        lstService.add(newService);
        
		ProductsIntegrationDTO.Offer newOffer = new ProductsIntegrationDTO.Offer('test','test'); 
        newOffer.price = '1';
        
        ProductsIntegrationDTO.Product newProduct = new ProductsIntegrationDTO.Product('test','test',new ProductsIntegrationDTO.ProductOffering());        
        newProduct.promotion = newPromotion;
        newProduct.productOffering = newProductOffering;
        newProduct.services = lstService;
        newProduct.offer = newOffer;
       
        ProductsIntegrationDTO.ProductsResponses newProductsResponses = 
            new ProductsIntegrationDTO.ProductsResponses();

        newProductsResponses.data = new ProductsIntegrationDTO.ProductsResponse();
        newProductsResponses.data.product = newProduct;
        newProductsResponses.type_z = 'Controle';
        newProductsResponses.title = 'teste';
        newProductsResponses.orderPrice = '5'; 
        newProductsResponses.descriptionPenality = '$12teste1pró-rata';
        
        List<ProductsIntegrationDTO.ProductsResponses> lstProd = new List<ProductsIntegrationDTO.ProductsResponses>();
		lstProd.add(newProductsResponses); 
        
        /*Phone*/
        PhoneNumberReservationDTO.PhoneNumber phone = new PhoneNumberReservationDTO.PhoneNumber();
        phone.number_z = '1198769876';
        
        List<PhoneNumberReservationDTO.PhoneNumber> lstPhone = new List<PhoneNumberReservationDTO.PhoneNumber>();
        lstPhone.add(phone);
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneValue phoneValue = new PhoneNumberReservationDTO.IntegrationTestTelephoneValue();          
        phoneValue.telephoneNumbers = lstPhone;
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo numberReservation = new PhoneNumberReservationDTO.IntegrationTestTelephoneInfo(phoneValue);      

        /*CredAnalysis*/
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData mobRespData = 
            new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData('01/01/2001', '10000', 'Result', 'ResultReason', 'Description');

        IntegrationCreditAnalysisMobileDTO.CreditSituation creditSituation = new 
            IntegrationCreditAnalysisMobileDTO.CreditSituation(mobRespData);        
        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys = 
            new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp(mobRespData);
      
        /*Test*/
        CEC_SalesOrder_Integration salesInt = new CEC_SalesOrder_Integration();
        
        map<Id,PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> mapNumberReservation = new map<Id,PhoneNumberReservationDTO.IntegrationTestTelephoneInfo>();
        
        mapNumberReservation.put(order.OrderItems[0].Id, numberReservation);
        
        SalesOrderIntegrationDTO.SalesOrderMobileResponse response = salesInt.executeSalesOrderMobile(order, user, profile, credAnalisys,
            portability, lstProd, salesMen, mapNumberReservation, ibge); 
        
        SalesOrderIntegrationDTO.SalesOrderMobileResponse responseMobile = CEC_SalesOrder_Integration.consultar();
    }
    
    @isTest
    static void testSomeMethods() {
        SalesOrderIntegrationDTO.Interaction interaction = new SalesOrderIntegrationDTO.Interaction('001', '002', '003');
        List<SalesOrderIntegrationDTO.Interaction> lstInteraction = new List<SalesOrderIntegrationDTO.Interaction>();
    	
        SalesOrderIntegrationDTO.OrderResponse orderResponse = new SalesOrderIntegrationDTO.OrderResponse('001', lstInteraction);
        
        SalesOrderIntegrationDTO.CreditLimitAnalysis cred = new SalesOrderIntegrationDTO.CreditLimitAnalysis('1', '1', '1');
        
        SalesOrderIntegrationDTO.ProductOffering_Z prodOffer = new SalesOrderIntegrationDTO.ProductOffering_Z('type_Z', 'subType');
        SalesOrderIntegrationDTO.Type_Z typeZ = new SalesOrderIntegrationDTO.Type_Z('001');
        SalesOrderIntegrationDTO.User_Z userZ = new SalesOrderIntegrationDTO.User_Z('001', typeZ, 'Nome');
        SalesOrderIntegrationDTO.ItemPaymentMixed item = new SalesOrderIntegrationDTO.ItemPaymentMixed('1', typeZ);
        SalesOrderIntegrationDTO.Manufacturer manufacturer = new SalesOrderIntegrationDTO.Manufacturer('001', 'Nome', 'Type');
        SalesOrderIntegrationDTO.PointsOfSale point = new SalesOrderIntegrationDTO.PointsOfSale('001', 'Trading');
        SalesOrderIntegrationDTO.Reason reason = new SalesOrderIntegrationDTO.Reason('001', 'Descrição');
        SalesOrderIntegrationDTO.AddressAnalysis addr = new SalesOrderIntegrationDTO.AddressAnalysis('001', reason);
        SalesOrderIntegrationDTO.Model model = new SalesOrderIntegrationDTO.Model('1', 'Nome', 'Descricao');
        SalesOrderIntegrationDTO.EquipmentPaymentPlan equip = new SalesOrderIntegrationDTO.EquipmentPaymentPlan('tableAmount', 'cashAmount', 'discountAmount', 'installmentNr', 'installmentAmount', 'balanceAmount', 'totalAmountInterest', 'percentAmountInterest', 'percentUnitOfMeasure');
        List<SalesOrderIntegrationDTO.EquipmentPaymentPlan> lstEquip = new List<SalesOrderIntegrationDTO.EquipmentPaymentPlan>();
        SalesOrderIntegrationDTO.ItemTablePrice itemPrice = new SalesOrderIntegrationDTO.ItemTablePrice(model, lstEquip);
        List<SalesOrderIntegrationDTO.ItemTablePrice> lstItemPrice = new List<SalesOrderIntegrationDTO.ItemTablePrice>();
        lstItemPrice.add(itemPrice);
        SalesOrderIntegrationDTO.Equipment equipment = new SalesOrderIntegrationDTO.Equipment('1', 'Stock', 'Imei', 'Elegivel', 'Amarelo', model, lstItemPrice, manufacturer, '1');
        SalesOrderIntegrationDTO.Operation_Z operation = new SalesOrderIntegrationDTO.Operation_Z(typeZ, userZ, typeZ);
        SalesOrderIntegrationDTO.Session session = new SalesOrderIntegrationDTO.Session('001', '01/01/2020', true);
        SalesOrderIntegrationDTO.ItemTablePrice_Z itemPriceZ = new SalesOrderIntegrationDTO.ItemTablePrice_Z(equip);
        List<SalesOrderIntegrationDTO.ItemTablePrice_Z> lstItemPriceZ = new List<SalesOrderIntegrationDTO.ItemTablePrice_Z>();
        lstItemPriceZ.add(itemPriceZ);
        SalesOrderIntegrationDTO.Equimpment eq = new SalesOrderIntegrationDTO.Equimpment(lstItemPriceZ);
        SalesOrderIntegrationDTO.SubCampaign subCampaign = new SalesOrderIntegrationDTO.SubCampaign('001', 'Nome', eq);
    }
}