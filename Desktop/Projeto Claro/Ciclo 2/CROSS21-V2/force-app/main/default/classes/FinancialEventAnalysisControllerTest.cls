/**
 * @description       : Classe de testes da classe FinancialEventAnalysisController
 * @author            : Felipe Ducheiko
 * @group             : 
 * @last modified on  : 24-02-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   10-02-2021   Felipe Ducheiko   Initial Version
**/
@isTest
public class FinancialEventAnalysisControllerTest {

	@TestSetup
	static void makeData(){
		configureServices();

		Id recordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AutomaticDiagnostics').getRecordTypeId();

		Parameters__c parameterDaysSettings = new Parameters__c();
		parameterDaysSettings.Active__c = true;
		parameterDaysSettings.RecordTypeId = recordTypeId;
		parameterDaysSettings.Channel__c = 'Atendimento';
		parameterDaysSettings.Process__c = 'Contestação';
		parameterDaysSettings.Business_Division__c = 'Residencial';
		parameterDaysSettings.Parametertype__c = 'Quantidade de dias para Histórico Eventos';
		parameterDaysSettings.NumberDaysEnd__c = 1;
		parameterDaysSettings.NumberDaysStart__c = 1;
		insert parameterDaysSettings;

		Parameters__c parameterKBSettings = new Parameters__c();
		parameterKBSettings.Active__c = true;
		parameterKBSettings.RecordTypeId = recordTypeId;
		parameterKBSettings.Channel__c = 'Atendimento';
		parameterKBSettings.Process__c = 'Contestação';
		parameterKBSettings.Business_Division__c = 'Residencial';
		parameterKBSettings.Parametertype__c = 'Tipos de Eventos';
		parameterKBSettings.Events__c = 'Cancelamentos em andamento ou executados;Compras/Movimentações de Produtos e Serviços;Eventos Técnicos / Serviços;Lançamentos Manuais;Oferta Contratada;PPV;Reajuste Anual;Taxas Técnicas';
		parameterKBSettings.ContentArticleLink__c = 'https://www.test.com/';
		insert parameterKBSettings;
	}

	@isTest
	public static void getAllEventsSuccess() {
		FinancialEventAnalysisController.ComparisonInvoiceFull comparisonInvoiceFull1 = new FinancialEventAnalysisController.ComparisonInvoiceFull();
		comparisonInvoiceFull1.dataVencimento = '01/05/2020'; 
		FinancialEventAnalysisController.ComparisonInvoice comparisonInvoice1 = new FinancialEventAnalysisController.ComparisonInvoice();
		comparisonInvoice1.invoice = comparisonInvoiceFull1;

		FinancialEventAnalysisController.ComparisonInvoiceFull comparisonInvoiceFull2 = new FinancialEventAnalysisController.ComparisonInvoiceFull();
		comparisonInvoiceFull2.dataVencimento = '01/01/2020'; 
		FinancialEventAnalysisController.ComparisonInvoice comparisonInvoice2 = new FinancialEventAnalysisController.ComparisonInvoice();
		comparisonInvoice2.invoice = comparisonInvoiceFull2;		

		FinancialEventAnalysisController.DiagnosticComparison diagnosticComparison = new FinancialEventAnalysisController.DiagnosticComparison();
		diagnosticComparison.contractNumber = '1842374';
		diagnosticComparison.operatorCode = '550';
		diagnosticComparison.invoicesDataToCompare = new List<FinancialEventAnalysisController.ComparisonInvoice>{comparisonInvoice1, comparisonInvoice2};

		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
		Map<String, Object> response = FinancialEventAnalysisController.getAllEvents(JSON.serialize(diagnosticComparison));
		Test.stopTest();
		
		System.assert(true, response.get('success'));
	}

	private static void configureServices () {
		List<ServiceParameter__c> settings = new List<ServiceParameter__c>();

		//Events
		ServiceParameter__c eventsSettings = new ServiceParameter__c();
		eventsSettings.name = 'Events';
		eventsSettings.EndPoint__c = 'Events';
		eventsSettings.Method__c = 'GET';
		eventsSettings.Timeout__c = 120000;
		settings.add(eventsSettings);

		//HistoryEvents
		ServiceParameter__c historySettings = new ServiceParameter__c();
		historySettings.name = 'historyEvents';
		historySettings.EndPoint__c = 'historyEvents';
		historySettings.Method__c = 'GET';
		historySettings.Timeout__c = 120000;
		settings.add(historySettings);

		//RequestFees
		ServiceParameter__c requestFeesSettings = new ServiceParameter__c();
		requestFeesSettings.name = 'GetRequestFees';
		requestFeesSettings.EndPoint__c = 'GetRequestFees';
		requestFeesSettings.Method__c = 'GET';
		requestFeesSettings.Timeout__c = 120000;
		settings.add(requestFeesSettings);

		//PPV
		ServiceParameter__c customerPpvSettings = new ServiceParameter__c();
		customerPpvSettings.name = 'GetCustomerPpv';
		customerPpvSettings.EndPoint__c = 'GetCustomerPpv';
		customerPpvSettings.Method__c = 'GET';
		customerPpvSettings.Timeout__c = 120000;
		settings.add(customerPpvSettings);

		//Readjustments
		ServiceParameter__c readjustmentSettings = new ServiceParameter__c();
		readjustmentSettings.name = 'GetReadjustments';
		readjustmentSettings.EndPoint__c = 'GetReadjustments';
		readjustmentSettings.Method__c = 'GET';
		readjustmentSettings.Timeout__c = 120000;
		settings.add(readjustmentSettings);

		//NewProducts
		ServiceParameter__c newProductsSettings = new ServiceParameter__c();
		newProductsSettings.name = 'GetNewProducts';
		newProductsSettings.EndPoint__c = 'GetNewProducts';
		newProductsSettings.Method__c = 'GET';
		newProductsSettings.Timeout__c = 120000;
		settings.add(newProductsSettings);

		insert settings;
	}

