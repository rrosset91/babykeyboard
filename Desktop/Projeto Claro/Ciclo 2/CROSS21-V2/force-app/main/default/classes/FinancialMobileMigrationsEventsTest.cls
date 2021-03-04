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
public class FinancialMobileMigrationsEventsTest {
	
	@testSetup 
	static void makeData(){
    
        ServiceParameter__c memosSetting = new ServiceParameter__c();
		memosSetting.Token__c = 'returnedToken';
        memosSetting.Name = 'GetMigrations';
        memosSetting.EndPoint__c = 'GetMigrations';
        memosSetting.Method__c = 'GET';
        memosSetting.Timeout__c = 120000;
		insert memosSetting;
		
	}
	
    @isTest
    public static void getParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.startTest();
        Map<String, String> result = FinancialMobileMigrationsEvents.getParams(requesterAccordion, baseAttributes, filters);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        Map<String, String> result = FinancialMobileMigrationsEvents.getHeaders(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.startTest();
        String result = FinancialMobileMigrationsEvents.getBody(requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void processJsonTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        String responseJSON = getMockData('ResponseJson');
		
		Test.startTest();
        Object result = FinancialMobileMigrationsEvents.processJSON(responseJSON, requesterAccordion);
		Test.stopTest();
		
        System.assert(result != null);
    }
	
	@isTest
    public static void getColumnsTest(){
		
		Test.startTest();
        Object result = FinancialMobileMigrationsEvents.getColumns();
		Test.stopTest();
		
        System.assert(result != null);
    }
    
    private static String getMockData(String parameters){
   		switch on parameters {
            when 'Accordion'{
                return '{"customSetting":"GetMigrations","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'props'{
                return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}';
            }
            when 'filters'{
                return '{"periodFilter":6,"isCustomDateFilter":false}';
            }
            when 'ResponseJson'{
                return '{"apiVersion":"1;2019-01-04","transactionId":"Id-3f72ad5f6ddc37ad40e189b8","data":{"memoObj":[{"mobileMemoId":"3267052187","mobileBan":"125767602","msisdn":null,"subscriberMobileId":null,"mobileClientId":"802736190","memoType":"2075","memoLevel":"TODOS","memoCategoryId":null,"memoCategoryDesc":"Receb. de Pagamento ","memoGenerationForm":"MANUAL","memoDate":"2014-10-04T05:05:56.000-03:00","memoUserId":"41002","memoText":"nTEXTO DO SISTEMA:nPagamento Recebido.  Data do Deposito do Pagamento: 20141004.  Valor: $0.43.nTEXTO DO USUARIO:nSolicitacao PS8n"}]}}';
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