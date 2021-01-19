@IsTest
global with sharing class EventsControllerTest {
	
    @testSetup static void charge(){
        
        List<ServiceParameter__c> settings = new List<ServiceParameter__c>();
        //Events
		ServiceParameter__c eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'Events';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        
        settings.add(eventsSettings);
        
        //HistoryEvents
		ServiceParameter__c historySettings = new ServiceParameter__c();
        historySettings.name = 'historyEvents';
        historySettings.EndPoint__c = 'https://api-test.claro.com.br/residential/v1/customers/financialaccounts';
        historySettings.Method__c = 'GET';
        historySettings.Timeout__c = 120000;
        
        settings.add(historySettings);
        
        //EventsConfigurationOrders
        ServiceParameter__c eventConfOrdersSettings = new ServiceParameter__c();
        eventConfOrdersSettings.name = 'EventsConfigurationOrders';
        eventConfOrdersSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventConfOrdersSettings.Method__c = 'GET';
        eventConfOrdersSettings.Timeout__c = 120000;
        
        settings.add(eventConfOrdersSettings);
        
        //EventsWorkOrders
        ServiceParameter__c eventWorkOrdersSettings = new ServiceParameter__c();
        eventWorkOrdersSettings.name = 'EventsWorkOrders';
        eventWorkOrdersSettings.EndPoint__c = 'callout:OAGClaro/orders/workorder';
        eventWorkOrdersSettings.Method__c = 'GET';
        eventWorkOrdersSettings.Timeout__c = 120000;
        
        settings.add(eventWorkOrdersSettings);
		       
        //RequestFees
        ServiceParameter__c requestFeesSettings = new ServiceParameter__c();
        requestFeesSettings.name = 'GetRequestFees';
        requestFeesSettings.EndPoint__c = 'callout:APIClaroResidential/customers/requestfees';
        requestFeesSettings.Method__c = 'GET';
        requestFeesSettings.Timeout__c = 120000;
        requestFeesSettings.ReturnMock__c = true;
        
        settings.add(requestFeesSettings);
		
        //PPV
        ServiceParameter__c customerPpvSettings = new ServiceParameter__c();
        customerPpvSettings.name = 'GetCustomerPpv';
        customerPpvSettings.EndPoint__c = 'callout:APIClaroResidentia/customers/products/ppv';
        customerPpvSettings.Method__c = 'GET';
        customerPpvSettings.Timeout__c = 120000;
        customerPpvSettings.ReturnMock__c = true;
        
        settings.add(customerPpvSettings);
		
        //Occurrences
        ServiceParameter__c occurrenceSettings = new ServiceParameter__c();
        occurrenceSettings.name = 'GetOccurrence';
        occurrenceSettings.EndPoint__c = 'callout:OAGClaro/contactrecords';
        occurrenceSettings.Method__c = 'GET';
        occurrenceSettings.Timeout__c = 120000;
        occurrenceSettings.ReturnMock__c = true;
        
        settings.add(occurrenceSettings);
		
        //Readjustments
        ServiceParameter__c readjustmentSettings = new ServiceParameter__c();
        readjustmentSettings.name = 'GetReadjustments';
        readjustmentSettings.EndPoint__c = 'callout:APIClaroResidential/customers/lastreadjustments';
        readjustmentSettings.Method__c = 'GET';
        readjustmentSettings.Timeout__c = 120000;
        readjustmentSettings.ReturnMock__c = true;
        
        settings.add(readjustmentSettings);
		
		//NewProducts
        ServiceParameter__c newProductsSettings = new ServiceParameter__c();
        newProductsSettings.name = 'GetNewProducts';
        newProductsSettings.EndPoint__c = 'callout:APIClaroResidential/customers/newproducts';
        newProductsSettings.Method__c = 'GET';
        newProductsSettings.Timeout__c = 120000;
        newProductsSettings.ReturnMock__c = true;
        
        settings.add(newProductsSettings);
        
        //Outage
        ServiceParameter__c outageSettings = new ServiceParameter__c();
        outageSettings.name = 'GetOutage';
        outageSettings.EndPoint__c = 'callout:APIClaroResidential​/billingaccounts​/outageperiods';
        outageSettings.Method__c = 'GET';
        outageSettings.Timeout__c = 120000;
        outageSettings.ReturnMock__c = true;
        
        settings.add(outageSettings);

        insert settings;
    }
    /********************* testes do metodo getEvents(sucesso, erro e exceção) ***********************/
	@isTest 
	public static void getEventsSuccess() {
        Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getEventsSuccessJSON(), 200));
        Test.startTest();
        response = EventsController.getEvents('2132131', '51232156',12);
        Test.stopTest();
        System.assert((Boolean)response.get('success') == true);
	}
    @isTest 
	public static void getEventsError() {
        Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getApiErrorJSON(), 400));
        Test.startTest();
        response = EventsController.getEvents('2132131', '51232156',24);
        Test.stopTest();
        System.assert((Boolean)response.get('success') == false);
	}
    @isTest 
	public static void getEventsException() {
        String message = '';
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{rrr}', 500));
        Test.startTest();
        try{
            EventsController.getEvents('2132131', '51232156',24);
        }catch(Exception e){
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
        System.assert((Boolean)response.get('success') == true);
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
        System.assert((Boolean)response.get('success') == false);
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
        try{
            EventsController.getEventDetails('2132131', '51232156', '123213456');
        }catch(Exception e){
            message = e.getMessage();
        }
        Test.stopTest();
        System.assert(message.contains('Script'));
    }
    /********************* testes do metodo setParams (sucesso e erro) ***********************/
    @isTest 
    public static void setParamsSuccess(){
        Map<String, String> response = EventsController.setParams('2132131', '51232156','2015-01-01','2020-01-01');
        System.assert(response.get('contractNumber').equals('2132131'));
        System.assert(response.get('operatorCode').equals('51232156'));
    }
    @isTest
    public static void setParamsError(){
		String message = '';
        try{
            EventsController.setParams(null, null,null,null);
        }catch(Exception e){
            message = e.getMessage();
        }
        System.assert(message.contains('devem ser preenchidos'));
    }
    /********************* testes do metodo setParamsDetails (sucesso e erro) ***********************/
    @isTest 
    public static void setParamsDetailsSuccess(){
        Map<String, String> response = EventsController.setParamsDetails('2132131', '51232156', '42132145');
        System.assert(response.get('contractNumber').equals('2132131'));
        System.assert(response.get('operatorCode').equals('51232156'));
        System.assert(response.get('requestID').equals('42132145'));
    }
    @isTest
    public static void setParamsDetailsError(){
		String message = '';
        try{
            EventsController.setParamsDetails(null, null, null);
        }catch(Exception e){
            message = e.getMessage();
        }
        System.assert(message.contains('devem ser preenchidos'));
    }
    
    //@@@@@@@@@@@@Testes das classes de agrupamentos de histórico de eventos@@@@@@@@@@@@@@@
    
    @isTest
    public static void getNewProductsByPeriodTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getNewProductsByPeriod('1027935', '004', 6);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getNewProductsByDateTest(){
        Date startDate = Date.newInstance(2010, 02, 10);
       	Date endDate = Date.newInstance(2020, 02, 10);
        Test.startTest();
        Map<String, Object> result = EventsController.getNewProductsByDate('1027935', '004', startDate, endDate);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getPpvByPeriodTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getPpvByPeriod('1027935', '004', 6);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getPpvByDateTest(){
        Date startDate = Date.newInstance(2010, 02, 10);
       	Date endDate = Date.newInstance(2020, 02, 10);
        Test.startTest();
        Map<String, Object> result = EventsController.getPpvByDate('1027935', '004', startDate, endDate);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }

    @isTest
    public static void getOutageByPeriodTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getOutageByPeriod('1027935', '004', 6);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getOutageByDateTest(){
        Date startDate = Date.newInstance(2010, 02, 10);
       	Date endDate = Date.newInstance(2020, 02, 10);
        Test.startTest();
        Map<String, Object> result = EventsController.getOutageByDate('1027935', '004', startDate, endDate);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getRequestFeesByPeriodTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getRequestFeesByPeriod('1027935', '004', 6);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getRequestFeesDateTest(){
        Date startDate = Date.newInstance(2010, 02, 10);
       	Date endDate = Date.newInstance(2020, 02, 10);
        Test.startTest();
        Map<String, Object> result = EventsController.getRequestFeesByDate('1027935', '004', startDate, endDate);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getOccurrencesByPeriodTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getOccurrencesByPeriod('1027935', '004', 6);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getOccurrencesByDateTest(){
        Date startDate = Date.newInstance(2010, 02, 10);
       	Date endDate = Date.newInstance(2020, 02, 10);
        Test.startTest();
        Map<String, Object> result = EventsController.getOccurrencesByDate('1027935', '004', startDate, endDate);
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }
    
    @isTest
    public static void getReadjustmentsTest(){
        Test.startTest();
        Map<String, Object> result = EventsController.getReadjustments('1027935', '004');
        Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }

    private static String getEventsSuccessJSON(){
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
    
    private static String getApiErrorJSON(){
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
    
    private static String getEventsConfOrderJSON(){
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
    
    private static String getEventsWorkOrderJSON(){
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
    
    private static String getHistorySuccessJSON(){
        String historyJSON = '{"billDocumentList":,[{"id":474854532,"billNo":170778375,"billId":245961436,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-17T20:29:46Z","description":"NETFONE MULTI ILIMIT BRASIL 21","name":"NETFONE MULTI ILIMITADO BRASIL 21","installments":null,"extractItemTypeId":1053,"extractItemTypeDescription":"NETFONE MULTI ILIMIT BRASIL 21","amountDue":32.7,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":125,"invoiceItemGroupDemoDescription":"NETFONE MULTI ILIMITADO BRASIL 21","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"2","partnerName":"EMBRATEL","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":null,"productId":null,"productDescription":null,"detTypeExtractItemNote":"NETFONE MULTI ILIMIT BRASIL 21","registrationUser":"OPS$NMC","note":null,"isMinimumValueExtended":"N"}]}}';
    	return historyJSON;
    }
    
    @isTest
    private static void getHistoryEventsTest(){
        Map<String, Object> response;
		Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getHistorySuccessJSON(), 200));
        Test.startTest();
        try{
            Date startDate = Date.newInstance(2015, 2, 17);
       		Date endDate = Date.newInstance(2020, 2, 17);
        	eventsController.getHistoryEvents('1027935','004','ISSUED',startDate,endDate);
        }
        catch(exception e){
            e.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getHistoryEventsErrorTest(){
        Test.startTest();
        Map<String, Object> response;
        String message = '';
        try{
            Date startDate = Date.newInstance(2015, 2, 17);
       		Date endDate = Date.newInstance(2020, 2, 17);
        	response = eventsController.getHistoryEvents('','004','ISSUED',startDate,endDate);
        }
        catch(exception e){
            message = e.getMessage();
        }
        Test.stopTest();
    }
}