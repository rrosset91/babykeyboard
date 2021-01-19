@isTest
public class FinancialMobileInteractionsEventsTest {
@testSetup static void charge(){
    
        ServiceParameter__c interactionsSetting = new ServiceParameter__c();
        interactionsSetting.Token__c = 'returnedToken';
        interactionsSetting.Name = 'GetInteractions';
        interactionsSetting.EndPoint__c = 'callout:OAGClaro/interactions';
        interactionsSetting.Method__c = 'GET';
        interactionsSetting.ReturnMock__c = true;
        interactionsSetting.Timeout__c = 120000;

        insert interactionsSetting;

    
    	ServiceParameter__c protocolSetting = new ServiceParameter__c();
        protocolSetting.Token__c = 'returnedToken';
        protocolSetting.Name = 'GetInteractionsProtocol';
        protocolSetting.EndPoint__c = 'callout:OAGClaro/interactions';
        protocolSetting.Method__c = 'GET';
        protocolSetting.ReturnMock__c = true;
        protocolSetting.Timeout__c = 120000;
        insert protocolSetting;
    }
    

    //TESTE DOS METODOS DE REQUEST
    @isTest
    public static void getParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
        test.startTest();
        Map<String, String> result = FinancialMobileInteractionsEvents.getParams(requesterAccordion, baseAttributes, filters);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest
    public static void getHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        test.startTest();
        Map<String, String> result = FinancialMobileInteractionsEvents.getHeaders(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest
    public static void getBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        test.startTest();
        String result = FinancialMobileInteractionsEvents.getBody(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
   	//TESTE DOS MÉTODOS DE RESPONSE
	@isTest
    public static void processJsonTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        String responseJSON = getMockData('ResponseJson');
        test.startTest();
        Object result = FinancialMobileInteractionsEvents.processJSON(responseJSON, requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest
    public static void getColumnsTest(){
        test.startTest();
        Object result = FinancialMobileInteractionsEvents.getColumns();
        test.stopTest();
        system.assert(result != null);
    }
    @isTest
    public static void getModalFieldsTest(){
        test.startTest();
        Object result = FinancialMobileInteractionsEvents.getModalFields();
        test.stopTest();
        system.assert(result != null);
    }

    
    @isTest
    public static void rowActionRequestPerformerTest(){
        test.startTest();
        String message = '';
        try{
        	Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getMockData('successProtocolJson'), 200));
            FinancialMobileInteractionsEvents.rowActionRequestPerformer('GetInteractionsProtocol', '20203310');
        }catch(Exception e){
            message = e.getMessage();
        }
        test.stopTest();
        system.assertEquals(false, message == null);
    }
    @isTest
    public static void processRowJsonTest(){
        test.startTest();
       	Object result = FinancialMobileInteractionsEvents.processRowActionResponse(getMockData('successProtocolJson'));
        test.stopTest();
        system.assert(result != null);
    }

    private static String getMockData(String parameters){
   		switch on parameters {
            when 'Accordion'{
                return '{"customSetting":"GetInteractions","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
            }
            when 'props'{
                return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}';
            }
            when 'filters'{
                return '{"periodFilter":6,"isCustomDateFilter":false}';
            }
            when 'ResponseJson'{
                return '{"apiVersion":"1;2019-08-28","transactionId":"Id-4d6e985fd0fe64bfd472c9a7","data":{"attendances":[{"occurrenceId":"36644412","interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","protocolNumber":"202033346","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644269","interactionSequenceId":"1","solicitationDateOpening":"2020-09-17T10:00:44.000-03:00","protocolNumber":"202033138","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "}]}}';
            }

            when 'successProtocolJson'{
                return '{"apiVersion":"1;2019-08-28","transactionId":"Id-3a65a15f7300bb0256ceba7e","data":{"attendances":[{"interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","interactionModificationDate":"2020-09-21T17:42:38.000-03:00","protocolNumber":"202033346","contactName":"JESSICA SANTOS","msisdn":"11940634801","channelRequestId":"PROCEDURE","situation":"ABERTO","slaIndicatorExceeded":"false","reasonDescription1":"Procedimento Interno","reasonDescription2":"Claro Controle","reasonCode3":"CEC","reasonDescription3":"CEC","reasonCode4":"Anatel","reasonDescription4":"Anatel","description":" ","closedSituationIndicator":"false","memo":"Teste campo memo regressão","contactReturnType":"TELEFONE","contactTelephoneNumber":"11940634801","name":"JESSICA SANTOS","updateInteraction":[{"updateResume":"1-Teste resumo regressão","updateDetail":"Teste detalhes TU31 regressão","updateDate":["2020-09-21T17:42:38.000-03:00","2020-09-21T17:42:38.000-03:00"]}],"address":null}]}}';
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