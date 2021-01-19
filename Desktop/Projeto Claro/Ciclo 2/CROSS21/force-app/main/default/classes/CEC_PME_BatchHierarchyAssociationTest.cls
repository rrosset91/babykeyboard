@isTest 
public class CEC_PME_BatchHierarchyAssociationTest {
    @testSetup
    public static void testSetup() {
        Hierarchy__c newHierarchyParent = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchy();
        insert newHierarchyParent;
        
        Hierarchy__c newHierarchy = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchyWithParent(newHierarchyParent.Id);
        insert newHierarchy;
    }
    
    @isTest
    public static void main() {
        Database.executeBatch(new CEC_PME_BatchHierarchyAssociation(), 1000);
    }

}