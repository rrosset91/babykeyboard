@isTest
public class CEC_PME_BatchHierarchyMemberTest {

    @testSetup 
    static void testSetup() {
        Member__c newMember = CEC_PME_MemberTriggerHandlerTest.builderMember();
        insert newMember;
    }
    
    @isTest
    static void executeBatch() {
        Database.executeBatch(new CEC_PME_BatchHierarchyMember(), 1000);
    }
    
}