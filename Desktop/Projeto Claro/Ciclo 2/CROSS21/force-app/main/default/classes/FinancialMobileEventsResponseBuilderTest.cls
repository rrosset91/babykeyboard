@isTest
public class FinancialMobileEventsResponseBuilderTest {
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
    @isTest public static void processSubscriberResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        String responseJSON = getMockData('SubscriberResponse');
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void getSubscriberAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void getSubscriberModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('SubscriberAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
        test.stopTest();
        system.assert(result == null);
    }
    
    //TESTE PARA INTERACTIONS
    @isTest public static void processInteractionsResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        String responseJSON = getMockData('InteractionsResponse');
        test.startTest();
        FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
        test.stopTest();
    }
    @isTest public static void getInteractionsAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
    @isTest public static void getInteractionsModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('InteractionsAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
        test.stopTest();
        system.assert(result != null);
    }
     //TESTE PARA NULL/OUTROS
    @isTest public static void processNullResponseTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        String responseJSON = getMockData('NullResponse');
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion);
        test.stopTest();
        system.assert(result == null);
    }
    @isTest public static void getNullAccordionColumnsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion);
        test.stopTest();
        system.assert(result == null);
    }
    @isTest public static void getNullModalFieldsTest(){
        FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(getMockData('NullAccordion'));
        test.startTest();
        Object result = FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion);
        test.stopTest();
        system.assert(result == null);
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
}