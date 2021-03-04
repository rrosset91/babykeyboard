@isTest
public class FinancialMobileEventsControllerTest {
	@testSetup
	static void charge() {
		ServiceParameter__c setting = new ServiceParameter__c();
		setting.Token__c = 'returnedToken';
		setting.Name = 'GetSubscriberVas';
		setting.EndPoint__c = 'GetSubscriberVas';
		setting.Method__c = 'GET';
		setting.Timeout__c = 120000;
		insert setting;
	}

	@isTest
	public static void getAccordionsTest() {
		test.startTest();
		List<FinancialMobileEventsWrapper.EventGroup> result = FinancialMobileEventsController.eventsAccordionsProvider();
		test.stopTest();
		system.assertEquals(true, result.size() > 1);
	}

	@isTest
	public static void buildRequestsTest() {
		String mockAccordion = getMockData('accordion');
		String mockProps = getMockData('props');
		String mockFilters = getMockData('filters');
		test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
		Map<String, Object> result = FinancialMobileEventsController.accordionsRequestBuilder(mockAccordion, mockProps, mockFilters);
		test.stopTest();
		system.assert(result != null);
	}

	@isTest
	public static void accordionsRequestPerfomerTest() {
		String body = null;
		Map<String, String> params = null;
		Map<String, String> headers = null;
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = new FinancialMobileEventsWrapper.EventRequestAttributes();
		requesterAccordion.customSetting = 'GetSubscriberVas';
		requesterAccordion.namedCredential = 'namedCredential';
		test.startTest();
		String message = '';
		try {
			Test.setMock(HttpCalloutMock.class, new Mock());
			FinancialMobileEventsController.accordionsRequestPerfomer(body, params, headers, requesterAccordion);
		} catch (Exception e) {
			message = e.getMessage();
		}
		test.stopTest();
		system.assertEquals(false, message == null);
	}

	private static String getMockData(String parameters) {
		switch on parameters {
			when 'accordion' {
				return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'props' {
				return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}';
			}
			when 'filters' {
				return '{"periodFilter":6,"isCustomDateFilter":false}';
			}
			when 'successJson' {
				return '{"apiVersion":"1;2019-10-06","transactionId":"Id-1059985fdce48cb957846d84","data":{"subscribersVas":[{"serviceName":"3","serviceAggregatorName":"Livroh TESTE","aggregatorName":"Minha Claro","msisdn":"11992702918","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2018-12-19T14:26:38.000-02:00","effectiveDate":"2018-12-19T14:26:38.000-02:00","expirationDate":"2018-12-19T14:26:40.000-02:00","amount":"4.99","amountType":"NET","cancellationDate":"2018-12-21T16:53:11.000-02:00","cancellationCode":"201813767","requestTypeId":"MIGRADO","requestDescription":"CUSTOMER_SERVICE","statusReasonDescription":"Serviço cancelado","confirmationDate":"2018-12-19T14:26:38.000-02:00","confirmationCode":"201813672","rateCode":"SGV029","id":"53720","solicitationDate":"2018-12-19T14:26:38.000-02:00","aggregatorDateRequest":"2018-12-19T14:26:38.000-02:00"}]}}';
			}
			when else {
				return null;
			}
		}
	}

	private class Mock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			if (req.getEndpoint().startsWith('GetSubscriberVas')) {
				HTTPResponse res = new HTTPResponse();
				res.setBody(
					'{"apiVersion":"1;2019-10-06","transactionId":"Id-eb2a945f3ddfc9898b35aa23","data":{"subscribersVas":[{"serviceName":"560","serviceAggregatorName":"Pocoyo House","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:04:09.000-03:00","effectiveDate":"2020-06-05T15:04:09.000-03:00","expirationDate":"2020-06-05T15:04:10.000-03:00","amount":"10.9","amountType":"NET","cancellationDate":"2020-06-05T15:08:02.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:04:09.000-03:00","rateCode":"963","id":"776","solicitationDate":"2020-06-05T15:04:09.000-03:00","aggregatorDateRequest":"2020-06-05T15:04:09.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:00:30.000-03:00","effectiveDate":"2020-04-27T20:00:30.000-03:00","expirationDate":"2020-04-27T20:00:31.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:01:14.000-03:00","cancellationCode":"202026063","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:00:30.000-03:00","confirmationCode":"202026062","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:00:30.000-03:00","aggregatorDateRequest":"2020-04-27T20:00:30.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:20:45.000-03:00","effectiveDate":"2020-04-27T20:20:45.000-03:00","expirationDate":"2020-04-27T20:20:46.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:21:23.000-03:00","cancellationCode":"202026067","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:20:45.000-03:00","confirmationCode":"202026066","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:20:45.000-03:00","aggregatorDateRequest":"2020-04-27T20:20:45.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:12:08.000-03:00","effectiveDate":"2020-04-27T20:12:08.000-03:00","expirationDate":"2020-04-27T20:12:09.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:12:44.000-03:00","cancellationCode":"202026065","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:12:08.000-03:00","confirmationCode":"202026064","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:12:08.000-03:00","aggregatorDateRequest":"2020-04-27T20:12:08.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:42:41.000-03:00","effectiveDate":"2020-04-27T20:42:41.000-03:00","expirationDate":"2020-04-27T20:42:42.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:42:49.000-03:00","cancellationCode":"202026071","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:42:41.000-03:00","confirmationCode":"202026070","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:42:41.000-03:00","aggregatorDateRequest":"2020-04-27T20:42:41.000-03:00"},{"serviceName":"567","serviceAggregatorName":"Descomplica","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-04-27T20:31:43.000-03:00","effectiveDate":"2020-04-27T20:31:43.000-03:00","expirationDate":"2020-04-27T20:31:44.000-03:00","amount":"5.99","amountType":"NET","cancellationDate":"2020-04-27T20:32:00.000-03:00","cancellationCode":"202026069","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-04-27T20:31:43.000-03:00","confirmationCode":"202026068","rateCode":"929","id":"766","solicitationDate":"2020-04-27T20:31:43.000-03:00","aggregatorDateRequest":"2020-04-27T20:31:43.000-03:00"},{"serviceName":"192","serviceAggregatorName":"Discovery Kids On","aggregatorName":"Minha Claro","msisdn":"11945762552","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2020-06-05T15:09:48.000-03:00","effectiveDate":"2020-06-05T15:09:48.000-03:00","expirationDate":"2020-06-05T15:09:49.000-03:00","amount":"4.99","amountType":"NET","cancellationDate":"2020-06-05T15:23:38.000-03:00","requestTypeId":"MIGRADO","requestDescription":"MINHACLARO","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2020-06-05T15:09:48.000-03:00","rateCode":"932","id":"767","solicitationDate":"2020-06-05T15:09:48.000-03:00","aggregatorDateRequest":"2020-06-05T15:09:48.000-03:00"}],"totalRecords":null}}'
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