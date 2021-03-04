/*      
* Autor: Bruno Felix- IBM
* Data: 30/07/2020
* Descrição: SOLAR FASE 2 + SQUAD KB: Classe handler da trigger do objeto KNOWLEDGE.
*/
public class KB_KnowledgeTriggerHandler extends TriggerHandler {
    
    Map<Id, Knowledge__kav> triggerNewMapKB;
    Map<Id, Knowledge__kav> triggerOldMapKB;
    
    public KB_KnowledgeTriggerHandler () {
        triggerNewMapKB = (Map<Id, Knowledge__kav>) Trigger.newMap;
        triggerOldMapKB = (Map<Id, Knowledge__kav>) Trigger.oldMap;
    }
    
    public override void beforeUpdate() {
        KB_KnowledgeTriggerHelper.getArticleCategory(triggerOldMapKB, triggerNewMapKB, triggerNewMapKB.values());
    }
}