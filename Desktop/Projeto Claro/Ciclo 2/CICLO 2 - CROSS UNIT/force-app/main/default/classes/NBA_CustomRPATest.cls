@isTest 
private class NBA_CustomRPATest {

	@TestSetup private static void setupMethod(){ 
        
		List<NBA_Integration_Definitions__mdt> configuracoesDeIntegracao = [SELECT	Id, NBA_Endpoint__c, NBA_Username__c, NBA_Password__c, NBA_NumeroOfertas__c, NBA_InProduction__c, NBA_Domain__c, NBA_HttpMethod__c, NBA_Timeout__c, DeveloperName FROM	NBA_Integration_Definitions__mdt WHERE	DeveloperName = 'RPA_Aprovisionamento'];

		Account acc = new Account();
        acc.Name	= 'Teste N/A';
        insert acc;
        
		Contract ct				= new Contract();
        ct.AccountId			= acc.Id;
        ct.BL__c				= true;
		ct.CityCode__c			= '13'; 
        insert ct;

		Order order			= new Order();
		order.AccountId		= acc.Id;
		order.Status		= 'Draft';
		order.EffectiveDate = System.today();
		order.ContractId	= ct.Id;
        order.RecordTypeId 	= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId(); 
		insert order;

		Case caso					= new Case();
        caso.RecordTypeId			= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        caso.Time_of_Service__c		= 'Ofertas';
        caso.CallReason__c			= 'Financeiro';
        caso.Subreason__c			= null;
        caso.ProductTV__c			= true;
		caso.Order__c				= order.Id;
        insert caso;

		Solic_NBA__c sTV			= new Solic_NBA__c();
		sTV.Order__c				= order.Id;
		sTV.Message__c				= 'Teste';
		sTV.Status__c				= 'Em aberto';
		sTV.ProductName__c			= 'Teste';
		sTV.LegacyNameProduct__c	= 'Teste';
		sTV.ComboProfile__c			= 'Teste';
		sTV.SerialNumber__c			= 'Teste';
		sTV.PaymentMethod__c		= 'Teste';
		sTV.TechnologyType__c		= 'Teste';
		sTV.Movement__c				= '';
		sTV.SolicitationType__c		= 'Teste';
		sTV.ProductType__c			= 'TV PACOTE';
		sTV.OfferType__c			= 'Teste';
		sTV.Priority__c				= 'Teste';
		sTV.Family__c				= 'Teste';
		sTV.FeePrice__c				= 0;
		sTV.PromotionName__c		= 'Teste';
        sTV.RenewFidelity__c        = true;
		insert sTV;

		Solic_NBA__c sMovel				= new Solic_NBA__c();
		sMovel.Order__c					= order.Id;
		sMovel.Message__c				= 'Teste';
		sMovel.Status__c				= 'Em aberto';
		sMovel.ProductName__c			= 'Teste';
		sMovel.LegacyNameProduct__c		= 'Teste';
		sMovel.ComboProfile__c			= 'Teste';
		sMovel.SerialNumber__c			= 'Teste';
		sMovel.PaymentMethod__c			= 'Teste';
		sMovel.TechnologyType__c		= 'Teste';
		sMovel.Movement__c				= 'Aquisição';
		sMovel.SolicitationType__c		= 'Teste';
		sMovel.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel.OfferType__c				= 'Teste';
		sMovel.Priority__c				= 'Teste';
		sMovel.Family__c				= 'Teste';
		sMovel.FeePrice__c				= 0;
		sMovel.PromotionName__c			= 'Teste';
        sMovel.RenewFidelity__c         = true;
        sMovel.PenaltyPrice__c          = 0;
		insert sMovel;
        
        Solic_NBA__c sMovel7			= new Solic_NBA__c();
		sMovel7.Order__c					= order.Id;
		sMovel7.Message__c				= 'Teste';
		sMovel7.Status__c				= 'Em aberto';
		sMovel7.ProductName__c			= 'Teste';
		sMovel7.LegacyNameProduct__c		= 'Teste';
		sMovel7.ComboProfile__c			= 'Teste';
		sMovel7.SerialNumber__c			= 'Teste';
		sMovel7.PaymentMethod__c			= 'Teste';
		sMovel7.TechnologyType__c		= 'Teste';
		sMovel7.Movement__c				= 'Lateral';
		sMovel7.SolicitationType__c		= 'Teste';
		sMovel7.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel7.OfferType__c				= 'Teste';
		sMovel7.Priority__c				= 'Teste';
		sMovel7.Family__c				= 'Teste';
		sMovel7.FeePrice__c				= 0;
		sMovel7.PromotionName__c			= 'Teste';
        sMovel7.RenewFidelity__c         = true;
        sMovel7.PenaltyPrice__c          = 0;
		insert sMovel7;
        
        Solic_NBA__c sMovel8			= new Solic_NBA__c();
		sMovel8.Order__c					= order.Id;
		sMovel8.Message__c				= 'Teste';
		sMovel8.Status__c				= 'Em aberto';
		sMovel8.ProductName__c			= 'Teste';
		sMovel8.LegacyNameProduct__c		= 'Teste';
		sMovel8.ComboProfile__c			= 'Teste';
		sMovel8.SerialNumber__c			= 'Teste';
		sMovel8.PaymentMethod__c			= 'Teste';
		sMovel8.TechnologyType__c		= 'Teste';
		sMovel8.Movement__c				= 'Downgrade';
		sMovel8.SolicitationType__c		= 'Teste';
		sMovel8.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel8.OfferType__c				= 'Teste';
		sMovel8.Priority__c				= 'Teste';
		sMovel8.Family__c				= 'Teste';
		sMovel8.FeePrice__c				= 0;
		sMovel8.PromotionName__c			= 'Teste';
        sMovel8.RenewFidelity__c         = true;
        sMovel8.PenaltyPrice__c          = 0;
		insert sMovel8;
        
        Solic_NBA__c sMovel4			= new Solic_NBA__c();
		sMovel4.Order__c					= order.Id;
		sMovel4.Message__c				= 'Teste';
		sMovel4.Status__c				= 'Em aberto';
		sMovel4.ProductName__c			= 'Teste';
		sMovel4.LegacyNameProduct__c		= 'Teste';
		sMovel4.ComboProfile__c			= 'Teste';
		sMovel4.SerialNumber__c			= 'Teste';
		sMovel4.PaymentMethod__c			= 'Teste';
		sMovel4.TechnologyType__c		= 'Teste';
		sMovel4.Movement__c				= 'Upgrade';
		sMovel4.SolicitationType__c		= 'Teste';
		sMovel4.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel4.OfferType__c				= 'Teste';
		sMovel4.Priority__c				= 'Teste';
		sMovel4.Family__c				= 'Teste';
		sMovel4.FeePrice__c				= 0;
		sMovel4.PromotionName__c			= 'Teste';
        sMovel4.RenewFidelity__c         = true;
        sMovel4.PenaltyPrice__c          = 0;
		insert sMovel4;
        
        Solic_NBA__c sMovel3			= new Solic_NBA__c();
		sMovel3.Order__c					= order.Id;
		sMovel3.Message__c				= 'Teste';
		sMovel3.Status__c				= 'Em aberto';
		sMovel3.ProductName__c			= 'Teste';
		sMovel3.LegacyNameProduct__c		= 'Teste';
		sMovel3.ComboProfile__c			= 'Teste';
		sMovel3.SerialNumber__c			= 'Teste';
		sMovel3.PaymentMethod__c			= 'Teste';
		sMovel3.TechnologyType__c		= 'Teste';
		sMovel3.Movement__c				= 'Aquisição';
		sMovel3.SolicitationType__c		= 'Teste';
		sMovel3.ProductType__c			= 'MOVEL DEP';
		sMovel3.OfferType__c				= 'Teste';
		sMovel3.Priority__c				= 'Teste';
		sMovel3.Family__c				= 'Teste';
		sMovel3.FeePrice__c				= 0;
		sMovel3.PromotionName__c			= 'Teste';
        sMovel3.RenewFidelity__c         = true;
        sMovel3.PenaltyPrice__c          = 0;
		insert sMovel3;
        
        Solic_NBA__c sMovel5			= new Solic_NBA__c();
		sMovel5.Order__c				= order.Id;
		sMovel5.Message__c				= 'Teste';
		sMovel5.Status__c				= 'Em aberto';
		sMovel5.ProductName__c			= 'Teste';
		sMovel5.LegacyNameProduct__c	= 'Teste';
		sMovel5.ComboProfile__c			= 'Teste';
		sMovel5.SerialNumber__c			= 'Teste';
		sMovel5.PaymentMethod__c		= 'Teste';
		sMovel5.TechnologyType__c		= 'Teste';
		sMovel5.Movement__c				= 'Lateral';
		sMovel5.SolicitationType__c		= 'Teste';
		sMovel5.ProductType__c			= 'MOVEL DEP';
		sMovel5.OfferType__c			= 'Teste';
		sMovel5.Priority__c				= 'Teste';
		sMovel5.Family__c				= 'Teste';
		sMovel5.FeePrice__c				= 0;
		sMovel5.PromotionName__c		= 'Teste';
        sMovel5.RenewFidelity__c        = true;
        sMovel5.PenaltyPrice__c         = 0;
		insert sMovel5;
        
        Solic_NBA__c sAlacarte				= new Solic_NBA__c();
		sAlacarte.Order__c					= order.Id;
		sAlacarte.Message__c				= 'Teste';
		sAlacarte.Status__c					= 'Em aberto';
		sAlacarte.ProductName__c			= 'Teste';
		sAlacarte.LegacyNameProduct__c		= 'Teste';
		sAlacarte.ComboProfile__c			= 'Teste';
		sAlacarte.SerialNumber__c			= 'Teste';
		sAlacarte.PaymentMethod__c			= 'Teste';
		sAlacarte.TechnologyType__c			= 'Teste';
		sAlacarte.Movement__c				= '';
		sAlacarte.SolicitationType__c		= 'Teste';
		sAlacarte.ProductType__c			= 'CANAL A LA CARTE';
		sAlacarte.OfferType__c				= 'Teste';
		sAlacarte.Priority__c				= 'Teste';
		sAlacarte.Family__c					= 'Teste';
		sAlacarte.FeePrice__c				= 0;
		sAlacarte.PromotionName__c			= 'Teste';
        sAlacarte.RenewFidelity__c          = true;
		insert sAlacarte;

		Solic_NBA__c sBL			= new Solic_NBA__c();
		sBL.Order__c				= order.Id;
		sBL.Message__c				= 'Teste';
		sBL.Status__c				= 'Em aberto';
		sBL.ProductName__c			= 'Teste';
		sBL.LegacyNameProduct__c	= 'Teste';
		sBL.ComboProfile__c			= 'Teste';
		sBL.SerialNumber__c			= 'Teste';
		sBL.PaymentMethod__c		= 'Teste';
		sBL.TechnologyType__c		= 'Teste';
		sBL.Movement__c				= 'Lateral';
		sBL.SolicitationType__c		= 'Teste';
		sBL.ProductType__c			= 'BL ASSINATURA';
		sBL.OfferType__c			= 'Teste';
		sBL.Priority__c				= 'Teste';
		sBL.Family__c				= 'Teste';
		sBL.FeePrice__c				= 0;
		sBL.PromotionName__c		= 'Teste';
        sBL.RenewFidelity__c        = true;
		insert sBL;

		Solic_NBA__c sNet			= new Solic_NBA__c();
		sNet.Order__c				= order.Id;
		sNet.Message__c				= 'Teste';
		sNet.Status__c				= 'Em aberto';
		sNet.ProductName__c			= 'Teste';
		sNet.LegacyNameProduct__c	= 'Teste';
		sNet.ComboProfile__c		= 'Teste';
		sNet.SerialNumber__c		= 'Teste';
		sNet.PaymentMethod__c		= 'Teste';
		sNet.TechnologyType__c		= 'Teste';
		sNet.Movement__c			= '';
		sNet.SolicitationType__c	= 'Teste';
		sNet.ProductType__c			= 'NET FONE';
		sNet.OfferType__c			= 'Teste';
		sNet.Priority__c			= 'Teste';
		sNet.Family__c				= 'Teste';
		sNet.FeePrice__c			= 0;
		sNet.PromotionName__c		= 'Teste';
        sNet.RenewFidelity__c       = true;
		insert sNet;

		//Cancelamento Parcial
		Account acc1	= new Account();
        acc1.Name		= 'Teste Parcial';
        insert acc1;
        
		Contract ct1			= new Contract();
        ct1.AccountId			= acc1.Id;
        ct1.BL__c				= true;
		ct1.CityCode__c			= '13'; 
        insert ct1;

		Order order1			 = new Order();
		order1.AccountId		 = acc1.Id;
		order1.Status			 = 'Draft';
		order1.EffectiveDate	 = System.today();
		order1.ContractId		 = ct1.Id;
        order1.SchedulingDate__c = System.today();
        order1.SchedulingTime__c = '';
        order1.RecordTypeId 	 = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		insert order1;

		Case caso1					= new Case();
        caso1.RecordTypeId			= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        caso1.Time_of_Service__c	= 'Ofertas';
        caso1.CallReason__c			= 'Financeiro';
        caso1.Subreason__c			= null;
        caso1.ProductTV__c			= true;
		caso1.Order__c				= order1.Id;
        insert caso1;

		Solic_NBA__c sTV1			= new Solic_NBA__c();
		sTV1.Order__c				= order1.Id;
		sTV1.Message__c				= 'Teste';
		sTV1.Status__c				= 'Em aberto';
		sTV1.ProductName__c			= 'Teste';
		sTV1.LegacyNameProduct__c	= 'Teste';
		sTV1.ComboProfile__c		= 'Teste';
		sTV1.SerialNumber__c		= 'Teste';
		sTV1.PaymentMethod__c		= 'Teste';
		sTV1.TechnologyType__c		= 'Teste';
		sTV1.Movement__c			= 'Cancelamento';
		sTV1.SolicitationType__c	= 'Teste';
		sTV1.ProductType__c			= 'TV PACOTE';
		sTV1.OfferType__c			= 'Teste';
		sTV1.Priority__c			= 'Teste';
		sTV1.Family__c				= 'Teste';
		sTV1.FeePrice__c			= 0;
		sTV1.PromotionName__c		= 'Teste';
        sTV1.RenewFidelity__c       = true;
		insert sTV1;

		Solic_NBA__c sMovel1			= new Solic_NBA__c();
		sMovel1.Order__c				= order1.Id;
		sMovel1.Message__c				= 'Teste';
		sMovel1.Status__c				= 'Em aberto';
		sMovel1.ProductName__c			= 'Teste';
		sMovel1.LegacyNameProduct__c	= 'Teste';
		sMovel1.ComboProfile__c			= 'Teste';
		sMovel1.SerialNumber__c			= 'Teste';
		sMovel1.PaymentMethod__c		= 'Teste';
		sMovel1.TechnologyType__c		= 'Teste';
		sMovel1.Movement__c				= 'Lateral';
		sMovel1.SolicitationType__c		= 'Teste';
        sMovel1.PenaltyPrice__c         = 0;
		sMovel1.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel1.OfferType__c			= 'Teste';
		sMovel1.Priority__c				= 'Teste';
		sMovel1.Family__c				= 'Teste';
		sMovel1.FeePrice__c				= 0;
		sMovel1.PromotionName__c		= 'Teste';
        sMovel1.RenewFidelity__c        = true;
		insert sMovel1;

		Solic_NBA__c sAlacarte1				= new Solic_NBA__c();
		sAlacarte1.Order__c					= order1.Id;
		sAlacarte1.Message__c				= 'Teste';
		sAlacarte1.Status__c				= 'Em aberto';
		sAlacarte1.ProductName__c			= 'Teste';
		sAlacarte1.LegacyNameProduct__c		= 'Teste';
		sAlacarte1.ComboProfile__c			= 'Teste';
		sAlacarte1.SerialNumber__c			= 'Teste';
		sAlacarte1.PaymentMethod__c			= 'Teste';
		sAlacarte1.TechnologyType__c		= 'Teste';
		sAlacarte1.Movement__c				= 'Cancelamento';
		sAlacarte1.SolicitationType__c		= 'Teste';
		sAlacarte1.ProductType__c			= 'CANAL A LA CARTE';
		sAlacarte1.OfferType__c				= 'Teste';
		sAlacarte1.Priority__c				= 'Teste';
		sAlacarte1.Family__c				= 'Teste';
		sAlacarte1.FeePrice__c				= 0;
		sAlacarte1.PromotionName__c			= 'Teste';
        sAlacarte1.RenewFidelity__c         = true;
		insert sAlacarte1;

		Solic_NBA__c sBL1			= new Solic_NBA__c();
		sBL1.Order__c				= order1.Id;
		sBL1.Message__c				= 'Teste';
		sBL1.Status__c				= 'Em aberto';
		sBL1.ProductName__c			= 'Teste';
		sBL1.LegacyNameProduct__c	= 'Teste';
		sBL1.ComboProfile__c		= 'Teste';
		sBL1.SerialNumber__c		= 'Teste';
		sBL1.PaymentMethod__c		= 'Teste';
		sBL1.TechnologyType__c		= 'Teste';
		sBL1.Movement__c			= '';
		sBL1.SolicitationType__c	= 'Teste';
		sBL1.ProductType__c			= 'BL ASSINATURA';
		sBL1.OfferType__c			= 'Teste';
		sBL1.Priority__c			= 'Teste';
		sBL1.Family__c				= 'Teste';
		sBL1.FeePrice__c			= 0;
		sBL1.PromotionName__c		= 'Teste';
        sBL1.RenewFidelity__c       = true;
		insert sBL1;

		Solic_NBA__c sNet1			= new Solic_NBA__c();
		sNet1.Order__c				= order1.Id;
		sNet1.Message__c			= 'Teste';
		sNet1.Status__c				= 'Em aberto';
		sNet1.ProductName__c		= 'Teste';
		sNet1.LegacyNameProduct__c	= 'Teste';
		sNet1.ComboProfile__c		= 'Teste';
		sNet1.SerialNumber__c		= 'Teste';
		sNet1.PaymentMethod__c		= 'Teste';
		sNet1.TechnologyType__c		= 'Teste';
		sNet1.Movement__c			= 'Cancelamento';
		sNet1.SolicitationType__c	= 'Teste';
		sNet1.ProductType__c		= 'NET FONE';
		sNet1.OfferType__c			= 'Teste';
		sNet1.Priority__c			= 'Teste';
		sNet1.Family__c				= 'Teste';
		sNet1.FeePrice__c			= 0;
		sNet1.PromotionName__c		= 'Teste';
        sNet1.RenewFidelity__c      = true;
		insert sNet1;

		//Cancelamento Total
		Account acc2	= new Account();
        acc2.Name		= 'Teste Total';
        insert acc2;
        
		Contract ct2			= new Contract();
        ct2.AccountId			= acc2.Id;
        ct2.BL__c				= true;
		ct2.CityCode__c			= '13'; 
        insert ct2;

		Order order2			= new Order();
		order2.AccountId		= acc2.Id;
		order2.Status			= 'Draft';
		order2.EffectiveDate	= System.today();
		order2.ContractId		= ct2.Id;
        order2.RecordTypeId		= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		insert order2;

		Case caso2					= new Case();
        caso2.RecordTypeId			= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        caso2.Time_of_Service__c	= 'Ofertas';
        caso2.CallReason__c			= 'Inadimplente';
        caso2.Subreason__c			= null;
        caso2.ProductTV__c			= true;
		caso2.Order__c				= order2.Id;
        insert caso2;

		Solic_NBA__c sTV2			= new Solic_NBA__c();
		sTV2.Order__c				= order2.Id;
		sTV2.Message__c				= 'Teste';
		sTV2.Status__c				= 'Em aberto';
		sTV2.ProductName__c			= 'Teste';
		sTV2.LegacyNameProduct__c	= 'Teste';
		sTV2.ComboProfile__c		= 'Teste';
		sTV2.SerialNumber__c		= 'Teste';
		sTV2.PaymentMethod__c		= 'Teste';
		sTV2.TechnologyType__c		= 'Teste';
		sTV2.Movement__c			= 'Cancelamento';
		sTV2.SolicitationType__c	= 'Teste';
		sTV2.ProductType__c			= 'TV PACOTE';
		sTV2.OfferType__c			= 'Teste';
		sTV2.Priority__c			= 'Teste';
		sTV2.Family__c				= 'Teste';
		sTV2.FeePrice__c			= 0;
		sTV2.PromotionName__c		= 'Teste';
        sTV2.MainPoint__c           = 'Teste';
        sTV2.RenewFidelity__c       = true;
        sTV2.FullCancel__c          = true;
		insert sTV2;

		Solic_NBA__c sMovel2			= new Solic_NBA__c();
		sMovel2.Order__c				= order2.Id;
		sMovel2.Message__c				= 'Teste';
		sMovel2.Status__c				= 'Em aberto';
		sMovel2.ProductName__c			= 'Teste';
		sMovel2.LegacyNameProduct__c	= 'Teste';
		sMovel2.ComboProfile__c			= 'Teste';
		sMovel2.SerialNumber__c			= 'Teste';
		sMovel2.PaymentMethod__c		= 'Teste';
		sMovel2.TechnologyType__c		= 'Teste';
		sMovel2.Movement__c				= 'Cancelamento';
		sMovel2.SolicitationType__c		= 'Teste';
		sMovel2.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel2.OfferType__c			= 'Teste';
		sMovel2.Priority__c				= 'Teste';
		sMovel2.Family__c				= 'Teste';
		sMovel2.FeePrice__c				= 0;
		sMovel2.PromotionName__c		= 'Teste';
        sMovel2.MainPoint__c            = 'Teste';
        sMovel2.RenewFidelity__c        = true;
        sMovel2.FullCancel__c           = true;
        sMovel.PenaltyPrice__c          = 0;
		insert sMovel2;

		Solic_NBA__c sAlacarte2				= new Solic_NBA__c();
		sAlacarte2.Order__c					= order2.Id;
		sAlacarte2.Message__c				= 'Teste';
		sAlacarte2.Status__c				= 'Em aberto';
		sAlacarte2.ProductName__c			= 'Teste';
		sAlacarte2.LegacyNameProduct__c		= 'Teste';
		sAlacarte2.ComboProfile__c			= 'Teste';
		sAlacarte2.SerialNumber__c			= 'Teste';
		sAlacarte2.PaymentMethod__c			= 'Teste';
		sAlacarte2.TechnologyType__c		= 'Teste';
		sAlacarte2.Movement__c				= 'Cancelamento';
		sAlacarte2.SolicitationType__c		= 'Teste';
		sAlacarte2.ProductType__c			= 'CANAL A LA CARTE';
		sAlacarte2.OfferType__c				= 'Teste';
		sAlacarte2.Priority__c				= 'Teste';
		sAlacarte2.Family__c				= 'Teste';
		sAlacarte2.FeePrice__c				= 0;
		sAlacarte2.PromotionName__c			= 'Teste';
        sAlacarte2.MainPoint__c             = 'Teste';
        sAlacarte2.RenewFidelity__c         = true;
        sAlacarte2.FullCancel__c            = true;
		insert sAlacarte2;

		Solic_NBA__c sBL2			= new Solic_NBA__c();
		sBL2.Order__c				= order2.Id;
		sBL2.Message__c				= 'Teste';
		sBL2.Status__c				= 'Em aberto';
		sBL2.ProductName__c			= 'Teste';
		sBL2.LegacyNameProduct__c	= 'Teste';
		sBL2.ComboProfile__c		= 'Teste';
		sBL2.SerialNumber__c		= 'Teste';
		sBL2.PaymentMethod__c		= 'Teste';
		sBL2.TechnologyType__c		= 'Teste';
		sBL2.Movement__c			= 'Cancelamento';
		sBL2.SolicitationType__c	= 'Teste';
		sBL2.ProductType__c			= 'BL ASSINATURA';
		sBL2.OfferType__c			= 'Teste';
		sBL2.Priority__c			= 'Teste';
		sBL2.Family__c				= 'Teste';
		sBL2.FeePrice__c			= 0;
		sBL2.PromotionName__c		= 'Teste';
        sBL2.MainPoint__c           = 'Teste';
        sBL2.RenewFidelity__c       = true;
        sBL2.FullCancel__c          = true;
		insert sBL2;

		Solic_NBA__c sNet2			= new Solic_NBA__c();
		sNet2.Order__c				= order2.Id;
		sNet2.Message__c			= 'Teste';
		sNet2.Status__c				= 'Em aberto';
		sNet2.ProductName__c		= 'Teste';
		sNet2.LegacyNameProduct__c	= 'Teste';
		sNet2.ComboProfile__c		= 'Teste';
		sNet2.SerialNumber__c		= 'Teste';
		sNet2.PaymentMethod__c		= 'Teste';
		sNet2.TechnologyType__c		= 'Teste';
		sNet2.Movement__c			= 'Cancelamento';
		sNet2.SolicitationType__c	= 'Teste';
		sNet2.ProductType__c		= 'NET FONE';
		sNet2.OfferType__c			= 'Teste';
		sNet2.Priority__c			= 'Teste';
		sNet2.Family__c				= 'Teste';
		sNet2.FeePrice__c			= 0;
		sNet2.PromotionName__c		= 'Teste';
        sNet2.MainPoint__c          = 'Teste';
        sNet2.RenewFidelity__c      = true;
        sNet2.FullCancel__c         = true;
		insert sNet2;


		Account accMovel	= new Account();
        accMovel.Name		= 'Teste Movel';
        insert accMovel;
        
		Contract ctMovel			= new Contract();
        ctMovel.AccountId			= accMovel.Id;
        ctMovel.BL__c				= true;
		ctMovel.CityCode__c			= '13'; 
        insert ctMovel;

		Order orderMovel			 = new Order();
		orderMovel.AccountId		 = accMovel.Id;
		orderMovel.Status			 = 'Draft';
		orderMovel.EffectiveDate	 = System.today();
		orderMovel.ContractId		 = ctMovel.Id;
        orderMovel.SchedulingDate__c = System.today();
        orderMovel.SchedulingTime__c = '';
        orderMovel.RecordTypeId		 = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		insert orderMovel;

		Case casoMovel					= new Case();
        casoMovel.RecordTypeId			= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        casoMovel.Time_of_Service__c	= 'Ofertas';
        casoMovel.CallReason__c			= 'Financeiro';
        casoMovel.Subreason__c			= null;
        casoMovel.ProductTV__c			= true;
		casoMovel.Order__c				= orderMovel.Id;
        insert casoMovel;

		Solic_NBA__c sMovelAquisicao			= new Solic_NBA__c();
		sMovelAquisicao.Order__c				= orderMovel.Id;
		sMovelAquisicao.Message__c				= 'Teste';
		sMovelAquisicao.Status__c				= 'Em aberto';
		sMovelAquisicao.ProductName__c			= 'Teste';
		sMovelAquisicao.LegacyNameProduct__c	= 'Teste';
		sMovelAquisicao.ComboProfile__c			= 'Teste';
		sMovelAquisicao.SerialNumber__c			= 'Teste';
		sMovelAquisicao.PaymentMethod__c		= 'Teste';
		sMovelAquisicao.TechnologyType__c		= 'Teste';
		sMovelAquisicao.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
		sMovelAquisicao.SolicitationType__c		= 'Aquisicao';
        sMovelAquisicao.PenaltyPrice__c         = 0;
		sMovelAquisicao.ProductType__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
		sMovelAquisicao.OfferType__c			= 'Teste';
		sMovelAquisicao.Priority__c				= 'Teste';
		sMovelAquisicao.Family__c				= 'Teste';
		sMovelAquisicao.FeePrice__c				= 0;
		sMovelAquisicao.PromotionName__c		= 'Teste';
        sMovelAquisicao.RenewFidelity__c        = true;
		insert sMovelAquisicao;

		Solic_NBA__c sMovelDepAquisicao			= new Solic_NBA__c();
		sMovelDepAquisicao.Order__c				= orderMovel.Id;
		sMovelDepAquisicao.Message__c				= 'Teste';
		sMovelDepAquisicao.Status__c				= 'Em aberto';
		sMovelDepAquisicao.ProductName__c			= 'Teste';
		sMovelDepAquisicao.LegacyNameProduct__c	= 'Teste';
		sMovelDepAquisicao.ComboProfile__c			= 'Teste';
		sMovelDepAquisicao.SerialNumber__c			= 'Teste';
		sMovelDepAquisicao.PaymentMethod__c		= 'Teste';
		sMovelDepAquisicao.TechnologyType__c		= 'Teste';
		sMovelDepAquisicao.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
		sMovelDepAquisicao.SolicitationType__c		= 'Aquisicao';
        sMovelDepAquisicao.PenaltyPrice__c         = 0;
		sMovelDepAquisicao.ProductType__c			= NBA_Constants.MOVEL_DEPENDENTES;
		sMovelDepAquisicao.OfferType__c			= 'Teste';
		sMovelDepAquisicao.Priority__c				= 'Teste';
		sMovelDepAquisicao.Family__c				= 'Teste';
		sMovelDepAquisicao.FeePrice__c				= 0;
		sMovelDepAquisicao.PromotionName__c		= 'Teste';
        sMovelDepAquisicao.RenewFidelity__c        = true;
		insert sMovelDepAquisicao;
    }


