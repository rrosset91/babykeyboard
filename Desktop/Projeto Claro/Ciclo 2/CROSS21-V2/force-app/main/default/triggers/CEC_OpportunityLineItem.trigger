trigger CEC_OpportunityLineItem on OpportunityLineItem (after delete, after insert, after update, before insert, before update) {
 CEC_PME_OppLineItem_TriggerHandler opportunityLineItemHandler = new CEC_PME_OppLineItem_TriggerHandler();

    if(trigger.isBefore){
        if(trigger.isUpdate){
            opportunityLineItemHandler.verifyVlcPricing(Trigger.new, Trigger.oldMap);
            opportunityLineItemHandler.applyOpportunityDiscountItem(Trigger.new, Trigger.oldMap);
        }
    } 
}