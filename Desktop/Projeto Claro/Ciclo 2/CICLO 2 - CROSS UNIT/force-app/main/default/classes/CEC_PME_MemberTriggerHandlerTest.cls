@isTest 
public class CEC_PME_MemberTriggerHandlerTest {
    
    public static Member__c builderMember() {
        Hierarchy__c newHierarchy = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchyWithParent(null);
        insert newHierarchy;
        
        return builderMember(newHierarchy.Id, null);
    }
    
    public static Member__c builderMember(Id hierarchyId,Id companyId) {
        Member__c newMember = new Member__c();
        newMember.Hierarchy__c = hierarchyId;
        newMember.User__c = System.UserInfo.getUserId();
        newMember.IdExterno__c = 'teste ' + newMember.Hierarchy__c + System.UserInfo.getUserId() + companyId;
        newMember.Company__c = companyId;
        return newMember;
    }
    
    public static Company__c builderCompany(String companyCode) {
        Company__c newCompany = new Company__c();
        newCompany.Name = 'test';
        newCompany.RazaoSocial__c = 'test';
        newCompany.CompanyCode__c = companyCode;
        return newCompany;
    }
    
	@testSetup 
    static void testSetup() {
        Company__c newCompany = builderCompany('testSetup');
        insert newCompany;
            
        Hierarchy__c newHierarchy = CEC_PME_HierarchyTriggerHandlerTest.builderHierarchy();
        insert newHierarchy;
        
        Member__c newMember = builderMember();
        insert newMember;
        
        Database.executeBatch(new CEC_PME_BatchHierarchy(), 1000);
    }
    
    @isTest
    static void inserUpdateMember() {
        
        Id hierarchyId = [SELECT Id FROM Hierarchy__c LIMIT 1].Id;
        Id companyId = [SELECT Id FROM Company__c LIMIT 1].Id;
        Member__c newMember = builderMember(hierarchyId, companyId);
        insert newMember;
        update newMember;
    }
    
    @isTest
    public static void deleteMember() {
        delete [SELECT Id FROM Member__c];
    }
}