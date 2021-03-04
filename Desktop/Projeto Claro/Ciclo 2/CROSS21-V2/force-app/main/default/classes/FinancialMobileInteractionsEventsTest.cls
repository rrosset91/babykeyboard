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
public class FinancialMobileInteractionsEventsTest {

	@testSetup 
	static void makeData(){
    
        ServiceParameter__c interactionsSetting = new ServiceParameter__c();
        interactionsSetting.Token__c = 'returnedToken';
        interactionsSetting.Name = 'GetInteractions';
        interactionsSetting.EndPoint__c = 'GetInteractions';
        interactionsSetting.Method__c = 'GET';
        interactionsSetting.Timeout__c = 120000;
        insert interactionsSetting;
    
    	ServiceParameter__c protocolSetting = new ServiceParameter__c();
        protocolSetting.Token__c = 'returnedToken';
        protocolSetting.Name = 'GetInteractionsProtocol';
        protocolSetting.EndPoint__c = 'GetInteractionsProtocol';
        protocolSetting.Method__c = 'GET';
        protocolSetting.Timeout__c = 120000;
        insert protocolSetting;
    }
    
    @isTest
    public static void getParamsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(getMockData('props'));
        FinancialMobileFiltersWrapper.filterValues filters = parseFilterParams(getMockData('filters'));
		
		Test.startTest();
        Map<String, String> result = FinancialMobileInteractionsEvents.getParams(requesterAccordion, baseAttributes, filters);
        Test.stopTest();
		