	@isTest
	private static void aprovisionamentoAquisicaoMovelTest(){
		Order order			= [SELECT Id FROM Order WHERE Account.Name = 'Teste Movel' LIMIT 1];
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.provisionamento(  order.Id );
		Test.stopTest();
	}

    @isTest
	private static void aprovisionamentoNATest(){
		Order order			= [SELECT Id FROM Order WHERE Account.Name = 'Teste N/A' LIMIT 1];
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.provisionamento(  order.Id );
		Test.stopTest();
	}

	@isTest
	private static void aprovisionamentoParcialTest(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste Parcial' LIMIT 1];
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.provisionamento(  order.Id );
		Test.stopTest();
	}
    
    @isTest
	private static void aprovisionamentoTotalTest(){
		Order order			= [SELECT Id FROM Order WHERE Account.Name = 'Teste Total' LIMIT 1];
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.provisionamento(  order.Id );
		Test.stopTest();
	}

    @isTest
	private static void checkTasksTest(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste Total' LIMIT 1];
        NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= true;
		Test.startTest();
		NBA_CustomRPA.checkTasks(  order.Id );
        System.assertNotEquals(order, null);
		Test.stopTest();
	}
    
    @isTest
	private static void updateOrderTest(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste Total' LIMIT 1];
		NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success	= true;
		
		Test.startTest();
		NBA_CustomRPA.updateOrder(res, order.Id);
        System.assertNotEquals(order, null);
		Test.stopTest();
	}
    
