@isTest
global with sharing class FinancialMobileGeneralServiceTest {
	@TestSetup
	static void makeData() {
		Account contrato = new Account(
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(),
			name = 'Teste',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black',
			BusinessUnit__c = 'CLARO'
		);
		insert contrato;

		Account cliente = new Account(
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId(),
			name = 'Cliente',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black',
			BusinessUnit__c = 'CLARO',
			ParentId = contrato.Id
		);
		insert cliente;

		Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		Case caso = new Case(ContractBillingAccount__c = contrato.Id, RecordTypeId = recordTypeIdCase);
		insert caso;
	}

	@isTest
	public static void shouldReturnTrueCase() {
		Test.startTest();
		Case cs = [SELECT Id FROM Case LIMIT 1];

		FinancialMobileGeneralService.EntryPointWrapper epw = FinancialMobileGeneralService.getRecordProps(cs.Id);

		System.assertEquals(epw.recordId, cs.Id);
		System.assertEquals(epw.isCase, true);
		System.assertEquals(epw.contractId, '229531991');

		Test.stopTest();
	}

	@isTest
	public static void shouldReturnFalseCase() {
		Test.startTest();
		Account acc = [SELECT Id FROM Account LIMIT 1];

		FinancialMobileGeneralService.EntryPointWrapper epw = FinancialMobileGeneralService.getRecordProps(acc.Id);

		System.assertEquals(epw.recordId, acc.Id);
		System.assertEquals(epw.isCase, false);
		System.assertEquals(epw.contractId, '229531991');

		Test.stopTest();
	}
}