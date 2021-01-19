public class CEC_InstanceObject {
    
  public static vlocity_cmt__CustomerInteraction__c getCustomerInteraction()
  {
      vlocity_cmt__CustomerInteraction__c varCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
      varCustomerInteraction.Name = 'Interação Consumidor.gov';
      varCustomerInteraction.vlocity_cmt__Type__c = 'Consumidor.gov';
      varCustomerInteraction.vlocity_cmt__Channel__c = 'Web';
      varCustomerInteraction.Description__c = 'Teste';
      varCustomerInteraction.vlocity_cmt__Status__c = 'Completed';
      varCustomerInteraction.vlocity_cmt__StartDateTime__c = System.now();
      
      return varCustomerInteraction;
  }
    
    public static vlocity_cmt__CustomerInteractionTopic__c getCustomerInteractionTopic(vlocity_cmt__CustomerInteraction__c varCustomerInteraction, Case varCase)
    {
        vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c = varCustomerInteraction.Id;
        varCustomerInteractionTopic.vlocity_cmt__CaseId__c = varCase.Id;
            
        return varCustomerInteractionTopic;
    }
    
  public static Account getAccount()
  {
    Account lAccount = new Account();
    lAccount.Name = 'Conta Teste';
      
    return lAccount;
  }
    
  public static Contact getContact()
  {
    Contact lContact = new Contact();
    lContact.FirstName = 'Nome ';
    lContact.LastName = 'Test';
      
    return lContact;
  }
   
  public static Case getCase(Account aAcc)
  {
    Case lCase = new Case();
    lCase.BusinessUnit__c = 'Claro';
    lCase.AccountId = aAcc.Id;
    lCase.Grouping__c = 'Consumidor.gov';
    lCase.Channel__c = 'Consumidor.gov';
    lCase.InputType__c = 'Site Consumidor.gov';
    lCase.Status = 'Novo';
    lCase.SubStatus__c = 'Não Iniciado';
    lCase.InputType__c = 'Site Consumidor.gov';
    lCase.CriticalChannelProtocol__c = '1234567';
    lCase.OpenDateRobot__c = system.now();
      
    return lCase;
      
  }
    
  public static Case getCase(Contact lContact)
  {
    Case lCase = new Case();
    lCase.BusinessUnit__c = 'Claro';
    lCase.ContactId = lContact.Id;
    lCase.Grouping__c = 'Consumidor.gov';
    lCase.Channel__c = 'Consumidor.gov';
    lCase.InputType__c = 'Site Consumidor.gov';
    lCase.Status = 'Novo';
    lCase.SubStatus__c = 'Não Iniciado';
    lCase.InputType__c = 'Site Consumidor.gov';
    lCase.CriticalChannelProtocol__c = '1234567';
    lCase.OpenDateRobot__c = system.now();
      
    return lCase;
      
  }
    
  public static ServiceParameter__c getServiceParameter(String name, String endPoint, String method,
                                                          String password, String user)
  {
    ServiceParameter__c lService = new ServiceParameter__c();
    lService.Name = name;
    lService.EndPoint__c = endPoint;
    lService.Method__c = method;
    lService.Password__c =  password;
    lService.User__c = user;
    
    return lService;
  }
    
  public static Quiz__c getQuiz()
  {
    Quiz__c lQuiz = new Quiz__c();
    lQuiz.Name = 'Area' + Math.random();
    lQuiz.SubArea__c = 'Sub Area' + Math.random();
    return lQuiz;
  }
    
  public static List<Quiz__c> getListQuiz(Integer quantity)
  {
    List<Quiz__c> lstQuiz = new List<Quiz__c>();
    for (Integer i = 0; i < quantity; i++) {
      Quiz__c sObjQuiz = getQuiz();
      lstQuiz.add(sObjQuiz);
    }
    return lstQuiz;
  }
  
  public static ParamQuestion__c getParamQuestion(Quiz__c lQuiz)
  {
      ParamQuestion__c lParamQuestion = new ParamQuestion__c();
      lParamQuestion.Name = 'Pergunta ' + Math.random();
      lParamQuestion.TypeQuestion__c = 'Text';
      lParamQuestion.Questionario__c = lQuiz.Id;
      return lParamQuestion;
  }
    
  public static List<ParamQuestion__c> getListParamQuestion(Integer quantity,Quiz__c lQuiz)
  {
    List<ParamQuestion__c> lstParamQuestion = new List<ParamQuestion__c>();
    for (Integer i = 0; i < quantity; i++) {
      ParamQuestion__c sObjParamQuestion = getParamQuestion(lQuiz);
      lstParamQuestion.add(sObjParamQuestion);
    }
    return lstParamQuestion;
  }
  
  public static ContentVersion getContentVersion()
  {
    ContentVersion contentVersion = new ContentVersion();
    contentVersion.Title = 'Penguins'+ Math.random();
    contentVersion.PathOnClient = 'Penguins.jpg';
    contentVersion.VersionData = Blob.valueOf('Test Content');
    contentVersion.IsMajorVersion = true;
    return contentVersion;
    //insert contentVersion; 
  }
  
  public static List<ContentVersion> getListContentVersion(Integer quantity)
  {
    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    for (Integer i = 0; i < quantity; i++) {
      ContentVersion sObjContentVersion = getContentVersion();
      lstContentVersion.add(sObjContentVersion);
    }
    return lstContentVersion;
  }
  
  public static ContentDocumentLink getContentDocumentLink(Id lDocument)
  {
    ContentDocumentLink lContentDocumentLink = New ContentDocumentLink();
    lContentDocumentLink.LinkedEntityId = UserInfo.getUserId();
    lContentDocumentLink.ContentDocumentId = lDocument;
    lContentDocumentLink.shareType = 'V';
    return lContentDocumentLink;
  }
       
  public static  Entitlement getEntitlement()
  {
    return new Entitlement(Name = 'Name');
  }
    
  public static goal__c getGoal(Id userId)
  {
      goal__c lGoal = new goal__c();
      lGoal.Name = 'Meta'+ Math.random();
      lGoal.StartDate__c = system.today();
      lGoal.EndDate__c = system.today()+1;
      lGoal.Value_Calculation__c = 10;
      lGoal.User__c = userId;
      
      return lGoal;
  }
    
  /*public static string getstatusInteraction()
      
  {
      List<vlocity_cmt__CustomerInteraction__c> listObj =  
          [SELECT vlocity_cmt__Status__c 
              FROM vlocity_cmt__CustomerInteraction__c 
              LIMIT 1];
      return listObj[0].vlocity_cmt__Status__c;
  }*/
}