	@isTest
	private static void getCodAssinateTest(){
		Contract ct = [SELECT Id, ContractNumber__c, CityCode__c FROM Contract LIMIT 1];
		Test.startTest();
		System.assertNotEquals(ct, null);
		NBA_CustomRPA.getCodAssinate( ct.CityCode__c, ct.ContractNumber__c );
		NBA_CustomRPA.getCodAssinate( null, null );
		Test.stopTest();
	}
	
	@isTest
	private static void getOperationTypeTest(){
		Test.startTest();
		String result = '';
		result = NBA_CustomRPA.getOperationType('Retencao');
		System.assertNotEquals(result, null);
		result = NBA_CustomRPA.getOperationType('Rentabilizacao');
		System.assertNotEquals(result, null);
		result = NBA_CustomRPA.getOperationType('Rentabilizacao Ativo');
		System.assertNotEquals(result, null);
		result = NBA_CustomRPA.getOperationType('Rentabilizacao Receptivo');
		System.assertNotEquals(result, null);
		Test.stopTest();
	}
	
	@isTest
	private static void getSolicsTest(){
		Order order = [SELECT Id FROM Order LIMIT 1];
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.getSolics(order.Id);
		Test.stopTest();
	}

	@IsTest private static void updateStatusSolicSucessTest(){
		Order order			= [SELECT Id FROM Order LIMIT 1];
		NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= true;
		Test.startTest();

		System.assertNotEquals(order, null);
		System.assertNotEquals(res, null);

		NBA_CustomRPA.updateStatusSolic(res, order.Id);
		Test.stopTest();
	}

