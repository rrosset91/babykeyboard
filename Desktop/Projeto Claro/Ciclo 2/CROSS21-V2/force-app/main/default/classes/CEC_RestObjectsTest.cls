@isTest
public class CEC_RestObjectsTest {

    @isTest
    public static void mainTest() {
        CEC_RestObjects.mockError(1);
        CEC_RestObjects.mockError();
        CEC_RestObjects.invoiceRetrive newinvoiceRetrive = new CEC_RestObjects.invoiceRetrive();
        newinvoiceRetrive.content = 'test';
        newinvoiceRetrive.name = 'test';
        newinvoiceRetrive.notificationId  = 'test';
        newinvoiceRetrive.status = 'test';
        newinvoiceRetrive.message = 'test';
        
        CEC_RestObjects.SalesMan newSalesMan = new CEC_RestObjects.SalesMan();
        newSalesMan.data = new CEC_RestObjects.SalesManData();
        newSalesMan.data.salesman = new CEC_RestObjects.Salesmen();
        
        newSalesMan.data.salesman.id = 'test';
        newSalesMan.data.salesman.name = 'test';
        newSalesMan.data.salesman.registration = 'test';
        newSalesMan.data.salesman.situation = 'test';
        newSalesMan.data.salesman.situationDate = 'test';
        newSalesMan.data.salesman.partyidentification = new CEC_RestObjects.Partyidentification();
        newSalesMan.data.salesman.contact  =new List<CEC_RestObjects.ContactSalesMan>();
        newSalesMan.data.salesman.salesAgent = new CEC_RestObjects.SalesManAgent();
        newSalesMan.data.salesman.marketArea = new List<CEC_RestObjects.MarketArea>();
        newSalesMan.data.salesman.user = new CEC_RestObjects.UserSalesMan();
        
        
    	CEC_RestObjects.WindowPortabilityType window = new CEC_RestObjects.WindowPortabilityType(); 
        window.startDate = '01/01/2001';
        string newDate = window.startDateFmt; 
        
        //Proposal NET SALES AWS
    	CEC_RestObjects.AdhesionProposal adhesion = new CEC_RestObjects.AdhesionProposal();
        adhesion.price = 1;
        adhesion.period = 1;
        
    	CEC_RestObjects.DiscountProposal discount = new CEC_RestObjects.DiscountProposal();
        discount.validity = 1;   
        
        List<Object> lstObject = new List<Object>();
        
    	CEC_RestObjects.AdditionalProposal additional = new CEC_RestObjects.AdditionalProposal();
        additional.internet = lstObject;
        additional.paytv = lstObject; 
        additional.phone = lstObject; 
        additional.mobile = lstObject; 
        additional.alacarte = lstObject;       
        
   		CEC_RestObjects.CharacteristicsProposal charac = new CEC_RestObjects.CharacteristicsProposal();
        charac.name = 'Nome'; 
        charac.value = '1'; 
        
        List<CEC_RestObjects.CharacteristicsProposal> lstCharac = new List<CEC_RestObjects.CharacteristicsProposal>();
        lstCharac.add(charac);
        
        CEC_RestObjects.InternetProposal internetProposal = new CEC_RestObjects.InternetProposal();
        internetProposal.name = 'Nome';
        internetProposal.price = 1.0; 
        internetProposal.discount = discount;
        internetProposal.adhesion = adhesion; 
        internetProposal.additional = additional;
        internetProposal.characteristics = lstCharac;    
        
		CEC_RestObjects.ProspectProposal prospect = new CEC_RestObjects.ProspectProposal();
        prospect.name = 'name'; 
        prospect.birthday = '';
        prospect.cpf = ''; 
        prospect.rg = '';
       	prospect.mobileAreaCode = '';
        prospect.mobileNumber = ''; 
        prospect.phoneAreaCode = ''; 
        prospect.phoneNumber = ''; 
        prospect.email = '';
        prospect.motherName = ''; 
        prospect.gender = 1; 
        prospect.maritalStatus = 1;

    	CEC_RestObjects.ProductsProposal products = new CEC_RestObjects.ProductsProposal();
        products.internet = internetProposal;
        products.paytv = internetProposal;
        products.phone = internetProposal;
        products.mobile = internetProposal; 
        products.alacarte = internetProposal; 

    	CEC_RestObjects.AddressProposal addrProp = new CEC_RestObjects.AddressProposal();
        addrProp.neighborhood = '';
        addrProp.postalCode = '';
        addrProp.street = '';
        addrProp.complements = '';
        addrProp.number_Z = '';   

    	CEC_RestObjects.OfferProposal offer = new CEC_RestObjects.OfferProposal();
        offer.type_Z = '';
        offer.products = products;

    	CEC_RestObjects.TransitionsProposal trans = new CEC_RestObjects.TransitionsProposal();
        List<CEC_RestObjects.TransitionsProposal> lstTrans = new List<CEC_RestObjects.TransitionsProposal>();
        
        CEC_RestObjects.SchedulingProposal sched = new CEC_RestObjects.SchedulingProposal();
        sched.date_Z = '';
        sched.alternativeDate = ''; 
    
    	CEC_RestObjects.RulesProposal rules = new CEC_RestObjects.RulesProposal();
        rules.fixedOffset = true;
        rules.transitions = lstTrans;
        rules.transitionRules = lstTrans; 
            
    	CEC_RestObjects.OffsetProposal offset = new CEC_RestObjects.OffsetProposal();
        offset.totalSeconds = 1;
        offset.id = '';
        offset.rules = rules;        
        
		CEC_RestObjects.DateZ dateZ = new CEC_RestObjects.DateZ();
        dateZ.offset = offset;
        dateZ.dayOfYear = 1; 
        dateZ.dayOfWeek = ''; 
        dateZ.month= ''; 
        dateZ.dayOfMonth = 1; 
        dateZ.year = 1;
        dateZ.monthValue = 1; 
        dateZ.nano = 1; 
        dateZ.hour = 1; 
        dateZ.minute = 1; 
        dateZ.second = 1; 

        CEC_RestObjects.HpProposal hp = new CEC_RestObjects.HpProposal();
        hp.id = 1;

        CEC_RestObjects.BankAccountProposal bank = new CEC_RestObjects.BankAccountProposal();
        bank.bank = 1;
        bank.agency = '1'; 
        bank.account = '1';
        bank.digit = '1'; 
        
        CEC_RestObjects.ChargeProposal charge = new CEC_RestObjects.ChargeProposal();
        charge.bankAccount = bank; 
        charge.type_Z = '';
        charge.invoiceShippingEmail = '';
        charge.invoiceDay = ''; 
        
        CEC_RestObjects.DataProposal dataProp = new CEC_RestObjects.DataProposal();  
        dataProp.prospect = prospect;
        //public Map<String,Object> charge {get;set;} 
        //public Map<String,String> scheduling {get;set;} 
        //public Map<String,Object> offer {get;set;} 
        dataProp.hp= hp;
        //public Map<String,String> billingAddress {get;set;} 
        dataProp.seller = ''; 
        dataProp.salesForceID = '';

        CEC_RestObjects.mobileDocuments mobDoc = new CEC_RestObjects.mobileDocuments();
        mobDoc.cpf = ''; 
        mobDoc.rg = ''; 
        mobDoc.passport = '';
        mobDoc.cnpj = '';
        mobDoc.ie = '';
        
        CEC_RestObjects.mobileCustomer mobCus = new CEC_RestObjects.mobileCustomer();
        mobCus.name = ''; 
        mobCus.personType = '';
        mobCus.type_Z = '';
        mobCus.subType = '';
        mobCus.segment = ''; 
        mobCus.mobileId = ''; 
        mobCus.mobileType = ''; 
        mobCus.mobileSubType = ''; 
        mobCus.mobileBan = '';
        mobCus.faId = ''; 
        mobCus.companyName = '';  
        mobCus.businessName = '';  
        mobCus.documents = mobDoc;
        mobCus.acrmCustomerId = '';
        mobCus.crmCustomerId = '';
        mobCus.crmCustomerSubType = '';        
        
        CEC_RestObjects.mobileSubscribers mobSub = new CEC_RestObjects.mobileSubscribers();
        mobSub.mobileSubscriberId = ''; 
        mobSub.name = ''; 
        mobSub.serviceType = ''; 
        mobSub.type_Z = ''; 
        mobSub.subType = ''; 
        mobSub.comboType = '';
        mobSub.effectiveSinceDate = ''; 
        mobSub.cancellationDate = ''; 
        mobSub.status = '';
        mobSub.statusDate = ''; 
        mobSub.documentationStatus = ''; 
        mobSub.msisdn = '';
        mobSub.ticketAttendance = ''; 
        mobSub.productFamily = '';
        mobSub.customer = mobCus;
        mobSub.omsSubscriberId = '';
        mobSub.crmSubscriberId = ''; 
        mobSub.titularId = ''; 
    
		CEC_RestObjects.Addresses addresses = new CEC_RestObjects.Addresses();
        addresses.addressType= ''; 
        addresses.prefix= ''; 
        addresses.logradouro = ''; 
        addresses.numberZ = 1;
        addresses.addressComplement= ''; 
        addresses.neighborhood= ''; 
        addresses.mailbox = 1;
        addresses.city= ''; 
        addresses.state= '';
        addresses.zipCode = 1; 
        addresses.ibgeCityId = 1; 
        addresses.IbgeUfId = 1; 
        addresses.ddd = 1; 
        addresses.ruralAreaIndicator= '';
    
        List<CEC_RestObjects.Addresses> lstAddresses = new List<CEC_RestObjects.Addresses>();
        lstAddresses.add(addresses);
        
    	CEC_RestObjects.AddressData addrData = new CEC_RestObjects.AddressData(); 
        addrData.address = lstAddresses; 
        addrData.pageSize = 1;
        addrData.pageNumber = 1; 
        addrData.totalCount = 1; 
          
		CEC_RestObjects.Birthday birthReq = new CEC_RestObjects.Birthday();

    	CEC_RestObjects.BankAccount bankReq = new CEC_RestObjects.BankAccount();
        bankReq.bank = 1;
        bankReq.agency = '';
        bankReq.account = 1; 
        bankReq.digit = 1; 
    
 		CEC_RestObjects.Scheduling schedReq = new CEC_RestObjects.Scheduling();
    	schedReq.proposalDate = ''; 
		schedReq.date_Z = ''; 
		schedReq.alternativeDate = '';
    
        CEC_RestObjects.Adhesion adhesionReq = new CEC_RestObjects.Adhesion();
        adhesionReq.price = 1;
        adhesionReq.period = 1; 
	
        CEC_RestObjects.Characteristics characReq = new CEC_RestObjects.Characteristics();
        characReq.name = '';
        characReq.value = ''; 
        
        CEC_RestObjects.Prospect prospectReq = new CEC_RestObjects.Prospect();
        prospectReq.name = ''; 
        prospectReq.birthday = birthReq; 
        prospectReq.cpf = 1;
        prospectReq.rg = 1; 
        prospectReq.mobileAreaCode = 1; 
        prospectReq.mobileNumber = 1;
        prospectReq.phoneAreaCode = 1;
        prospectReq.phoneNumber = 1; 
        prospectReq.email = ''; 
        prospectReq.motherName = ''; 
        prospectReq.gender = 1; 
        prospectReq.maritalStatus = 1; 
    
        CEC_RestObjects.Charge chargeReq = new CEC_RestObjects.Charge();
        chargeReq.type_Z = '';
        chargeReq.invoiceShippingEmail = ''; 
        chargeReq.invoiceDay = 1; 
        chargeReq.bankAccount = bankReq;    
        
        CEC_RestObjects.Hp hpReq = new CEC_RestObjects.Hp();
        Hp.id = 1; 
        
        List<Object> lstObjectReq = new List<Object>();
        
    	CEC_RestObjects.Additional additionalReq = new CEC_RestObjects.Additional();
        additionalReq.internet = lstObjectReq; 
		additionalReq.paytv = lstObjectReq; 
        additionalReq.phone = lstObjectReq; 
        additionalReq.mobile = lstObjectReq; 
        additionalReq.alacarte = lstObjectReq;        
        
        List<CEC_RestObjects.Characteristics> lstCharacReq = new List<CEC_RestObjects.Characteristics>();
        
        CEC_RestObjects.Discount discountReq = new CEC_RestObjects.Discount();
        discountReq.validity = '';         
        
		CEC_RestObjects.Internet internetReq = new CEC_RestObjects.Internet();
		internetReq.name = '';
		internetReq.price = 1.0; 
		internetReq.discount = discountReq;
		internetReq.adhesion = adhesionReq;
		internetReq.additional = additionalReq; 
		internetReq.characteristics = lstCharacReq;        
        
    	CEC_RestObjects.Products prodsReq = new CEC_RestObjects.Products();
		prodsReq.internet = internetReq;
		prodsReq.paytv = internetReq;
		prodsReq.phone = internetReq; 
		prodsReq.mobile = internetReq; 
		prodsReq.alacarte = internetReq;
	
		CEC_RestObjects.ProposalAddress propAddrReq = new CEC_RestObjects.ProposalAddress();
		propAddrReq.neighborhood = ''; 
		propAddrReq.postalCode = 1; 
		propAddrReq.street = '';
		propAddrReq.complements = ''; 
		propAddrReq.number_Z = 1;

		CEC_RestObjects.Product prodReq = new CEC_RestObjects.Product();
        prodReq.name = '';
        prodReq.price = 1.0;
        prodReq.discount = discountReq;
        prodReq.adhesion = adhesionReq; 
        prodReq.additional = additionalReq; 
        prodReq.characteristics = lstCharacReq;
        
        CEC_RestObjects.Offer offerReq = new CEC_RestObjects.Offer();
        offerReq.type_Z = '';
        offerReq.products = prodsReq;         
        
		CEC_RestObjects.ProposalRequest propReq = new CEC_RestObjects.ProposalRequest();
        propReq.prospect = prospectReq; 
        propReq.charge = chargeReq; 
        propReq.scheduling = schedReq; 
        propReq.offer = offerReq;
        propReq.address = propAddrReq; 
        propReq.discount = discountReq; 
        propReq.adhesion = adhesionReq; 
        propReq.hp = hpReq;
        propReq.billingAddress = propAddrReq;      


        CEC_RestObjects.CustomerAccounts customerAccounts = new CEC_RestObjects.CustomerAccounts();
        customerAccounts.partyId = 'a';
        customerAccounts.firstName = 'a';
        customerAccounts.lastName = 'a';
        customerAccounts.salutation = 'a';
        customerAccounts.companyName = 'a';
        customerAccounts.partyRoleId = 'a';
        customerAccounts.partyIdentificationNumber = 'a';
        customerAccounts.partyIdentificationType = 'a';
        customerAccounts.customerAccountId = 'a';
        customerAccounts.status = 'a';
        customerAccounts.customerTypeName = 'a';
        customerAccounts.customerTypeDescription = 'a';
        customerAccounts.customerSegmentName = 'a';
        customerAccounts.customerSegmentDescription = 'a';
        customerAccounts.customerComboMultiFlag = 'a';
        customerAccounts.involvementIdentificationRole = 'a';


        CEC_RestObjects.DomicileHistory domicileHistory  = new CEC_RestObjects.DomicileHistory();
        domicileHistory.city='aaaaaa'; 
        domicileHistory.id='aaaaaa'; 
        domicileHistory.type_Z='aaaaaa'; // in json: type
        domicileHistory.status='aaaaaa'; 
        domicileHistory.name='aaaaaa'; 
        domicileHistory.telephoneNumber='aaaaaa'; 
        domicileHistory.installationAddress='aaaaaa'; 
        domicileHistory.partyIdentificationType='aaaaaa'; 
        domicileHistory.partyIdentificationNumber='aaaaaa'; 
       // Account acc = CEC_RestObjects.CustomerAccounts.getAccount();

       CEC_RestObjects.HistoryHeader historyHeader = new CEC_RestObjects.HistoryHeader();

       CEC_RestObjects.Partyidentification Partyidentification = new CEC_RestObjects.Partyidentification();
       Partyidentification.type = 'a';
       Partyidentification.numberZ = 'a';

       CEC_RestObjects.ContactSalesMan ContactSalesMan = new CEC_RestObjects.ContactSalesMan();
       ContactSalesMan.emailAddress = 'bbbbbbbb'; 
       ContactSalesMan.telephoneNumbertype = 'bbbbbbbb'; 
       ContactSalesMan.telephoneNumber = 'bbbbbbbb';

       CEC_RestObjects.Address Addres= new CEC_RestObjects.Address();
       Addres.type= 'cccccccccccc';
        Addres.placeId= 'cccccccccccc'; 
        Addres.city= 'cccccccccccc'; 
        Addres.postalCode= 'cccccccccccc'; 
        Addres.neighborhood= 'cccccccccccc'; 
        Addres.streetType= 'cccccccccccc'; 
        Addres.streetName= 'cccccccccccc'; 
        Addres.streetNumber= 'cccccccccccc'; 
        Addres.urbanPropertySubAddress= 'cccccccccccc'; 
        Addres.boxNr= 'cccccccccccc';

       CEC_RestObjects.SalesManAgent salesMan = new CEC_RestObjects.SalesManAgent();
       salesMan.iwSalesAgentId = 'asas' ;
        salesMan.iwTypeId = 'asas';
        salesMan.description = 'asas' ;
        salesMan.channelId = 'asas' ;
        salesMan.businessName = 'asas'; 
        salesMan.regionalId = 'asas' ;
        salesMan.iwRegionalId = 'asas' ;
        salesMan.address = Addres;

        CEC_RestObjects.UserSalesMan UserSalesMan = new CEC_RestObjects.UserSalesMan ();
        UserSalesMan.userId =  'afaf'; 
        UserSalesMan.roleId =  'afaf'; 
        UserSalesMan.description = 'afaf';
    }
    
}