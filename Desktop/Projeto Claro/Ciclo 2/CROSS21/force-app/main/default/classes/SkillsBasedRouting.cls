Global class SkillsBasedRouting {

  @ InvocableMethod
  public static void routeUsingSkills(List<String> cases) {
    
    List<Case> caseObjects = [SELECT Id, Description,Skill__c FROM Case WHERE Id in :cases];
    system.debug('ENTROU AQUI!!');
    for (Case caseObj : caseObjects) {
      
      PendingServiceRouting psrObj = new PendingServiceRouting(
        CapacityWeight = 1,
        IsReadyForRouting = false,
        RoutingModel  = 'MostAvailable',
        RoutingPriority = 1,
        RoutingType = 'SkillsBased',
        ServiceChannelId = getChannelId('CaseCC'),
        WorkItemId = caseObj.Id
      );
      
      insert psrObj;
      
      psrObj = [select id, IsReadyForRouting from PendingServiceRouting where id = : psrObj.id];
         
         
      System.debug('>> PendingServiceRouting: '+psrObj);

      SkillRequirement srObj = new SkillRequirement(
        RelatedRecordId = psrObj.id,
        SkillId = getSkillId(caseObj.Skill__c),
        SkillLevel = 5
      );
      
      insert srObj;

      psrObj.IsReadyForRouting = TRUE;
      update psrObj;

    }
    return;
  }
  
  public static String getChannelId(String channelName) {
      System.debug('>> getChannelId');
      ServiceChannel channel = [Select Id From ServiceChannel Where DeveloperName = :channelName];
      
      System.debug('>> channel: '+channel);
      
      return channel.Id;
  }
  
  public static String getSkillId(String caseDescription) {
     
    Skill skill = [Select Id From Skill Where DeveloperName = :caseDescription];
      
    System.debug('>> skill: '+skill);
      
    return skill.Id;
  }
}