	@IsTest private static void updateStatusSolicErrorTest(){
		Order order			= [SELECT Id FROM Order LIMIT 1];
		NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= false;
		Test.startTest();
		System.assertNotEquals(order, null);
		NBA_CustomRPA.updateStatusSolic(res, order.Id);
		Test.stopTest();
	}

    @isTest
	private static void sendProvisionamentoTest1(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste N/A' LIMIT 1];
        NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= true;
		Test.startTest();
        	NBA_CustomRPA.updateStatusSolic(res, order.Id);
        	NBA_CustomRPA.sendProvisionamento(  order.Id );        
        System.assertNotEquals(order, null);
		Test.stopTest();
	}
    
    @isTest
	private static void sendProvisionamentoTest2(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste Parcial' LIMIT 1];
        NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= true;
		Test.startTest();
        	NBA_CustomRPA.updateStatusSolic(res, order.Id);
        	NBA_CustomRPA.sendProvisionamento(  order.Id );        
        System.assertNotEquals(order, null);
		Test.stopTest();
	}
    
    @isTest
	private static void sendProvisionamentoTest3(){
		Order order = [SELECT Id FROM Order WHERE Account.Name = 'Teste Total' LIMIT 1];
        NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
		res.success			= true;
		Test.startTest();
        	NBA_CustomRPA.updateStatusSolic(res, order.Id);
        	NBA_CustomRPA.sendProvisionamento(  order.Id );        
        System.assertNotEquals(order, null);
		Test.stopTest();
	}

