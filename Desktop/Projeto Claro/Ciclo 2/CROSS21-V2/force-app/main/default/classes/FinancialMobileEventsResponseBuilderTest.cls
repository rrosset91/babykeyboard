/**
 * @description       : 
 * @author            : Felipe Ducheiko
 * @group             : 
 * @last modified on  : 04-02-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   04-02-2021   Felipe Ducheiko   Initial Version
**/
@isTest
public class FinancialMobileEventsResponseBuilderTest {
	
	@testSetup 
	static void charge(){

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
	public static void processSubscriberResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        String responseJSON = getMockData('SubscriberResponse');
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	@isTest 
	public static void getSubscriberAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	@isTest 
	public static void getSubscriberModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
    }

	@isTest 
	public static void processInteractionsResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        String responseJSON = getMockData('InteractionsResponse');
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
		Test.stopTest();
		
	}
	
	@isTest 
	public static void getInteractionsAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
	}
	
	@isTest 
	public static void getInteractionsModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }

	@isTest 
	public static void processNullResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        String responseJSON = getMockData('NullResponse');
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
	}
	
	@isTest 
	public static void getNullAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
    }
	@isTest 
	public static void getNullModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
		Test.stopTest();
		
        System.assert(result == null);
    }
    
    private static String getMockData(String parameters){
   		switch on parameters {
            when 'SubscriberAccordion'{
                return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'SubscriberResponse'{
                return '{"apiVersion":"1;2019-10-06","transactionId":"Id-1059985fdce48cb957846d84","data":{"subscribersVas":[{"serviceName":"3","serviceAggregatorName":"Livroh TESTE","aggregatorName":"Minha Claro","msisdn":"11992702918","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2018-12-19T14:26:38.000-02:00","effectiveDate":"2018-12-19T14:26:38.000-02:00","expirationDate":"2018-12-19T14:26:40.000-02:00","amount":"4.99","amountType":"NET","cancellationDate":"2018-12-21T16:53:11.000-02:00","cancellationCode":"201813767","requestTypeId":"MIGRADO","requestDescription":"CUSTOMER_SERVICE","statusReasonDescription":"Serviço cancelado","confirmationDate":"2018-12-19T14:26:38.000-02:00","confirmationCode":"201813672","rateCode":"SGV029","id":"53720","solicitationDate":"2018-12-19T14:26:38.000-02:00","aggregatorDateRequest":"2018-12-19T14:26:38.000-02:00"}]}}';
            }
            when 'InteractionsAccordion'{
                return '{"customSetting":"GetInteractions","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'InteractionsResponse'{
                return '{"apiVersion":"1;2019-08-28","transactionId":"Id-4d6e985fd0fe64bfd472c9a7","data":{"attendances":[{"occurrenceId":"36644412","interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","protocolNumber":"202033346","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644269","interactionSequenceId":"1","solicitationDateOpening":"2020-09-17T10:00:44.000-03:00","protocolNumber":"202033138","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "}]}}';
            }
            when 'NullAccordion'{
                return '{"customSetting":"MockOne","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'NullResponse'{
                return null;
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
	
	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
			HTTPResponse res = new HTTPResponse();
            if (req.getEndpoint().startsWith('InvoicesNegotiationOptions')) {
                res.setBody('{"apiVersion":"1;2019-10-06","transactionId":"Id-eb2a945f3ddfc9898b35aa23","data":{"subscribersVas":[{"serviceName":"560","serviceAggregatorName":"Pocoyo House","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:04:09.000-03:00","effectiveDate":"2020-06-05T15:04:09.000-03:00","expirationDate":"2020-06-05T15:04:10.000-03:00","amount":"10.9","amountType":"NET","cancellationDate":"2020-06-05T15:08:02.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:04:09.000-03:00","rateCode":"963","id":"776","solicitationDate":"2020-06-05T15:04:09.000-03:00","aggregatorDateRequest":"2020-06-05T15:04:09.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:00:30.000-03:00","effectiveDate":"2020-04-27T20:00:30.000-03:00","expirationDate":"2020-04-27T20:00:31.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:01:14.000-03:00","cancellationCode":"202026063","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:00:30.000-03:00","confirmationCode":"202026062","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:00:30.000-03:00","aggregatorDateRequest":"2020-04-27T20:00:30.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:20:45.000-03:00","effectiveDate":"2020-04-27T20:20:45.000-03:00","expirationDate":"2020-04-27T20:20:46.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:21:23.000-03:00","cancellationCode":"202026067","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:20:45.000-03:00","confirmationCode":"202026066","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:20:45.000-03:00","aggregatorDateRequest":"2020-04-27T20:20:45.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:12:08.000-03:00","effectiveDate":"2020-04-27T20:12:08.000-03:00","expirationDate":"2020-04-27T20:12:09.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:12:44.000-03:00","cancellationCode":"202026065","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:12:08.000-03:00","confirmationCode":"202026064","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:12:08.000-03:00","aggregatorDateRequest":"2020-04-27T20:12:08.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:42:41.000-03:00","effectiveDate":"2020-04-27T20:42:41.000-03:00","expirationDate":"2020-04-27T20:42:42.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:42:49.000-03:00","cancellationCode":"202026071","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:42:41.000-03:00","confirmationCode":"202026070","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:42:41.000-03:00","aggregatorDateRequest":"2020-04-27T20:42:41.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:31:43.000-03:00","effectiveDate":"2020-04-27T20:31:43.000-03:00","expirationDate":"2020-04-27T20:31:44.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:32:00.000-03:00","cancellationCode":"202026069","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:31:43.000-03:00","confirmationCode":"202026068","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:31:43.000-03:00","aggregatorDateRequest":"2020-04-27T20:31:43.000-03:00"},{"serviceName":"192","serviceAggregatorName":"Discovery Kids On","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:09:48.000-03:00","effectiveDate":"2020-06-05T15:09:48.000-03:00","expirationDate":"2020-06-05T15:09:49.000-03:00","amount":"4.99","amountType":"NET","cancellationDate":"2020-06-05T15:23:38.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:09:48.000-03:00","rateCode":"932","id":"767","solicitationDate":"2020-06-05T15:09:48.000-03:00","aggregatorDateRequest":"2020-06-05T15:09:48.000-03:00"}],"totalRecords":null}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('GetInteractions')) {
                res.setBody('{"apiVersion":"1;2019-08-28","transactionId":"Id-932a945f3adf011427e1e6e7","data":{"attendances":[{"occurrenceId":"36644412","interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","protocolNumber":"202033346","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644269","interactionSequenceId":"1","solicitationDateOpening":"2020-09-17T10:00:44.000-03:00","protocolNumber":"202033138","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644448","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T17:07:47.000-03:00","solicitationDateClosing":"2020-09-15T17:07:47.000-03:00","protocolNumber":"202033030","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644447","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:40.000-03:00","solicitationDateClosing":"2020-09-15T16:51:40.000-03:00","protocolNumber":"202033028","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644446","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:29.000-03:00","solicitationDateClosing":"2020-09-15T16:51:29.000-03:00","protocolNumber":"202033027","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644445","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T15:04:21.000-03:00","solicitationDateClosing":"2020-09-15T15:04:21.000-03:00","protocolNumber":"202033016","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643122","interactionSequenceId":"1","solicitationDateOpening":"2020-09-02T11:53:00.000-03:00","solicitationDateClosing":"2020-09-02T11:53:00.000-03:00","protocolNumber":"202031618","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643102","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T17:50:26.000-03:00","solicitationDateClosing":"2020-08-31T17:50:26.000-03:00","protocolNumber":"202031438","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643103","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T16:11:17.000-03:00","solicitationDateClosing":"2020-08-31T16:11:17.000-03:00","protocolNumber":"202031395","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642781","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T12:11:42.000-03:00","solicitationDateClosing":"2020-08-27T12:11:42.000-03:00","protocolNumber":"202031236","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642780","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T11:38:49.000-03:00","solicitationDateClosing":"2020-08-27T11:38:49.000-03:00","protocolNumber":"202031235","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642779","interactionSequenceId":"1","solicitationDateOpening":"2020-08-26T14:49:32.000-03:00","solicitationDateClosing":"2020-08-26T14:49:32.000-03:00","protocolNumber":"202031175","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Conta","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "}]}}');
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