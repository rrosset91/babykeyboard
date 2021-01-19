/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1: acionador do objeto ContentDocumentLink
*/
trigger CEC_ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before insert) {
    new CEC_PME_ContentDocLinkTriggerHandler().run();
    new CEC_CC_ContentDocumentLinkHandler().run();
}