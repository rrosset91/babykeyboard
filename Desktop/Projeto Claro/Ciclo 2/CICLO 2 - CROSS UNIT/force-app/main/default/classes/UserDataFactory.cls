/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (User)
* @date: 16-09-2020
*/
@isTest
public without sharing class UserDataFactory {
    //********** Este metodo recebe como parametro o nome Strings contendo Role (Name), Profile (Name) e Lista de Permission Sets a adicionar (Name)**********
    public static User getSingleUser(String roleId, String profileId, String email){
        Map<String, SObject> userReturn = new Map<String, SObject>();
        User user = new User();
        user.alias = StringDataFactory.getMockString('Word');
        //user.email = StringDataFactory.getMockString('Email');
        user.email = email;
        user.ProfileId = profileId;
        user.UserRoleId = roleId;
        user.emailencodingkey='ISO-8859-1';
        user.firstName = StringDataFactory.getMockString('Name');
        user.lastname = StringDataFactory.getMockString('Word');
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'pt_BR';
        user.timezonesidkey = 'America/Sao_Paulo';
        user.username = user.email;
        system.debug('@@SingleUser-->'+user);
        return user;
    }

    public static Map<String,List<SObject>> getMockUserRoleProfiles(String assignedProfile, String assignedRole, List<String> assignedPermissionSets){
        Map<String,List<SObject>> returnMap = new Map<String,List<SObject>>();
        List<Profile> profile = new List<Profile>();
        if(assignedProfile.contains('Admin')){
            profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador do sistema' LIMIT 1];
        }else{
            profile = [SELECT Id FROM Profile WHERE Name= :assignedProfile LIMIT 1];
        }
        List<UserRole> role = [SELECT Id FROM UserRole WHERE DeveloperName= :assignedRole LIMIT 1]; 
        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name IN :assignedPermissionSets];
        returnMap.put('profile', profile);
        returnMap.put('role', role);
        returnMap.put('permissions', permissionSets);
        return returnMap;
    }
}