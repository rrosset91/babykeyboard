@isTest
public class FinancialMobileHistoriesEventsTest {
	@testSetup
	static void charge() {
		ServiceParameter__c memosSetting = new ServiceParameter__c();
		memosSetting.Token__c = 'returnedToken';
		memosSetting.Name = 'GetMobileHistory';
		memosSetting.EndPoint__c = 'callout:OAGClaro/accounteventshistories';
		memosSetting.Method__c = 'GET';
		memosSetting.ReturnMock__c = true;
		memosSetting.Timeout__c = 120000;

		insert memosSetting;
	}
	//TESTE DOS METODOS DE REQUEST
	@isTest
	public static void getParamsTest() {
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
		FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		test.startTest();
		Map<String, String> result = FinancialMobileHistoriesEvents.getParams(requesterAccordion, baseAttributes, filters);
		test.stopTest();
		system.assert(result != null);
	}
	@isTest
	public static void getHeadersTest() {
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		test.startTest();
		Map<String, String> result = FinancialMobileHistoriesEvents.getHeaders(requesterAccordion);
		test.stopTest();
		system.assert(result != null);
	}
	@isTest
	public static void getBodyTest() {
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		test.startTest();
		String result = FinancialMobileHistoriesEvents.getBody(requesterAccordion);
		test.stopTest();
		system.assert(result != null);
	}
	//TESTE DOS MÉTODOS DE RESPONSE
	@isTest
	public static void processJsonTest() {
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		String responseJSON = getMockData('ResponseJson');
		test.startTest();
		Object result = FinancialMobileHistoriesEvents.processJSON(responseJSON, requesterAccordion);
		test.stopTest();
		system.assert(result != null);
	}
	@isTest
	public static void getColumnsTest() {
		test.startTest();
		Object result = FinancialMobileHistoriesEvents.getColumns();
		test.stopTest();
		system.assert(result != null);
	}

	private static String getMockData(String parameters) {
		switch on parameters {
			when 'Accordion' {
				return '{"customSetting":"GetMobileHistory","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
			}
			when 'props' {
				return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}';
			}
			when 'filters' {
				return '{"periodFilter":6,"isCustomDateFilter":false}';
			}
			when 'ResponseJson' {
				return '{"apiVersion":"1;2020-09-28","transactionId":"96dd1a35-6a3d-49d0-9121-c169ee1c25ce","data":{"accountevent":[{"contract":[{"contractNumber":"11111111","offers":[{"offerlId":"31231231231","offerDescription":" Claro Pós Mais 10GB + Minutos Ilimitados","serviceplanlevel":"Assinante","accessionDate":"01/10/2018","status":"Ativo","expirationDate":"01/10/2018"}]}],"subscriber":[{"msisdn":"1196695436","subscriberNumber":"222222","offers":[{"offerlId":"31231231231","offerDescription":" Claro Pós Mais 10GB + Minutos Ilimitados","serviceplanlevel":"Assinante","accessionDate":"01/10/2018","status":"Ativo","expirationDate":"01/10/2018"}]}]}]}}';
			}
			when else {
				return null;
			}
		}
	}
	private static FinancialMobileEventsWrapper.EventRequestAttributes parseRequesterAccordion(String stringData) {
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = new FinancialMobileEventsWrapper.EventRequestAttributes();
		FinancialMobileEventsWrapper.EventRequestAttributes request = (FinancialMobileEventsWrapper.EventRequestAttributes) JSON.deserialize(stringData, FinancialMobileEventsWrapper.EventRequestAttributes.class);

		requesterAccordion.customSetting = request.customSetting;
		requesterAccordion.groupBy = request.groupBy;
		requesterAccordion.hasMultipleGroups = request.hasMultipleGroups;
		requesterAccordion.namedCredential = request.namedCredential;

		return requesterAccordion;
	}

	private static FinancialMobileGeneralService.EntryPointWrapper parseRequestAttributes(String stringData) {
		FinancialMobileGeneralService.EntryPointWrapper baseAttributes = new FinancialMobileGeneralService.EntryPointWrapper();
		FinancialMobileGeneralService.EntryPointWrapper request = (FinancialMobileGeneralService.EntryPointWrapper) JSON.deserialize(stringData, FinancialMobileGeneralService.EntryPointWrapper.class);
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

	private static FinancialMobileFiltersWrapper.filterValues parseFilterParams(String stringData) {
		FinancialMobileFiltersWrapper.filterValues filterParams = new FinancialMobileFiltersWrapper.filterValues();
		FinancialMobileFiltersWrapper.filterValues request = (FinancialMobileFiltersWrapper.filterValues) JSON.deserialize(stringData, FinancialMobileFiltersWrapper.filterValues.class);
		filterParams.periodFilter = request.periodFilter;
		filterParams.isCustomDateFilter = request.isCustomDateFilter;
		filterParams.startDateFilter = request.startDateFilter;
		filterParams.endDateFilter = request.endDateFilter;
		filterParams.liveSearchFilter = request.liveSearchFilter;
		filterParams.productFilter = request.productFilter;
		filterParams.statusFilter = request.statusFilter;

		return filterParams;
	}
}