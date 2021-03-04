/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :

 * @last modified on  : 18-12-2020
 * @last modified by  : Diego Almeida

 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   16-11-2020   Diego Almeida   Initial Version
**/

@isTest
global class FinancialMobileInvoicesTest {

    @TestSetup
    static void makeData(){
        ServiceParameter__c setting = new ServiceParameter__c();
            setting.Token__c = 'returnedToken';
            setting.Name = 'Invoices';
            setting.EndPoint__c = 'www.google.com';
            setting.Method__c = 'GET';
            setting.Timeout__c = 120000;

            setting = new ServiceParameter__c();
            setting.Token__c = 'returnedToken';
            setting.Name = 'MobileInvoicesPaymentHistories';
            setting.EndPoint__c = 'www.google.com';
            setting.Method__c = 'GET';
            setting.Timeout__c = 120000;
        insert setting;
    }


	@isTest
	public static void getOpenInvoicesManualPeriodTest() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion" : "1;2019-01-08", "transactionId" : "Id-b189d25faaa131c296dd40ad", "data" : { "invoices" : [ { "referenceMonth" : "9", "referenceYear" : "2014", "startDate" : "2014-08-24-03:00", "endDate" : "2014-09-23-03:00", "issuanceDate" : "2014-09-24-03:00", "documentNumber" : "5", "noteFiscalNumber" : "125767602005", "dueDate" : "2014-10-10-03:00", "indicatorInvoiceNotPaid" : "false", "indicatorSuspensionCauses" : "false", "invoiceAmount" : "19.49", "amountPaymentMade" : "0.0", "amountAdjustmentMade" : "0.0", "amountPreviousBalance" : "377.14", "amountAfterBalance" : "396.63", "amountPrincipal" : "19.49", "amountPrincipalPaymentMade" : "19.49" }] } }',
			200
		);

		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;

		User u = new User(Id = UserInfo.getUserId());
		Map<String, Object> inv = new Map<String, Object>();

		Test.startTest();
		System.runAs(u) {
			inv = FinancialMobileInvoices.getOpenInvoicesManualPeriod('125767602', Date.newInstance(2000, 11, 2), Date.newInstance(2020, 11, 8));
		}
		Test.stopTest();

		System.assertEquals(inv.get('success'), true);

		List<FinancialMobileInvoices.MobileInvoicesWrapper> wrp = (List<FinancialMobileInvoices.MobileInvoicesWrapper>) inv.get('invoices');

		System.assertEquals(wrp[0].noteFiscalNumber, 125767602005L);
	}

	@isTest
	public static void getOpenInvoicesByPeriodTest() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion" : "1;2019-01-08", "transactionId" : "Id-b189d25faaa131c296dd40ad", "data" : { "invoices" : [ { "referenceMonth" : "9", "referenceYear" : "2014", "startDate" : "2014-08-24-03:00", "endDate" : "2014-09-23-03:00", "issuanceDate" : "2014-09-24-03:00", "documentNumber" : "5", "noteFiscalNumber" : "125767602005", "dueDate" : "2014-10-10-03:00", "indicatorInvoiceNotPaid" : "false", "indicatorSuspensionCauses" : "false", "invoiceAmount" : "19.49", "amountPaymentMade" : "0.0", "amountAdjustmentMade" : "0.0", "amountPreviousBalance" : "377.14", "amountAfterBalance" : "396.63", "amountPrincipal" : "19.49", "amountPrincipalPaymentMade" : "19.49" }] } }',
			200
		);

		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;

		User u = new User(Id = UserInfo.getUserId());
		Map<String, Object> inv = new Map<String, Object>();

		Test.startTest();
		System.runAs(u) {
			inv = FinancialMobileInvoices.getOpenInvoicesByPeriod('125767602', 6);
		}
		Test.stopTest();

		System.assertEquals(inv.get('success'), true);

		List<FinancialMobileInvoices.MobileInvoicesWrapper> wrp = (List<FinancialMobileInvoices.MobileInvoicesWrapper>) inv.get('invoices');

		System.assertEquals(wrp[0].noteFiscalNumber, 125767602005L);
	}

	@isTest
	public static void getOpenErrorTest() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion" : "1;2019-01-08", "transactionId" : "Id-c491d25f66a4703b8d531ceb", "error" : { "httpCode" : "500", "errorCode" : "API-INVOICE-011", "message" : "Internal Server Error", "detailedMessage" : "TE-0500 - org.apache.xmlbeans.impl.values.XmlValueOutOfRangeException: Invalid date value: wrong type: 324242", "link" : { "rel" : "related", "href" : "https://oag.claro.com.br/docs/error_codes.html" } } }',
			500
		);

		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'GET';
		customSetting.Timeout__c = 120;
		insert customSetting;

		User u = new User(Id = UserInfo.getUserId());
		Map<String, Object> inv = new Map<String, Object>();

		Test.startTest();
		inv = FinancialMobileInvoices.getOpenInvoicesByPeriod('125767602', 6);
		Test.stopTest();

		System.assertEquals(inv.get('success'), false);

	}

    @isTest
	public static void getInvoiceDetailTest() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion" : "1;2019-01-08", "transactionId" : "Id-b189d25faaa131c296dd40ad", "data" : { "invoices" : {"invoice" : { "invoiceNumber":"108683917001", "referenceMonth" : "9", "referenceYear" : "2014", "startDate" : "2014-08-24-03:00", "endDate" : "2014-09-23-03:00", "issuanceDate" : "2014-09-24-03:00", "documentNumber" : "5", "noteFiscalNumber" : "125767602005", "paymentDate":"2014-10-10","dueDate" : "2014-10-10-03:00", "indicatorInvoiceNotPaid" : "false", "indicatorSuspensionCauses" : "false", "invoiceAmount" : "19.49", "paymentAmount" : "19.49", "amountPaymentMade" : "0.0", "amountAdjustmentMade" : "0.0", "amountPreviousBalance" : "377.14", "amountAfterBalance" : "396.63", "amountPrincipal" : "19.49", "amountPrincipalPaymentMade" : "19.49" } } }}',
			200
        );
        String selectedInvoiceString = '{"billDate":"2018-12-20","formatAmount":"R$ 23.58","formatDueDate":"12/01/2019","formatIsContested":"Não Contestado","isInvoiceNotPaid":true,"noteFiscalNumber":108683917001,"product":"Não definido","rawAmount":23.58,"rawDueDate":"2019-01-12","rawIsContested":false,"status":"Em Aberto","type":"Não definido"}';


        Test.setMock(HttpCalloutMock.class, mock);


        Test.startTest();
            MobileInvoiceWrapper.ResponsePaymentWrapper request = FinancialMobileInvoices.getInvoiceDetail('123456789', selectedInvoiceString);
            System.debug('getInvoiceDetailTest: '+request);
		Test.stopTest();

		System.assertEquals(request.responseData.noteFiscalNumber, '108683917001');
	}



}