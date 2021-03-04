/* 
* Autor: Diogo Braga - Deloitte
* Data: 23/05/2019
* 
*  ---------------------------------------------------------------
*/
public class CEC_PME_BatchHierarchyAssociation implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime nowLessOneDay = System.now().addDays(-1);
        String query = 'SELECT Id, ParentHierarchy__c, LastModifiedDate FROM Hierarchy__c WHERE ParentHierarchy__c != null AND LastModifiedDate >= :nowLessOneDay';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Hierarchy__c> listHierarchies) {
        new CEC_PME_HierarchyBO().associateHierarchies(listHierarchies);
    }
    
    public void finish(Database.BatchableContext batchableContext) {
        Database.executeBatch(new CEC_PME_BatchHierarchyMember(), 1000);
    }
}