		System.assert(result != null);
	}
	
    @isTest
    public static void getHeadersTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.setMock(HttpCalloutMock.class, new Mock());
		
		Test.startTest();
        Map<String, String> result = FinancialMobileInteractionsEvents.getHeaders(requesterAccordion);
        Test.stopTest();
		
		System.assert(result != null);
	}
	
    @isTest
    public static void getBodyTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
		
		Test.startTest();
        String result = FinancialMobileInteractionsEvents.getBody(requesterAccordion);
        Test.stopTest();
		
		System.assert(result != null);
	}
	
	@isTest
    public static void processJsonTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('Accordion'));
        String responseJSON = getMockData('ResponseJson');
		
		Test.startTest();
        Object result = FinancialMobileInteractionsEvents.processJSON(responseJSON, requesterAccordion);
        Test.stopTest();
		
		System.assert(result != null);
	}
	
    @isTest
    public static void getColumnsTest(){
		
		Test.startTest();
        Object result = FinancialMobileInteractionsEvents.getColumns();
        Test.stopTest();
		
		System.assert(result != null);
	}
	
    @isTest
    public static void getModalFieldsTest(){
		
		Test.startTest();
        Object result = FinancialMobileInteractionsEvents.getModalFields();
        Test.stopTest();
		
		System.assert(result != null);
    }
    
    @isTest
    public static void rowActionRequestPerformerTest(){
		
		Test.startTest();
        String message = '';
		
		try{
        	Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getMockData('successProtocolJson'), 200));
            FinancialMobileInteractionsEvents.rowActionRequestPerformer('GetInteractionsProtocol', '20203310');
        }catch(Exception e){
            message = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, message == null);
	}
	
    @isTest
    public static void processRowJsonTest(){
		
		Test.startTest();
       	Object result = FinancialMobileInteractionsEvents.processRowActionResponse(getMockData('successProtocolJson'));
        Test.stopTest();
		
		System.assert(result != null);
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
	
	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('GetInteractions')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2019-08-28","transactionId":"Id-932a945f3adf011427e1e6e7","data":{"attendances":[{"occurrenceId":"36644412","interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","protocolNumber":"202033346","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644269","interactionSequenceId":"1","solicitationDateOpening":"2020-09-17T10:00:44.000-03:00","protocolNumber":"202033138","situation":"ABERTO","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"CEC","reasonCode4":"Anatel","description":" "},{"occurrenceId":"36644448","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T17:07:47.000-03:00","solicitationDateClosing":"2020-09-15T17:07:47.000-03:00","protocolNumber":"202033030","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644447","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:40.000-03:00","solicitationDateClosing":"2020-09-15T16:51:40.000-03:00","protocolNumber":"202033028","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644446","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T16:51:29.000-03:00","solicitationDateClosing":"2020-09-15T16:51:29.000-03:00","protocolNumber":"202033027","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36644445","interactionSequenceId":"1","solicitationDateOpening":"2020-09-15T15:04:21.000-03:00","solicitationDateClosing":"2020-09-15T15:04:21.000-03:00","protocolNumber":"202033016","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643122","interactionSequenceId":"1","solicitationDateOpening":"2020-09-02T11:53:00.000-03:00","solicitationDateClosing":"2020-09-02T11:53:00.000-03:00","protocolNumber":"202031618","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643102","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T17:50:26.000-03:00","solicitationDateClosing":"2020-08-31T17:50:26.000-03:00","protocolNumber":"202031438","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36643103","interactionSequenceId":"1","solicitationDateOpening":"2020-08-31T16:11:17.000-03:00","solicitationDateClosing":"2020-08-31T16:11:17.000-03:00","protocolNumber":"202031395","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642781","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T12:11:42.000-03:00","solicitationDateClosing":"2020-08-27T12:11:42.000-03:00","protocolNumber":"202031236","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642780","interactionSequenceId":"1","solicitationDateOpening":"2020-08-27T11:38:49.000-03:00","solicitationDateClosing":"2020-08-27T11:38:49.000-03:00","protocolNumber":"202031235","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Controle","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "},{"occurrenceId":"36642779","interactionSequenceId":"1","solicitationDateOpening":"2020-08-26T14:49:32.000-03:00","solicitationDateClosing":"2020-08-26T14:49:32.000-03:00","protocolNumber":"202031175","situation":"PROCEDENTE","slaIndicatorExceeded":"false","reclassificationIndicator":"false","reasonCode1":"Procedimento Interno","reasonCode2":"Claro Conta","reasonCode3":"Solar - ação sistêmica","reasonCode4":"Financeiro","description":" "}]}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('GetInteractionsProtocol')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2019-08-28","transactionId":"Id-3a65a15f7300bb0256ceba7e","data":{"attendances":[{"interactionSequenceId":"1","solicitationDateOpening":"2020-09-21T17:37:31.000-03:00","interactionModificationDate":"2020-09-21T17:42:38.000-03:00","protocolNumber":"202033346","contactName":"JESSICA SANTOS","msisdn":"11940634801","channelRequestId":"PROCEDURE","situation":"ABERTO","slaIndicatorExceeded":"false","reasonDescription1":"Procedimento Interno","reasonDescription2":"Claro Controle","reasonCode3":"CEC","reasonDescription3":"CEC","reasonCode4":"Anatel","reasonDescription4":"Anatel","description":" ","closedSituationIndicator":"false","memo":"Teste campo memo regressão","contactReturnType":"TELEFONE","contactTelephoneNumber":"11940634801","name":"JESSICA SANTOS","updateInteraction":[{"updateResume":"1-Teste resumo regressão","updateDetail":"Teste detalhes TU31 regressão","updateDate":["2020-09-21T17:42:38.000-03:00","2020-09-21T17:42:38.000-03:00"]},{"updateResume":"2-Resumo regressão","updateDetail":"Teste detalhes TU32 regressão","updateDate":["2020-09-19T17:42:38.000-03:00","2020-09-21T17:42:38.000-03:00"]},{"updateResume":"3-Teste resumo atualizado","updateDetail":"Teste detalhes TU33 regressão","updateDate":["2020-08-17T17:42:38.000-03:00","2020-09-21T17:42:38.000-03:00"]},{"updateResume":"4-Teste resumo novo","updateDetail":"Teste detalhes TU34 regressão","updateDate":["2020-08-25T17:42:38.000-03:00","2020-09-21T17:42:38.000-03:00"]}],"address":null}]}}');
                res.setStatusCode(200);
                return res;
			} else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}