@isTest
public class CEC_GoalMethodsTest {
    
  @isTest private static void updateGoalOwnerTest()
  {
    Goal__C lGoal = CEC_InstanceObject.getGoal(UserInfo.getUserId());
    test.startTest();
      database.saveresult lSavRes = database.insert(lGoal);
    test.stopTest();

    system.assert(lSavRes.isSuccess());
  }
    
  @isTest private static void updateGoalOwnerUpdateTest()
  {
    Goal__C lGoal = CEC_InstanceObject.getGoal(UserInfo.getUserId());
    database.insert(lGoal);
      
    list<Profile> lLstProf = [SELECT Id FROM Profile WHERE PermissionsAuthorApex = true limit 1];
    system.assert(!lLstProf.isEmpty(), 'Erro perfil');
    Id profileTest = lLstProf[0].Id;
        
    user lUser = new user(firstName = 'test', lastName = 'test1', Alias = 'alias', Email = 'teste@claro.com.br', Username = 'rpacc@teste.com.br', Profileid = profileTest, LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
    lUser.CommunityNickname = lUser.lastName;
    test.startTest();
      lGoal.User__c =   lUser.Id;
      Database.SaveResult saveRes = database.update(lGoal, false);
    test.stopTest();
      
    String lAllErrors = '';
    for (Database.Error iError: saveRes.getErrors()) lAllErrors += iError.getMessage() + '\n';
    system.assert(lAllErrors.contains('Não pode alterar o proprietário dessa meta. Crie uma nova meta.'));
  }
    
  @isTest private static void updateGoalOwnerNullTest()
  {
    Goal__C lGoal = CEC_InstanceObject.getGoal(null);
    test.startTest();
      database.saveresult lSavRes = database.insert(lGoal);
    test.stopTest();

    system.assert(lSavRes.isSuccess());  }

}