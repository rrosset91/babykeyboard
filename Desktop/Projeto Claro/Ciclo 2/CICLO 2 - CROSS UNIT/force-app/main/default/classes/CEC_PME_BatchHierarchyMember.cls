/* 
* Autor: Diogo Braga - Deloitte
* Data: 08/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto membro
*/
public class CEC_PME_BatchHierarchyMember implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime nowLessOneDay = System.now().addDays(-10);
        String query = 'SELECT Id, User__c, Hierarchy__c FROM Member__c WHERE LastModifiedDate >= :nowLessOneDay';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Member__c> listMembers) {
        
        new CEC_PME_HierarchyMemberBO().createListMembersWithoutAssociations(listMembers);
        
    }
    
    public void finish(Database.BatchableContext batchableContext) {
       
    }
}