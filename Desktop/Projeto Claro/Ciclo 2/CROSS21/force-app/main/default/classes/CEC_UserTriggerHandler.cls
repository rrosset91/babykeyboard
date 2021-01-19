public class CEC_UserTriggerHandler extends TriggerHandler {
    List<User> triggerNew;
    List<User> triggerOld;
	Map<Id, User> triggerOldMap;    
  
    public CEC_UserTriggerHandler() {
		triggerNew = (List<User>) getTriggerNew();
        triggerOld = (List<User>) getTriggerOld();
        
        triggerOldMap = new Map<Id, User>();
        triggerOldMap.putAll(triggerOld);        
    }

    public override void beforeInsert() {	
            CEC_UserMethods.changeRolesbyProfile((List<User>)Trigger.new);
            CEC_CTI_UpdateCallCenterProfile.updateProfile(TriggerNew);            
    }     
    

    public override void afterInsert() {
    	CEC_UserMethods.atribuiLicencaVlocity(triggerNew);
        CEC_UserMethods.chkUserGroup(triggerNew);             
    } 

    public override void beforeUpdate() {
        CEC_UserMethods.changeRolesbyProfile((List<User>)Trigger.new);
		CEC_CTI_UpdateCallCenterProfile.updateProfile(TriggerNew);	        
        List<User> listOnChangeProfileOld = getListOnChangeProfile('Old');
        List<User> listOnChangeProfileNew = getListOnChangeProfile('New');
        
        if(!listOnChangeProfileOld.isEmpty()) {
            CEC_UserMethods.rmvUserGroup(listOnChangeProfileOld);
        }
        
        if(!listOnChangeProfileNew.isEmpty()) {
            CEC_UserMethods.chkUserGroup(listOnChangeProfileNew);
        }
    } 
    private List<User> getListOnChangeProfile(String profVal) {
        List<User> listOnChangeProfile = new List<User>();  

        for(User iUser : triggerNew) {
            String oldProfile = triggerOldMap.get(iUser.Id).ProfileId;
            
            
            if (oldProfile != iUser.ProfileId) {
        		if (profVal == 'Old') {  
                    listOnChangeProfile.add(TriggerOldMap.get(iUser.Id));
                } else {
                    listOnChangeProfile.add(iUser);
                }
            } 
        }
        
        return listOnChangeProfile;
    }    
}