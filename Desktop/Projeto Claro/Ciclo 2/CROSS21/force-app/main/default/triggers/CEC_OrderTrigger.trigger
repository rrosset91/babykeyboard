/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1: acionador do objeto pedido
*/
trigger CEC_OrderTrigger on Order (after insert, before update) {
    new CEC_PME_OrderTriggerHandler().run();
}