	private class Mock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			if (req.getEndpoint().startsWith('GetRequestFees')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"technicalRequestFees":[{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","requestTypeId":"24","requestTypeDescription":"ACIONAMENTO DE TÉCNICO","releaseDate":"2020-07-27T12:12:00Z","extractItemTypeId":"123","extractItemTypeDescription":"DESCONTO SUPORTE","itemExtractRegistrationUser":"MCIDA","requestRegistrationUser":"MCIDA","amount":"23","paymentPlanId":"5","paymentPlanName":"2 VEZES","installmentNumber":"2"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","requestTypeId":"24","requestTypeDescription":"MUDANCA DE PACOTE","releaseDate":"2020-07-27T12:12:00Z","extractItemTypeId":"123","extractItemTypeDescription":"DESCONTO SUPORTE","itemExtractRegistrationUser":"MCIDA","requestRegistrationUser":"MCIDA","amount":"99.9","paymentPlanId":"5","paymentPlanName":"2 VEZES","installmentNumber":"2"}]}}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('Events')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{ "apiVersion": "1;2019-11-19", "transactionId": "Id-af1e2460c9ab851f6c4b9887", "data": { "requests": [ { "cityId": "06139", "operatorCode": "004", "contractNumber": "1027935", "requestID": 176, "requestTypeID": 10, "requestTypeDescription": "VISITA TECNICA", "status": 1, "statusDescription": "EXECUTADA", "closeDate": "Mon Sep 09 00:00:00 BRT 1996", "closeUser": "INDEFINIDO", "openUser": "INDEFINIDO", "obs": "ASSINANTE AUSENTE ** I R E M P E R I O D O D A **TARDE********* // TEC.CELSO N. ", "cancelReasonID": null, "cancelReasonDescription": null }, { "cityId": "06139", "operatorCode": "004", "contractNumber": "1027935", "requestID": 614670, "requestTypeID": 26, "requestTypeDescription": "CONTRATACAO DE CANAL A LA CARTE", "status": 1, "statusDescription": "EXECUTADA", "closeDate": "Wed Sep 06 00:00:00 BRT 2000", "closeUser": "PROD_JD", "openUser": "ASALOMON", "obs": "CONF DADOS E CIENTE DE TX.........ANDRE", "cancelReasonID": null, "cancelReasonDescription": null }, { "cityId": "06139", "operatorCode": "004", "contractNumber": "1027935", "requestID": 19889540, "requestTypeID": 30, "requestTypeDescription": "DEVOLUCAO DE DECODER", "status": 1, "statusDescription": "EXECUTADA", "closeDate": "Mon Aug 21 00:00:00 BRT 2006", "closeUser": "ABEBUENO", "openUser": "ABEBUENO", "obs": null, "cancelReasonID": null, "cancelReasonDescription": null } ] } }'
				);
				res.setStatusCode(200);
				return res;
			}  else if (req.getEndpoint().startsWith('historyEvents')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"billDocumentList":[{"id":474854532,"billNo":170778375,"billId":245961436, "extractItensDetails":[{"partnerId":"2","partnerName":"EMBRATEL","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":null,"productId":null,"productDescription":null,"detTypeExtractItemNote":"NETFONE MULTI ILIMIT BRASIL 21","registrationUser":"OPS$NMC","note":null,"isMinimumValueExtended":"N"}], "paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-17T20:29:46Z","description":"NETFONE MULTI ILIMIT BRASIL 21","name":"NETFONE MULTI ILIMITADO BRASIL 21","installments":null,"extractItemTypeId":1053,"extractItemTypeDescription":"NETFONE MULTI ILIMIT BRASIL 21","amountDue":32.7,"isContestation":"NAO","complement":null,"reasonId":10,"reasonDescription":null,"invoiceItemGroupDemoId":125,"invoiceItemGroupDemoDescription":"NETFONE MULTI ILIMITADO BRASIL 21","extractItemStatus":"ISSUED","extractIte`nsDetails":[{"partnerId":"2","partnerName":"EMBRATEL","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":null,"productId":null,"productDescription":null,"detTypeExtractItemNote":"NETFONE MULTI ILIMIT BRASIL 21","registrationUser":"OPS$NMC","note":null,"isMinimumValueExtended":"N"}]}]}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('GetCustomerPpv')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"consumption":[{"contractNumber":12078302,"cityId":"06139","typeSaleId":85,"typeSaleDescription":"AAC - PPV BRINDE","saleDate":"2020-07-01T22:28:15","salesChannelsDescription":"AAC - PPV BRINDE","salesStatusId":2,"salesStatusDescription":"EFETIVADA","eventId":"80602010639","eventDescription":"XUXA EMBARCA NESSA AVENTURA COM OS DUENDES","eventName":"XUXA E OS DUENDES","eventDuration":"300","price":1.9,"categoryPPVId":402,"categoryPPVDescription":"AVENTURA","typePPVId":4,"typePPVDescription":"FILME"},{"contractNumber":12078302,"cityId":"06139","typeSaleId":85,"typeSaleDescription":"CAA - PPV DIGITAL","saleDate":"2020-06-01T22:28:15","salesChannelsDescription":">CAA - PPV DIGITAL","salesStatusId":2,"salesStatusDescription":"EFETIVADA","eventId":"80602010639","eventDescription":"WILL, ELIZABETH E O CAPITÃO BARBOSSA VÃO A CINGAPURA, EM BUSCA DE UM MAPA QUE POSSIBILITE O RESGATE DO CAPITÃO JACK SPARROW.","eventName":"PIRATAS DO CARIBE NO FIM DO MUNDO","eventDuration":"300","price":9.9,"categoryPPVId":402,"categoryPPVDescription":"AVENTURA","typePPVId":4,"typePPVDescription":"FILME"}],"pagination":{"totalCount":76,"page":1,"totalPages":4,"links":[{"rel":"first","href":"https://api.net.com.br/corp/ppvconsumptionhistory?contractNumber=12078302&cityId=06139&startDate=2014-05-01&endDate=2019-05-01&page=1&limit=10"}]}}}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('GetReadjustments')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"lastReadjustments":[{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","readjustmentType":"PERCENTUAL","amount":"99.9","readjustmentDate":"2020-02-01T12:12:00Z","previousPrice":"99.9","readjustmentPrice":"99.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO A","readjustmentType":"PERCENTUAL","amount":"10","readjustmentDate":"2020-02-01T12:12:00Z","previousPrice":"100","readjustmentPrice":"110"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO B","readjustmentType":"PERCENTUAL","amount":"10","readjustmentDate":"2020-03-01T12:12:00Z","previousPrice":"99.90","readjustmentPrice":"100"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO C","readjustmentType":"FIXO","amount":"18.00","readjustmentDate":"2018-07-21T12:12:00Z","previousPrice":"71.90","readjustmentPrice":"99.90"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO E","readjustmentType":"FIXO","amount":"1.90","readjustmentDate":"2017-07-19T12:12:00Z","previousPrice":"70.00","readjustmentPrice":"71.90"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO E","readjustmentType":"PERCENTUAL","amount":"5","readjustmentDate":"2016-07-13T12:12:00Z","previousPrice":"65.90","readjustmentPrice":"70.00"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","readjustmentType":"FIXO","amount":"15.90","readjustmentDate":"2015-07-16T12:12:00Z","previousPrice":"50.00","readjustmentPrice":"65.90"}]}}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('GetNewProducts')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"newProducts":[{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO A","effectiveDate":"2019-07-21T12:12:00Z","amount":"199.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO PREMIUM B","effectiveDate":"2018-12-19T12:12:00Z","amount":"229.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO C","effectiveDate":"2018-12-20T12:12:00Z","amount":"99.9"},{"returnCode":"00","productId":"123","productDescription":"ADVANCED CONFORTO D","effectiveDate":"2018-11-30T12:12:00Z","amount":"84.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","effectiveDate":"2019-01-12T12:12:00Z","amount":"149.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO A","effectiveDate":"2019-06-10T12:12:00Z","amount":"49.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO B","effectiveDate":"2019-06-12T12:12:00Z","amount":"39.9"},{"returnCode":"00","productId":"123","productDescription":"ADVANCED ENTERPRISE A","effectiveDate":"2020-04-27T12:12:00Z","amount":"290.9"},{"returnCode":"00","productId":"123","productDescription":"ADVANCED HOME D","effectiveDate":"2020-07-27T12:12:00Z","amount":"129.9"},{"returnCode":"00","productId":"123","productDescription":"STANDARD CONFORTO A","effectiveDate":"2020-06-27T12:12:00Z","amount":"119.9"},{"returnCode":"00","productId":"123","productDescription":"PREMIUM CONFORTO S","effectiveDate":"2020-05-27T12:12:00Z","amount":"299.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","effectiveDate":"2020-07-27T12:12:00Z","amount":"99.9"}]}}'
				);
				res.setStatusCode(200);
				return res;
			} else {
				System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
				return null;
			}
		}
	}
}