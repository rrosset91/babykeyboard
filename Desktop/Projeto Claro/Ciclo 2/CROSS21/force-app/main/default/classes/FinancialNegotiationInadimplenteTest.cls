@isTest
global class FinancialNegotiationInadimplenteTest {
	@TestSetup
	static void makeData() {
		ServiceParameter__c setting = new ServiceParameter__c();
		setting.Token__c = 'returnedToken';
		setting.Name = 'Invoices';
		setting.EndPoint__c = 'www.google.com';
		setting.Method__c = 'GET';
		setting.Timeout__c = 120000;

		setting = new ServiceParameter__c();
		setting.Token__c = 'returnedToken';
		setting.Name = 'InvoicesPendingItems';
		setting.EndPoint__c = 'www.google.com';
		setting.Method__c = 'GET';
		setting.Timeout__c = 120000;
		insert setting;
	}

	@isTest
	public static void getInvoicesPendingTest() {
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
		try {
			System.runAs(u) {
				inv = FinancialNegotiationInadimplente.getInvoicesPending('125767602', '456789098');
			}
		} catch (exception e) {
		}
		Test.stopTest();

		System.assertEquals(inv.get('success'), null);

		List<FinancialNegotiationInadimplente.BillsWrapper> wppBills = (List<FinancialNegotiationInadimplente.BillsWrapper>) inv.get('bills');
		List<FinancialNegotiationInadimplente.StatementsWrapper> wppStatements = (List<FinancialNegotiationInadimplente.StatementsWrapper>) inv.get('statements');
	}

	/*
   @isTest
   public static void setErrorMessageTest(){
     
		String request = '{"apiVersion":"1;2019-11-06","transactionId":"Id-8fe42a5fed8fd489d07c43b9","error":{"httpCode":"500","errorCode":"API-CONTESTATIONITEMS-500","message":"Internal Server Error","detailedMessage":"EJB Exception: ;","link":{"rel":"related","href":"https://oag.claro.com.br/docs/error_codes.html"}}}';

		Test.startTest();
        try 
        {
		String result = FinancialNegotiatinInadimplente.setErrorMessage(request());
        } catch (Exception e) {}
		Test.stopTest();
    }
   */

	@isTest
	public static void processBillsTest() {
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

		Test.startTest();
		try {
			FinancialNegotiationInadimplente.processBills('456789098');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	public static void processStatementsTest() {
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

		Test.startTest();
		try {
			FinancialNegotiationInadimplente.processStatements('456789098');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	public static void setErrorMessageTest() {
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

		Test.startTest();
		try {
			FinancialNegotiationInadimplente.setErrorMessage('456789098');
		} catch (exception e) {
		}
		Test.stopTest();
	}
}