	@isTest
	private static void createDefaultSolicForBonusDiscount(){
		Test.startTest();
		Order order = (Order) JSON.deserialize('{\"attributes\":{\"type\":\"Order\",\"url\":\"/services/data/v48.0/sobjects/Order/801J0000001OVU9IAO\"},\"Id\":\"801J0000001OVU9IAO\",\"SchedulingTime__c\":\"false\",\"AccountId\":\"0010v00000UAyyoAAD\",\"OrderNumber\":\"00008501\",\"TVMovement__c\":\"Aquisição\",\"VirtuaMovement__c\":\"Upgrade\",\"NETFoneMovement__c\":\"Lateral\",\"MobileMovement__c\":\"Lateral\",\"FeeAddValuePaymentForm__c\":\"ISENTO\",\"ContractId\":\"8000v000000EBeaAAG\",\"OwnershipProfile__c\":\"PTV + VIRTUA\",\"OwnerId\":\"0051H000008rayoQAA\",\"CreatedDate\":\"2020-02-18T14:34:58.000+0000\",\"Account\":{\"attributes\":{\"type\":\"Account\",\"url\":\"/services/data/v48.0/sobjects/Account/0010v00000UAyyoAAD\"},\"Id\":\"0010v00000UAyyoAAD\",\"Name\":\"JULIANA CARDOSO PEREIRA\",\"DocumentNumber__c\":\"431043043\"},\"Contract\":{\"attributes\":{\"type\":\"Contract\",\"url\":\"/services/data/v48.0/sobjects/Contract/8000v000000EBeaAAG\"},\"Id\":\"8000v000000EBeaAAG\",\"CityCode__c\":\"040\",\"ContractNumber\":\"160184304\",\"ContractNumber__c\":\"33773791\",\"LegacyStatus__c\":\"CONECTADO\"},\"Owner\":{\"attributes\":{\"type\":\"Name\",\"url\":\"/services/data/v48.0/sobjects/User/0051H000008rayoQAA\"},\"Id\":\"0051H000008rayoQAA\",\"ProfileId\":\"00e1H000001JcwYQAS\",\"Name\":\"MILENA PRAXEDES MELO\",\"Profile\":{\"attributes\":{\"type\":\"Profile\",\"url\":\"/services/data/v48.0/sobjects/Profile/00e1H000001JcwYQAS\"},\"Id\":\"00e1H000001JcwYQAS\",\"Name\":\"Atendente NBA - Retencao\"}}}',Order.class);
		List<Solic_NBA__c> solics = (List<Solic_NBA__c>)JSON.deserialize('[{\"attributes\":{\"type\":\"Solic_NBA__c\",\"url\":\"/services/data/v48.0/sobjects/Solic_NBA__c/a4pJ00000005SuwIAE\"},\"Order__c\":\"801J0000001O0eRIAS\",\"Status__c\":\"Não enviado\",\"ProductName__c\":\"FÁCIL TURBO HD\",\"CurrentProduct__c\":\"ACESSO VIRTUA\",\"Value__c\":54.90,\"FeeType__c\":\"Aquisição\",\"FeePrice__c\":899.00,\"LegacyNameProduct__c\":\"FACIL HD TURBO C/VTA/ FONE RENT CONF FID\",\"ComboProfile__c\":\"PTV+VTA+FONE+CELULAR\",\"PaymentMethod__c\":\"ISENTO\",\"RenewFidelity__c\":false,\"FullCancel__c\":false,\"TechnologyType__c\":\"Net Digital HD\",\"Movement__c\":\"Aquisição\",\"SolicitationType__c\":\"MUDANCA DE PACOTE\",\"ProductType__c\":\"TV PACOTE\",\"OfferType__c\":\"BLINDAGEM\",\"Fidelity__c\":false,\"AcceptedOffer__c\":false,\"Family__c\":\"FACIL TURBO\",\"PromotionName__c\":\"PROMO BS FACIL HD TURBO RENT P_49,9 3M\",\"Name\":\"SOLIC-19064\",\"QuantityPromoMonths__c\":\"3\",\"PromotionValue__c\":20.00,\"SpotType__c\":\"PP\",\"Id\":\"a4pJ00000005SuwIAE\",\"Portability__c\":false,\"IsComboMulti__c\":false,\"TotalValue__c\":74.90}]',List<Solic_NBA__c>.class);
		List<Case> lstCaso = (List<Case>) JSON.deserialize('[{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KniijIAB\"},\"Id\":\"500J000000KniijIAB\",\"A_la_Carte__c\":false,\"Fixo__c\":false,\"Movel__c\":true,\"ProductTV__c\":false,\"broadband__c\":true,\"CallResult__c\":\"Venda\",\"Order__c\":\"801J0000001OS3PIAW\",\"TVN1Result__c\":\"VENDA\",\"PhoneN1Result__c\":\"NÃO VENDA\",\"MobileN1Result__c\":\"VENDA\",\"BLN1Result__c\":\"UPGRADE\",\"EPS_Operador__c\":\"VGX CONTACT CENTER NORTE MG LTDA\"},{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KnnmdIAB\"},\"Id\":\"500J000000KnnmdIAB\",\"A_la_Carte__c\":true,\"Fixo__c\":true,\"Movel__c\":true,\"ProductTV__c\":true,\"broadband__c\":true,\"CallResult__c\":\"Retido\",\"TVN1Result__c\":\"NÃO POSSUI\",\"TVN2Result__c\":\"N/A\",\"TVN3Result__c\":\"N/A\",\"PhoneN3Result__c\":\"N/A\",\"PhoneN2Result__c\":\"N/A\",\"PhoneN1Result__c\":\"NÃO POSSUI\",\"MobileN2Result__c\":\"N/A\",\"MobileN3Result__c\":\"N/A\",\"MobileN1Result__c\":\"NÃO POSSUI\",\"BLN3Result__c\":\"N/A\",\"BLN2Result__c\":\"N/A\",\"BLN1Result__c\":\"NÃO POSSUI\",\"EPS_Operador__c\":\"NEOBPO\"}]',List<Case>.class);
		Map<String, User> mapUser = new Map<String, User>([SELECT Id,Profile.name,NetServicos__c,FederationIdentifier,Name, Claro__c FROM	User]);

		NBA_IntegrationModels.RPA_tasks task = NBA_CustomRPA.createDefaultSolicForBonusDiscount(solics.get(0),order,lstCaso.get(0),mapUser,'','0');

		System.assertNotEquals(task, null);
		Test.stopTest();
	}

