@isTest
public class FinancialMobileRequestsBuilderTest {
    @testSetup static void charge(){
        List<ServiceParameter__c> servicesList = new List<ServiceParameter__c>();
        ServiceParameter__c subscribersSetting = new ServiceParameter__c();
        subscribersSetting.Token__c = 'returnedToken';
        subscribersSetting.Name = 'GetSubscriberVas';
        subscribersSetting.EndPoint__c = 'callout:OAGClaro/subscribervas';
        subscribersSetting.Method__c = 'GET';
        subscribersSetting.ReturnMock__c = true;
        subscribersSetting.Timeout__c = 120000;
        servicesList.add(subscribersSetting);
        
        ServiceParameter__c interactionsSetting = new ServiceParameter__c();
        interactionsSetting.Token__c = 'returnedToken';
        interactionsSetting.Name = 'GetInteractions';
        interactionsSetting.EndPoint__c = 'callout:OAGClaro/interactions';
        interactionsSetting.Method__c = 'GET';
        interactionsSetting.ReturnMock__c = true;
        interactionsSetting.Timeout__c = 120000;
        servicesList.add(interactionsSetting);
        
        ServiceParameter__c mockSetting = new ServiceParameter__c();
        mockSetting.Token__c = 'returnedToken';
        mockSetting.Name = 'MockOne';
        mockSetting.EndPoint__c = 'callout:OAGClaro/mockedOne';
        mockSetting.Method__c = 'GET';
        mockSetting.ReturnMock__c = true;
        mockSetting.Timeout__c = 120000;
        servicesList.add(mockSetting);
        
        insert servicesList;
    }
    //TESTE PARA SUBSCRIBERS
    @isTest public static void requestParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void requestHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void requestBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    
    //TESTE PARA INTERACTIONS
    @isTest public static void requestInteractionsParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void requestInteractionsHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void requestInteractionsBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
     //TESTE PARA NULL/OUTROS
    @isTest public static void requestNullParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filters);
        test.stopTest();
        system.assert(result == null);
    }
    @isTest public static void requestNullHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        test.startTest();
        Map<String, String> result = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
        test.stopTest();
        system.assert(result == null);
    }
    @isTest public static void requestNullBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        test.startTest();
        String result = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
        test.stopTest();
        system.assert(result == null);
    }
    
        private static String getMockData(String parameters){
   	switch on parameters {
        when 'SubscriberAccordion'{
        	return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
        }
        when 'InteractionsAccordion'{
        	return '{"customSetting":"GetInteractions","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
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
}