@isTest
public class FinancialMobileEventsAccordionsTest {
    @testSetup static void charge(){
    }
    
    @isTest public static void getAccordionsListTest(){
        test.startTest();
        List<FinancialMobileEventsWrapper.EventGroup> result = FinancialMobileEventsAccordionsProvider.getAccordionsList();
        test.stopTest();
        system.assertEquals(true, result.size() > 1);
    }
}