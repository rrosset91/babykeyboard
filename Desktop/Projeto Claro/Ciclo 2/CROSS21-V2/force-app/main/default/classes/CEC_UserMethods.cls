public class CEC_UserMethods {
    
   Static Profile admProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR
                            Name = 'Administrador do Sistema' LIMIT 1];
    
    @AuraEnabled
    public static void atribuiLicencaVlocity(List<User> lstNewUser)
    {
        if(!Test.isRunningTest())
        {
            PackageLicense pck = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'vlocity_cmt'];
            List<UserPackageLicense> lstUserPckLicense = new List<UserPackageLicense>();
            
            for(User user : lstNewUser)
            {
                UserPackageLicense userPckLicense =new UserPackageLicense();
                userPckLicense.PackageLicenseId = pck.Id;
                userPckLicense.UserId = user.Id;
                lstUserPckLicense.add(userPckLicense);
            }
            
            insert lstUserPckLicense;
        }
    }
    
    /*
    * Autor: Rhaone Sena - Deloitte
    * Data: 23/10/2019
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD PME - Extensao] + 
    * [ muda papel de acordo com perfil assinalado] 
    */
    public static void changeRolesbyProfile(List<User> users){
        map<String, String> profileRoleMap = getCustomSettingProfileRoleNames();
        profileRoleMap = changeProfileRoleNameMapToMapIDs(profileRoleMap);
        changeRoleFromUsers(users,profileRoleMap);
    }

    private static Map<String,String> changeProfileRoleNameMapToMapIDs(Map<String,String> profileRoleMap){
        Map<String,String> profileIdNameMap = getProfileIdNameMap(profileRoleMap.keySet());
        Map<String,String> roleIdDeveloperNameMap = getRoleIdDeveloperNameMap(profileRoleMap.values());
        profileRoleMap = changeProfileRoleMapNameToId(profileRoleMap,profileIdNameMap,roleIdDeveloperNameMap);
        return profileRoleMap;
    }

    private static void changeRoleFromUsers(List<User> users,Map<String,String> profileRoleMap){
        for(User userr : users){
            if((ID)profileRoleMap.get(userr.ProfileId) <> null){
                userr.UserRoleId = (ID)profileRoleMap.get(userr.ProfileId);
            }
        }
    }

    public static Map<String, String> getCustomSettingProfileRoleNames() {
        map<String, String> mapCustomSettingRole = new map<String, String>();
        for(CEC_Role__c role : CEC_Role__c.getAll().values()) {
            mapCustomSettingRole.put(role.Profile__c, role.Role__c);
        }
        return mapCustomSettingRole;      
    }

    private static Map<String,String> changeProfileRoleMapNameToId(Map<String,String> profileRoleMap,
                                                                    Map<String,String> profileIdNameMap,
                                                                    Map<String,String> roleIdDeveloperNameMap){
        Map<String,String> profileRoleMapUsingId = new Map<String,String>();
        for(String pfile: profileRoleMap.keySet()){
            profileRoleMapUsingId.put(
                profileIdNameMap.get(pfile),
                roleIdDeveloperNameMap.get(profileRoleMap.get(pfile))
            );
        }                                                                 
        return profileRoleMapUsingId;
    }

    public static Map<String,String> getProfileIdNameMap(Set<String> profilesNames){
        Map<String,String> profileIdNameMap = new Map<String,String>();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN :profilesNames];
        for(Profile prof : profiles){
            profileIdNameMap.put(prof.Name,prof.Id);
        }
        return profileIdNameMap;
    }

    public static Map<String,String> getRoleIdDeveloperNameMap(List<String> rolesDeveloperNames){
        Map<String,String> roleIdDeveloperNameMap = new Map<String,String>();
        List<UserRole> roles = [SELECT Id, DeveloperName From UserRole WHERE DeveloperName IN :rolesDeveloperNames];
        for(UserRole role : roles){
            roleIdDeveloperNameMap.put(role.DeveloperName,role.Id);
        }
        return roleIdDeveloperNameMap;
    }

