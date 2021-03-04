/**
 * @description       : Classe de teste para a classe FinancialNegotiationInadimplente
 * @author            : Roger Rosset
 * @group             : Financeiro - Negociacao
 * @last modified on  : 22-01-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   22-01-2021   Roger Rosset   Initial Version
 **/
@isTest
public class FinancialNegotiationInadimplenteTest {
	@TestSetup
	static void makeData() {
		ServiceParameter__c setting = new ServiceParameter__c();
		setting = new ServiceParameter__c();
		setting.Token__c = 'returnedToken';
		setting.Name = 'InvoicesPendingItems';
		setting.EndPoint__c = 'https://oagcechomolog.claro.com.br/P06CEC/corp/invoices/pendingitems';
		setting.Method__c = 'GET';
		setting.Timeout__c = 120000;
		insert setting;

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(name = 'Teste Param', Channel__c = 'Atendimento', Process__c = 'Negociação', Profile__c = 'CEC_Backoffice', RecordTypeId = recordTypeIdParameter, Active__c = true, Amount__c = 1000, Business_Division__c = 'Residencial');
		insert parametro;

		Account contrato = AccountDataFactory.getSingleAccount('Billing');
		contrato.ContractReferenceNumber__c = ('229531991');
		contrato.StatusLegado__c = 'Conectado';
		insert contrato;

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
		Account consumer = new Account(DocumentNumber__c = '64204294987', DocumentType__c = 'CPF', Name = 'MassaInadimplencia Residencial - Consumidor', RecordTypeId = consumerRecordType);
		insert consumer;

		Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		Case casoAtual = new Case(AccountId = consumer.id, ContractBillingAccount__c = contrato.id, RecordTypeId = caseRecordType, Subject = 'Caso Atual');
		insert casoAtual;

		List<String> lstPermission = new List<String>();
		lstPermission.add('AttendanceN1');
		lstPermission.add('CEC_Backoffice');
		Map<String, List<sObject>> returnProfileMap = UserDataFactory.getMockUserRoleProfiles('System Administrator', 'SupervisorCRC', lstPermission);
		List<sObject> ps = returnProfileMap.get('permissions');
		List<sObject> role1 = returnProfileMap.get('role');
		List<sObject> profile1 = returnProfileMap.get('profile');

		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(currentUser) {
			User usuario = UserDataFactory.getSingleUser(role1[0].Id, profile1[0].Id, 'dabliudabliudabliu@gmail.com');
			insert usuario;
			insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps[0].Id);
		}
	}

	/**
	 * @description teste do método principal da classe
	 * @author Roger Rosset | 22-01-2021
	 **/
	@isTest
	static void getInvoicesPendingTest() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock());
			String operatorCode = getData('operatorCode');
			String contractNumber = getData('contractNumber');
			Map<String, Object> result = FinancialNegotiationInadimplente.getInvoicesPending(operatorCode, contractNumber);
			System.assertEquals(result.get('success'), true);
			System.debug('@@getInvoicesPending:: result => ' + JSON.serializePretty(result));
			Test.stopTest();
		}
	}

	/**
	 * @description testa a exceção quando nao for passado nenhum parametro
	 * @author Roger Rosset | 22-01-2021
	 **/
	@isTest
	static void getInvoicesPendingMissingAttributesTest() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock());
			String operatorCode = getData('operatorCode');
			String contractNumber = getData('contractNumber');
			try {
				Map<String, Object> result = FinancialNegotiationInadimplente.getInvoicesPending('', '');
			} catch (exception e) {
				Boolean expectedExceptionThrown = e.getMessage().contains('Script-thrown exception') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}

			Test.stopTest();
		}
	}

	/**
	 * @description teste da classe utilizada pra tratamento de erros
	 * @author Roger Rosset | 22-01-2021
	 **/
	@isTest
	static void testErrorMessage() {
		Test.startTest();
		FinancialNegotiationInadimplente.setErrorMessage(getData('errorMock'));
		Test.stopTest();
	}

	private class Mock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HTTPResponse res = new HTTPResponse();
			res.setBody(
				'{"apiVersion":"1;2020-01-27","transactionId":"Id-49cc0a60915579dbefb3e26c","data":{"invoicesItems":[{"hasHistoricRenegotiation":false,"termRenegotiationId":null,"cityId":"08533","contractNumber":"14053010","functionalityRuleId":"10","checkUseItemRenegotiation":"N","enableFirstInstallmentSeparateDebts":"0","migratedCityMessage":"","businessMessage":"Fatura fora do prazo para a retirada de DCC, informar o cliente que deve solicitar a retirada diretamente no banco. Deseja selecionar assim mesmo?","billsValue":"399,10","bills":[{"isMandatory":true,"isEnabled":true,"isOutOfTime":true,"dueDate":"05/01/2020","status":"Em Aberto","paymentMethod":"DEBITO EM CONTA","amount":"399,10","billId":"172648773","charges":[{"partnerName":"EMBRATEL","partnerId":"2","segmentationId":"EMBRATEL","titleNumber":"119928806","generationDate":"06/12/2019","amount":"24,98"},{"partnerName":"NET","partnerId":"1","segmentationId":"NET","titleNumber":"151774668","generationDate":"16/12/2019","amount":"374,12"}]}],"statements":[{"dueDate":"01/01/2020","valueInvoice":"100.10","isMandatory":true,"statementId":"9128918"}]}]}}'
			);
			res.setStatusCode(200);
			return res;
		}
	}

	private static User getTestUser() {
		User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];
		return u;
	}

	private static Case getTestCase() {
		Case cs = [SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1];
		return cs;
	}

	private static String getData(String param) {
		String data;
		switch on param {
			when 'contractNumber' {
				data = '14053010';
				return data;
			}
			when 'operatorCode' {
				data = '011';
				return data;
			}
			when 'errorMock' {
				return '{"apiVersion":"1;2020-01-27","transactionId":"Id-fccb0a6087559e5175c0a4d6","error":{"httpCode":"422","errorCode":"API-PENDINGITEMS-422","message":"Unprocessable Entity","detailedMessage":"Prazo de carência não ultrapassado","link":{"rel":"related","href":"https://oag.claro.com.br/docs/error_codes.html"}}}';
			}
			when else {
				return null;
			}
		}
	}
}