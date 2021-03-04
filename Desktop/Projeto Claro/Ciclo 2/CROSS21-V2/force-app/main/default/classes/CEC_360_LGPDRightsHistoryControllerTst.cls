@isTest
public class CEC_360_LGPDRightsHistoryControllerTst {

        @isTest
    static void testGetOrdersCallout() {
        // create test account 
        Account acc = new Account();
        acc.Name = 'Teste Get dsar';
        acc.DocumentNumber__c = '11111111111';
        insert acc;
        
        System.Test.startTest();
        CEC_360_LGPDIntegrationObjects.getRightsHistory responseGetDsar = new CEC_360_LGPDIntegrationObjects.getRightsHistory();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationdsarTest());
        responseGetDsar = CEC_360_LGPDRightsHistoryController.getOrdersRightsHistory(acc.id);
        System.Test.stopTest();
        
		system.debug('responseGetDsar: ' + responseGetDsar);
        System.assertEquals(responseGetDsar.customerOrders[0].Id, 'SL244HWD6D');        
    }
            @isTest
    static void testGetOrdersDetailsCallout() {

        
        System.Test.startTest();
        CEC_360_LGPDIntegrationObjects.getHistoricRightsDetails responseGetDsar = new  CEC_360_LGPDIntegrationObjects.getHistoricRightsDetails();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationHistoryDetailsTst()); 
        responseGetDsar = CEC_360_LGPDRightsHistoryController.getOrdersDetailsRightsHistory('5DAPJRSJCK');
        System.Test.stopTest();
        
           
    }
    @isTest
        static void testGetOrdersDetailsGroupsCallout() {

        System.Test.startTest();
        CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract responseGetDsar = new  CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationHistoryExtractTst()); 
        responseGetDsar = CEC_360_LGPDRightsHistoryController.getExtractRightsHistory('5DAPJRSJCK');
        System.Test.stopTest();
        

    }
}