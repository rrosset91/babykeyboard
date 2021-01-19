@isTest 
public class CEC_PME_BatchDeleteTest {

    @isTest
    public static void deleteMember() {
        Member__c newMember = CEC_PME_MemberTriggerHandlerTest.builderMember();
        List<Id> listIdsToDelete = new List<Id>();
        
        Database.executeBatch( new CEC_PME_BatchDelete(listIdsToDelete, 'Member__c'), 100);
    }
}