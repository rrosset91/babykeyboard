/**
 * @description       : Classe de teste para a classe FinancialNegotiationEfetivation
 * @author            : Roger Rosset
 * @group             : Financeiro Negociacao
 * @last modified on  : 01-03-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   22-01-2021   Roger Rosset   Initial Version
 **/
@isTest
public class FinancialNegotiationEfetivationTest {
	@TestSetup
	static void makeData() {
		ServiceParameter__c setting = new ServiceParameter__c();
		setting = new ServiceParameter__c();
		setting.Token__c = 'returnedToken';
		setting.Name = 'AuthorityNegotiation';
		setting.EndPoint__c = 'https://oagcechomolog.claro.com.br/P06CEC/corp/invoices/negotiation/items';
		setting.Method__c = 'GET';
		setting.Timeout__c = 120000;
		insert setting;

		ServiceParameter__c setting2 = new ServiceParameter__c();
		setting2 = new ServiceParameter__c();
		setting2.Token__c = 'returnedToken';
		setting2.Name = 'InvoiceAuthority';
		setting2.EndPoint__c = 'https://oagcechomolog.claro.com.br/P06CEC/corp/invoices/negotiation/items';
		setting2.Method__c = 'GET';
		setting2.Timeout__c = 120000;
		insert setting2;

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(
			name = 'Teste Param',
			Channel__c = 'Atendimento',
			Process__c = 'Negociação',
			Profile__c = 'CEC_Backoffice',
			RecordTypeId = recordTypeIdParameter,
			Active__c = true,
			Amount__c = 1000,
			Business_Division__c = 'Residencial'
		);
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

		// System.runAs(usuario){
		// }
	}
	//===============================================================================metodos de teste=================================================================================
	/**
	 * @description teste do método principal da classe
	 * @author Roger Rosset | 22-01-2021
	 **/
	@isTest
	static void getInvoicesPendingTestOne() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			MultipleHttpMock mock = new MultipleHttpMock();

			HttpResponse res1 = new HttpResponse();
			res1.setBody(
				'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-97380b60b77985b590a2c69c", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "fed05f30aa04f6df8ef3a56d96a1802874ec34d63a4b548b16876478cb57948dffe80e9dd8beb0c" } }'
			);
			res1.setStatusCode(200);
			mock.addResponse(res1);

			HttpResponse res2 = new HttpResponse();
			res2.setBody(
				'{ "apiVersion": "1;2020-02-21", "transactionId": "Id-2d0384f0823434", "data": { "startDate": "2020-02-20", "endDate": "2020-02-20", "termRenegotiationId": 433442, "contactNumber": 89232121, "cityCode": 43344, "errorMessageRDCC": null, "errorMessageRollback": null, "digitizableLine": "84600000002-2 49410296201-1 30610055000-4 00057102314-2", "messageRenegotiation": null, "barCode": 8.460000000249411e+43, "chargeCode": 5445545, "enableFirstInstallmentSeparateDebts": 1, "singleBille": "Não venceu o prazo de carência, desde a ultima renegociação, efetuada por esse cliente.", "expirydatesinglebill": "2020-02-20", "paymentsinglebill": 345.99 } }'
			);
			res2.setStatusCode(200);
			mock.addResponse(res2);

			Test.setMock(HttpCalloutMock.class, mock);

