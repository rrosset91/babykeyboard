/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto hierarquia 
*/
public class CEC_PME_HierarchyTriggerHandler extends TriggerHandler {
    
    private List<Hierarchy__c> triggerNew;
    private List<Hierarchy__c> triggerOld;
    private Map<Id, Hierarchy__c> triggerOldMap;
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Construtor
    */ 
    public CEC_PME_HierarchyTriggerHandler() {
        triggerNew = (List<Hierarchy__c>) getTriggerNew();
        triggerOld = (List<Hierarchy__c>) getTriggerOld();
        triggerOldMap = new Map<Id, Hierarchy__c>();
        triggerOldMap.putAll(triggerOld);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterInsert() {
        if(!CEC_PME_ResizableHierarchy.isScheduledLessNMinutes(20)) {
            new CEC_PME_ResizableHierarchy(0, 0, 19, false).schedule();
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterUpdate() {
        system.debug('afterUpdate');
            
        if(!CEC_PME_ResizableHierarchy.isScheduledLessNMinutes(20)) {
            new CEC_PME_ResizableHierarchy(0, 0, 19, false).schedule();
        }
        new CEC_PME_HierarchyBO().removeOldAssociationsOfHierarchies(triggerNew, triggerOldMap);  
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void beforeDelete() {
        new CEC_PME_HierarchyBO().deleteGroups(triggerOldMap);
    }
    
}