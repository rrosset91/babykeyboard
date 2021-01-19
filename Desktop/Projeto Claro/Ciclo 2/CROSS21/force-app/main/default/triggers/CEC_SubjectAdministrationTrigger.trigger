/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 24/07/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 10] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 24/07/2019  
* Autor: Squad Canais Criticos
* Alterações: Utilização de TriggerHandler  atualização do campo unidade de  negocio e produto do case
* ---------------------------------------------------------------
*/
trigger CEC_SubjectAdministrationTrigger on SubjectAdministration__c (before insert, before update) {
	
       //if(!Util.isTriggerEnabled()){ return ; }
    
    CEC_SubjectAdministrationHandler handler = new CEC_SubjectAdministrationHandler();
    
    handler.newRecordList = trigger.new;
    handler.oldRecordList = trigger.old;
    handler.newRecordMap = trigger.newMap;
    handler.oldRecordMap = trigger.oldMap;
    
    if(trigger.isBefore)
    {
        if(trigger.isUpdate){ handler.onBeforeUpdate(); }
        if(trigger.isInsert){ handler.onBeforeInsert(); }
    }
    
}