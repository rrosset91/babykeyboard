@IsTest
public with sharing class ContestarItemFuturoControllerTest {
	@testSetup
	static void makeData() {
		List<ServiceParameter__c> services = getTestServiceParameters();
		insert services;

		Account acc = getTestAccount();
		insert acc;

		Case cs = getTestCase(acc.Id, acc.Email__c);
		insert cs;

		vlocity_cmt__PaymentAdjustment__c pmt = getTestPaymentAdjustment(cs.Id, acc.Id);
		insert pmt;

		Parameters__c param = getTestParam();
		insert param;
	}

	@IsTest
	static void getContestationOptionsTest() {
		Test.startTest();
		List<InvoiceDetailsController.ReasonOption> result = ContestarItemFuturoController.getContestationOptions();
		Test.stopTest();
		system.assertEquals(true, result != null);
	}

	@IsTest
	static void performContestationTestApprovationTrue() {
		String contestationString = getMockString();
		System.runAs(getTestUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new SingleMockCallout('', 200));
			ContestarItemFuturoController.performContestation(contestationString, true);
			Test.stopTest();
		}
	}

	@IsTest
	static void performContestationTestApprovationFalse() {
		Test.startTest();
		String contestationString = getMockString();
		ContestarItemFuturoController.performContestation(contestationString, false);
		Test.stopTest();
	}

	@IsTest
	static void setReturnMethodTest() {
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout('', 200));
		Test.startTest();
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;
		ContestarItemFuturoController.denyCase(caseId, 'caseComment');
		ContestarItemFuturoController.setReturnMethod(caseId, 'E-mail');
		Test.stopTest();
	}

	@IsTest
	static void denyCaseTest() {
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout('', 200));
		Test.startTest();
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;
		ContestarItemFuturoController.denyCase(caseId, 'caseComment');
		Test.stopTest();
	}

	/*
	 * v---------------------------------------METODOS PARA GERAR OS DADOS USADOS NOS TESTES-----------------------------------------v
	 *
	 */

	private static String getMockString() {
		String contractNumber = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;
		String mockJSONString =
			'{"operatorCode":"052","contractNumber":"' +
			contractNumber +
			'","caseId":"' +
			caseId +
			'","comment":"test","items":[{"contestationReason":136,"partnerId":1,"originalValue":20.75,"valorContestar":1,"valorCorrigido":19.75,"itemId":596211961,"description":"ALUGUEL EQUIP HABILITADO PROP","note":"test"}],"dpGroup":[{"partnerId":1,"value":0}]}';
		return mockJSONString;
	}

	private static List<ServiceParameter__c> getTestServiceParameters() {
		List<ServiceParameter__c> service = new List<ServiceParameter__c>();
		ServiceParameter__c futureRelease = new ServiceParameter__c();
		futureRelease.name = 'ContestItemFuture';
		futureRelease.EndPoint__c = 'https://api-test.claro.com.br/residential/v1/billingaccounts/contestationfuturereleaseitens';
		futureRelease.Method__c = 'POST';
		futureRelease.Timeout__c = 120000;
		futureRelease.ReturnMock__c = true;
		service.add(futureRelease);

		ServiceParameter__c authority = new ServiceParameter__c();
		authority.name = 'InvoiceAuthority';
		authority.EndPoint__c = 'callout:OAGClaro/invoices/authorityAuthorization';
		authority.Method__c = 'GET';
		authority.Timeout__c = 120000;
		authority.ReturnMock__c = true;
		service.add(authority);

		ServiceParameter__c OAG_NET_SendEmail = new ServiceParameter__c();
		OAG_NET_SendEmail.name = 'OAG_NET_SendEmail';
		OAG_NET_SendEmail.EndPoint__c = '/communicationmanagement/send';
		OAG_NET_SendEmail.Method__c = 'POST';
		OAG_NET_SendEmail.Timeout__c = 120000;
		OAG_NET_SendEmail.IsActive__c = true;
		OAG_NET_SendEmail.User__c = 'MCIDAS';
		OAG_NET_SendEmail.NamedCredential__c = 'OAGClaro';
		OAG_NET_SendEmail.ReturnMock__c = true;
		service.add(OAG_NET_SendEmail);

		return service;
	}

	private static Account getTestAccount() {
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		Account acc = new Account();
		acc.Name = 'Teste';
		acc.RecordTypeId = recordTypeIdAccount;
		acc.ContractReferenceNumber__c = '1027935';
		acc.StatusLegado__c = 'Conectado';
		acc.vlocity_cmt__CustomerValue__c = 'Black';
		acc.Email__c = 'mock@mock.com';
		return acc;
	}

	private static Case getTestCase(String accId, String accEmail) {
		Case caso = new Case();
		caso.AttendanceByUser__c = [SELECT Id FROM User LIMIT 1].Id;
		caso.OpenDateRobot__c = System.now();
		caso.ContractBillingAccount__c = accId;
		caso.Email__c = accEmail;
		caso.Status = 'New';
		caso.Subject = 'Mock Case';
		caso.ProtocolNumber__c = '2233';
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		return caso;
	}

	private static vlocity_cmt__PaymentAdjustment__c getTestPaymentAdjustment(String caseId, String accId) {
		Id recordTypeIdPayment = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get('Itens_Contestados').getRecordTypeId();
		vlocity_cmt__PaymentAdjustment__c pmt = new vlocity_cmt__PaymentAdjustment__c();
		pmt.vlocity_cmt__DisputeId__c = caseId;
		pmt.vlocity_cmt__AccountId__c = accId;
		pmt.vlocity_cmt__Status__c = 'Pending';
		pmt.RecordTypeId = recordTypeIdPayment;
		return pmt;
	}

	private static Parameters__c getTestParam() {
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		return new Parameters__c(Amount__c = 10, Active__c = true, RecordTypeId = recordTypeIdParameter);
	}

	private static UserRole getTestRole() {
		UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		return role;
	}

	private static User getTestUser() {
		User usr = new User();
		usr.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Comunidade_KB' LIMIT 1].Id;
		usr.Username = 'mockusr@mck.com';
		usr.FirstName = 'Mock';
		usr.LastName = 'User';
		usr.Email = 'mock@email.com';
		usr.Alias = 'mckusr';
		usr.TimeZoneSidKey = 'America/Sao_Paulo';
		usr.IsActive = true;
		usr.LocaleSidKey = 'pt_BR';
		usr.EmailEncodingKey = 'UTF-8';
		usr.ProfileId = '00e1H000001SkRMQA0';
		usr.LanguageLocaleKey = 'en_US';
		return usr;
	}
}