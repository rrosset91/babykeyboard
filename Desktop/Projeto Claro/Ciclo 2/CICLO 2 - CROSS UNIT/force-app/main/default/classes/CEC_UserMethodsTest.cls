@isTest
public class CEC_UserMethodsTest {
   
    /*-------------------------------------------------------------------------------------------------------
      --- Company: Deloitte Brasil
      --- Creation Date: 14/11/2018 09:18
      --- Author: Squad Canais Críticos 
      --- Description: Método que faz a configuração inicial para testes 
      -------------------------------------------------------------------------------------------------------*/
    @testSetup
    public static void setup()
    {
    	/*-------------------------------------------------------------------------------------------------------
      	--- Company: Deloitte Brasil
      	--- Creation Date: 14/11/2018 09:18
      	--- Author: Squad PME - Otávio Fonseca 
      	--- Description: Método que faz a configuração inicial para testes do PME
      	-------------------------------------------------------------------------------------------------------*/
        CEC_Role__c lRole = new CEC_Role__c();
        lRole.Name = 'TOP PME';
        lRole.Profile__c = 'TOP PME';
        lRole.Role__c = 'PME';
        
        insert lRole;
        
        CEC_Role__c lRole2 = new CEC_Role__c();
        lRole2.Name = 'Gerente Canais Criticos';
        lRole2.Profile__c = 'Gerente Canais Criticos';
        lRole2.Role__c = 'Gerente_Canais_Criticos';
        
        insert lRole2;        
    }
    
    /*-------------------------------------------------------------------------------------------------------
      --- Company: Deloitte Brasil
      --- Creation Date: 04/10/2019
      --- Author: Squad PME
      --- Description: Método que testa a remoção do usuário do grupo do perfil
      -------------------------------------------------------------------------------------------------------*/    
      
	@isTest static void testRmvUserGroup()
    {      
        Profile profIns = [SELECT Id FROM Profile WHERE Name = 'TOP PME' LIMIT 1];
        Profile profUpd = [SELECT Id FROM Profile WHERE name = 'Loja Propria' LIMIT 1];        
        
        User usr = new User(firstName = 'test1', lastName = 'test1', Alias = 'alias1', Email = 'teste1@claro.com.br', 
                              Username = 'teste1@claro.com.br', LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', 
                              LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true,
                              Profileid = profIns.Id);
        
        Test.startTest();
        insert usr;
        usr.ProfileId = profUpd.Id;
        update usr;
        Test.stopTest(); 
    } 
    
    /*-------------------------------------------------------------------------------------------------------
      --- Company: Deloitte Brasil
      --- Creation Date: 04/10/2019
      --- Author: Squad PME
      --- Description: Método que testa as operações de carregamento e limpeza de grupo
      -------------------------------------------------------------------------------------------------------*/    
	@isTest static void testGroupsOperations()
    {   
        Profile profIns = [SELECT Id FROM Profile WHERE Name = 'TOP PME' LIMIT 1];
        
        User usr = new User(firstName = 'test1', lastName = 'test1', Alias = 'alias1', Email = 'teste1@claro.com.br',
                              Username = 'teste1@claro.com.br', LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', 
                              LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true, 
                              ProfileId = profIns.Id);
              
        Test.startTest();
        insert usr;
		CEC_UserMethods.loadGroupPME('TOP PME');
		CEC_UserMethods.clearGroupPME('TOP PME'); 
        Test.stopTest();         
       
    }
 

    @isTest static void changeRolesbyProfileSingleUserTest(){
        List<User> usuarios = new List<User>();
        Profile pfile = [SELECT Id, Name FROM Profile WHERE Name = 'TOP PME' LIMIT 1];
        List<UserRole> role = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN ('Supervisor','PME') ORDER BY DeveloperName DESC];
        UserRole rolePME  = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName= 'PME'];
        User usr = new User(firstName = 'firstNameTest1', lastName = 'LastNametest1', Alias = 'alias1', Email = 'teste1@claro.com.br', 
                               Username = 'teste1@claro.com.br', LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', 
                               LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true,
                               Profileid = pfile.Id, UserRoleId = role[0].Id);
        usuarios.add(usr);
        CEC_UserMethods.changeRolesbyProfile(usuarios);
        System.assertEquals(role[1].Id, usuarios[0].UserRoleId);
    }

    @isTest static void changeRolesByProfilesMultiplesUsersTest(){
        List<Profile> pfile = [ SELECT Id, Name 
                                FROM Profile WHERE Name 
                                IN('Gerente Canais Criticos','TOP PME' )
                                ORDER BY Name DESC];
        List<User> usrs = new List<User>();
        List<UserRole> role = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN ('Supervisor','GerenteNegocio') ORDER BY DeveloperName DESC];
        for(Integer i = 0; i < 100 ; i ++){
            User usr = new User(firstName = 'firstNameTest'+i, lastName = 'LastNametest'+i, Alias = 'alias'+i, Email = 'teste1@claro.com.br', 
                               Username = i+'teste1@claro.com.br', LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', 
                               LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true,
                               ProfileId = pfile[Math.mod(i,2)].Id , UserRoleId = role[Math.mod(i,2)].Id);
            usrs.add(usr);
        }
        List<UserRole> roleAssert = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN ('Gerente_Canais_Criticos','PME') ORDER BY DeveloperName DESC];
        CEC_UserMethods.changeRolesbyProfile(usrs);
        for(Integer i = 0; i < 100 ; i ++){
            System.assertEquals(roleAssert[Math.mod(i,2)].Id, usrs[Math.mod(i,2)].UserRoleId);
        }                 
    }  

}