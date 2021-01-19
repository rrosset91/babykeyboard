@isTest
public class NBA_CaseTriggerHandler_Test {

	private static final Id recordTypeIdRetencao = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
	private static final Id recordTypeIdRentabilizacao = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();

	@isTest static void updateStagebyReasonTest() {

		Account lAccount = NBA_DataFactory_Test.getAccount();

		Case caso1 = NBA_DataFactory_Test.getCase(lAccount);
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		caso1.CallReason__c = 'Falta de vantagens para Clientes';
		caso1.ProductTV__c = true;
		Case caso2 = NBA_DataFactory_Test.getCase(lAccount);
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
		caso2.CallReason__c = 'Produto - Adesão';
		caso2.Subreason__c = null;
		caso2.ProductTV__c = true;
		Case caso3 = NBA_DataFactory_Test.getCase(lAccount);
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
		caso3.CallReason__c = 'Falta de vantagens para Clientes';
		caso3.Subreason__c = null;
		caso3.ProductTV__c = true;

		List<Case> caseList = new List<Case>();
		caseList.add(caso1);
		caseList.add(caso2);
		caseList.add(caso3);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caseList;
		}

		caseList = getCases(caseList);

		for (Case c : caseList) {
			System.assertNotEquals('Sondagem', c.Time_of_Service__c);
		}
	}

	@isTest static void automaticFillingCallEndingTest() {

		Account lAccount = NBA_DataFactory_Test.getAccount();
		insert lAccount;

		Order pedido1 = new Order();
		pedido1.TVMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		pedido1.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido1.AccountId = lAccount.Id;
		pedido1.EffectiveDate = Date.today();
		pedido1.Status = 'Draft';
		insert pedido1;
        
		Order pedido2 = new Order();
		pedido2.TVMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido2.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido2.AccountId = lAccount.Id;
		pedido2.EffectiveDate = Date.today();
		pedido2.Status = 'Draft';
		insert pedido2;
        
		Order pedido3 = new Order();
		pedido3.TVMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;
		pedido3.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido3.AccountId = lAccount.Id;
		pedido3.EffectiveDate = Date.today();
		pedido3.Status = 'Draft';
		insert pedido3;

		Order pedido4 = new Order();
		pedido4.VirtuaMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		pedido4.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
        
		Order pedido5 = new Order();
		pedido5.VirtuaMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido5.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		
        Order pedido6 = new Order();
		pedido6.VirtuaMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;
		pedido6.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();

		Case caso1 = NBA_DataFactory_Test.getCase(lAccount);
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		caso1.CallReason__c = 'Atendimento';
		caso1.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;
		caso1.Order__c = pedido1.Id;
        caso1.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
		caso1.TVN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
        caso1.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
		
        Case caso2 = NBA_DataFactory_Test.getCase(lAccount);
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
		caso2.CallReason__c = 'Atendimento';
		caso2.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;
		caso2.Order__c = pedido2.Id;
		
        Case caso3 = NBA_DataFactory_Test.getCase(lAccount);
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		
        Case caso4 = NBA_DataFactory_Test.getCase(lAccount);
		caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		
        Case caso5 = NBA_DataFactory_Test.getCase(lAccount);
		caso5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
		
        Case caso6 = NBA_DataFactory_Test.getCase(lAccount);
		caso6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();

       
		List<Case> caseList = new List<Case>();
		caseList.add(caso1);
		caseList.add(caso2);
		caseList.add(caso3);
		caseList.add(caso4);
		caseList.add(caso5);
		caseList.add(caso6);

		Solic_NBA__c a1 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_EXCLUSIVO, ProductName__c = 'a1');
		a1.ProductType__c = NBA_Constants.NET_FONE;
		insert a1;
		
        Solic_NBA__c a3 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_PADRAO, ProductName__c = 'a3');
		a3.ProductType__c = NBA_Constants.MOVEL_ASSINATURA;
		insert a3;
		
        Solic_NBA__c a4 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_PADRAO, ProductName__c = 'a4');
		a4.ProductType__c = NBA_Constants.TV_PACOTE;
		insert a4;
		
        Solic_NBA__c a5 = new Solic_NBA__c(TechnologyType__c = 'DIGITAL', OfferType__c = NBA_Constants.TIPO_OFERTA_PADRAO, ProductName__c = 'a5');
		a5.ProductType__c = NBA_Constants.TV_PACOTE;
		insert a5;

		Test.startTest();
		NBA_CaseTriggerHandler.automaticFillingCallEnding(caseList);
		Test.stopTest();
        /*System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso1.TVN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso1.TVN2Result__c);
        System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso1.TVN3Result__c);*/
        
	}

	@isTest static void updateValuesRentabilizacaoTest() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso1 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso2 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso3 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso4 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso5 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso6 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso7 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		List<Case> casos = new Case[]{caso1, caso2, caso3, caso4, caso5, caso6, caso7};

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Receptivo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert casos;

			Order pedido1 = buildDefaultOrder(caso1, conta);
			Order pedido2 = buildDefaultOrder(caso2, conta);
			Order pedido3 = buildDefaultOrder(caso3, conta);
			Order pedido4 = buildDefaultOrder(caso4, conta);
			Order pedido5 = buildDefaultOrder(caso5, conta);
			Order pedido6 = buildDefaultOrder(caso6, conta);
			Order pedido7 = buildDefaultOrder(caso7, conta);

			pedido1.TVMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;		
			pedido2.TVMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;		
			pedido3.TVMovement__c = NBA_Constants.MOVIMENTO_DOWNGRADE;		
			pedido4.TVMovement__c = null;		
			pedido5.TVMovement__c = NBA_Constants.MOVIMENTO_LATERAL;		
			pedido6.TVMovement__c = NBA_Constants.MOVIMENTO_MANTIDO;		
			pedido7.TVMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;

			List<Order> pedidos = new Order[]{pedido1, pedido2, pedido3, pedido4, pedido5, pedido6, pedido7};
			insert pedidos;

			Solic_NBA__c solic1 = buildDefaultSolic(pedido1, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic2 = buildDefaultSolic(pedido2, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic3 = buildDefaultSolic(pedido3, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic4 = buildDefaultSolic(pedido4, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic5 = buildDefaultSolic(pedido5, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic6 = buildDefaultSolic(pedido6, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic7 = buildDefaultSolic(pedido7, NBA_Constants.TV_PACOTE, null, null);
			
			List<Solic_NBA__c> solics = new Solic_NBA__c[]{solic1, solic2, solic3, solic4, solic5, solic6, solic7};
			insert solics;

			for (Solic_NBA__c s : [SELECT Order__c FROM Solic_NBA__c]) {
				System.debug(s.Order__c);
			}

			caso1.Order__c = pedido1.Id;
			caso2.Order__c = pedido2.Id;
			caso3.Order__c = pedido3.Id;
			caso4.Order__c = pedido4.Id;
			caso5.Order__c = pedido5.Id;
			caso6.Order__c = pedido6.Id;
			caso7.Order__c = pedido7.Id;
			update casos;
		}

		casos = getCases(casos);
		System.assertEquals(7, casos.size());

		for (Case caso : casos) {
			if (caso.Id == caso1.Id) {
				//Movimento Aquisição
				System.assertEquals(NBA_Constants.RESULT_N1_VENDA, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.TVN3Result__c);
			}

			if (caso.Id == caso2.Id) {
				//Movimento Upgrade
				System.assertEquals(NBA_Constants.RESULT_N1_UPGRADE, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.TVN3Result__c);
			}

			if (caso.Id == caso3.Id) {
				//Movimento Downgrade
				System.assertEquals(NBA_Constants.RESULT_N1_DOWNGRADE, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.TVN3Result__c);
			}

			if (caso.Id == caso4.Id) {
				//Movimento null
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.TVN3Result__c);
			}

			if (caso.Id == caso5.Id) {
				//Movimento Lateral
				System.assertEquals(NBA_Constants.RESULT_N1_SIDEGRADE, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.TVN3Result__c);
			}

			if (caso.Id == caso6.Id) {
				//Movimento Mantido
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.TVN3Result__c);
			}

			if (caso.Id == caso7.Id) {
				//Movimento Nenhum
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.TVN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.TVN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.TVN3Result__c);
			}
		}
	}

	@isTest static void updateValuesRentabilizacaoTest2() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso1 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso2 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso3 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso4 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso5 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso6 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso7 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		List<Case> casos = new Case[]{caso1, caso2, caso3, caso4, caso5, caso6, caso7};

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Receptivo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert casos;

			Order pedido1 = buildDefaultOrder(caso1, conta);
			Order pedido2 = buildDefaultOrder(caso2, conta);
			Order pedido3 = buildDefaultOrder(caso3, conta);
			Order pedido4 = buildDefaultOrder(caso4, conta);
			Order pedido5 = buildDefaultOrder(caso5, conta);
			Order pedido6 = buildDefaultOrder(caso6, conta);
			Order pedido7 = buildDefaultOrder(caso7, conta);

			pedido1.VirtuaMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;		
			pedido2.VirtuaMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;		
			pedido3.VirtuaMovement__c = NBA_Constants.MOVIMENTO_DOWNGRADE;		
			pedido4.VirtuaMovement__c = null;		
			pedido5.VirtuaMovement__c = NBA_Constants.MOVIMENTO_LATERAL;		
			pedido6.VirtuaMovement__c = NBA_Constants.MOVIMENTO_MANTIDO;		
			pedido7.VirtuaMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;

			List<Order> pedidos = new Order[]{pedido1, pedido2, pedido3, pedido4, pedido5, pedido6, pedido7};
			insert pedidos;

			Solic_NBA__c solic1 = buildDefaultSolic(pedido1, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic2 = buildDefaultSolic(pedido2, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic3 = buildDefaultSolic(pedido3, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic4 = buildDefaultSolic(pedido4, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic5 = buildDefaultSolic(pedido5, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic6 = buildDefaultSolic(pedido6, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic7 = buildDefaultSolic(pedido7, NBA_Constants.TV_PACOTE, null, null);
			
			List<Solic_NBA__c> solics = new Solic_NBA__c[]{solic1, solic2, solic3, solic4, solic5, solic6, solic7};
			insert solics;

			for (Solic_NBA__c s : [SELECT Order__c FROM Solic_NBA__c]) {
				System.debug(s.Order__c);
			}

			caso1.Order__c = pedido1.Id;
			caso2.Order__c = pedido2.Id;
			caso3.Order__c = pedido3.Id;
			caso4.Order__c = pedido4.Id;
			caso5.Order__c = pedido5.Id;
			caso6.Order__c = pedido6.Id;
			caso7.Order__c = pedido7.Id;
			update casos;
		}

		casos = getCases(casos);
		System.assertEquals(7, casos.size());

		for (Case caso : casos) {
			if (caso.Id == caso1.Id) {
				//Movimento Aquisição
				System.assertEquals(NBA_Constants.RESULT_N1_VENDA, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.BLN3Result__c);
			}

			if (caso.Id == caso2.Id) {
				//Movimento Upgrade
				System.assertEquals(NBA_Constants.RESULT_N1_UPGRADE, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.BLN3Result__c);
			}

			if (caso.Id == caso3.Id) {
				//Movimento Downgrade
				System.assertEquals(NBA_Constants.RESULT_N1_DOWNGRADE, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.BLN3Result__c);
			}

			if (caso.Id == caso4.Id) {
				//Movimento null
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);
			}

			if (caso.Id == caso5.Id) {
				//Movimento Lateral
				System.assertEquals(NBA_Constants.RESULT_N1_SIDEGRADE, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.BLN3Result__c);
			}

			if (caso.Id == caso6.Id) {
				//Movimento Mantido
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);
			}

			if (caso.Id == caso7.Id) {
				//Movimento Nenhum
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.BLN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);
			}
		}
	}

	@isTest static void updateValuesRentabilizacaoTest3() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso1 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso2 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso3 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso4 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso5 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso6 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso7 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		List<Case> casos = new Case[]{caso1, caso2, caso3, caso4, caso5, caso6, caso7};

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Ativo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert casos;

			Order pedido1 = buildDefaultOrder(caso1, conta);
			Order pedido2 = buildDefaultOrder(caso2, conta);
			Order pedido3 = buildDefaultOrder(caso3, conta);
			Order pedido4 = buildDefaultOrder(caso4, conta);
			Order pedido5 = buildDefaultOrder(caso5, conta);
			Order pedido6 = buildDefaultOrder(caso6, conta);
			Order pedido7 = buildDefaultOrder(caso7, conta);

			pedido1.MobileMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;		
			pedido2.MobileMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;		
			pedido3.MobileMovement__c = NBA_Constants.MOVIMENTO_DOWNGRADE;		
			pedido4.MobileMovement__c = null;		
			pedido5.MobileMovement__c = NBA_Constants.MOVIMENTO_LATERAL;		
			pedido6.MobileMovement__c = NBA_Constants.MOVIMENTO_MANTIDO;		
			pedido7.MobileMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;

			List<Order> pedidos = new Order[]{pedido1, pedido2, pedido3, pedido4, pedido5, pedido6, pedido7};
			insert pedidos;

			Solic_NBA__c solic1 = buildDefaultSolic(pedido1, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic2 = buildDefaultSolic(pedido2, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic3 = buildDefaultSolic(pedido3, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic4 = buildDefaultSolic(pedido4, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic5 = buildDefaultSolic(pedido5, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic6 = buildDefaultSolic(pedido6, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic7 = buildDefaultSolic(pedido7, NBA_Constants.TV_PACOTE, null, null);
			
			List<Solic_NBA__c> solics = new Solic_NBA__c[]{solic1, solic2, solic3, solic4, solic5, solic6, solic7};
			insert solics;

			for (Solic_NBA__c s : [SELECT Order__c FROM Solic_NBA__c]) {
				System.debug(s.Order__c);
			}

			caso1.Order__c = pedido1.Id;
			caso2.Order__c = pedido2.Id;
			caso3.Order__c = pedido3.Id;
			caso4.Order__c = pedido4.Id;
			caso5.Order__c = pedido5.Id;
			caso6.Order__c = pedido6.Id;
			caso7.Order__c = pedido7.Id;
			update casos;
		}

		casos = getCases(casos);
		System.assertEquals(7, casos.size());

		for (Case caso : casos) {
			if (caso.Id == caso1.Id) {
				//Movimento Aquisição
				System.assertEquals(NBA_Constants.RESULT_N1_VENDA, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.MobileN3Result__c);
			}

			if (caso.Id == caso2.Id) {
				//Movimento Upgrade
				System.assertEquals(NBA_Constants.RESULT_N1_UPGRADE, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.MobileN3Result__c);
			}

			if (caso.Id == caso3.Id) {
				//Movimento Downgrade
				System.assertEquals(NBA_Constants.RESULT_N1_DOWNGRADE, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.MobileN3Result__c);
			}

			if (caso.Id == caso4.Id) {
				//Movimento null
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.MobileN3Result__c);
			}

			if (caso.Id == caso5.Id) {
				//Movimento Lateral
				System.assertEquals(NBA_Constants.RESULT_N1_SIDEGRADE, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.MobileN3Result__c);
			}

			if (caso.Id == caso6.Id) {
				//Movimento Mantido
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.MobileN3Result__c);
			}

			if (caso.Id == caso7.Id) {
				//Movimento Nenhum
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.MobileN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.MobileN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.MobileN3Result__c);
			}
		}
	}

	@isTest static void updateValuesRentabilizacaoTest4() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso1 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso2 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso3 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso4 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso5 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso6 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso7 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		List<Case> casos = new Case[]{caso1, caso2, caso3, caso4, caso5, caso6, caso7};

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Ativo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert casos;

			Order pedido1 = buildDefaultOrder(caso1, conta);
			Order pedido2 = buildDefaultOrder(caso2, conta);
			Order pedido3 = buildDefaultOrder(caso3, conta);
			Order pedido4 = buildDefaultOrder(caso4, conta);
			Order pedido5 = buildDefaultOrder(caso5, conta);
			Order pedido6 = buildDefaultOrder(caso6, conta);
			Order pedido7 = buildDefaultOrder(caso7, conta);

			pedido1.NETFoneMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;		
			pedido2.NETFoneMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;		
			pedido3.NETFoneMovement__c = NBA_Constants.MOVIMENTO_DOWNGRADE;		
			pedido4.NETFoneMovement__c = null;		
			pedido5.NETFoneMovement__c = NBA_Constants.MOVIMENTO_LATERAL;		
			pedido6.NETFoneMovement__c = NBA_Constants.MOVIMENTO_MANTIDO;		
			pedido7.NETFoneMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;

			List<Order> pedidos = new Order[]{pedido1, pedido2, pedido3, pedido4, pedido5, pedido6, pedido7};
			insert pedidos;

			Solic_NBA__c solic1 = buildDefaultSolic(pedido1, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic2 = buildDefaultSolic(pedido2, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic3 = buildDefaultSolic(pedido3, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic4 = buildDefaultSolic(pedido4, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic5 = buildDefaultSolic(pedido5, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic6 = buildDefaultSolic(pedido6, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic7 = buildDefaultSolic(pedido7, NBA_Constants.TV_PACOTE, null, null);
			
			List<Solic_NBA__c> solics = new Solic_NBA__c[]{solic1, solic2, solic3, solic4, solic5, solic6, solic7};
			insert solics;

			for (Solic_NBA__c s : [SELECT Order__c FROM Solic_NBA__c]) {
				System.debug(s.Order__c);
			}

			caso1.Order__c = pedido1.Id;
			caso2.Order__c = pedido2.Id;
			caso3.Order__c = pedido3.Id;
			caso4.Order__c = pedido4.Id;
			caso5.Order__c = pedido5.Id;
			caso6.Order__c = pedido6.Id;
			caso7.Order__c = pedido7.Id;
			update casos;
		}

		casos = getCases(casos);
		System.assertEquals(7, casos.size());

		for (Case caso : casos) {
			if (caso.Id == caso1.Id) {
				//Movimento Aquisição
				System.assertEquals(NBA_Constants.RESULT_N1_VENDA, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso2.Id) {
				//Movimento Upgrade
				System.assertEquals(NBA_Constants.RESULT_N1_UPGRADE, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso3.Id) {
				//Movimento Downgrade
				System.assertEquals(NBA_Constants.RESULT_N1_DOWNGRADE, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso4.Id) {
				//Movimento null
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso5.Id) {
				//Movimento Lateral
				System.assertEquals(NBA_Constants.RESULT_N1_SIDEGRADE, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_PRECO_OFERTA, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_OUTROS, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso6.Id) {
				//Movimento Mantido
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_APLICAVEL, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);
			}

			if (caso.Id == caso7.Id) {
				//Movimento Nenhum
				System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.PhoneN1Result__c);
				System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
				System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);
			}
		}
	}

	@isTest static void updateValuesRentabilizacaoTest5() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso1 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso2 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso3 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso4 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso5 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso6 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);
		Case caso7 = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		List<Case> casos = new Case[]{caso1, caso2, caso3, caso4, caso5, caso6, caso7};

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Receptivo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert casos;

			Order pedido1 = buildDefaultOrder(caso1, conta);
			Order pedido2 = buildDefaultOrder(caso2, conta);
			Order pedido3 = buildDefaultOrder(caso3, conta);
			Order pedido4 = buildDefaultOrder(caso4, conta);
			Order pedido5 = buildDefaultOrder(caso5, conta);
			Order pedido6 = buildDefaultOrder(caso6, conta);
			Order pedido7 = buildDefaultOrder(caso7, conta);

			pedido1.ALaCarteMoviment__c = null;		
			pedido2.ALaCarteMoviment__c = null;		
			pedido3.ALaCarteMoviment__c = null;		
			pedido4.ALaCarteMoviment__c = null;		
			pedido5.ALaCarteMoviment__c = null;		
			pedido6.ALaCarteMoviment__c = null;		
			pedido7.ALaCarteMoviment__c = null;

			List<Order> pedidos = new Order[]{pedido1, pedido2, pedido3, pedido4, pedido5, pedido6, pedido7};
			insert pedidos;

			Solic_NBA__c solic1 = buildDefaultSolic(pedido1, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic2 = buildDefaultSolic(pedido2, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic3 = buildDefaultSolic(pedido3, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic4 = buildDefaultSolic(pedido4, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic5 = buildDefaultSolic(pedido5, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic6 = buildDefaultSolic(pedido6, NBA_Constants.TV_PACOTE, null, null);
			Solic_NBA__c solic7 = buildDefaultSolic(pedido7, NBA_Constants.TV_PACOTE, null, null);
			
			List<Solic_NBA__c> solics = new Solic_NBA__c[]{solic1, solic2, solic3, solic4, solic5, solic6, solic7};
			insert solics;

			for (Solic_NBA__c s : [SELECT Order__c FROM Solic_NBA__c]) {
				System.debug(s.Order__c);
			}

			caso1.Order__c = pedido1.Id;
			caso2.Order__c = pedido2.Id;
			caso3.Order__c = pedido3.Id;
			caso4.Order__c = pedido4.Id;
			caso5.Order__c = pedido5.Id;
			caso6.Order__c = pedido6.Id;
			caso7.Order__c = pedido7.Id;
			update casos;
		}

		casos = getCases(casos);
		System.assertEquals(7, casos.size());

		for (Case caso : casos) {
			System.assertEquals(null, caso.ALaCarteN1Result__c);
			System.assertEquals(null, caso.ALaCarteN2Result__c);
			System.assertEquals(null, caso.ALaCarteN3Result__c);
		}
	}

	@isTest static void updateValuesRentabilizacaoTest6() {

		Account lAccount = NBA_DataFactory_Test.getAccount();

		Case caso1 = NBA_DataFactory_Test.getCase(lAccount);
		caso1.CallReason__c = NBA_Constants.MOTIVO_DIVERGENCIA_CADASTRO;
		Case caso2 = NBA_DataFactory_Test.getCase(lAccount);

		Order pedido;

		Test.startTest();
		NBA_CaseTriggerHandler.updateValuesRentabilizacao(caso1, pedido, false, NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_ATIVO);
		NBA_CaseTriggerHandler.updateValuesRentabilizacao(caso2, pedido, false, NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_RECEPTIVO);
		Test.stopTest();

		System.assertEquals(null, caso1.ALaCarteN1Result__c);

	}

	@isTest static void updateValuesRentabilizacaoTest7() {

		Account lAccount = NBA_DataFactory_Test.getAccount();

		Case caso1 = NBA_DataFactory_Test.getCase(lAccount);
		caso1.CallReason__c = NBA_Constants.MOTIVO_DIVERGENCIA_CADASTRO;
		caso1.Exceptions__c = NBA_Constants.EXCEPTION_MENOS_QUE_3_OFERTAS;
		Case caso2 = NBA_DataFactory_Test.getCase(lAccount);

		Order pedido;

		Test.startTest();
		NBA_CaseTriggerHandler.updateValuesRentabilizacao(caso1, pedido, false, NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_ATIVO);
		NBA_CaseTriggerHandler.updateValuesRentabilizacao(caso2, pedido, false, NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_RECEPTIVO);

		Test.stopTest();

		System.assertEquals(NBA_Constants.IMPRODUTIVO, caso1.ALaCarteN1Result__c);
		System.assertEquals(null, caso2.ALaCarteN1Result__c);
	}
  
    @isTest static void updateValuesN2RetencaoTest() {

		Account lAccount = NBA_DataFactory_Test.getAccount();

		Case caso1 = NBA_DataFactory_Test.getCase(lAccount);
		caso1.CallReason__c = NBA_Constants.MOTIVO_PRODUTO;
		Case caso2 = NBA_DataFactory_Test.getCase(lAccount);
		caso2.CallReason__c = NBA_Constants.MOTIVO_FINANCEIRO;
		Case caso3 = NBA_DataFactory_Test.getCase(lAccount);
		caso3.CallReason__c = NBA_Constants.MOTIVO_FALTA_DE_VANTAGENS;
		Case caso4 = NBA_DataFactory_Test.getCase(lAccount);
		caso4.CallReason__c = NBA_Constants.MOTIVO_ATENDIMENTO;
		Case caso5 = NBA_DataFactory_Test.getCase(lAccount);
		caso5.CallReason__c = NBA_Constants.MOTIVO_PROBLEMAS_TECNICOS;
		Case caso6 = NBA_DataFactory_Test.getCase(lAccount);
		caso6.CallReason__c = NBA_Constants.MOTIVO_MUDANCA_DE_ENDERECO;
		Case caso7 = NBA_DataFactory_Test.getCase(lAccount);
		caso7.CallReason__c = NBA_Constants.MOTIVO_INADIMPLENCIA;
		Case caso8 = NBA_DataFactory_Test.getCase(lAccount);
		caso8.CallReason__c = NBA_Constants.MOTIVO_FALECIMENTO;
		Case caso9 = NBA_DataFactory_Test.getCase(lAccount);
		caso9.CallReason__c = NBA_Constants.MOTIVO_REFORMA_OU_VIAGEM;

		Order pedido = new Order();
		pedido.TVMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido.VirtuaMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido.NETFoneMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido.MobileMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
		pedido.ALaCarteMoviment__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;

		Map<String, List<Solic_NBA__c>> mapOrderSolics = new Map<String, List<Solic_NBA__c>> ();

		Test.startTest();
		NBA_CaseTriggerHandler.updateResultsRetencao(caso1, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso2, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso3, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso4, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso5, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso6, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso7, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso8, pedido, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso9, pedido, mapOrderSolics);
		Test.stopTest();

		System.assertEquals('Produto', caso1.CallReason__c);

	}
    
	@isTest static void updateValuesN3RetencaoTest3() {

		Account lAccount = NBA_DataFactory_Test.getAccount();
		insert lAccount;

		Case caso = NBA_DataFactory_Test.getCase(lAccount);

		Order pedido1 = NBA_DataFactory_Test.getOrder(lAccount);
		pedido1.NETFoneMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		insert pedido1;
		Order pedido2 = NBA_DataFactory_Test.getOrder(lAccount);
		pedido2.VirtuaMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		insert pedido2;
		Order pedido3 = NBA_DataFactory_Test.getOrder(lAccount);
		pedido3.MobileMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		insert pedido3;
		Order pedido4 = NBA_DataFactory_Test.getOrder(lAccount);
		pedido4.TVMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		insert pedido4;
		Order pedido5 = NBA_DataFactory_Test.getOrder(lAccount);
		pedido5.ALaCarteMoviment__c = NBA_Constants.MOVIMENTO_AQUISICAO;
		insert pedido5;

		Solic_NBA__c a1 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_BLINDAGEM, ProductName__c = 'a1');
		a1.ProductType__c = NBA_Constants.NET_FONE;
		a1.QuantityPromoMonths__c = '1';
		insert a1;
		Solic_NBA__c a3 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_BLINDAGEM, ProductName__c = 'a3');
		a3.ProductType__c = NBA_Constants.MOVEL_ASSINATURA_RPA;
		a3.QuantityPromoMonths__c = '1';
		insert a3;
		Solic_NBA__c a4 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_BLINDAGEM, ProductName__c = 'a4');
		a4.ProductType__c = NBA_Constants.TV_PACOTE;
		a4.QuantityPromoMonths__c = '1';
		insert a4;
		Solic_NBA__c a5 = new Solic_NBA__c(OfferType__c = NBA_Constants.TIPO_OFERTA_BLINDAGEM, TechnologyType__c = 'DIGITAL', ProductName__c = 'a5');
		a5.ProductType__c = NBA_Constants.TV_PACOTE;
		a5.QuantityPromoMonths__c = '1';
		insert a5;

		List<Solic_NBA__c> ltSolic = [SELECT Id, ProductType__c, OfferType__c, QuantityPromoMonths__c FROM Solic_NBA__c];

		Map<String, List<Solic_NBA__c>> mapOrderSolics = new Map<String, List<Solic_NBA__c>> ();
		mapOrderSolics.put(pedido1.Id, ltSolic);
		mapOrderSolics.put(pedido2.Id, ltSolic);
		mapOrderSolics.put(pedido3.Id, ltSolic);
		mapOrderSolics.put(pedido4.Id, ltSolic);
		mapOrderSolics.put(pedido5.Id, ltSolic);

		Test.startTest();

		NBA_CaseTriggerHandler.updateResultsRetencao(caso, pedido1, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso, pedido2, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso, pedido3, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso, pedido4, mapOrderSolics);
		NBA_CaseTriggerHandler.updateResultsRetencao(caso, pedido5, mapOrderSolics);
		//NBA_CaseTriggerHandler.updateValuesN3Retencao(caso, pedido1, mapOrderSolics);
		//NBA_CaseTriggerHandler.updateValuesN3Retencao(caso, pedido2, mapOrderSolics);
		//NBA_CaseTriggerHandler.updateValuesN3Retencao(caso, pedido3, mapOrderSolics);
		//NBA_CaseTriggerHandler.updateValuesN3Retencao(caso, pedido4, mapOrderSolics);
		//NBA_CaseTriggerHandler.updateValuesN3Retencao(caso, pedido5, mapOrderSolics);
		Test.stopTest();

		System.assertEquals(NBA_Constants.RESULT_N3_BLINDAGEM, caso.TVN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_BLINDAGEM, caso.PhoneN3Result__c);
		//System.assertEquals(NBA_Constants.N_A, caso.BLN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_BLINDAGEM, caso.MobileN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_BLINDAGEM, caso.TVN3Result__c);

	}

	@IsTest 
	private static void shouldValidateNoOfferException() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Receptivo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.NETFoneMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			insert pedido;

			caso.Order__c = pedido.Id;
			caso.Exceptions__c = NBA_Constants.EXCEPTION_SEM_OFERTAS;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(NBA_Constants.INFORMACOES, caso.TVN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.TVN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.TVN3Result__c);

		System.assertEquals(NBA_Constants.INFORMACOES, caso.BLN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.BLN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.BLN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.PhoneN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);

		System.assertEquals(NBA_Constants.INFORMACOES, caso.MobileN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.MobileN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.MobileN3Result__c);

		System.assertEquals(NBA_Constants.INFORMACOES, caso.ALaCarteN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.ALaCarteN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldValidateNoOfferExceptionActive() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Rentabilizacao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Ativo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.VirtuaMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			insert pedido;

			caso.Order__c = pedido.Id;
			caso.Exceptions__c = NBA_Constants.EXCEPTION_SEM_OFERTAS;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(NBA_Constants.IMPRODUTIVO, caso.TVN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.TVN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.TVN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.BLN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);

		System.assertEquals(NBA_Constants.IMPRODUTIVO, caso.PhoneN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.PhoneN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.PhoneN3Result__c);

		System.assertEquals(NBA_Constants.IMPRODUTIVO, caso.MobileN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.MobileN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.MobileN3Result__c);

		System.assertEquals(NBA_Constants.IMPRODUTIVO, caso.ALaCarteN1Result__c);
		System.assertEquals(NBA_Constants.SEM_OFERTAS, caso.ALaCarteN2Result__c);
		System.assertEquals(NBA_Constants.SISTEMA_INDISPONIVEL, caso.ALaCarteN3Result__c);
	}

	@IsTest
	private static void shouldFilterNbaCases() {
		Account lAccount = NBA_DataFactory_Test.getAccount();

		List<Case> casos = new List<Case>();
		Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Case.getRecordTypeInfosById();

		for (String recordTypeName : recordTypeInfos.keySet()) {
			Case caso = NBA_DataFactory_Test.getCase(lAccount);
			caso.RecordTypeId = recordTypeInfos.get(recordTypeName).getRecordTypeId();
			casos.add(caso);
		}

		System.assertEquals(recordTypeInfos.size(), casos.size());
		
		List<Case> casosNba = NBA_CaseTriggerHandler.filterByNbaCases(casos);

		for (Case casoNba : casosNba) {
			System.assert(casoNba.RecordTypeId == recordTypeIdRetencao || casoNba.RecordTypeId == recordTypeIdRentabilizacao);
		}
	}

	@IsTest 
	private static void shouldTabTotalCancellationProperlyForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Falta de vantagens para Clientes', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
			pedido.VirtuaMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.NETFoneMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.MobileMovement__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
			pedido.ALaCarteMoviment__c = NBA_Constants.MOVIMENTO_CANCELAMENTO;
			insert pedido;

			insert buildDefaultSolic(pedido, 'CANCELAMENTO TOTAL', 'CANCELAMENTO TOTAL', null);

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assert(caso.TotalCancellation__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_RETIDO, caso.TVN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS, caso.TVN2Result__c);
		System.assertEquals(null, caso.TVN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.BLN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.PhoneN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_RETIDO, caso.MobileN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS, caso.MobileN2Result__c);
		System.assertEquals(null, caso.MobileN3Result__c);
		
		System.assertEquals(NBA_Constants.RESULT_N1_NAO_RETIDO, caso.ALaCarteN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldTabWithMixedMovementsProperlyForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = NBA_Constants.MOVIMENTO_MANTIDO;
			pedido.VirtuaMovement__c = NBA_Constants.MOVIMENTO_UPGRADE;
			pedido.NETFoneMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.MobileMovement__c = NBA_Constants.MOVIMENTO_AQUISICAO;
			pedido.ALaCarteMoviment__c = NBA_Constants.MOVIMENTO_NENHUMA;
			insert pedido;

			insert buildDefaultSolic(pedido, NBA_Constants.BL_ASSINATURA, NBA_Constants.BL_ASSINATURA, NBA_Constants.TIPO_OFERTA_EXCLUSIVO);
			insert buildDefaultSolic(pedido, NBA_Constants.MOVEL_ASSINATURA_RPA, NBA_Constants.MOVEL_ASSINATURA_RPA, null);

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(NBA_Constants.RESULT_N1_RETIDO, caso.TVN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA, caso.TVN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.TVN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_RETIDO, caso.BLN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_COM_OFERTA, caso.BLN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_EXCLUSIVA, caso.BLN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.PhoneN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);

		System.assertEquals(NBA_Constants.RESULT_N1_VENDA, caso.MobileN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_COM_OFERTA, caso.MobileN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_PROMOCAO, caso.MobileN3Result__c);
		
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldTabHasNoTvForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);
		
		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.VirtuaMovement__c = null;
			pedido.NETFoneMovement__c = null;
			pedido.MobileMovement__c = null;
			pedido.ALaCarteMoviment__c = null;
			insert pedido;

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.TVN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.TVN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.TVN3Result__c);
		System.assertEquals(null, caso.BLN1Result__c);
		System.assertEquals(null, caso.BLN2Result__c);
		System.assertEquals(null, caso.BLN3Result__c);
		System.assertEquals(null, caso.PhoneN1Result__c);
		System.assertEquals(null, caso.PhoneN2Result__c);
		System.assertEquals(null, caso.PhoneN3Result__c);
		System.assertEquals(null, caso.MobileN1Result__c);
		System.assertEquals(null, caso.MobileN2Result__c);
		System.assertEquals(null, caso.MobileN3Result__c);
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldTabHasNoVirtuaForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = null;
			pedido.VirtuaMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.NETFoneMovement__c = null;
			pedido.MobileMovement__c = null;
			pedido.ALaCarteMoviment__c = null;
			insert pedido;

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(null, caso.TVN1Result__c);
		System.assertEquals(null, caso.TVN2Result__c);
		System.assertEquals(null, caso.TVN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.BLN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.BLN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.BLN3Result__c);
		System.assertEquals(null, caso.PhoneN1Result__c);
		System.assertEquals(null, caso.PhoneN2Result__c);
		System.assertEquals(null, caso.PhoneN3Result__c);
		System.assertEquals(null, caso.MobileN1Result__c);
		System.assertEquals(null, caso.MobileN2Result__c);
		System.assertEquals(null, caso.MobileN3Result__c);
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldTabHasNoPhoneForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = null;
			pedido.VirtuaMovement__c = null;
			pedido.NETFoneMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.MobileMovement__c = null;
			pedido.ALaCarteMoviment__c = null;
			insert pedido;

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(null, caso.TVN1Result__c);
		System.assertEquals(null, caso.TVN2Result__c);
		System.assertEquals(null, caso.TVN3Result__c);
		System.assertEquals(null, caso.BLN1Result__c);
		System.assertEquals(null, caso.BLN2Result__c);
		System.assertEquals(null, caso.BLN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.PhoneN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.PhoneN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.PhoneN3Result__c);
		System.assertEquals(null, caso.MobileN1Result__c);
		System.assertEquals(null, caso.MobileN2Result__c);
		System.assertEquals(null, caso.MobileN3Result__c);
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldTabHasNoMobileForRetencaoProfile() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Retencao' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			Order pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = null;
			pedido.VirtuaMovement__c = null;
			pedido.NETFoneMovement__c = null;
			pedido.MobileMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.ALaCarteMoviment__c = null;
			insert pedido;

			caso.Order__c = pedido.Id;
			update caso;
		}

		caso = getCase(caso.Id);

		System.assertEquals(null, caso.TVN1Result__c);
		System.assertEquals(null, caso.TVN2Result__c);
		System.assertEquals(null, caso.TVN3Result__c);
		System.assertEquals(null, caso.BLN1Result__c);
		System.assertEquals(null, caso.BLN2Result__c);
		System.assertEquals(null, caso.BLN3Result__c);
		System.assertEquals(null, caso.PhoneN1Result__c);
		System.assertEquals(null, caso.PhoneN2Result__c);
		System.assertEquals(null, caso.PhoneN3Result__c);
		System.assertEquals(NBA_Constants.RESULT_N1_NAO_POSSUI, caso.MobileN1Result__c);
		System.assertEquals(NBA_Constants.RESULT_N2_NENHUM, caso.MobileN2Result__c);
		System.assertEquals(NBA_Constants.RESULT_N3_NENHUM, caso.MobileN3Result__c);
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	@IsTest 
	private static void shouldCleanOrder() {
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;

		Case caso = buildDefaultCase(conta, 'Claro_NBA_Retencao', 'Atendimento', NBA_Constants.ENCERRAMENTO);
		Order pedido;

		User atendente = [SELECT Id FROM User WHERE Profile.Name = 'Atendente NBA - Rentabilizacao Receptivo' AND IsActive = true LIMIT 1];
		System.runAs(atendente) {
			insert caso;

			pedido = buildDefaultOrder(caso, conta);
			pedido.TVMovement__c = null;
			pedido.VirtuaMovement__c = null;
			pedido.NETFoneMovement__c = null;
			pedido.MobileMovement__c = NBA_Constants.MOVIMENTO_NENHUMA;
			pedido.ALaCarteMoviment__c = null;
			insert pedido;

			caso.Order__c = pedido.Id;
			update caso;

			caso.Time_of_Service__c = 'Ação';
			update caso;
		}

		caso = getCase(caso.Id);
		System.assertEquals(null, caso.Order__c);

		pedido = [SELECT Id, IsDeleted FROM Order WHERE Id = :pedido.Id ALL ROWS];
		System.assert(pedido.IsDeleted);

		System.assertEquals(null, caso.TVN1Result__c);
		System.assertEquals(null, caso.TVN2Result__c);
		System.assertEquals(null, caso.TVN3Result__c);
		System.assertEquals(null, caso.BLN1Result__c);
		System.assertEquals(null, caso.BLN2Result__c);
		System.assertEquals(null, caso.BLN3Result__c);
		System.assertEquals(null, caso.PhoneN1Result__c);
		System.assertEquals(null, caso.PhoneN2Result__c);
		System.assertEquals(null, caso.PhoneN3Result__c);
		System.assertEquals(null, caso.MobileN1Result__c);
		System.assertEquals(null, caso.MobileN2Result__c);
		System.assertEquals(null, caso.MobileN3Result__c);
		System.assertEquals(null, caso.ALaCarteN1Result__c);
		System.assertEquals(null, caso.ALaCarteN2Result__c);
		System.assertEquals(null, caso.ALaCarteN3Result__c);
	}

	private static List<Case> getCases(List<Case> cases) {
		return	[SELECT Time_of_Service__c, TVN1Result__c, TVN2Result__c, TVN3Result__c, 
						BLN1Result__c, BLN2Result__c, BLN3Result__c, 
						PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, 
						MobileN1Result__c, MobileN2Result__c, MobileN3Result__c,
						ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c
				FROM Case WHERE Id IN :cases];
	}

	private static Case getCase(Id id) {
		return	[SELECT TVN1Result__c, TVN2Result__c, TVN3Result__c, 
						BLN1Result__c, BLN2Result__c, BLN3Result__c, 
						PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, 
						MobileN1Result__c, MobileN2Result__c, MobileN3Result__c,
						ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c,
						TotalCancellation__c, Order__c
				FROM Case WHERE Id = :id LIMIT 1];
	}

	private static Case buildDefaultCase(Account conta, String recordTypeName, String callReason, String timeOfService) {
		Case caso = NBA_DataFactory_Test.getCase(conta);
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
		caso.CallReason__c = callReason;
		caso.Subreason__c = null;
		caso.ProductTV__c = true;
		caso.broadband__c = true;
		caso.Time_of_Service__c = timeOfService;

		return caso;
	}

	private static Order buildDefaultOrder(Case caso, Account conta) {
		Order pedido = new Order();
		pedido.OrderCase__c = caso.Id;
		pedido.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		pedido.AccountId = conta.Id;
		pedido.EffectiveDate = Date.today();
		pedido.Status = 'Draft';

		return pedido;
	}

	private static Solic_NBA__c buildDefaultSolic(Order pedido, String productName, String productType, String tipoOferta) {
		return new Solic_NBA__c(
			Order__c = pedido.Id,
			ProductName__c = productName,
			ProductType__c = productType,
			OfferType__c = tipoOferta
		);
	}
    
	@testSetup
	private static void setup()
	{
		ServiceParameter__c varServiceParameter = NBA_DataFactory_Test.getServiceParameter('OcurrencyNet', 'http://200.169.123.170:9000/corp/contactrecords',
		                                                                                   'POST', 'claro123', 'APP_TESTE');
		insert varServiceParameter;
	}
}