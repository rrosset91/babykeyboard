@IsTest
global with sharing class EventsControllerTest {
	@testSetup
	static void charge() {
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

		//EventsConfigurationOrders
		ServiceParameter__c eventConfOrdersSettings = new ServiceParameter__c();
		eventConfOrdersSettings.name = 'EventsConfigurationOrders';
		eventConfOrdersSettings.EndPoint__c = 'EventsConfigurationOrders';
		eventConfOrdersSettings.Method__c = 'GET';
		eventConfOrdersSettings.Timeout__c = 120000;

		settings.add(eventConfOrdersSettings);

		//EventsWorkOrders
		ServiceParameter__c eventWorkOrdersSettings = new ServiceParameter__c();
		eventWorkOrdersSettings.name = 'EventsWorkOrders';
		eventWorkOrdersSettings.EndPoint__c = 'EventsWorkOrders';
		eventWorkOrdersSettings.Method__c = 'GET';
		eventWorkOrdersSettings.Timeout__c = 120000;

		settings.add(eventWorkOrdersSettings);

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

		//Occurrences
		ServiceParameter__c occurrenceSettings = new ServiceParameter__c();
		occurrenceSettings.name = 'GetOccurrence';
		occurrenceSettings.EndPoint__c = 'GetOccurrence';
		occurrenceSettings.Method__c = 'GET';
		occurrenceSettings.Timeout__c = 120000;

		settings.add(occurrenceSettings);

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

		//Outage
		ServiceParameter__c outageSettings = new ServiceParameter__c();
		outageSettings.name = 'GetOutage';
		outageSettings.EndPoint__c = 'GetOutage';
		outageSettings.Method__c = 'GET';
		outageSettings.Timeout__c = 120000;

		settings.add(outageSettings);

		insert settings;
	}
	/********************* testes do metodo getEvents(sucesso, erro e exceção) ***********************/
	@isTest
	public static void getEventsSuccess() {
		Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getEventsSuccessJSON(), 200));
		Test.startTest();
		response = EventsController.getEvents('2132131', '51232156', 12);
		Test.stopTest();
		System.assert((Boolean) response.get('success') == true);
	}
	@isTest
	public static void getEventsError() {
		Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getApiErrorJSON(), 400));
		Test.startTest();
		response = EventsController.getEvents('2132131', '51232156', 24);
		Test.stopTest();
		System.assert((Boolean) response.get('success') == false);
	}
	@isTest
	public static void getEventsException() {
		String message = '';
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{rrr}', 500));
		Test.startTest();
		try {
			EventsController.getEvents('2132131', '51232156', 24);
		} catch (Exception e) {
			message = e.getMessage();
		}
		Test.stopTest();
		System.assert(message.contains('Script'));
	}
	/********************* testes do metodo getEventsDetails(sucesso, erro e exceção) ***********************/
	@isTest
	public static void getEventsDetailsSuccess() {
		Map<String, Object> response;
		MultipleHttpMock mock = new MultipleHttpMock();
		//response 1
		HttpResponse res1 = new HttpResponse();
		res1.setBody(getEventsConfOrderJSON());
		res1.setStatusCode(200);
		mock.addResponse(res1);
		//response 2
		HttpResponse res2 = new HttpResponse();
		res2.setBody(getEventsWorkOrderJSON());
		res2.setStatusCode(200);
		mock.addResponse(res2);
		//set mock
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		response = EventsController.getEventDetails('2132131', '51232156', '123213456');
		Test.stopTest();
		System.assert((Boolean) response.get('success') == true);
	}
	@isTest
	public static void getEventsDetailsError() {
		Map<String, Object> response;
		MultipleHttpMock mock = new MultipleHttpMock();
		//response 1
		HttpResponse res1 = new HttpResponse();
		res1.setBody(getApiErrorJSON());
		res1.setStatusCode(401);
		mock.addResponse(res1);
		//response 2
		HttpResponse res2 = new HttpResponse();
		res2.setBody(getApiErrorJSON());
		res2.setStatusCode(401);
		mock.addResponse(res2);
		//set mock
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		response = EventsController.getEventDetails('2132131', '51232156', '123213456');
		Test.stopTest();
		System.assert((Boolean) response.get('success') == false);
	}

	@isTest
	public static void getEventsDetailsException() {
		String message = '';
		MultipleHttpMock mock = new MultipleHttpMock();
		//response 1
		HttpResponse res1 = new HttpResponse();
		res1.setBody('{rrr}');
		res1.setStatusCode(500);
		mock.addResponse(res1);
		//response 2
		HttpResponse res2 = new HttpResponse();
		res2.setBody('{rrr}');
		res2.setStatusCode(500);
		mock.addResponse(res2);
		//set mock
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		try {
			EventsController.getEventDetails('2132131', '51232156', '123213456');
		} catch (Exception e) {
			message = e.getMessage();
		}
		Test.stopTest();
		System.assert(message.contains('Script'));
	}
	/********************* testes do metodo setParams (sucesso e erro) ***********************/
	@isTest
	public static void setParamsSuccess() {
		Map<String, String> response = EventsController.setParams('2132131', '51232156', '2015-01-01', '2020-01-01');
		System.assert(response.get('contractNumber').equals('2132131'));
		System.assert(response.get('operatorCode').equals('51232156'));
	}
	@isTest
	public static void setParamsError() {
		String message = '';
		try {
			EventsController.setParams(null, null, null, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
		System.assert(message.contains('devem ser preenchidos'));
	}
	/********************* testes do metodo setParamsDetails (sucesso e erro) ***********************/
	@isTest
	public static void setParamsDetailsSuccess() {
		Map<String, String> response = EventsController.setParamsDetails('2132131', '51232156', '42132145');
		System.assert(response.get('contractNumber').equals('2132131'));
		System.assert(response.get('operatorCode').equals('51232156'));
		System.assert(response.get('requestID').equals('42132145'));
	}
	@isTest
	public static void setParamsDetailsError() {
		String message = '';
		try {
			EventsController.setParamsDetails(null, null, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
		System.assert(message.contains('devem ser preenchidos'));
	}

	//@@@@@@@@@@@@Testes das classes de agrupamentos de histórico de eventos@@@@@@@@@@@@@@@

	@isTest
	public static void getNewProductsByPeriodTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getNewProductsByPeriod('1027935', '004', 6);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getNewProductsByDateTest() {
		Date startDate = Date.newInstance(2010, 2, 10);
		Date endDate = Date.newInstance(2020, 2, 10);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getNewProductsByDate('1027935', '004', startDate, endDate);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getPpvByPeriodTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getPpvByPeriod('1027935', '004', 6);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getPpvByDateTest() {
		Date startDate = Date.newInstance(2010, 2, 10);
		Date endDate = Date.newInstance(2020, 2, 10);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getPpvByDate('1027935', '004', startDate, endDate);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getOutageByPeriodTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getOutageByPeriod('1027935', '004', 6);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getOutageByDateTest() {
		Date startDate = Date.newInstance(2010, 2, 10);
		Date endDate = Date.newInstance(2020, 2, 10);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getOutageByDate('1027935', '004', startDate, endDate);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getRequestFeesByPeriodTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getRequestFeesByPeriod('1027935', '004', 6);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getRequestFeesDateTest() {
		Date startDate = Date.newInstance(2010, 2, 10);
		Date endDate = Date.newInstance(2020, 2, 10);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getRequestFeesByDate('1027935', '004', startDate, endDate);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getOccurrencesByPeriodTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getOccurrencesByPeriod('1027935', '004', 6);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getOccurrencesByDateTest() {
		Date startDate = Date.newInstance(2010, 2, 10);
		Date endDate = Date.newInstance(2020, 2, 10);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getOccurrencesByDate('1027935', '004', startDate, endDate);
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	@isTest
	public static void getReadjustmentsTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = EventsController.getReadjustments('1027935', '004');
		Test.stopTest();
		system.assertEquals(true, result.get('success'));
	}

	private static String getEventsSuccessJSON() {
		String eventsJSON = '{';
		eventsJSON += '"apiVersion": "1;2019-11-19",';
		eventsJSON += '"transactionId": "Id-04ce085f29cead31f7be5f09",';
		eventsJSON += '"data": {';
		eventsJSON += '"requests": [{';
		eventsJSON += '"cityId": "06139",';
		eventsJSON += '"operatorCode": "004",';
		eventsJSON += '"contractNumber": "1027935",';
		eventsJSON += '"requestID": 176,';
		eventsJSON += '"requestTypeID": 10,';
		eventsJSON += '"requestTypeDescription": "VISITA TECNICA",';
		eventsJSON += '"status": 1,';
		eventsJSON += '"statusDescription": "EXECUTADA",';
		eventsJSON += '"closeDate": "Mon Sep 09 00:00:00 BRT 1996",';
		eventsJSON += '"closeUser": "INDEFINIDO",';
		eventsJSON += '"openUser": "INDEFINIDO",';
		eventsJSON += '"obs": "ASSINANTE AUSENTE **   I R E M  P E R I O D O  D A **TARDE*********  // TEC.CELSO N. ",';
		eventsJSON += '"cancelReasonID": null,';
		eventsJSON += '"cancelReasonDescription": null';
		eventsJSON += '}]';
		eventsJSON += '}';
		eventsJSON += '}';
		return eventsJSON;
	}

	private static String getApiErrorJSON() {
		String errorJSON = '{"apiVersion": "1",';
		errorJSON += '"transactionId": "32132131",';
		errorJSON += '"error": {';
		errorJSON += '"httpCode": "400",';
		errorJSON += '"errorCode": "API-3566",';
		errorJSON += '"message": "Mensagem de erro resumida",';
		errorJSON += '"detailedMessage": "Mensagem de erro detalhada",';
		errorJSON += '"link": {';
		errorJSON += '"rel": "related",';
		errorJSON += '"href": "https://oagcechomolog.claro.com.br/P06CEC/corp"';
		errorJSON += '}}}';
		return errorJSON;
	}

	private static String getEventsConfOrderJSON() {
		String confOrderJSON = '';
		confOrderJSON += '{"apiVersion": "1;2019-11-19",';
		confOrderJSON += '"transactionId": "Id-45ab0c5f02dcae4eed2cd49e",';
		confOrderJSON += '"data": {"configurationorders": [{';
		confOrderJSON += '"cityId": "06139",';
		confOrderJSON += '"operatorCode": "004",';
		confOrderJSON += '"contractNumber": "1027935",';
		confOrderJSON += '"requestID": 37756155,';
		confOrderJSON += '"configurationOrderID": 30104788,';
		confOrderJSON += '"configurationorderTypeID": 15,';
		confOrderJSON += '"configurationorderTypeDescription": "INICIALIZAR E HABILITAR CABLE MODEM",';
		confOrderJSON += '"productID": 7007,';
		confOrderJSON += '"productDescription": "VIRTUA 2 MB COM TV FIDELIDADE",';
		confOrderJSON += '"status": "3",';
		confOrderJSON += '"statusDescription": "CANCELADA",';
		confOrderJSON += '"closeUser": "PROD_JD",';
		confOrderJSON += '"terminationDate": "Tue Jul 01 00:00:00 BRT 2008",';
		confOrderJSON += '"pointID": 5599759}]}}';
		return confOrderJSON;
	}

	private static String getEventsWorkOrderJSON() {
		String workOrderJSON = '';
		workOrderJSON += '{"apiVersion": "1;2019-11-19","transactionId": "Id-2cae0c5f54e18722c1c124d4","data":';
		workOrderJSON += '{"workorders": [{"cityId": "06139","operatorCode": "004","contractNumber": "1027935",';
		workOrderJSON += '"requestID": 37756155,"workOrderID": "0875197489","workorderTypeID": 45,';
		workOrderJSON += '"workorderTypeDescription": "MUDANCA DE ENDERECO - INSTALAR PONTO ADICIONAL VIRTUA","status": "X",';
		workOrderJSON += '"statusDescription": "CANCELADA","note": "Solicitacao aberta automaticamente pelo SIGMA.",';
		workOrderJSON += '"terminationDate": "Tue Jul 01 00:00:00 BRT 2008","attendanceDate": "Tue Jul 01 15:46:12 BRT 2008",';
		workOrderJSON += '"isExempt": false,"eventDate": null,"closeUser": "T0056803"}]}}';
		return workOrderJSON;
	}

	private static String getHistorySuccessJSON() {
		String historyJSON = '{"billDocumentList":,[{"id":474854532,"billNo":170778375,"billId":245961436,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-17T20:29:46Z","description":"NETFONE MULTI ILIMIT BRASIL 21","name":"NETFONE MULTI ILIMITADO BRASIL 21","installments":null,"extractItemTypeId":1053,"extractItemTypeDescription":"NETFONE MULTI ILIMIT BRASIL 21","amountDue":32.7,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":125,"invoiceItemGroupDemoDescription":"NETFONE MULTI ILIMITADO BRASIL 21","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"2","partnerName":"EMBRATEL","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":null,"productId":null,"productDescription":null,"detTypeExtractItemNote":"NETFONE MULTI ILIMIT BRASIL 21","registrationUser":"OPS$NMC","note":null,"isMinimumValueExtended":"N"}]}}';
		return historyJSON;
	}

	@isTest
	private static void getHistoryEventsTest() {
		Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getHistorySuccessJSON(), 200));
		Test.startTest();
		try {
			Date startDate = Date.newInstance(2015, 2, 17);
			Date endDate = Date.newInstance(2020, 2, 17);
			eventsController.getHistoryEvents('1027935', '004', 'ISSUED', startDate, endDate);
		} catch (exception e) {
			e.getMessage();
		}
		Test.stopTest();
	}

	@isTest
	private static void getHistoryEventsErrorTest() {
		Test.startTest();
		Map<String, Object> response;
		String message = '';
		try {
			Date startDate = Date.newInstance(2015, 2, 17);
			Date endDate = Date.newInstance(2020, 2, 17);
			response = eventsController.getHistoryEvents('', '004', 'ISSUED', startDate, endDate);
		} catch (exception e) {
			message = e.getMessage();
		}
		Test.stopTest();
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
			} else if (req.getEndpoint().startsWith('GetCustomerPpv')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"consumption":[{"contractNumber":12078302,"cityId":"06139","typeSaleId":85,"typeSaleDescription":"AAC - PPV BRINDE","saleDate":"2020-07-01T22:28:15","salesChannelsDescription":"AAC - PPV BRINDE","salesStatusId":2,"salesStatusDescription":"EFETIVADA","eventId":"80602010639","eventDescription":"XUXA EMBARCA NESSA AVENTURA COM OS DUENDES","eventName":"XUXA E OS DUENDES","eventDuration":"300","price":1.9,"categoryPPVId":402,"categoryPPVDescription":"AVENTURA","typePPVId":4,"typePPVDescription":"FILME"},{"contractNumber":12078302,"cityId":"06139","typeSaleId":85,"typeSaleDescription":"CAA - PPV DIGITAL","saleDate":"2020-06-01T22:28:15","salesChannelsDescription":">CAA - PPV DIGITAL","salesStatusId":2,"salesStatusDescription":"EFETIVADA","eventId":"80602010639","eventDescription":"WILL, ELIZABETH E O CAPITÃO BARBOSSA VÃO A CINGAPURA, EM BUSCA DE UM MAPA QUE POSSIBILITE O RESGATE DO CAPITÃO JACK SPARROW.","eventName":"PIRATAS DO CARIBE NO FIM DO MUNDO","eventDuration":"300","price":9.9,"categoryPPVId":402,"categoryPPVDescription":"AVENTURA","typePPVId":4,"typePPVDescription":"FILME"}],"pagination":{"totalCount":76,"page":1,"totalPages":4,"links":[{"rel":"first","href":"https://api.net.com.br/corp/ppvconsumptionhistory?contractNumber=12078302&cityId=06139&startDate=2014-05-01&endDate=2019-05-01&page=1&limit=10"}]}}}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('GetOccurrence')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"contactrecords":[{"customerAccountId":"27","number":"861481903","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-20T01:14:16Z","resolutionDate":"2020-07-20T01:13:33Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"9970","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318451 - Ficha de Arrecadação -Dt. vcto.:  2019-07-10 - -  Lanc. Fut. Obs: dddd; - Motivo: REAJUSTE INDEVIDO; - Valor: 2.0 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481908","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-20T11:55:13Z","resolutionDate":"2020-07-20T11:54:30Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"1818","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318456 - Ficha de Arrecadação -Dt. vcto.:  2019-05-10 - -  Lanc. Fut. Obs: fff; - Motivo: COBRANCA EM DUPLICIDADE; - Valor: 0.25 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481909","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-20T11:59:54Z","resolutionDate":"2020-07-20T11:59:10Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"215","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318457 - Ficha de Arrecadação -Dt. vcto.:  2019-05-10 - -  Lanc. Fut. Obs: ddd; - Motivo: PROD/SERV N PRESTADO; - Valor: 0.5 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481910","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-20T13:29:35Z","resolutionDate":"2020-07-20T13:28:51Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"3888","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318458 - Ficha de Arrecadação -Dt. vcto.:  2019-07-10 - -  Lanc. Fut. Obs: fff; - Motivo: PROD/SERV N PRESTADO; - Valor: 0.375 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481911","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-20T13:31:03Z","resolutionDate":"2020-07-20T13:30:20Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"65","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318459 - Ficha de Arrecadação -Dt. vcto.:  2018-12-10 - -  Lanc. Fut. Obs: ddd; - Motivo: PROD/SERV N PRESTADO; - Valor: 4.0 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481914","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-21T10:50:14Z","resolutionDate":"2020-07-21T10:49:30Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"9197","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318460 - Ficha de Arrecadação -Dt. vcto.:  2019-07-10 - -  Lanc. Fut. Obs: jjj; - Motivo: DESC/DESAB N PROCESSADO; - Valor: 1.0 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861481915","loginOpening":"MCIDA","loginClosing":"MCIDA","creationDate":"2020-07-21T11:06:35Z","resolutionDate":"2020-07-21T11:05:51Z","returnDate":null,"name":"Bia","phoneLineNumber":"11996229999","originId":"250","areaOrigin":"CONTESTACAO","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"1818","typeDescription":"FI1 - CT - CONTESTACAO EFETUADA NET","status":"1","note":"ID_GRUPO_CONTEST:9318461 - Ficha de Arrecadação -Dt. vcto.:  2019-07-10 - -  Lanc. Fut. Obs: obs; - Motivo: PROD/SERV N PRESTADO; - Valor: 12.336799999999982 /","attendanceNumber":"389","description":"CONTESTACAO EFETUADA","protocolNumber":null},{"customerAccountId":"27","number":"861482030","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:31:27Z","resolutionDate":null,"returnDate":null,"name":"ROGER TESTE","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"9197","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##ROGER TESTE##undefined##Cliente pagou em duplicidade##false##ttttttttttt##11#-#undefined##22#-#undefined##33#-#undefined##rrrrr@rrrr.com##2020-08-12##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482031","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:32:08Z","resolutionDate":null,"returnDate":null,"name":"RRRRRRRRRRRR","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##RRRRRRRRRRRR##undefined##Cliente pagou em duplicidade##false##1111111111##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482032","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:33:24Z","resolutionDate":null,"returnDate":null,"name":"RRRRRRRRRRRR","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##RRRRRRRRRRRR##undefined##Cliente pagou em duplicidade##false##1111111111##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482033","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:35:33Z","resolutionDate":null,"returnDate":null,"name":"RRRRRRRRRRRR","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##RRRRRRRRRRRR##undefined##Cliente pagou em duplicidade##false##1111111111##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482034","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:36:51Z","resolutionDate":null,"returnDate":null,"name":"RRRRRRRRRRRRRRR","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"3888","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##RRRRRRRRRRRRRRR##undefined##Contrato cancelado gerando faturas(Desconexão Por Opção)##false##aaaaaaaaaaaaaa##11#-#undefined##11#-#undefined##33#-#undefined##rrrrr@rrrr.com##2020-08-12##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482035","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:43:49Z","resolutionDate":null,"returnDate":null,"name":"Beatriz Barbalho","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"65","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##Beatriz Barbalho##undefined##Cliente pagou em duplicidade##true##okokokok##11#-#undefined##11#-#undefined##11#-#undefined##beatriz@teste.com##2020-08-12##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482036","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T17:45:18Z","resolutionDate":null,"returnDate":null,"name":"Beatriz Barbalho","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##Beatriz Barbalho##undefined##Cliente pagou em duplicidade##true##okokokok##11#-#undefined##11#-#undefined##11#-#undefined##beatriz@teste.com##2020-08-12##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482043","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T20:38:22Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482044","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T20:40:06Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482045","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T20:46:13Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"215","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482047","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T20:58:50Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482048","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T21:13:51Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"9197","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482049","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T21:20:59Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482053","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T21:38:00Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"3888","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##a##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482057","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T21:48:53Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482059","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:27:24Z","resolutionDate":null,"returnDate":null,"name":"q","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1818","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##q##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482060","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:32:23Z","resolutionDate":null,"returnDate":null,"name":"q","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##q##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482062","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:32:28Z","resolutionDate":null,"returnDate":null,"name":"q","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##q##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482064","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:32:30Z","resolutionDate":null,"returnDate":null,"name":"q","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##q##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482069","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:47:58Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482071","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T22:50:54Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"27","number":"861482082","loginOpening":"MCIDA","loginClosing":null,"creationDate":"2020-08-12T23:07:54Z","resolutionDate":null,"returnDate":null,"name":"a","phoneLineNumber":null,"originId":"260","areaOrigin":"CLARO","groupTypeId":"23","groupTypeDescription":"FI2 - ISENCAO, REEMBOLSO E ACERTO","typeId":"1129","typeDescription":"FI2 - RS2 - ANALISE DE REEMBOLSO","status":"0","note":"OP#Pessoa Física##a##undefined##Cliente pagou em duplicidade##false##1##11#-#undefined##11#-#undefined##11#-#undefined##undefined##null##","attendanceNumber":null,"description":null,"protocolNumber":null},{"customerAccountId":"343391883","number":"343391883","loginOpening":"PROD_JD","loginClosing":"PROD_JD","creationDate":"2019-01-03T16:26:55","resolutionDate":"2019-01-03T16:26:55","returnDate":"2019-01-03T16:26:55","name":"Jose Carlos","phoneLineNumber":"295889669","originId":"257","areaOrigin":"Padronização Política Vencida","groupTypeId":"9","groupTypeDescription":"FI1 - COBRANCA","typeId":"1617","typeDescription":"FI1 - AC1 - ALTERACAO TIPO COBRANCA","status":"1","note":"Este cliente teve na data de...","attendanceNumber":"1","description":"ATENDIMENTO INFORMOU","protocolNumber":"80000000678"}]}}'
				);
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('GetReadjustments')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"string","transactionId":"string","data":{"lastReadjustments":[{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","readjustmentType":"PERCENTUAL","amount":"99.9","readjustmentDate":"2020-07-27T12:12:00Z","previousPrice":"99.9","readjustmentPrice":"99.9"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO A","readjustmentType":"PERCENTUAL","amount":"10","readjustmentDate":"2020-07-22T12:12:00Z","previousPrice":"100","readjustmentPrice":"110"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO B","readjustmentType":"PERCENTUAL","amount":"10","readjustmentDate":"2019-07-17T12:12:00Z","previousPrice":"99.90","readjustmentPrice":"100"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO C","readjustmentType":"FIXO","amount":"18.00","readjustmentDate":"2018-07-21T12:12:00Z","previousPrice":"71.90","readjustmentPrice":"99.90"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO E","readjustmentType":"FIXO","amount":"1.90","readjustmentDate":"2017-07-19T12:12:00Z","previousPrice":"70.00","readjustmentPrice":"71.90"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO E","readjustmentType":"PERCENTUAL","amount":"5","readjustmentDate":"2016-07-13T12:12:00Z","previousPrice":"65.90","readjustmentPrice":"70.00"},{"returnCode":"00","productId":"123","productDescription":"BASICO CONFORTO D","readjustmentType":"FIXO","amount":"15.90","readjustmentDate":"2015-07-16T12:12:00Z","previousPrice":"50.00","readjustmentPrice":"65.90"}]}}'
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
			} else if (req.getEndpoint().startsWith('GetOutage')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"data":{"installments":[{"returnCode":"01","OutageNumber":"65214","products":[{"productType":"HFC","affectedServices":"NOW","symptom":"Intermitente","coverage":"Distrito","nature":"Corretiva","startDate":"15/01/2020","previsionDate":"22/03/2020","endDate":"22/03/2020","status":"ATIVO","responsible":"JOÃO"}]},{"returnCode":"01","OutageNumber":"65543","products":[{"productType":"HFC","affectedServices":"NET VIRTUA","symptom":"Intermitente","coverage":"DistritoDistritoDistritoDistritoDistritoDistritoDistritoDistritoDistritoDistritoDistritoDistrito","nature":"Preventiva","startDate":"22/03/2020","previsionDate":"22/03/2020","endDate":"22/03/2020","status":"ATIVO","responsible":"JOÃO"},{"productType":"HFC","affectedServices":"CLARO NET","symptom":"Intermitente","coverage":"Distrito","nature":"Informativa","startDate":"11/10/2020","previsionDate":"22/03/2020","endDate":"22/03/2020","status":"ATIVO","responsible":"JOÃO"},{"productType":"HFC","affectedServices":"CLARO NET","symptom":"Intermitente","coverage":"Distrito","nature":"Informativa","startDate":"11/10/2020","previsionDate":"22/03/2020","endDate":"22/03/2020","status":"ATIVO","responsible":"JOÃO"}]}]}}'
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