@isTest
private class CEC_SSO_SAMLStandardUserTest
{
  private static Map<String, String> userMap = new Map<String, String>();
  static
  {
    userMap.put('User.UserName', 'test@claro.com.br');
    userMap.put('User.FederationIdentifier', 'test');
    userMap.put('User.Phone', '12551255');
    userMap.put('User.CPF__c', '084.301.020-78');
    userMap.put('User.FirstName', 'FirstName1');
    userMap.put('User.LastName', 'LastName1');
    userMap.put('User.Embratel__c', 'Embratel__c');
    userMap.put('User.CompanyName', 'CompanyName');
    userMap.put('User.NetServicos__c', 'NetServicos__c');
    userMap.put('User.Email__c', 'sememail@claro.com.br');
    userMap.put('User.LoginClaro__c', 'T404040');
  }

  @isTest static void testCreateUser()
  {
    // Define a new map
    userMap.put('User.ProfileId', CEC_SobjectFactory.PROF_ADM.Id);

    CEC_SSO_SAMLStandardUser userTest = new CEC_SSO_SAMLStandardUser();

    test.startTest();
    User usuario = userTest.createUser(null, null, null, null, userMap, null);
    database.insert(usuario);
    test.stopTest();

    system.assert(usuario.Id != null, 'Erro ao criar usuario');
  }

  @isTest static void testUpdateUser()
  {
    user userInsert = CEC_SobjectFactory.getUser();
    database.insert(userInsert);
  
    user usuario1 = [SELECT Id, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];

    CEC_SSO_SAMLStandardUser userTest = new CEC_SSO_SAMLStandardUser();
    String lEmail = userMap.get('User.Email__c');
    userMap.put('User.ProfileId', usuario1.ProfileId);

    test.startTest();
    userTest.updateUser(usuario1.id, null, null, null, null, userMap, null);
    test.stopTest();

    usuario1 = [SELECT Id, Email FROM User WHERE id =: usuario1.id];

    system.assert(usuario1.Email == lEmail, 'Erro de atualização');
  }
  
  @isTest static void erroPerfil()
  {
    user usuario1 = [SELECT Id, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];

    CEC_SSO_SAMLStandardUser userTest = new CEC_SSO_SAMLStandardUser();
    String lEmail = userMap.get('User.Email__c');

    test.startTest();
    try{
        userTest.updateUser(usuario1.id, null, null, null, null, userMap, null);
    }
    catch(Exception ex)
    {
        System.assertEquals(ex.getMessage(), 'Id de perfil vazio ou inexistente.');
    }
    test.stopTest();
  }
}