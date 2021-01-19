trigger CEC_OrderItem on OrderItem (before update) {
    CEC_PME_OrderItem_TriggerHandler orderItemHandler = new CEC_PME_OrderItem_TriggerHandler();
   if(trigger.isBefore){
        if(trigger.isUpdate){
            orderItemHandler.verifyVlcPricing(Trigger.new, Trigger.oldMap);
            orderItemHandler.applyOrderDiscountItem(Trigger.new, Trigger.oldMap);
        }
    }
}