@isTest
public class CEC_IntegrationInteractionsTest 
{ 
    
    @testSetup
    public static void testSetup()
    {
        insert new ServiceParameter__c(Name = 'Interactions', EndPoint__c = 'https://teste.com', Method__c = 'POST', IsActive__c=true);
    }
    
    @isTest
    public static void unitTest()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_IntegrationInteractions integration = new CEC_IntegrationInteractions();
        
        InteractionsDTO.Request request = (new InteractionsDTO()).builderRequestForControle('11945477785');
        integration.consultar('11977886655', true);
        //request = (new InteractionsDTO()).builderRequestForPos('11945477785');
        //integration.consultar(request);
        test.stopTest();
    }
    public static InteractionsDTO.Response generateMock(String url, Integer aHttpCode)
    {
        InteractionsDTO.Response response = new InteractionsDTO.Response();
        InteractionsDTO.DataResponse data = new InteractionsDTO.DataResponse();
        data.protocolNumber = '999999999';
        response.data = data;
        return response;
    }

}