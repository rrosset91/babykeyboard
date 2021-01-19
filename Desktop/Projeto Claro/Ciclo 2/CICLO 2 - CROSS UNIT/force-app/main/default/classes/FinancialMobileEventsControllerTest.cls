@isTest
public class FinancialMobileEventsControllerTest {
    @testSetup static void charge(){
        ServiceParameter__c setting = new ServiceParameter__c();
        setting.Token__c = 'returnedToken';
        setting.Name = 'GetSubscriberVas';
        setting.EndPoint__c = 'callout:OAGClaro/subscribervas';
        setting.Method__c = 'GET';
        setting.ReturnMock__c = true;
        setting.Timeout__c = 120000;
        insert setting;
       
    }
    
    @isTest public static void getAccordionsTest(){
        test.startTest();
        List<FinancialMobileEventsWrapper.EventGroup> result = FinancialMobileEventsController.eventsAccordionsProvider();
        test.stopTest();
        system.assertEquals(true, result.size() > 1);
    }

    @isTest public static void buildRequestsTest(){
        String mockAccordion = getMockData('accordion');
        String mockProps = getMockData('props');
        String mockFilters = getMockData('filters');
        test.startTest();
        Map<String,Object> result = FinancialMobileEventsController.accordionsRequestBuilder(mockAccordion, mockProps, mockFilters);
        test.stopTest();
        system.assert(result != null);
    }
    
    @isTest public static void accordionsRequestPerfomerTest(){
        
        String body = null;
        Map<String,String> params = null;
        Map<String,String> headers = null;
		FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = new FinancialMobileEventsWrapper.EventRequestAttributes();
        requesterAccordion.customSetting = 'GetSubscriberVas';
        requesterAccordion.namedCredential = 'namedCredential';
        test.startTest();
        String message = '';
        try{
        	Test.setMock(HttpCalloutMock.class, new SingleMockCallout(getMockData('successJson'), 200));
            FinancialMobileEventsController.accordionsRequestPerfomer(body, params, headers, requesterAccordion);
        }catch(Exception e){
            message = e.getMessage();
        }
        test.stopTest();
        system.assertEquals(false, message == null);
    }
    
    private static String getMockData(String parameters){
   	switch on parameters {
        when 'accordion'{
        	return '{"customSetting":"GetSubscriberVas","hasMultipleGroups":false,"namedCredential":"OAGClaro"}';
        }
        when 'props'{
        	return '{"contractAccountSalesforceId":"0011g00000pmhAeAAI","contractId":"18784183","isCase":true,"isN2User":false,"operatorId":"005","recordId":"5001g000009YYOyAAO"}'; 
        }
        when 'filters'{
        	return '{"periodFilter":6,"isCustomDateFilter":false}';
        }
        when 'successJson'{
        	return '{"apiVersion":"1;2019-10-06","transactionId":"Id-1059985fdce48cb957846d84","data":{"subscribersVas":[{"serviceName":"3","serviceAggregatorName":"Livroh TESTE","aggregatorName":"Minha Claro","msisdn":"11992702918","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2018-12-19T14:26:38.000-02:00","effectiveDate":"2018-12-19T14:26:38.000-02:00","expirationDate":"2018-12-19T14:26:40.000-02:00","amount":"4.99","amountType":"NET","cancellationDate":"2018-12-21T16:53:11.000-02:00","cancellationCode":"201813767","requestTypeId":"MIGRADO","requestDescription":"CUSTOMER_SERVICE","statusReasonDescription":"Serviço cancelado","confirmationDate":"2018-12-19T14:26:38.000-02:00","confirmationCode":"201813672","rateCode":"SGV029","id":"53720","solicitationDate":"2018-12-19T14:26:38.000-02:00","aggregatorDateRequest":"2018-12-19T14:26:38.000-02:00"}]}}';
        }
        when else {
        return null;
        }
    }
    }
}