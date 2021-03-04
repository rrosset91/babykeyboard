trigger DocuSignRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (after insert, after update) {
    DocuSignRecipientStatusTriggerHandler handler = new DocuSignRecipientStatusTriggerHandler();
    handler.listNew = Trigger.new;

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.onAfterInsert();
        }
        if(Trigger.isUpdate) {
            handler.onAfterUpdate();
        }
    }
}