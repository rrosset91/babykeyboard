/*      
* Autor: Bruno Felix- IBM
* Data: 30/07/2020
* Descrição: SOLAR FASE 2 + SQUAD KB:Trigger do objeto KNOWLEDGE.
*/
trigger KB_KnowledgeTrigger  on Knowledge__kav (before update) {
    new KB_KnowledgeTriggerHandler().run();
}