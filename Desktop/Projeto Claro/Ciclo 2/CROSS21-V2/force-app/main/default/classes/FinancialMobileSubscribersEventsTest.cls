/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 29-01-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
**/
@isTest
public class FinancialMobileSubscribersEventsTest {
	
	@testSetup 
	static void makeData(){
    
        ServiceParameter__c interactionsSetting = new ServiceParameter__c();
        interactionsSetting.Token__c = 'returnedToken';
        interactionsSetting.Name = 'GetSubscriberVas';
        interactionsSetting.EndPoint__c = 'callout:OAGClaro/subscribervas';
        interactionsSetting.Method__c = 'GET';
        interactionsSetting.Timeout__c = 120000;

        insert interactionsSetting;
	}
	
    @isTest
    public static void getParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.startTest();
        Map<String, String> result = FinancialMobileSubscribersEvents.getParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileSubscribersEvents.getHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.startTest();
        String result = FinancialMobileSubscribersEvents.getBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void processJsonTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        String responseJSON = getMockData('ResponseJson');
		
		Test.startTest();
        Object result = FinancialMobileSubscribersEvents.processJSON(responseJSON, requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getColumnsTest(){
		
		Test.startTest();
        Object result = FinancialMobileSubscribersEvents.getColumns();
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getModalFieldsTest(){
		
		Test.startTest();
        Object result = FinancialMobileSubscribersEvents.getModalFields();
		Test.stopTest();
		
        System.assert(result == null);
	}
	
    private static String getMockData(String parameters){
   		switch on parameters {
            when 'Accordion'{
                return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'props'{
                return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}';
            }
            when 'filters'{
                return '{"periodFilter":6,"isCustomDateFilter":false}';
            }
            when 'ResponseJson'{
                return '{"apiVersion":"1;2019-10-06","transactionId":"Id-1059985fdce48cb957846d84","data":{"subscribersVas":[{"serviceName":"3","serviceAggregatorName":"Livroh TESTE","aggregatorName":"Minha Claro","msisdn":"11992702918","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2018-12-19T14:26:38.000-02:00","effectiveDate":"2018-12-19T14:26:38.000-02:00","expirationDate":"2018-12-19T14:26:40.000-02:00","amount":"4.99","amountType":"NET","cancellationDate":"2018-12-21T16:53:11.000-02:00","cancellationCode":"201813767","requestTypeId":"MIGRADO","requestDescription":"CUSTOMER_SERVICE","statusReasonDescription":"Serviço cancelado","confirmationDate":"2018-12-19T14:26:38.000-02:00","confirmationCode":"201813672","rateCode":"SGV029","id":"53720","solicitationDate":"2018-12-19T14:26:38.000-02:00","aggregatorDateRequest":"2018-12-19T14:26:38.000-02:00"}]}}';
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
                res.setStatusCode(200);
                return res;
        }
    }
}