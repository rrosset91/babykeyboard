@isTest  
public class CEC_PME_HierarchyTriggerHandlerTest {
    
    public static Hierarchy__c builderHierarchy() {
        Hierarchy__c newHierarchy = new Hierarchy__c();
        newHierarchy.Name = 'HierarchyTest';
        newHierarchy.NomHierarquia__c = 'HierarchyTest';
        newHierarchy.TerritoryCode__c = 'HierarchyTest';
        return newHierarchy;
    }
    
    public static Hierarchy__c builderHierarchyWithParent(Id parentHierarchyId) {
        Hierarchy__c newHierarchy = new Hierarchy__c();
        newHierarchy.Name = 'HierarchyTestWithParent';
        newHierarchy.NomHierarquia__c = 'HierarchyTestWithParent';
        newHierarchy.TerritoryCode__c = 'HierarchyTestWithParent';
        newHierarchy.ParentHierarchy__c = parentHierarchyId;
        return newHierarchy;
    }
	
    /*@isTest public static void insertNewHierarchy() {
        Hierarchy__c newHierarchy = builderHierarchy();
        insert newHierarchy;
        
        List<Group> listGroups = [SELECT Id
                                  FROM Group
                                  WHERE DeveloperName = :newHierarchy.Id];
        System.debug('listGroups ' + listGroups);
        
        System.assert(!listGroups.isEmpty(), 'Erro: Não criou grupo');
    }
    
    @isTest public static void insertNewHierarchyWithParent() {
        Hierarchy__c newHierarchyParent = builderHierarchy();
        insert newHierarchyParent;
        
        Hierarchy__c newHierarchy = builderHierarchyWithParent(newHierarchyParent.Id);
        insert newHierarchy;
        
        List<Group> listGroups = [SELECT Id
                                  FROM Group
                                  WHERE DeveloperName = :newHierarchyParent.Id
                                  OR DeveloperName = :newHierarchy.Id];
        System.debug('listGroups ' + listGroups);
        
        System.assert(listGroups.size() >= 2, 'Erro: Não criou a quantidade correta de grupos');
    }
    
    @isTest public static void addParentOnHierarchy() {
        Hierarchy__c newHierarchyParent = builderHierarchy();
        insert newHierarchyParent;
        
        Hierarchy__c newHierarchy = builderHierarchyWithParent(null);
        insert newHierarchy;
        newHierarchy.ParentHierarchy__c = newHierarchyParent.Id;
        update newHierarchy;
        
        List<Group> listGroups = [SELECT Id
                                  FROM Group
                                  WHERE DeveloperName = :newHierarchyParent.Id
                                  OR DeveloperName = :newHierarchy.Id];
        
        System.assert(listGroups.size() >= 2, 'Erro: Não criou a quantidade correta de grupos');
    }
*/
    @testSetup
    public static void testSetup() {
        Hierarchy__c newHierarchyParent = builderHierarchy();
        insert newHierarchyParent;
        
        Hierarchy__c newHierarchy = builderHierarchyWithParent(newHierarchyParent.Id);
        insert newHierarchy;
        
        Database.executeBatch(new CEC_PME_BatchHierarchy(), 1000);
    }
    
    @isTest 
    public static void removeParentOnHierarchy() {
        Hierarchy__c newHierarchy = [SELECT Id, ParentHierarchy__c FROM Hierarchy__c WHERE ParentHierarchy__c != null];
        newHierarchy.ParentHierarchy__c = null;
        update newHierarchy;
    }
    
    @isTest 
    public static void deleteHierarchy() {
        Hierarchy__c newHierarchy = [SELECT Id, ParentHierarchy__c FROM Hierarchy__c LIMIT 1];
        delete newHierarchy;
        
        List<Hierarchy__c> listHierarchies = [SELECT Id
                                              FROM Hierarchy__c
                                              WHERE Id = :newHierarchy.Id];
        
        System.assert(listHierarchies.isEmpty(), 'Erro: Hierarquia não foi deletada');
    }
}