	@isTest
	private static void getTaskBonusDiscountForMovelTest(){
		Test.startTest();
		Order order = (Order) JSON.deserialize('{\"attributes\":{\"type\":\"Order\",\"url\":\"/services/data/v48.0/sobjects/Order/801J0000001OVU9IAO\"},\"Id\":\"801J0000001OVU9IAO\",\"SchedulingTime__c\":\"false\",\"AccountId\":\"0010v00000UAyyoAAD\",\"OrderNumber\":\"00008501\",\"TVMovement__c\":\"Aquisição\",\"VirtuaMovement__c\":\"Upgrade\",\"NETFoneMovement__c\":\"Lateral\",\"MobileMovement__c\":\"Lateral\",\"FeeAddValuePaymentForm__c\":\"ISENTO\",\"ContractId\":\"8000v000000EBeaAAG\",\"OwnershipProfile__c\":\"PTV + VIRTUA\",\"OwnerId\":\"0051H000008rayoQAA\",\"CreatedDate\":\"2020-02-18T14:34:58.000+0000\",\"Account\":{\"attributes\":{\"type\":\"Account\",\"url\":\"/services/data/v48.0/sobjects/Account/0010v00000UAyyoAAD\"},\"Id\":\"0010v00000UAyyoAAD\",\"Name\":\"JULIANA CARDOSO PEREIRA\",\"DocumentNumber__c\":\"431043043\"},\"Contract\":{\"attributes\":{\"type\":\"Contract\",\"url\":\"/services/data/v48.0/sobjects/Contract/8000v000000EBeaAAG\"},\"Id\":\"8000v000000EBeaAAG\",\"CityCode__c\":\"040\",\"ContractNumber\":\"160184304\",\"ContractNumber__c\":\"33773791\",\"LegacyStatus__c\":\"CONECTADO\"},\"Owner\":{\"attributes\":{\"type\":\"Name\",\"url\":\"/services/data/v48.0/sobjects/User/0051H000008rayoQAA\"},\"Id\":\"0051H000008rayoQAA\",\"ProfileId\":\"00e1H000001JcwYQAS\",\"Name\":\"MILENA PRAXEDES MELO\",\"Profile\":{\"attributes\":{\"type\":\"Profile\",\"url\":\"/services/data/v48.0/sobjects/Profile/00e1H000001JcwYQAS\"},\"Id\":\"00e1H000001JcwYQAS\",\"Name\":\"Atendente NBA - Retencao\"}}}',Order.class);
		List<Solic_NBA__c> solics = (List<Solic_NBA__c>)JSON.deserialize('[{\"attributes\":{\"type\":\"Solic_NBA__c\",\"url\":\"/services/data/v48.0/sobjects/Solic_NBA__c/a4pJ00000005SuwIAE\"},\"Order__c\":\"801J0000001O0eRIAS\",\"Status__c\":\"Não enviado\",\"ProductName__c\":\"FÁCIL TURBO HD\",\"Bonus__c\":\"Bônus 6GB com WhatsApp\",\"Discount__c\":\"Desc10%RetMulta\",\"CurrentProduct__c\":\"ACESSO VIRTUA\",\"Value__c\":54.90,\"FeeType__c\":\"Aquisição\",\"FeePrice__c\":899.00,\"LegacyNameProduct__c\":\"FACIL HD TURBO C/VTA/ FONE RENT CONF FID\",\"ComboProfile__c\":\"PTV+VTA+FONE+CELULAR\",\"PaymentMethod__c\":\"ISENTO\",\"RenewFidelity__c\":false,\"FullCancel__c\":false,\"TechnologyType__c\":\"Net Digital HD\",\"Movement__c\":\"Aquisição\",\"SolicitationType__c\":\"MUDANCA DE PACOTE\",\"ProductType__c\":\"TV PACOTE\",\"OfferType__c\":\"BLINDAGEM\",\"Fidelity__c\":false,\"AcceptedOffer__c\":false,\"Family__c\":\"FACIL TURBO\",\"PromotionName__c\":\"PROMO BS FACIL HD TURBO RENT P_49,9 3M\",\"Name\":\"SOLIC-19064\",\"QuantityPromoMonths__c\":\"3\",\"PromotionValue__c\":20.00,\"SpotType__c\":\"PP\",\"Id\":\"a4pJ00000005SuwIAE\",\"Portability__c\":false,\"IsComboMulti__c\":false,\"TotalValue__c\":74.90}]',List<Solic_NBA__c>.class);
		List<Case> lstCaso = (List<Case>) JSON.deserialize('[{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KniijIAB\"},\"Id\":\"500J000000KniijIAB\",\"A_la_Carte__c\":false,\"Fixo__c\":false,\"Movel__c\":true,\"ProductTV__c\":false,\"broadband__c\":true,\"CallResult__c\":\"Venda\",\"Order__c\":\"801J0000001OS3PIAW\",\"TVN1Result__c\":\"VENDA\",\"PhoneN1Result__c\":\"NÃO VENDA\",\"MobileN1Result__c\":\"VENDA\",\"BLN1Result__c\":\"UPGRADE\",\"EPS_Operador__c\":\"VGX CONTACT CENTER NORTE MG LTDA\"},{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KnnmdIAB\"},\"Id\":\"500J000000KnnmdIAB\",\"A_la_Carte__c\":true,\"Fixo__c\":true,\"Movel__c\":true,\"ProductTV__c\":true,\"broadband__c\":true,\"CallResult__c\":\"Retido\",\"TVN1Result__c\":\"NÃO POSSUI\",\"TVN2Result__c\":\"N/A\",\"TVN3Result__c\":\"N/A\",\"PhoneN3Result__c\":\"N/A\",\"PhoneN2Result__c\":\"N/A\",\"PhoneN1Result__c\":\"NÃO POSSUI\",\"MobileN2Result__c\":\"N/A\",\"MobileN3Result__c\":\"N/A\",\"MobileN1Result__c\":\"NÃO POSSUI\",\"BLN3Result__c\":\"N/A\",\"BLN2Result__c\":\"N/A\",\"BLN1Result__c\":\"NÃO POSSUI\",\"EPS_Operador__c\":\"NEOBPO\"}]',List<Case>.class);
		Map<String, User> mapUser = new Map<String, User>([SELECT Id,Profile.name,NetServicos__c,FederationIdentifier,Name, Claro__c FROM	User]);

		List<NBA_IntegrationModels.RPA_tasks> tasks = NBA_CustomRPA.getTaskBonusDiscountForMovel(solics.get(0),order,lstCaso.get(0),mapUser,'','0');

		System.assertEquals(tasks.isEmpty(), false);
		Test.stopTest();
	}

