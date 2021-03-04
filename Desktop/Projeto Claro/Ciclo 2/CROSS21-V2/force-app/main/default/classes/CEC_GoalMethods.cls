public class CEC_GoalMethods {
    
  public static void updateGoalOwner(list<Goal__c> lstNewGoal, map<id,Goal__C> mapGoalOld)
  {
    boolean isInsert = (mapGoalOld == null);
      
    for (Goal__c iGoal: lstNewGoal)
    {
      Goal__c lOldGoal = (isInsert) ? new Goal__c() : mapGoalOld.get(iGoal.id);
      if(isInsert && iGoal.User__c != null) iGoal.OwnerId = iGoal.User__c;
      else if(!isInsert && iGoal.User__c != lOldGoal.User__c )
          iGoal.addError('Não pode alterar o proprietário dessa meta. Crie uma nova meta.', false);
      else continue;
    }
   
  }

}