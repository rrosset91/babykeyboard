/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1: acionador do objeto membro
*/
trigger CEC_MemberTrigger on Member__c (after insert, after update, before delete) {
    new CEC_PME_MemberTriggerHandler().run();
}