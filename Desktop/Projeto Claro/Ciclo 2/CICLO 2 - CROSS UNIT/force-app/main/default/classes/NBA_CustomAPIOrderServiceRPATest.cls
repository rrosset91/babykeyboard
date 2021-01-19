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
		
		Solic_NBA__c solic	= new Solic_NBA__c();
		solic.Order__c		= order.Id;
		insert solic;

		Solic_NBA__c solic1		= new Solic_NBA__c();
		solic1.Order__c			= order1.Id;
		solic1.FullCancel__c	= true;
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

		List<Solic_NBA__c> solics = [SELECT Id, Order__c FROM Solic_NBA__c];

		for(Solic_NBA__c s : solics) {
			s.Order__c = null;
		}

		update solics;

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

	@IsTest
	private static void shouldUpdateOrderStatusToFail() {
		
		Order ord = [SELECT Id FROM Order LIMIT 1];
		
		Solic_NBA__c solic = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c FROM Solic_NBA__c LIMIT 1];
		solic.Status__c = 'Erro';
		update solic;

		Solic_NBA__c solic2	= new Solic_NBA__c();
		solic2.Order__c = ord.Id;
		solic2.Status__c = 'Concluído';
		insert solic2;

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
		RestContext.response	= res;

		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task.taskId		= solic.Id;
		task.message	= solic.Message__c;
		task.Status		= solic.Status__c;
		listTask.add( task );

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task2				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task2.taskId		= solic.Id;
		task2.message	= solic.Message__c;
		task2.Status		= solic.Status__c;
		listTask.add( task2 );

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertNotEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		ord = [SELECT Status FROM Order WHERE Id = :ord.Id];
		System.assertEquals('Erro', ord.Status);

		Test.stopTest();
	}

	@IsTest
	private static void shouldNotUpdateOrderStatus() {
		
		Order ord = [SELECT Id FROM Order LIMIT 1];
		
		Solic_NBA__c solic = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c FROM Solic_NBA__c LIMIT 1];
		solic.Status__c = 'Em processamento';
		update solic;

		Solic_NBA__c solic2	= new Solic_NBA__c();
		solic2.Order__c = ord.Id;
		solic2.Status__c = 'Concluído';
		insert solic2;

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
		RestContext.response	= res;

		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task.taskId		= solic.Id;
		task.message	= solic.Message__c;
		task.Status		= solic.Status__c;
		listTask.add( task );

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task2				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task2.taskId		= solic.Id;
		task2.message	= solic.Message__c;
		task2.Status		= solic.Status__c;
		listTask.add( task2 );

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertNotEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		ord = [SELECT Status FROM Order WHERE Id = :ord.Id];
		System.assertEquals('Draft', ord.Status);

		Test.stopTest();
	}

	@IsTest
	private static void shouldUpdateOrderStatusToCompleted() {
		
		Order ord = [SELECT Id FROM Order LIMIT 1];
		
		Solic_NBA__c solic = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c FROM Solic_NBA__c LIMIT 1];
		solic.Status__c = 'Concluído';
		update solic;

		Solic_NBA__c solic2	= new Solic_NBA__c();
		solic2.Order__c = ord.Id;
		solic2.Status__c = 'Concluído';
		insert solic2;

		Test.startTest();

        RestRequest req			= new RestRequest(); 
        RestResponse res		= new RestResponse();
		req.requestURI			= '/api/updateTasks';
		req.httpMethod			= 'POST';
        RestContext.request		= req;
		RestContext.response	= res;

		NBA_CustomAPIOrderServiceRPA.RPA_order order			= new NBA_CustomAPIOrderServiceRPA.RPA_order();
		List<NBA_CustomAPIOrderServiceRPA.RPA_tasks> listTask	= new List<NBA_CustomAPIOrderServiceRPA.RPA_tasks>();

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task.taskId		= solic.Id;
		task.message	= solic.Message__c;
		task.Status		= solic.Status__c;
		listTask.add( task );

		NBA_CustomAPIOrderServiceRPA.RPA_tasks task2				= new NBA_CustomAPIOrderServiceRPA.RPA_tasks();
		task2.taskId		= solic.Id;
		task2.message	= solic.Message__c;
		task2.Status		= solic.Status__c;
		listTask.add( task2 );

		order.orderId = ord.Id;
		order.tasks   = listTask;

		System.assertNotEquals(order, null);
		System.assertNotEquals(order.tasks, null);
		System.assertNotEquals(order.orderId, null);

		NBA_CustomAPIOrderServiceRPA.doPost( order );

		ord = [SELECT Status FROM Order WHERE Id = :ord.Id];
		System.assertEquals('Concluído', ord.Status);

		Test.stopTest();
	}

}