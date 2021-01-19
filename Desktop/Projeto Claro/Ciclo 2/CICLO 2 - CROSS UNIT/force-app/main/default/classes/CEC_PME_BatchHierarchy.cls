/*  
* Autor: Diogo Braga - Deloitte
* Data: 23/05/2019
* 
*  ---------------------------------------------------------------
*/
public class CEC_PME_BatchHierarchy implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime nowLessOneDay = System.now().addDays(-1);
        String query = 'SELECT Id, Name, ParentHierarchy__c, LastModifiedDate FROM Hierarchy__c WHERE LastModifiedDate >= :nowLessOneDay';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Hierarchy__c> listHierarchies) {
        CEC_PME_HierarchyBO hierarchyBO = new CEC_PME_HierarchyBO();
        
        List<Hierarchy__c> listHierarchiesWithoutGroups = hierarchyBO.getListHierarchiesWithoutGroups(listHierarchies);
        List<Group> listNewGroups = hierarchyBO.createGroups(listHierarchiesWithoutGroups);
        
    }
    
    public void finish(Database.BatchableContext batchableContext) {
       Database.executeBatch(new CEC_PME_BatchHierarchyAssociation(), 1000);
    }
}