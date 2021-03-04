/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 28-01-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
**/
@isTest 
public class LancamentosFuturosControllerTest {
	
	@TestSetup 
	static void makeData(){

		Account acc = AccountDataFactory.getSingleAccount('Billing');
		acc.ContractReferenceNumber__c = '001027935';
		acc.StatusLegado__c  =  'Conectado';
		acc.vlocity_cmt__CustomerValue__c = 'Black';
		insert acc;

        Case cs = CaseDataFactory.getSingleCase('Financial', acc.Id);
		insert cs;
		
		Vlocity_cmt__PaymentAdjustment__c paymentAdjustment = PaymentAdjustmentDataFactory.getSinglePaymentAdjustment('Itens_Contestados', cs.Id, acc.Id);
		paymentAdjustment.vlocity_cmt__Status__c = 'Pending';
		insert paymentAdjustment;
		
        ServiceParameter__c historySettings = new ServiceParameter__c();
        historySettings.name = 'futureReleaseAttributes';
        historySettings.EndPoint__c = 'https://api-test.claro.com.br/residential/v1/billingaccounts/contestationfuturereleaseitens';
        historySettings.Method__c = 'GET';
        historySettings.Timeout__c = 120000;
        insert historySettings;	
	}
	
	@isTest 
	static void getCasedetailsTest(){
		Case cs = [SELECT Id FROM Case LIMIT 1];
		
        Test.startTest();
        List<vlocity_cmt__PaymentAdjustment__c> paymentAdjustment = LancamentosFuturosController.getCasedetails(cs.Id);
		Test.stopTest();
		
		System.assertNotEquals(null, paymentAdjustment);
		System.assertEquals(1, paymentAdjustment.size());
    }
    
	@isTest 
	static void getHistoryByDatePeriodFailTest(){
        Integer period = 24;
        Date startDate = Date.newInstance(2018, 09, 11);
		Date endDate = Date.newInstance(2020, 09, 10);
		
		Test.setMock(HttpCalloutMock.class, new MockFail());
		
		Test.startTest();
		Map<String, Object> result = LancamentosFuturosController.getHistoryByDatePeriod('1027935', '038','FUTURE_RELEASE', period, startDate, endDate, null);
    	Test.stopTest();
		
		System.assertEquals(false, result.get('success'));
    }
    
	@isTest 
	static void getHistoryByDatePeriodSuccessTest() {

        Integer period = 24;
        Date startDate = Date.newInstance(2018, 09, 11);
		Date endDate = Date.newInstance(2020, 09, 10);


			Test.setMock(HttpCalloutMock.class, new MockSuccess());

			Test.startTest();
			Map<String, Object> result = LancamentosFuturosController.getHistoryByDatePeriod('1027935','038','MOCK_FUTURE_RELEASE', period, startDate, endDate, null);
			Test.stopTest();


			System.assertEquals(true, result.get('success'));
    }
	
	private class MockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"data":{"totalCount":5,"operatorCode":"052","contractNumber":"13979740","userName":"MCIDA","installments":[{"idExtractItem":840208934,"descriptionExtractItem":"JUROS PGTO EM ATRASO","idExtractItemType":33,"itemDescriptionType":"JUROS PGTO EM ATRASO","allowContestation":true,"idInvoiceGroupDemo":25,"idItemExtractComboSva":null,"releaseDate":"2019-02-11","dueDate":"2049-12-30","value":1,"sourceValue":1.52,"contestationReasonTypes":[{"contestationReasonId":12,"contestationDescription":"N REC COBR/ PGTO NO VENC"},{"contestationReasonId":15,"contestationDescription":"FRAUDE"},{"contestationReasonId":7,"contestationDescription":"CANCEL DENTRO DE 7 DIAS"},{"contestationReasonId":3,"contestationDescription":"PROD/SERV N CONTRATADO"},{"contestationReasonId":5,"contestationDescription":"COBRANCA EM DUPLICIDADE"}],"descriptionInvoiceGroupDemo":"Encargos/Juros/Multas"},{"idExtractItem":840208935,"descriptionExtractItem":"MULTA","idExtractItemType":34,"itemDescriptionType":"MULTA ","allowContestation":true,"idInvoiceGroupDemo":25,"idItemExtractComboSva":null,"releaseDate":"2019-02-11","dueDate":"2049-12-30","value":1,"sourceValue":1.84,"contestationReasonTypes":[{"contestationReasonId":5,"contestationDescription":"COBRANCA EM DUPLICIDADE"},{"contestationReasonId":12,"contestationDescription":"N REC COBR/ PGTO NO VENC"},{"contestationReasonId":15,"contestationDescription":"FRAUDE"},{"contestationReasonId":7,"contestationDescription":"CANCEL DENTRO DE 7 DIAS"},{"contestationReasonId":3,"contestationDescription":"PROD/SERV N CONTRATADO"}],"descriptionInvoiceGroupDemo":"Encargos/Juros/Multas"},{"idExtractItem":1010682034,"descriptionExtractItem":"ESTORNO MULTA E JUROS","idExtractItemType":122,"itemDescriptionType":"ESTORNO MULTA E JUROS","allowContestation":false,"idInvoiceGroupDemo":25,"idItemExtractComboSva":null,"releaseDate":"2019-12-06","dueDate":"2049-12-30","value":0,"sourceValue":-1,"contestationReasonTypes":[],"descriptionInvoiceGroupDemo":"Encargos/Juros/Multas"},{"idExtractItem":1010682035,"descriptionExtractItem":"ESTORNO MULTA E JUROS","idExtractItemType":122,"itemDescriptionType":"ESTORNO MULTA E JUROS","allowContestation":false,"idInvoiceGroupDemo":25,"idItemExtractComboSva":null,"releaseDate":"2020-09-04","dueDate":"2049-12-30","value":0,"sourceValue":-1,"contestationReasonTypes":[],"descriptionInvoiceGroupDemo":"Encargos/Juros/Multas"},{"idExtractItem":1010682040,"descriptionExtractItem":"DESCONTO DE MENSALIDADE","idExtractItemType":831,"itemDescriptionType":"DESCONTO DE MENSALIDADE","allowContestation":false,"idInvoiceGroupDemo":28,"idItemExtractComboSva":null,"releaseDate":"2020-09-10","dueDate":"2020-09-10","value":0,"sourceValue":-3.5,"contestationReasonTypes":[],"descriptionInvoiceGroupDemo":"Descontos/Cancelamentos"}]}}');
            res.setStatusCode(200);
            return res;
        }
	}
	
	private class MockFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{ "apiVersion": "1", "transactionId": "969932de-059c-4605-9143-478b59abe0a1", "error": { "httpCode": "422", "errorCode": "API-CUSTOMERSFINANCIALACC-422", "message": "Unprocessable Entity", "detailedMessage": "Backend: [filtered exception]", "link": { "rel": "related", "href": "https://api.claro.com.br/docs" } } }');
            res.setStatusCode(422);
            return res;
        }
    }
}