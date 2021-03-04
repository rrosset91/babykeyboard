trigger CustomerInteractionTopicTrigger on vlocity_cmt__CustomerInteractionTopic__c (after insert) 
{
    CustomerInteractionTopicTriggerHandler handler = new CustomerInteractionTopicTriggerHandler();
    
    handler.newRecordList = trigger.new;
    handler.oldRecordList = trigger.old;
    handler.newRecordMap = trigger.newMap;
    handler.oldRecordMap = trigger.oldMap;    
    
    if(trigger.isAfter)
    {       
        if(trigger.isInsert)
        { 
            handler.onAfterInsert(); 
        }
    }    
}