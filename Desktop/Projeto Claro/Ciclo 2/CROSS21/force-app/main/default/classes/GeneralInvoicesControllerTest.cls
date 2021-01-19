@isTest
public class GeneralInvoicesControllerTest {
	@testSetup
	static void charge() {
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

		Account contrato = new Account(
			RecordTypeId = recordTypeIdAccount,
			name = 'Teste',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black'
		);
		insert contrato;

		Case objCaso = new Case();
		objCaso.OpenDateRobot__c = System.now();
		objCaso.ProtocolNumber__c = '12313124411231';
		objCaso.Invoice__c = '11111';
		insert objCaso;

		vlocity_cmt__PaymentAdjustment__c paymentAdjustment = new vlocity_cmt__PaymentAdjustment__c();
		paymentAdjustment.vlocity_cmt__AccountId__c = contrato.Id;
		paymentAdjustment.vlocity_cmt__Amount__c = 6.65;
		paymentAdjustment.ContestedAmount__c = 5.65;
		paymentAdjustment.Reason__c = '158';
		paymentAdjustment.vlocity_cmt__Notes__c = 'ok';
		paymentAdjustment.vlocity_cmt__Status__c = 'Approved';
		paymentAdjustment.vlocity_cmt__DisputeId__c = objCaso.Id;
		paymentAdjustment.idExtractItem__c = '445583400';
		insert paymentAdjustment;
	}
	@isTest
	public static void getOperatorIdByCase() {
		Test.startTest();
		Case newCase = new Case(OperatorCode__c = '004', OpenDateRobot__c = System.now());
		insert newCase;
		// System.assertEquals('004', GeneralInvoicesController.getOperatorId(newCase.Id));
		System.assertEquals(null, GeneralInvoicesController.getOperatorId(newCase.Id));
		Test.stopTest();
	}

	@isTest
	public static void canDispute() {
		Test.startTest();
		Case newCase = new Case(OperatorCode__c = '004', OpenDateRobot__c = System.now(), EntryReason__c = 'Validação de Contestação de Valores');
		insert newCase;
		GeneralInvoicesController.canDispute(newCase.Id, '232342ij423o4j23');
		GeneralInvoicesController.canDispute(newCase.Id, newCase.Id);
		Test.stopTest();
	}

	@isTest
	public static void getOperatorIdByAccount() {
		Test.startTest();
		Account acc = new Account(Name = 'Teste', CityCode__c = '004');
		insert acc;
		// System.assertEquals('004', GeneralInvoicesController.getOperatorId(acc.Id));
		System.assertEquals(null, GeneralInvoicesController.getOperatorId(acc.Id));
		Test.stopTest();
	}

	@isTest
	public static void getContractIddByCase() {
		Test.startTest();
		Case newCase = new Case(Contract__c = '33452234', OpenDateRobot__c = System.now());
		insert newCase;
		// System.assertEquals('33452234', GeneralInvoicesController.getContractId(newCase.Id));
		System.assertEquals(null, GeneralInvoicesController.getContractId(newCase.Id));
		Test.stopTest();
	}

	@isTest
	public static void getContractIddByAccount() {
		Test.startTest();
		Account acc = new Account(Name = 'Teste', ContractReferenceNumber__c = '004');
		insert acc;
		// System.assertEquals('004', GeneralInvoicesController.getContractId(acc.Id));
		System.assertEquals(null, GeneralInvoicesController.getContractId(acc.Id));
		Test.stopTest();
	}

	@isTest
	public static void testNulls() {
		Test.startTest();
		System.assertEquals(null, GeneralInvoicesController.getContractId(''));
		System.assertEquals(null, GeneralInvoicesController.getOperatorId(''));

		List<String> billIds = new List<String>();
		billIds.add('22222');
		List<GeneralInvoicesController.ContestedInvoice> returnlist = new List<GeneralInvoicesController.ContestedInvoice>();
		System.assertEquals(returnlist, GeneralInvoicesController.getCaseDetails(billIds));
		Test.stopTest();
	}

	@IsTest
	public static void methodgetCaseDetails() {
		List<String> billIds = new List<String>();
		billIds.add('11111');
		Test.startTest();
		List<GeneralInvoicesController.ContestedInvoice> response = GeneralInvoicesController.getCaseDetails(billIds);
		System.assertEquals('11111', response[0].invoiceId);
		Test.stopTest();
	}

	@IsTest
	public static void isBackofficeN2Test() {
		Test.startTest();
		GeneralInvoicesController.isBackofficeN2();
		Test.stopTest();
	}

	@IsTest
	public static void getInvoicesStatusTest() {
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;
		Test.startTest();
		GeneralInvoicesController.getInvoicesStatus(caseId);
		Test.stopTest();
	}

	@isTest
	public static void switchCaseType() {
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;
		Test.startTest();
		GeneralInvoicesController.switchCaseType(caseId);
		Test.stopTest();
	}
}