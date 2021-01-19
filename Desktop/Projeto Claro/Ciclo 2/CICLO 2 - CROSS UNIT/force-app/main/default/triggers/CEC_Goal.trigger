trigger CEC_Goal on goal__c (before insert, before update) {

  if(trigger.isBefore)
  {
    if(trigger.isInsert)
    {
      CEC_GoalMethods.updateGoalOwner(trigger.new, trigger.oldMap);
    }
    if(trigger.isUpdate)
    {
      CEC_GoalMethods.updateGoalOwner(trigger.new, trigger.oldMap);   
    }
  }
}