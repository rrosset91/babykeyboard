/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 31-01-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
**/
@isTest
public class FinancialMobileRequestsBuilderTest {
	
	@testSetup 
	static void makeData(){

        List<ServiceParameter__c> servicesList = new List<ServiceParameter__c>();
        ServiceParameter__c subscribersSetting = new ServiceParameter__c();
        subscribersSetting.Token__c = 'returnedToken';
        subscribersSetting.Name = 'GetSubscriberVas';
        subscribersSetting.EndPoint__c = 'GetSubscriberVas';
        subscribersSetting.Method__c = 'GET';
        subscribersSetting.Timeout__c = 120000;
        servicesList.add(subscribersSetting);
        
        ServiceParameter__c interactionsSetting = new ServiceParameter__c();
        interactionsSetting.Token__c = 'returnedToken';
        interactionsSetting.Name = 'GetInteractions';
        interactionsSetting.EndPoint__c = 'GetInteractions';
        interactionsSetting.Method__c = 'GET';
        interactionsSetting.Timeout__c = 120000;
		servicesList.add(interactionsSetting);
		
		ServiceParameter__c migrationsSetting = new ServiceParameter__c();
        migrationsSetting.Token__c = 'returnedToken';
        migrationsSetting.Name = 'GetMigrations';
        migrationsSetting.EndPoint__c = 'GetMigrations';
        migrationsSetting.Method__c = 'GET';
        migrationsSetting.Timeout__c = 120000;
		servicesList.add(migrationsSetting);
		
		ServiceParameter__c mobileHistorySetting = new ServiceParameter__c();
        mobileHistorySetting.Token__c = 'returnedToken';
        mobileHistorySetting.Name = 'GetMobileHistory';
        mobileHistorySetting.EndPoint__c = 'GetMobileHistory';
        mobileHistorySetting.Method__c = 'GET';
        mobileHistorySetting.Timeout__c = 120000;
        servicesList.add(mobileHistorySetting);
        
        ServiceParameter__c mockSetting = new ServiceParameter__c();
        mockSetting.Token__c = 'returnedToken';
        mockSetting.Name = 'MockOne';
        mockSetting.EndPoint__c = 'MockOne';
        mockSetting.Method__c = 'GET';
        mockSetting.Timeout__c = 120000;
        servicesList.add(mockSetting);
        
        insert servicesList;
    }
	
