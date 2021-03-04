/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 08-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   03-12-2020   Diego Almeida   Initial Version
**/
@IsTest
global class FinancialHierarchyTest {
	@TestSetup
	static void makeData() {
		List<String> lstPermission = new List<String>();
		lstPermission.add('AttendanceN1');
		Map<String, List<sObject>> returnProfileMap = UserDataFactory.getMockUserRoleProfiles('System Administrator', 'SupervisorCRC', lstPermission);
		List<sObject> ps = returnProfileMap.get('permissions');
		List<sObject> role1 = returnProfileMap.get('role');
		List<sObject> profile1 = returnProfileMap.get('profile');

		//current user
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//force to avoid mixed dml error
		System.runAs(currentUser) {
			User usuario = UserDataFactory.getSingleUser(role1[0].Id, profile1[0].Id, 'dabliudabliudabliu@gmail.com');
			insert usuario;
			insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps[0].Id);
		}

		Account contrato = AccountDataFactory.getSingleAccount('Billing');
			contrato.ContractReferenceNumber__c = ('229531991');
			contrato.StatusLegado__c = 'Conectado';
		insert contrato;
		system.debug('@@@@ contrato: ' + contrato);

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
		Account consumer = new Account(
			DocumentNumber__c = '64204294987',
			DocumentType__c = 'CPF',
			Name = 'MassaInadimplencia Residencial - Consumidor',
			RecordTypeId = consumerRecordType
		);
		insert consumer;

		Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		Case casoAtual = new Case(
			AccountId = consumer.id,
			ContractBillingAccount__c = contrato.id,
			RecordTypeId = caseRecordType,
			Subject = 'Caso Atual'
		);
		insert casoAtual;

		List<String> lstParameters = new List<String>();
		lstParameters.add('InvoiceAuthority');

		List<ServiceParameter__c> lstService = ServiceParameterDataFactory.getMockServiceParameters(lstParameters);

		insert lstService;
		system.debug('@@@@ lstService: ' + lstService);

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(
			name = 'Teste Param',
			RecordTypeId = recordTypeIdParameter,
			Active__c = true,
			ContractStatus__c = 'Conectado',
			Channel__c = 'Atendimento',
			ItemType__c = 'MENSALIDADE TV PRINCIPAL',
			ItemQtt__c = 1.0,
			Profile__c = 'CEC_Backoffice',
			Segment__c = 'BLACK',
			Amount__c = 100,
			Business_Division__c = 'Residencial',
			AnatelProconProneTargeting__c = '1;2;3;4;5;6;7;8;9;10',
			DefaultTargeting__c = 'MÉDIO'
		);
		insert parametro;

		parametro = new Parameters__c(
				name = 'Teste Param',
				Channel__c = 'Atendimento',
				RecordTypeId = recordTypeIdParameter,
				Active__c = true,
				Amount__c = 1000,
				Business_Division__c = 'Residencial'
		);
		insert parametro;
		system.debug('@@@@ parametro: ' + parametro);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'InvoiceAuthority';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;

		insert customSetting;

		//**US105985
		customSetting = new ServiceParameter__c();
		customSetting.name = 'CustomerProconPropensity';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;

		insert customSetting;

		customSetting = new ServiceParameter__c();
		customSetting.name = 'CustomerDefaultSegmetation';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;

		insert customSetting;
		//**US105985

	}

	@isTest
	global static void getAuthority() {
		User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u) {
			InvoiceDetailsMock mock = new InvoiceDetailsMock(
				'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-995f135fef07d962a358d99d", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "f3e1e2a58cd3960bfbe193c4c2c19de76457f9ef13675b118aa90f743e6dd992956a19efcd40f0c" } }',
				200
			);
			Test.setMock(HttpCalloutMock.class, mock);
			String contract = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
			Id casoAtualId =[SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1].Id;

			List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
			CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
			invoiceItems.idInvoiceItem = '1579031159';
			invoiceItems.idGroupItem = '1';
			invoiceItems.reason = '1';
			invoiceItems.originalValue = 308.42;
			invoiceItems.ItemDescription = 'MENSALIDADE TV PRINCIPAL';
			invoiceItems.wishedValue = 15.42;
			invoiceItems.disputePercentage = 5;
			invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
			invoiceItems.notes = 'Observação da contestação';
			invoiceItems.status = 'EM ABERTO';
			lst.add(invoiceItems);

			CEC_DisputeInvoice.DisputeInvoiceRequest invoice = new CEC_DisputeInvoice.DisputeInvoiceRequest();
			invoice.contractNumber = '229531991';
			invoice.operatorCode = '004';
			invoice.channel = 'L';
			invoice.idInvoice = '245961436';
			invoice.userName = 'MCIDA';
			invoice.source = 1;
			invoice.type = 'R';
			invoice.invoiceItems = lst;
			invoice.caseId = casoAtualId;

			Test.startTest();
			FinancialService.getAuthority(invoice, '004', '229531991', null, 10, null, '74226094');
			Test.stopTest();
		}
	}

	@isTest
	global static void getAuthError() {
		User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u) {
			InvoiceDetailsMock mock = new InvoiceDetailsMock(
				'{"apiVersion": "1;2019-11-06","transactionId": "Id-d7b2635f8bf4aa2bf00f0f0e","error": {"httpCode": "422","errorCode": "API-CONTESTATIONITEMS-422","message": "Unprocessable Entity","detailedMessage" : "teste"}}',
				423
			);
			Test.setMock(HttpCalloutMock.class, mock);
			String contract = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
			Id casoAtualId =[SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1].Id;


			List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
			CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
			invoiceItems.idInvoiceItem = '1579031159';
			invoiceItems.idGroupItem = '1';
			invoiceItems.reason = '1';
			invoiceItems.originalValue = 308.42;
			invoiceItems.ItemDescription = 'MENSALIDADE TV PRINCIPAL';
			invoiceItems.wishedValue = 15.42;
			invoiceItems.disputePercentage = 5;
			invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
			invoiceItems.notes = 'Observação da contestação';
			invoiceItems.status = 'EM ABERTO';
			lst.add(invoiceItems);

			CEC_DisputeInvoice.DisputeInvoiceRequest invoice = new CEC_DisputeInvoice.DisputeInvoiceRequest();
			invoice.contractNumber = '229531991';
			invoice.operatorCode = '004';
			invoice.channel = 'L';
			invoice.idInvoice = '245961436';
			invoice.userName = 'MCIDA';
			invoice.source = 1;
			invoice.type = 'R';
			invoice.caseId = casoAtualId;
			invoice.invoiceItems = lst;

			Test.startTest();
			FinancialService.getAuthority(invoice, '004', '229531991', null, 10, null, '74226094');
			Test.stopTest();
		}
	}
}