/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-07-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-07-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/


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



	@isTest
	public static void hasPermissionSetTest(){
		User varUser = new User();
        varUser.ProfileId = [SELECT Id FROM Profile WHERE name = 'Atendimento Call Center'].Id;
        varUser.FirstName = 'Teste Solar';
        varUser.LastName = 'Teste Solar';
        varUser.Alias = 'Test';
        varUser.Email = 'TesteSolar@teste.com';
        varUser.Username = 'TesteSolar@teste.com';
        varUser.CommunityNickname = 'TesteSolar';
        varUser.LocaleSidKey = 'pt_BR';
        varUser.LanguageLocaleKey = 'pt_BR';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.TimeZoneSidKey = 'America/Sao_Paulo';
		insert varUser;

		User varUser2 = new User();
        varUser2.ProfileId = [SELECT Id FROM Profile WHERE name = 'Atendimento Call Center'].Id;
        varUser2.FirstName = 'Teste Solarr';
        varUser2.LastName = 'Teste Solarr';
        varUser2.Alias = 'Test';
        varUser2.Email = 'TesteSolar3@teste.com';
        varUser2.Username = 'TesteSolar3@teste.com';
        varUser2.CommunityNickname = 'TesteSolar3';
        varUser2.LocaleSidKey = 'pt_BR';
        varUser2.LanguageLocaleKey = 'pt_BR';
        varUser2.EmailEncodingKey = 'UTF-8';
        varUser2.TimeZoneSidKey = 'America/Sao_Paulo';
		insert varUser2;

		PermissionSet permissionResid = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Solar_Cross_ResidentialBusinessUnit' LIMIT 1];
		PermissionSetAssignment permiResid = new PermissionSetAssignment();
		permiResid.AssigneeId = varUser.Id;
		permiResid.PermissionSetId = permissionResid.Id;
		insert permiResid;

		PermissionSet permissionMob = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Solar_Cross_MobileBusinessUnit' LIMIT 1];
		PermissionSetAssignment permiMob = new PermissionSetAssignment();
		permiMob.AssigneeId = varUser2.Id;
		permiMob.PermissionSetId = permissionMob.Id;
		insert permiMob;

		System.runAs(varUser){
			Case cs = [SELECT Id FROM Case LIMIT 1];
			FinancialMobileGeneralService.hasPermissionSet(cs.Id);
		}
		System.runAs(varUser2){
			Case cs = [SELECT Id FROM Case LIMIT 1];
			FinancialMobileGeneralService.hasPermissionSet(cs.Id);
		}

	}
/*
	@isTest
	public static void buttonVisibility(){
		Case cs = [SELECT Id FROM Case LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"billDocumentList":[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]}',422));
        ServiceParameter__c serviceParam = getServiceParameter('callout:OAGClaro/invoices/pendingitems','GET','InvoicesPendingItems');
        insert serviceParam;
		Test.StartTest();
		FinancialMobileGeneralService.getButtonVisibility(cs.Id);
		Test.stopTest();
	}
	*/
    
    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = 'APP_TESTE';
        param.Timeout__c = 120000;
        return param;
    	
     }  


}