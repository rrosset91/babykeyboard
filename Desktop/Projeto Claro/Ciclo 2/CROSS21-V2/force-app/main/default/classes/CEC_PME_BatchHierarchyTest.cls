@isTest 
public class CEC_PME_BatchHierarchyTest {
    
    @testSetup
    public static void testSetup() {
        Hierarchy__c hierarchy = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchy();
        insert hierarchy;
    }

    @isTest
    public static void main() {
        Database.executeBatch(new CEC_PME_BatchHierarchy(), 1000);
    }
    
}