	@isTest
	private static void getTaskBonusDiscountWithDependentTest(){
		Test.startTest();
		Map<String, User> mapUser = new Map<String, User>([SELECT Id,Profile.name,NetServicos__c,FederationIdentifier,Name, Claro__c FROM	User]);
		Order order = (Order) JSON.deserialize('{\"attributes\":{\"type\":\"Order\",\"url\":\"/services/data/v48.0/sobjects/Order/801J0000001OVU9IAO\"},\"Id\":\"801J0000001OVU9IAO\",\"SchedulingTime__c\":\"false\",\"AccountId\":\"0010v00000UAyyoAAD\",\"OrderNumber\":\"00008501\",\"TVMovement__c\":\"Aquisição\",\"VirtuaMovement__c\":\"Upgrade\",\"NETFoneMovement__c\":\"Lateral\",\"MobileMovement__c\":\"Lateral\",\"FeeAddValuePaymentForm__c\":\"ISENTO\",\"ContractId\":\"8000v000000EBeaAAG\",\"OwnershipProfile__c\":\"PTV + VIRTUA\",\"OwnerId\":\"0051H000008rayoQAA\",\"CreatedDate\":\"2020-02-18T14:34:58.000+0000\",\"Account\":{\"attributes\":{\"type\":\"Account\",\"url\":\"/services/data/v48.0/sobjects/Account/0010v00000UAyyoAAD\"},\"Id\":\"0010v00000UAyyoAAD\",\"Name\":\"JULIANA CARDOSO PEREIRA\",\"DocumentNumber__c\":\"431043043\"},\"Contract\":{\"attributes\":{\"type\":\"Contract\",\"url\":\"/services/data/v48.0/sobjects/Contract/8000v000000EBeaAAG\"},\"Id\":\"8000v000000EBeaAAG\",\"CityCode__c\":\"040\",\"ContractNumber\":\"160184304\",\"ContractNumber__c\":\"33773791\",\"LegacyStatus__c\":\"CONECTADO\"},\"Owner\":{\"attributes\":{\"type\":\"Name\",\"url\":\"/services/data/v48.0/sobjects/User/0051H000008rayoQAA\"},\"Id\":\"0051H000008rayoQAA\",\"ProfileId\":\"00e1H000001JcwYQAS\",\"Name\":\"MILENA PRAXEDES MELO\",\"Profile\":{\"attributes\":{\"type\":\"Profile\",\"url\":\"/services/data/v48.0/sobjects/Profile/00e1H000001JcwYQAS\"},\"Id\":\"00e1H000001JcwYQAS\",\"Name\":\"Atendente NBA - Retencao\"}}}',Order.class);
		List<Solic_NBA__c> solics = (List<Solic_NBA__c>)JSON.deserialize('[{\"attributes\":{\"type\":\"Solic_NBA__c\",\"url\":\"/services/data/v48.0/sobjects/Solic_NBA__c/a4p1H000000EA2VQAW\"},\"Id\":\"a4p1H000000EA2VQAW\",\"Portability__c\":false,\"Movement__c\":\"Lateral\",\"MSISDN__c\":\"11991396095\",\"Bonus__c\":\"Bônus 6GB com WhatsApp\",\"Discount__c\":\"Desc10%RetMulta\",\"Order__c\":\"8011H000001B55AQAS\",\"DependentProfile__c\":\"DEPENDENTE VOZ + DADOS SEM DESCONTO\"},{\"attributes\":{\"type\":\"Solic_NBA__c\",\"url\":\"/services/data/v48.0/sobjects/Solic_NBA__c/a4p1H000000EB5AQAW\"},\"Id\":\"a4p1H000000EB5AQAW\",\"Portability__c\":false,\"Movement__c\":\"Lateral\",\"MSISDN__c\":\"11985991000\",\"Order__c\":\"8011H000001C3BgQAK\",\"DependentProfile__c\":\"DEPENDENTE VOZ + DADOS SEM DESCONTO\"},{\"attributes\":{\"type\":\"Solic_NBA__c\",\"url\":\"/services/data/v48.0/sobjects/Solic_NBA__c/a4p1H000000E4VzQAK\"},\"Id\":\"a4p1H000000E4VzQAK\",\"Portability__c\":false,\"Movement__c\":\"Lateral\",\"MSISDN__c\":\"11985991000\",\"Order__c\":\"8011H0000012E4IQAU\",\"DependentProfile__c\":\"DEPENDENTE VOZ + DADOS SEM DESCONTO\"}]',List<Solic_NBA__c>.class);
		List<Case> lstCaso = (List<Case>) JSON.deserialize('[{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KniijIAB\"},\"Id\":\"500J000000KniijIAB\",\"A_la_Carte__c\":false,\"Fixo__c\":false,\"Movel__c\":true,\"ProductTV__c\":false,\"broadband__c\":true,\"CallResult__c\":\"Venda\",\"Order__c\":\"801J0000001OS3PIAW\",\"TVN1Result__c\":\"VENDA\",\"PhoneN1Result__c\":\"NÃO VENDA\",\"MobileN1Result__c\":\"VENDA\",\"BLN1Result__c\":\"UPGRADE\",\"EPS_Operador__c\":\"VGX CONTACT CENTER NORTE MG LTDA\"},{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v48.0/sobjects/Case/500J000000KnnmdIAB\"},\"Id\":\"500J000000KnnmdIAB\",\"A_la_Carte__c\":true,\"Fixo__c\":true,\"Movel__c\":true,\"ProductTV__c\":true,\"broadband__c\":true,\"CallResult__c\":\"Retido\",\"TVN1Result__c\":\"NÃO POSSUI\",\"TVN2Result__c\":\"N/A\",\"TVN3Result__c\":\"N/A\",\"PhoneN3Result__c\":\"N/A\",\"PhoneN2Result__c\":\"N/A\",\"PhoneN1Result__c\":\"NÃO POSSUI\",\"MobileN2Result__c\":\"N/A\",\"MobileN3Result__c\":\"N/A\",\"MobileN1Result__c\":\"NÃO POSSUI\",\"BLN3Result__c\":\"N/A\",\"BLN2Result__c\":\"N/A\",\"BLN1Result__c\":\"NÃO POSSUI\",\"EPS_Operador__c\":\"NEOBPO\"}]',List<Case>.class);

		List<NBA_IntegrationModels.RPA_tasks> tasks = NBA_CustomRPA.getTaskBonusDiscountWithDependent(solics,order,lstCaso.get(0),mapUser,'','0');

		System.assertEquals(tasks.isEmpty(), false);
		Test.stopTest();
	}

