@isTest 
private class NBA_CustomAPIOrderServiceRPATest {

	@TestSetup private static void setupMethod(){
		Account acc = new Account();
        acc.Name	= 'Teste';
        insert acc;

		Account acc1	= new Account();
        acc1.Name		= 'Teste - Cancelado';
        insert acc1;
        
        Contract ct		= new Contract();
		ct.AccountId	= acc.Id;
        ct.BL__c		= true;
        insert ct;

		Contract ct1	= new Contract();
		ct1.AccountId	= acc1.Id;
        ct1.BL__c		= true;
		insert ct1;
		
		Account conta = NBA_DataFactory_Test.getAccount();
		insert conta;
        
		Order order			= new Order();
		order.RecordTypeId  = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		order.AccountId		= acc.Id;
		order.Status		= 'Draft';
		order.EffectiveDate = System.today();
		order.ContractId	= ct.Id;
		insert order;

		Order order1			= new Order();
		order1.RecordTypeId     = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
		order1.AccountId		= acc1.Id;
		order1.Status			= 'Draft';
		order1.EffectiveDate	= System.today();
		order1.ContractId		= ct1.Id;
		insert order1;
		
        Case caso = new Case();
		caso.ContractNumber__c = String.valueOf(ct.Id);
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        caso.Order__c = order.Id;
		caso.ProductTV__c = true;
        insert caso;
        
        Case caso1 = new Case();
		caso1.ContractNumber__c = String.valueOf(ct1.Id);
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        caso1.Order__c = order1.Id;
		caso1.ProductTV__c = true;
        insert caso1;   
        
		Solic_NBA__c solic	= new Solic_NBA__c();
		solic.Order__c		= order.Id;
        solic.Status__c		= 'Em processamento';
		insert solic;

		Solic_NBA__c solic1		= new Solic_NBA__c();
		solic1.Order__c			= order1.Id;
		solic1.FullCancel__c	= true;
        solic1.Status__c		= 'Em processamento';
		insert solic1;
    }

	@isTest
	private static void doPost() {
		
		Order ord			= [SELECT Id FROM Order LIMIT 1];
		Solic_NBA__c solic	= [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c FROM Solic_NBA__c LIMIT 1];

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		NBA_CustomAPIOrderServiceRPA.RPA_tasks task				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		task.taskId		= solic.Id;
		task.message	= solic.Message__c;
		task.Status		= solic.Status__c;
        task.executionCode = 'TST0123';
        task.protocolNumber = '0123456878974';
		listTask.add( task );

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertNotEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}

	@isTest
	private static void doPostTaskCancel() {
		
		Order ord			= [SELECT Id FROM Order WHERE Account.Name = 'Teste - Cancelado' LIMIT 1];
		Solic_NBA__c solic	= [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c FROM Solic_NBA__c WHERE Order__c = :ord.Id LIMIT 1];

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		NBA_CustomAPIOrderServiceRPA.RPA_tasks task				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		task.taskId		= solic.Id;
		task.message	= solic.Message__c;
		task.Status		= solic.Status__c;
        task.executionCode = 'TST0123';
        task.protocolNumber = '0123456878974';
		listTask.add( task );

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertNotEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}

	@isTest
	private static void doPostTaskCancelNoTasks() {
		
		Order ord				= new Order();

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order	= new NBA_CustomAPIOrderServiceRPA.RPA_order();

		order.orderId = ord.Id;
		order.tasks   = null;

		System.assertNotEquals(order, null);
		System.assertEquals(order.tasks, null);
		System.assertEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}

	@isTest
	private static void doPostOrderNull() {
		
		Order ord			= new Order();

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask   = new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}

	@isTest
	private static void doPostOrderElse() {
		
		Order ord			= new Order();

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}

	@isTest
	private static void doPostOrderNoTasks() {
		
		Order ord				= new Order();
		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
        RestContext.response	= res;


		NBA_CustomAPIOrderServiceRPA.RPA_order order = new NBA_CustomAPIOrderServiceRPA.RPA_order();

		order.orderId	= ord.Id;
		order.tasks		= null; 

		System.assertNotEquals(order, null);
		System.assertEquals(order.tasks, null);
		System.assertEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		Test.stopTest();
	}
}