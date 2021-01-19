public class CEC_CC_Util {
    
    public static map<String, set<String>> semaphoreMap = new map<String, set<String>> ();
    
    public static map<String, String> getPicklistValueByLabel(String objectAPIName, String fieldAPIName)
    {
        map<String, String> mapPickValByLabel = new Map<String, String>();
        list<String> lstPickValues = new list<String>();
                
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldAPIName).getDescribe();
        // Get the picklist information by field and object
        List<Schema.PicklistEntry> lstPickValueEntries = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : lstPickValueEntries){
            if(pickListVal.isActive() && !mapPickValByLabel.containsKey(pickListVal.getValue()))
                mapPickValByLabel.put(pickListVal.getValue(), pickListVal.getLabel());
        }     
        
        return mapPickValByLabel;
    }
    
    public static Set<Id> getAllCecRtByObj (String objectAPIName)
    {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Set<Id> setRecordTypeId = new Set<Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){ 
            if(info.getDeveloperName().contains('CEC_CC'))
            	setRecordTypeId.add(info.getRecordTypeId());
        }
        
        return setRecordTypeId;
    } 
    
    public static Map<String,Id> getRecordTypeInfoByObj (String objectAPIName)
    {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){            
            mapRecordTypeNameandId.put(info.getDeveloperName(),info.getRecordTypeId());
        }
        
        return mapRecordTypeNameandId;
    } 
     
    public static Map<String,String> getCSEntitlementByArea()
    { 
        List<CEC_CC_Entitlement__c> lstEntitlements = CEC_CC_Entitlement__c.getAll().values();
        Map<String, String> mapCSEntitlementBySupportArea = new Map<String,String>();
        
        for(CEC_CC_Entitlement__c varCSEntitlement : lstEntitlements) {
            if(!mapCSEntitlementBySupportArea.containsKey(varCSEntitlement.SupportArea__c)){
                mapCSEntitlementBySupportArea.put(varCSEntitlement.SupportArea__c, varCSEntitlement.TypeName__c);
            }
        }
        
        return mapCSEntitlementBySupportArea;  
    }
    
     /*-------------------------------------------------------------------------------------------------------
    --- Company: Deloitte Brazil
    --- Creation Date: 12/09/2018
    --- Author: Squad Canais Críticos
    --- Description: Método auxiliar na prevenção de duplicação de chamadas
    -------------------------------------------------------------------------------------------------------*/
    public static Boolean isSemaphored(String objId, String objCode)
    {
        Set<String> setSemaphore = semaphoreMap.get(objId);
        setSemaphore = (setSemaphore == null) ? new set<String> () : setSemaphore;
        
        if(setSemaphore.contains(objCode)) {  return true; }
        
        setSemaphore.add(objCode);        
        semaphoreMap.put(objId, setSemaphore);
        return false;
    }
}