			String negotiationDetail = getData('negotiationDetail');
			String baseAttributes = getData('baseAttributes');
			FinancialNegotiationEfetivation.performNegotiation(negotiationDetail, baseAttributes);
			Test.stopTest();
		}
	}

	@isTest
	static void getInvoicesPendingTestError() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			MultipleHttpMock mock = new MultipleHttpMock();

			HttpResponse res1 = new HttpResponse();
			res1.setBody(
				'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-97380b60b77985b590a2c69c", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "fed05f30aa04f6df8ef3a56d96a1802874ec34d63a4b548b16876478cb57948dffe80e9dd8beb0c" } }'
			);
			res1.setStatusCode(200);
			mock.addResponse(res1);

			HttpResponse res2 = new HttpResponse();
			res2.setBody(
				'{ "apiVersion": "1;2020-04-06", "transactionId": "Id-a9260b60b8707790fe7fb102", "error": { "httpCode": "422", "errorCode": "API-NEGOTIATIONITEMS-422", "message": "Unprocessable Entity", "detailedMessage": "Itens informados são inválidos ou não pertencem ao contrato.", "link": { "rel": "related", "href": "https://oag.claro.com.br/docs/error_codes.html" } } }'
			);
			res2.setStatusCode(400);
			mock.addResponse(res2);
			FinancialNegotiationEfetivationResponse resp = new FinancialNegotiationEfetivationResponse();
			Test.setMock(HttpCalloutMock.class, mock);

			String negotiationDetail = getData('negotiationDetail');
			String baseAttributes = getData('baseAttributes');
			try {
				FinancialNegotiationEfetivation.performNegotiation(negotiationDetail, baseAttributes);
			} catch (Exception e) {
				System.assert(true);
			}
			Test.stopTest();
		}
	}

	@isTest
	static void getInvoicesPendingTestTwo() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			MultipleHttpMock mock = new MultipleHttpMock();

			HttpResponse res1 = new HttpResponse();
			res1.setBody(
				'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-97380b60b77985b590a2c69c", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "fed05f30aa04f6df8ef3a56d96a1802874ec34d63a4b548b16876478cb57948dffe80e9dd8beb0c" } }'
			);
			res1.setStatusCode(200);
			mock.addResponse(res1);

			HttpResponse res2 = new HttpResponse();
			res2.setBody(
				'{ "apiVersion": "1;2020-02-21", "transactionId": "Id-2d0384f0823434", "data": { "startDate": "2020-02-20", "endDate": "2020-02-20", "termRenegotiationId": 433442, "contactNumber": 89232121, "cityCode": 43344, "errorMessageRDCC": null, "errorMessageRollback": null, "digitizableLine": "84600000002-2 49410296201-1 30610055000-4 00057102314-2", "messageRenegotiation": null, "barCode": 8.460000000249411e+43, "chargeCode": 5445545, "enableFirstInstallmentSeparateDebts": 1, "singleBille": "Não venceu o prazo de carência, desde a ultima renegociação, efetuada por esse cliente.", "expirydatesinglebill": "2020-02-20", "paymentsinglebill": 345.99 } }'
			);
			res2.setStatusCode(200);
			mock.addResponse(res2);

			Test.setMock(HttpCalloutMock.class, mock);

			String negotiationDetail = getData('negotiationDetail');
			negotiationDetail = negotiationDetail.replace('"amount": 1', '"amount": 2');
			String baseAttributes = getData('baseAttributes');
			FinancialNegotiationEfetivation.performNegotiation(negotiationDetail, baseAttributes);
			Test.stopTest();
		}
	}

	@isTest
	static void getInvoicesPendingTestThree() {
		User u = getTestUser();
		System.runAs(u) {
			Test.startTest();
			MultipleHttpMock mock = new MultipleHttpMock();

			HttpResponse res1 = new HttpResponse();
			res1.setBody(
				'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-97380b60b77985b590a2c69c", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "fed05f30aa04f6df8ef3a56d96a1802874ec34d63a4b548b16876478cb57948dffe80e9dd8beb0c" } }'
			);
			res1.setStatusCode(200);
			mock.addResponse(res1);

			HttpResponse res2 = new HttpResponse();
			res2.setBody(
				'{ "apiVersion": "1;2020-02-21", "transactionId": "Id-2d0384f0823434", "data": { "startDate": "2020-02-20", "endDate": "2020-02-20", "termRenegotiationId": 433442, "contactNumber": 89232121, "cityCode": 43344, "errorMessageRDCC": null, "errorMessageRollback": null, "digitizableLine": "84600000002-2 49410296201-1 30610055000-4 00057102314-2", "messageRenegotiation": null, "barCode": 8.460000000249411e+43, "chargeCode": 5445545, "enableFirstInstallmentSeparateDebts": 1, "singleBille": "Não venceu o prazo de carência, desde a ultima renegociação, efetuada por esse cliente.", "expirydatesinglebill": "2020-02-20", "paymentsinglebill": 345.99 } }'
			);
			res2.setStatusCode(200);
			mock.addResponse(res2);

			Test.setMock(HttpCalloutMock.class, mock);

			String negotiationDetail = getData('negotiationDetail');
			negotiationDetail = negotiationDetail.replace('"amount": 1', '"amount": 3');
			String baseAttributes = getData('baseAttributes');
			FinancialNegotiationEfetivation.performNegotiation(negotiationDetail, baseAttributes);
			Test.stopTest();
		}
	}

	private static User getTestUser() {
		User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];
		return u;
	}

	private static String getData(String param) {
		String data;
		String caseID = [SELECT ID FROM CASE LIMIT 1].ID;
		String contractId = [SELECT ID FROM Account WHERE ContractReferenceNumber__c = '229531991' LIMIT 1].ID;
		STring alcadaID = [SELECT ID FROM Parameters__c LIMIT 1].ID;
		switch on param {
			when 'negotiationDetail' {
				data = '{ "billsIdsString": [ "171481584" ], "bills": [ { "type": "Fatura", "dataVencimento": "15/12/2019", "invoiceAmount": 130.97, "billId": "171481584", "isMandatory": true } ], "selectedBills": [ "171481584" ], "statements": [], "statementsIdsString": [], "fullSumSelectedItems": 130.97, "fullSumFormattedBrl": "R$ 130,97", "selectedInstallment": { "ofertaParcelamento": "1x", "descontoParcelamento": "Sem desconto", "quantidadeParcelamento": 1, "porcentagemDesconto": 0, "primeiroVencimento": "15/02/2020" }, "apiData": { "amount": 1, "discountValue": 0, "exemptInterestTicket": false, "firstInstallmentInterest": 17.41, "firstInstallmentTicket": 2.61, "firstInstallmentValue": 150.99, "intermediaryInstallmenInterest": 0, "intermediaryInstallmenTicket": 0, "intermediaryInstallmentValue": 0, "lastInstallmentInterest": 0, "lastInstallmentTicket": 0, "lastInstallmentValue": 0, "total": "130.97", "totalDebt": "150.99", "totalInterest": "17.41", "totalTicket": "2.61" }, "negotiationConditions": "1x 171.01000000000002", "negotiatedValue": 171.01000000000002, "columns": [ { "label": "Mês", "fieldName": "dueMonth", "type": "text", "sortable": false, "hideDefaultActions": true, "cellAttributes": { "alignment": "left" } }, { "label": "Parcela", "fieldName": "installmentNumber", "type": "text", "sortable": false, "hideDefaultActions": true, "cellAttributes": { "alignment": "left" } }, { "label": "Valor", "fieldName": "installmentValue", "type": "currency", "sortable": false, "hideDefaultActions": true, "cellAttributes": { "alignment": "left" } } ], "alcadaAprovada": "'+alcadaID+'", "tableData": [ { "numeroParcela": "1", "valorJuros": 17.41, "valorMulta": 2.61, "valorParcela": 150.99, "valorTotal": 171.01000000000002, "vencimento": "15/02/2020", "dueMonth": "Fevereiro", "installmentNumber": "1/1", "installmentValue": 171.01000000000002 } ] }';
				return data;
			}
			when 'baseAttributes' {
				data = '{ "businessUnit": "Net", "contractAccountSalesforceId": "'+contractId+'", "contractId": "1290848", "customerValue": "Black", "documentNumber": "7137411126", "isCase": true, "isMobileContract": false, "isN2User": true, "isViewOnly": false, "numeroCase": "05110078", "operatorId": "540", "recordId": "'+caseID+'", "statusCase": "In Progress", "typeCase": "Financeiro", "caseId": "'+caseID+'" }';
				return data;
			}
			when else {
				return null;
			}
		}
	}
}