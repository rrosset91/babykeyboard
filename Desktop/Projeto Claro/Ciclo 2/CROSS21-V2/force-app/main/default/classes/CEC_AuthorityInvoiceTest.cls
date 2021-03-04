/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 04-02-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-01-2021   Joao Neves   Initial Version
 **/
@isTest
public class CEC_AuthorityInvoiceTest {
	@TestSetup
	static void makeData() {
		Account contrato = AccountDataFactory.getSingleAccount('Billing');
		contrato.ContractReferenceNumber__c = ('229531991');
		contrato.StatusLegado__c = 'Conectado';
		contrato.CityCode__c = '004';
		insert contrato;
		system.debug('@@@@ contrato: ' + contrato);

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
		Account consumer = new Account(DocumentNumber__c = '64204294987', DocumentType__c = 'CPF', Name = 'MassaInadimplencia Residencial - Consumidor', RecordTypeId = consumerRecordType);
		insert consumer;

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'ContestationItem';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;

		ServiceParameter__c serviceParameter = new ServiceParameter__c();
		serviceParameter.name = 'InvoiceAuthority';
		serviceParameter.EndPoint__c = '00';
		serviceParameter.Method__c = 'GET';
		serviceParameter.Timeout__c = 120;
		insert serviceParameter;

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(
			name = 'Teste Param',
			RecordTypeId = recordTypeIdParameter,
			Active__c = true,
			Channel__c = 'Atendimento',
			Amount__c = 100,
			Business_Division__c = 'Residencial'
		);
		insert parametro;
	}

	static void setupGetMock() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/api/DisputeInvoice/*';

		req.httpMethod = 'Get';
		RestContext.request = req;
		RestContext.response = res;
	}

	@isTest
	static void disputeInvoiceOk() {
		setupGetMock();
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2020-04-03", "transactionId": "Id-995f135fef07d962a358d99d", "data": { "returnCode": "0", "returnMessage": "Valor dentro do limite de alçada", "authorized": true, "hashAuthority": "f3e1e2a58cd3960bfbe193c4c2c19de76457f9ef13675b118aa90f743e6dd992956a19efcd40f0c" } }',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
		CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
		invoiceItems.idInvoiceItem = '1579031159';
		invoiceItems.idGroupItem = '1';
		invoiceItems.reason = '1';
		invoiceItems.partnerId = '3';
		invoiceItems.originalValue = 2.42;
		invoiceItems.wishedValue = 2.42;
		invoiceItems.disputePercentage = 5;
		invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
		invoiceItems.notes = 'Observação da contestação';
		invoiceItems.status = 'EM ABERTO';
		lst.add(invoiceItems);

		CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
		entrada.contractNumber = '229531991';
		entrada.operatorCode = '004';
		entrada.channel = 'L';
		entrada.idInvoice = '245961436';
		entrada.userName = 'MCIDA';
		entrada.source = 1;
		entrada.type = 'R';
		entrada.invoiceItems = lst;
		CEC_AuthorityInvoice.authorityInvoice(entrada);
		Test.stopTest();

		System.assertNotEquals(null, entrada);
	}

	@isTest
	static void disputeInvoiceMissingProperties() {
		setupGetMock();

		Test.startTest();
		CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
		CEC_AuthorityInvoice.authorityInvoice(entrada);
		Test.stopTest();

		System.assertEquals(null, null);
	}
}