	@isTest 
	public static void requestParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestInteractionsParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestInteractionsHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestInteractionsBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
	}
	
	@isTest 
	public static void requestGetMigrationsParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMigrations'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestGetMigrationsHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMigrations'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestGetMigrationsBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMigrations'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
	}
	
	@isTest 
	public static void requestGetMobileHistoryParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMobileHistory'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestGetMobileHistoryHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMobileHistory'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestGetMobileHistoryBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('GetMobileHistory'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest 
	public static void requestNullParamsTest(){
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
		FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
		FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));

		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
		Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();

		System.assert(result == null);
    }
	
	@isTest 
	public static void requestNullHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
    }
	
	@isTest 
	public static void requestNullBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
    }
    
    private static String getMockData(String parameters){
		switch on parameters {
			when 'SubscriberAccordion'{
				return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'InteractionsAccordion'{
				return '{"customSetting":"GetInteractions","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'GetMigrations'{
				return '{"customSetting":"GetMigrations","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'GetMobileHistory'{
				return '{"customSetting":"GetMobileHistory","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'NullAccordion'{
				return '{"customSetting":"MockOne","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'props'{
				return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}'; 
			}
			when 'filters'{
				return '{"periodFilter":6,"isCustomDateFilter":false}';
			}
			when else {
				return null;
			}
		}
	}
	
    private static FinancialMobileEventsWrapper.EventRequestAttributes parseRequesterAccordion(String stringData){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = new FinancialMobileEventsWrapper.EventRequestAttributes();
        FinancialMobileEventsWrapper.EventRequestAttributes request = (FinancialMobileEventsWrapper.EventRequestAttributes)JSON.deserialize(stringData, FinancialMobileEventsWrapper.EventRequestAttributes.class);
		requesterAccordion.customSetting = request.customSetting;
		requesterAccordion.groupBy = request.groupBy;
		requesterAccordion.hasMultipleGroups = request.hasMultipleGroups;
		requesterAccordion.namedCredential = request.namedCredential;

        return requesterAccordion;
    }

    private static FinancialMobileGeneralService.EntryPointWrapper parseRequestAttributes(String stringData){
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = new FinancialMobileGeneralService.EntryPointWrapper();
        FinancialMobileGeneralService.EntryPointWrapper request = (FinancialMobileGeneralService.EntryPointWrapper)JSON.deserialize(stringData, FinancialMobileGeneralService.EntryPointWrapper.class);
		baseAttributes.contractAccountSalesforceId = request.contractAccountSalesforceId;
		baseAttributes.contractId = request.contractId;
		baseAttributes.customerAccountSalesforceId = request.customerAccountSalesforceId;
		baseAttributes.customerCrmId = request.customerCrmId;
		baseAttributes.isCase = request.isCase;
		baseAttributes.isN2User = request.isN2User;
		baseAttributes.msisdn = request.msisdn;
		baseAttributes.operatorId = request.operatorId;
		baseAttributes.recordId = request.recordId;
	
        return baseAttributes;
    }

    private static FinancialMobileFiltersWrapper.filterValues parseFilterParams(String stringData){
        FinancialMobileFiltersWrapper.filterValues filterParams = new FinancialMobileFiltersWrapper.filterValues();
        FinancialMobileFiltersWrapper.filterValues request = (FinancialMobileFiltersWrapper.filterValues)JSON.deserialize(stringData, FinancialMobileFiltersWrapper.filterValues.class);
		filterParams.periodFilter = request.periodFilter;
		filterParams.isCustomDateFilter = request.isCustomDateFilter;
		filterParams.startDateFilter = request.startDateFilter;
		filterParams.endDateFilter = request.endDateFilter;
		filterParams.liveSearchFilter = request.liveSearchFilter;
		filterParams.productFilter = request.productFilter;
		filterParams.statusFilter = request.statusFilter;
    
        return filterParams;
	}
	
	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
			HTTPResponse res = new HTTPResponse();
            if (req.getEndpoint().startsWith('GetSubscriberVas')) {
                res.setBody('{"apiVersion":"1;2019-10-06","transactionId":"Id-eb2a945f3ddfc9898b35aa23","data":{"subscribersVas":[{"serviceName":"560","serviceAggregatorName":"Pocoyo House","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:04:09.000-03:00","effectiveDate":"2020-06-05T15:04:09.000-03:00","expirationDate":"2020-06-05T15:04:10.000-03:00","amount":"10.9","amountType":"NET","cancellationDate":"2020-06-05T15:08:02.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:04:09.000-03:00","rateCode":"963","id":"776","solicitationDate":"2020-06-05T15:04:09.000-03:00","aggregatorDateRequest":"2020-06-05T15:04:09.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:00:30.000-03:00","effectiveDate":"2020-04-27T20:00:30.000-03:00","expirationDate":"2020-04-27T20:00:31.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:01:14.000-03:00","cancellationCode":"202026063","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:00:30.000-03:00","confirmationCode":"202026062","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:00:30.000-03:00","aggregatorDateRequest":"2020-04-27T20:00:30.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:20:45.000-03:00","effectiveDate":"2020-04-27T20:20:45.000-03:00","expirationDate":"2020-04-27T20:20:46.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:21:23.000-03:00","cancellationCode":"202026067","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:20:45.000-03:00","confirmationCode":"202026066","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:20:45.000-03:00","aggregatorDateRequest":"2020-04-27T20:20:45.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:12:08.000-03:00","effectiveDate":"2020-04-27T20:12:08.000-03:00","expirationDate":"2020-04-27T20:12:09.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:12:44.000-03:00","cancellationCode":"202026065","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:12:08.000-03:00","confirmationCode":"202026064","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:12:08.000-03:00","aggregatorDateRequest":"2020-04-27T20:12:08.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:42:41.000-03:00","effectiveDate":"2020-04-27T20:42:41.000-03:00","expirationDate":"2020-04-27T20:42:42.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:42:49.000-03:00","cancellationCode":"202026071","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:42:41.000-03:00","confirmationCode":"202026070","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:42:41.000-03:00","aggregatorDateRequest":"2020-04-27T20:42:41.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:31:43.000-03:00","effectiveDate":"2020-04-27T20:31:43.000-03:00","expirationDate":"2020-04-27T20:31:44.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:32:00.000-03:00","cancellationCode":"202026069","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:31:43.000-03:00","confirmationCode":"202026068","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:31:43.000-03:00","aggregatorDateRequest":"2020-04-27T20:31:43.000-03:00"},{"serviceName":"192","serviceAggregatorName":"Discovery Kids On","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:09:48.000-03:00","effectiveDate":"2020-06-05T15:09:48.000-03:00","expirationDate":"2020-06-05T15:09:49.000-03:00","amount":"4.99","amountType":"NET","cancellationDate":"2020-06-05T15:23:38.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:09:48.000-03:00","rateCode":"932","id":"767","solicitationDate":"2020-06-05T15:09:48.000-03:00","aggregatorDateRequest":"2020-06-05T15:09:48.000-03:00"}],"totalRecords":null}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('GetInteractions')) {
                res.setBody('{"apiVersion":"1;2019-08-28","transactionId":"Id-932a945f3adf011427e1e6e7","data":{"attendances":[{"occurrenceId":"36644412","interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","protocolNumber":"202033346","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644269","interactionSequenceId":"1","solicitationDateOpening":"2020-09-17T10:00:44.000-03:00","protocolNumber":"202033138","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644448","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T17:07:47.000-03:00","solicitationDateClosing":"2020-09-15T17:07:47.000-03:00","protocolNumber":"202033030","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644447","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:40.000-03:00","solicitationDateClosing":"2020-09-15T16:51:40.000-03:00","protocolNumber":"202033028","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644446","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:29.000-03:00","solicitationDateClosing":"2020-09-15T16:51:29.000-03:00","protocolNumber":"202033027","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644445","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T15:04:21.000-03:00","solicitationDateClosing":"2020-09-15T15:04:21.000-03:00","protocolNumber":"202033016","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643122","interactionSequenceId":"1","solicitationDateOpening":"2020-09-02T11:53:00.000-03:00","solicitationDateClosing":"2020-09-02T11:53:00.000-03:00","protocolNumber":"202031618","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643102","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T17:50:26.000-03:00","solicitationDateClosing":"2020-08-31T17:50:26.000-03:00","protocolNumber":"202031438","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643103","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T16:11:17.000-03:00","solicitationDateClosing":"2020-08-31T16:11:17.000-03:00","protocolNumber":"202031395","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642781","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T12:11:42.000-03:00","solicitationDateClosing":"2020-08-27T12:11:42.000-03:00","protocolNumber":"202031236","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642780","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T11:38:49.000-03:00","solicitationDateClosing":"2020-08-27T11:38:49.000-03:00","protocolNumber":"202031235","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642779","interactionSequenceId":"1","solicitationDateOpening":"2020-08-26T14:49:32.000-03:00","solicitationDateClosing":"2020-08-26T14:49:32.000-03:00","protocolNumber":"202031175","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Conta","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "}]}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('GetMigrations')) {
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('GetMobileHistory')) {
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('MockOne')) {
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}