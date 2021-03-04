/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1: acionador do objeto oportunidade
*/
trigger CEC_OpportunityTrigger on Opportunity (after insert, before update) { 
    new CEC_PME_OpportunityTriggerHandler().run();
}