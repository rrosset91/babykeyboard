/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-16-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_InvoicesMobileTest {

    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

	@TestSetup
	static void makeData() {

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.BusinessUnit__c = 'Claro';
        contrato.ContractReferenceNumber__c = '12345';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        caso.invoice__c = '244986912';
        insert caso;
    }

    @isTest
	public static void getOpenInvoicesByPeriod() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-01-08", "transactionId": "Id-c409fe5e27ca60097b48cc1e", "data": { "invoices": [ { "invoiceId": "244986912", "statusInvoiceId": "1", "statusInvoiceDescription": "Em Aberto", "dueDate": "2019-08-10", "invoiceAmount": "450.61", "paymentForm": null,"indicatorInvoiceNotPaid":"true" }, { "invoiceId": "243088994", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-07-10", "invoiceAmount": "449.89", "paymentForm": null,"indicatorInvoiceNotPaid":"true" }, { "invoiceId": "241201968", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-06-10", "invoiceAmount": "449.89", "paymentForm": null,"indicatorInvoiceNotPaid":"true" } ] } }',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);
        Case objCase = [SELECT Id, ContractBillingAccount__r.ContractReferenceNumber__c, ContractBillingAccount__r.cityCode__c,invoice__c FROM Case WHERE ContractBillingAccount__r.ExternalID__c = 'Contratot123' LIMIT 1];
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;
		InvoicesWrapper wrp = new InvoicesWrapper();
		wrp.dataBaixa = '';
		wrp.dataPagamento = '';
		wrp.produto = '';

		Test.startTest();
		Map<String, Object> objInvoices = Solar_CrossInvoices_MobileIntegration.getOpenInvoicesByPeriod(objCase, 6, null);
		Test.stopTest();

		System.assertEquals(objInvoices.get('success'), true);
		System.assertEquals(((List<InvoicesWrapper>) objInvoices.get('invoices')).size(), 3);

    }

    @isTest
	public static void getOpenInvoicesByPeriodError() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-01-08", "transactionId": "Id-c409fe5e27ca60097b48cc1e", "data": { "invoices": [ { "invoiceId": "244986912", "statusInvoiceId": "1", "statusInvoiceDescription": "Em Aberto", "dueDate": "2019-08-10", "invoiceAmount": "450.61", "paymentForm": null,"indicatorInvoiceNotPaid":"true" }, { "invoiceId": "243088994", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-07-10", "invoiceAmount": "449.89", "paymentForm": null,"indicatorInvoiceNotPaid":"true" }, { "invoiceId": "241201968", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-06-10", "invoiceAmount": "449.89", "paymentForm": null,"indicatorInvoiceNotPaid":"true" } ] } }',
			400
		);
		Test.setMock(HttpCalloutMock.class, mock);
        Case objCase = [SELECT Id, ContractBillingAccount__r.ContractReferenceNumber__c, ContractBillingAccount__r.cityCode__c,invoice__c FROM Case WHERE ContractBillingAccount__r.ExternalID__c = 'Contratot123' LIMIT 1];
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;
		InvoicesWrapper wrp = new InvoicesWrapper();
		wrp.dataBaixa = '';
		wrp.dataPagamento = '';
		wrp.produto = '';

		Test.startTest();
		Map<String, Object> objInvoices = Solar_CrossInvoices_MobileIntegration.getOpenInvoicesByPeriod(objCase, 6, null);
		Test.stopTest();

		System.assertEquals(objInvoices.get('success'), false);
		//System.assertEquals(((List<InvoicesWrapper>) objInvoices.get('invoices')).size(), 3);

    }
}