//--------------------------------
 
    private static map<Id, String> getProfilePME(set<Id> lstProfileId) {
        
        map<Id, String> mapProfileName = new map<Id, String>();
        
        for(Profile profl : [SELECT Id, Name FROM Profile WHERE Id = :lstProfileId]) {
            
            mapProfileName.put(profl.Id, profl.Name);
        }
        
        return mapProfileName;
        
    }
	public static void chkUserGroup(List<User> lstUserNew) { 
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        GroupMember gm;
        
        String userGroupName;
        String userNewGroupId;
        GroupMember groupMember;
        String userGroupId;
        
        set<Id> lstProfileId = new set<Id>();
        
        for(User usr : lstUserNew) { 
            lstProfileId.add(usr.ProfileId);
        }
        
        if(lstProfileId.isEmpty()) return;        
        
        map<Id, String> mapProfileName = getProfilePME(lstProfileId);
		map<String, Id> mapGroupRole = getGroupRolePME(mapProfileName.values());
        map<Id, GroupMember> mapGroupMember = getGroupMembersPME(mapGroupRole.values());               
        
        for(User usr : lstUserNew) { 
            userGroupName = mapProfileName.get(usr.ProfileId);
            userNewGroupId = mapGroupRole.get(userGroupName);
            groupMember = mapGroupMember.get(usr.Id);
            
            if (groupMember != null) {
            	userGroupId = groupMember.UserOrGroupId; 
            }
                
            if (String.isNotBlank(userNewGroupId) && (userNewGroupId != userGroupId || String.isBlank(userGroupId))) {
                gm = new GroupMember();
                gm.GroupId = userNewGroupId;
                gm.UserOrGroupId = usr.Id;
                
                lstGroupMember.add(gm);
            }                
        }
        
        if (lstGroupMember.size() > 0) {
        	upsert lstGroupMember;
        }
    } 

	public static void rmvUserGroup(List<User> lstUserOld) { 
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        GroupMember gm;
        
        String userGroupName;
        String userOldGroupId;
        GroupMember groupMember;        
        String userGroupMemberId;
        
        set<Id> lstProfileId = new set<Id>();
        
        for(User usr : lstUserOld) { 
            lstProfileId.add(usr.ProfileId);
        }
        
        if(lstProfileId.isEmpty()) return;        
        
        map<Id, String> mapProfileName = getProfilePME(lstProfileId);
		map<String, Id> mapGroupRole = getGroupRolePME(mapProfileName.values());
        map<Id, GroupMember> mapGroupMember = getGroupMembersPME(mapGroupRole.values());       
        
        for(User usr : lstUserOld) { 
            userGroupName = mapProfileName.get(usr.ProfileId);
            userOldGroupId = mapGroupRole.get(userGroupName);
           
            if (String.isNotBlank(userOldGroupId)) {              
            	groupMember = mapGroupMember.get(usr.Id); 
                if (groupMember != null) {
                	lstGroupMember.add(groupMember);
                }
            }
        }
        
        if (lstGroupMember.size() > 0) {
        	delete lstGroupMember;
        }
    } 
    
	private static map<String, Id> getGroupRolePME(List<String> lstProfiles) {
        
        map<String, Id> mapGroupRole = new map<String, Id>();
        
        for(Group varGroup : [SELECT Id, Name FROM Group WHERE Name = :lstProfiles]) {
            mapGroupRole.put(varGroup.Name, varGroup.Id);
        }
        
        return mapGroupRole;
    } 
    
    private static map<Id, GroupMember> getGroupMembersPME(List<Id> lstGroup) {
        
        map<Id, GroupMember> mapGroupMember = new map<Id, GroupMember>();
        
        for(GroupMember member : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :lstGroup]) {
            mapGroupMember.put(member.UserOrGroupId, member);
        }
        
        return mapGroupMember;
    }    
    
	public static void loadGroupPME(String profileName)
    {
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        GroupMember gm;
        Group grp;
        
        List<Group> lstGrp = [SELECT Id FROM Group WHERE Name = :profileName];
        if (lstGrp.size() > 0) {
            grp = lstGrp[0];
        }
		
        List<User> lstUser = [SELECT Id, Name, Username FROM User Where Profile.Name = :profileName AND IsActive = true];
        
        if (grp != null) {
            for (User usr : lstUser) {
                gm = new GroupMember();
                gm.GroupId = grp.Id;
                gm.UserOrGroupId = usr.Id;
                
                lstGroupMember.add(gm);                
            }
        }
        
        if (lstGroupMember.size() > 0) {
        	upsert lstGroupMember;
        }        
    }    
    
	public static void clearGroupPME(String profileName)
    {      
        List<GroupMember> lstGroupMember;
        Group grp;
        List<Group> lstGrp = [SELECT Id FROM Group WHERE Name = :profileName];
        
        if (lstGrp.size() > 0) {
            grp = lstGrp[0];
        }        
        
        if (grp != null) {
            lstGroupMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :grp.Id];
            
            if (lstGroupMember.size() > 0) {
                delete lstGroupMember;
            }             
        }     
    }   
}