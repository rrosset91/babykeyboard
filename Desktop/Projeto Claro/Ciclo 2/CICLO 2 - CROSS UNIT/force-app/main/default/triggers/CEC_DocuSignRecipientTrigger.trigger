/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1: acionador do objeto dsfs__DocuSign_Recipient_Status__c
*/
trigger CEC_DocuSignRecipientTrigger on dsfs__DocuSign_Recipient_Status__c (after insert, after update) {
    new CEC_PME_DocuSignRecipientTriggerHandler().run();
}