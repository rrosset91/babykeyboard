@isTest 
public class CEC_PME_SharerRecordTest {

    @testSetup
    public static void testSetup() {
        Hierarchy__c newHierarchyParent = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchy();
        insert newHierarchyParent;
        
        Hierarchy__c newHierarchy = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchyWithParent(newHierarchyParent.Id);
        insert newHierarchy;
        
        Member__c newMember = CEC_PME_MemberTriggerHandlerTest.builderMember(newHierarchy.Id, null);
        insert newMember;
        
    }
    
    @isTest
    public static void sharingRecordOrder() {
        Order newOrder = CEC_OrderTriggerTest.builderOrder();
        
        new CEC_PME_SharerRecord().sharingRecordOrder(new List<Order>{newOrder});
    }
    
    @isTest
    public static void sharingRecordOpportunity() {
        Opportunity newOpportunity = CEC_OpportunityTriggerTest.builderOpportunity();
        newOpportunity.OwnerId = System.UserInfo.getUserId();
        update newOpportunity;
        
        new CEC_PME_SharerRecord().sharingRecordOpportunity(new List<Opportunity>{newOpportunity});
    }
    
    @isTest
    public static void testBuilders() {
        new CEC_PME_SharerRecord().builderOrderShare(null, null);
        new CEC_PME_SharerRecord().builderOpportunityShare(null, null);
    }
    
    
}