public with sharing class SolarPFInvokeMethod implements Callable {

    
    public static void callClassByCustomSetting(List<User> users){
        Map<String, String> mapProfileNameRoleName = CEC_UserMethods.getCustomSettingProfileRoleNames();
        Map<String,String> profileIdNameMap  = CEC_UserMethods.getProfileIdNameMap(mapProfileNameRoleName.keySet());
        Map<String,String> roleIdDeveloperNameMap = CEC_UserMethods.getRoleIdDeveloperNameMap(mapProfileNameRoleName.values()); 
        List<CEC_Role__c> roleToexec;
        if(CEC_Role__c.SObjectType.getDescribe().isAccessible()){
            roleToexec = [SELECT Profile__c, Role__c, UpdateMethod__c from CEC_Role__c WHERE UpdateMethod__c != null ];
        }
        for(CEC_Role__c r : roleToexec){
            r.Profile__c = profileIdNameMap.get(r.Profile__c);
            r.Role__c = roleIdDeveloperNameMap.get(r.Role__c);
        }
        
        for(User usr : users){
            for(CEC_Role__c r : roleToexec){
                if(usr.ProfileId == r.Profile__c && usr.UserRoleId == r.Role__c){
                    String[] method = r.UpdateMethod__c.split('\\.');
                    Callable extension = (Callable) Type.forName('SolarPFInvokeMethod').newInstance();
                    extension.call(method[1], new Map<String, Object>());
                }
            }
        }
    }

    @future
    public static void invokeUpdateMethod(){
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        try{
            controller.invokeMethod('updateDadosVendedor', inputMap, outputMap, optionsMap);
        }catch(NullPointerException e){
            system.debug(e.getMessage());
        }
    }


    public Object call(String action, Map<String, Object> args) {
        switch on action {
          when 'updateDadosVendedor' {
            SolarPFInvokeMethod.invokeUpdateMethod();
            return true;
          }
          when else {
            return 'metodo inexistente';
          }
        }
    }

}