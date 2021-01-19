trigger CEC_InteractionTopicTrigger on vlocity_cmt__CustomerInteractionTopic__c (after insert, before insert) 
{
    CEC_InteractionTopicTriggerHandler handler = new CEC_InteractionTopicTriggerHandler();    
    handler.newRecordList = trigger.new;
    handler.oldRecordList = trigger.old;
    handler.newRecordMap  = trigger.newMap;
    handler.oldRecordMap  = trigger.oldMap;    
    
    if(trigger.isAfter)
    {       
        system.debug('>> trigger.isAfter');        
        if(trigger.isInsert){handler.onAfterInsert();} 
        if(trigger.isUpdate){handler.onAfterUpdate();}
    }else
    {
        system.debug('>> trigger.isBefore');        
        if(trigger.isInsert){handler.onBeforeInsert();} 
        if(trigger.isUpdate){handler.onBeforeUpdate();}
    }
}