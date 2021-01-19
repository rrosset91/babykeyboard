@isTest
global class CEC_360_IntegrationHistoryDetailsTst  implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiVersion": "1;2020-07-21","transactionId": "5f4b284e-e5e7-4ee0-890a-7bf3220d3a42","data": {"formField33": "A Claro e a Covid 19","formField35":" identificado","formField29": "Salesforce","requestDetails": "teste"}}');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest
    public static void testGetCallout() {
        CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails objectGet = new  CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails();
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationHistoryDetailsTst()); 
        
        objectGet = CEC_360_IntegrationHistoryDetails.GetHistoryOrdersDetails('2RGGJ87YKT');
        System.debug('Id response get: ' + objectGet.data.formField29);
        System.assertEquals(objectGet.data.formField29, 'Salesforce');
    }
    
    
}