	@IsTest
	private static void shouldUpdateOrderStatusToError() {
		Account lAccount = NBA_DataFactory_Test.getAccount();
		insert lAccount;

		Case caso;
		Order pedido;

		caso = NBA_DataFactory_Test.getCase(lAccount);
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		caso.CallReason__c = 'Falta de vantagens para Clientes';
		caso.ProductTV__c = true;
		caso.broadband__c = true;
		caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;

		pedido = new Order();
		pedido.OrderCase__c = caso.Id;

		pedido.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido.AccountId = lAccount.Id;
		pedido.EffectiveDate = Date.today();
		pedido.Status = 'Draft';

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Ativo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;
			insert pedido;

			insert new Solic_NBA__c(
				Order__c = pedido.Id,
				OfferType__c = NBA_Constants.TIPO_OFERTA_EXCLUSIVO, 
				ProductName__c = 'BL ASSINATURA',
				ProductType__c = NBA_Constants.BL_ASSINATURA
			);

			caso.Order__c = pedido.Id;
			caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;
			update caso;

			NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
			res.success	= false;

			NBA_CustomRPA.updateOrder(res, pedido.Id );
		}

		pedido = [SELECT Status FROM Order WHERE Id = :pedido.Id];

		System.assertEquals('Erro Envio', pedido.Status);
	}

	@IsTest
	private static void shouldUpdateOrderStatusToCompleted() {
		Account lAccount = NBA_DataFactory_Test.getAccount();
		insert lAccount;

		Case caso;
		Order pedido;

		caso = NBA_DataFactory_Test.getCase(lAccount);
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		caso.CallReason__c = 'Falta de vantagens para Clientes';
		caso.ProductTV__c = true;
		caso.broadband__c = true;
		caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;

		pedido = new Order();
		pedido.OrderCase__c = caso.Id;

		pedido.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido.AccountId = lAccount.Id;
		pedido.EffectiveDate = Date.today();
		pedido.Status = 'Draft';

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;
			insert pedido;

			insert new Solic_NBA__c(
				Order__c = pedido.Id,
				ProductName__c = 'CANCELAMENTO TOTAL',
				ProductType__c = 'CANCELAMENTO TOTAL'
			);

			caso.Order__c = pedido.Id;
			caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;
			update caso;

			NBA_IntegrationUtils.HttpResponseModel res = new NBA_IntegrationUtils.HttpResponseModel();
			res.success	= true;

			NBA_CustomRPA.updateOrder(res, pedido.Id );
		}

		pedido = [SELECT Status FROM Order WHERE Id = :pedido.Id];

		System.assertEquals('Em Processamento', pedido.Status);
	}

}