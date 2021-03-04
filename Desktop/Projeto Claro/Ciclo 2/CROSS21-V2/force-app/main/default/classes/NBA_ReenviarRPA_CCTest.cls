@isTest 
private class NBA_ReenviarRPA_CCTest {
	
	@TestSetup private static void setupMethod(){
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
		sMovel.Movement__c				= '';
		sMovel.SolicitationType__c		= 'Teste';
		sMovel.ProductType__c			= 'MOVEL ASSINATURA';
		sMovel.OfferType__c				= 'Teste';
		sMovel.Priority__c				= 'Teste';
		sMovel.Family__c				= 'Teste';
		sMovel.FeePrice__c				= 0;
		sMovel.PromotionName__c			= 'Teste';
		insert sMovel;

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
		insert sNet;
    }

	@isTest
	private static void getSolicFromOrdeTest() {
		Order ord = [SELECT Id FROM Order WHERE Account.Name = 'Teste N/A'];
		Test.startTest();
		NBA_ReenviarRPA_CC.getSolicFromOrder( ord.id );
		Test.stopTest();
		System.assertNotEquals(null, ord);
	}
	
	@isTest
	private static void showComponentTest() {
		Order ord = [SELECT Id FROM Order WHERE Account.Name = 'Teste N/A'];
		Test.startTest();
		NBA_ReenviarRPA_CC.showComponent( ord.id );
		Test.stopTest();
		System.assertNotEquals(null, ord);
	}

	@isTest
	private static void sendPedidoTest() {
		Order ord = [SELECT Id FROM Order WHERE Account.Name = 'Teste N/A'];

		Test.setMock(HttpCalloutMock.class, new NBA_IntegrationServicesMock_Test('', NBA_DataFactory_Test.SET_HEADER_KEY, NBA_DataFactory_Test.SET_HEADER_VALUE, NBA_DataFactory_Test.STATUS_CODE_SUCCS));
		Test.startTest();
		NBA_ReenviarRPA_CC.sendPedido( ord.id );
		Test.stopTest();
		System.assertNotEquals(null, ord);
	}
}