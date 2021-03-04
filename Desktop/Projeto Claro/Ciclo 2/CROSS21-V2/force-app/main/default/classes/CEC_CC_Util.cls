/*
* Data: 16/11/2020   
* Autor: Squad Canais Criticos
* Alterações: Inclusão de um método para buscar de um custom settings de canais que estao unificados
* ---------------------------------------------------------------
*/
public class CEC_CC_Util {

    private static final String SEPARADOR_UNIFICACAO = ';';

    //Lista do custom settings
    private static List<UnifiedChannel> UNIFIED_CHANNELS_CACHE = null;

    //Mapa de filas - Chave - nome da fila, value id da fila
    private static Map<String, Id> QUEUE_CACHE = null;

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

    /**
     * Classe que mapeia os dados do Custom Setting CEC_CC_Unified_Channel__c
     */
    public class UnifiedChannel {    
        public String developerName;    
        public Set<String> channels;
        public Set<String> groupings;
        public Set<String> recordTypeIds;
        public Set<String> excludedBusinessUnits;
        public String specialQueue;
    }

    /**
     * Obtem os dados de unificacao de canais de um canal unificado
     * Versao com Custom Settings
     */
    public static List<UnifiedChannel> getUnifiedChannels() {
        if(UNIFIED_CHANNELS_CACHE != null && UNIFIED_CHANNELS_CACHE.size() > 0) {
            return UNIFIED_CHANNELS_CACHE;
        } else {
            List<Solar_Unified_Channel__mdt> unifiedChannelsConfigs = [SELECT DeveloperName, ExcludedBusinessUnits__c, Channels__c, Groupings__c, RecordTypes__c, SpecialQueue__c FROM Solar_Unified_Channel__mdt];
            if(unifiedChannelsConfigs != null && unifiedChannelsConfigs.size() > 0) {
                List<UnifiedChannel> unifiedChannels = new List<UnifiedChannel>();
                for(Solar_Unified_Channel__mdt unifiedChannelsConfig : unifiedChannelsConfigs) {
                    UnifiedChannel unifiedChannel = new UnifiedChannel();
                    if(String.isNotBlank(unifiedChannelsConfig.Channels__c)) {
                        unifiedChannel.channels = new Set<String>(unifiedChannelsConfig.Channels__c.split(SEPARADOR_UNIFICACAO));
                    }
                    if(String.isNotBlank(unifiedChannelsConfig.Groupings__c)) {
                        unifiedChannel.groupings = new Set<String>(unifiedChannelsConfig.Groupings__c.split(SEPARADOR_UNIFICACAO));
                    }
                    if(String.isNotBlank(unifiedChannelsConfig.ExcludedBusinessUnits__c)) {
                        unifiedChannel.excludedBusinessUnits = new Set<String>(unifiedChannelsConfig.ExcludedBusinessUnits__c.split(SEPARADOR_UNIFICACAO));
                    }
                    if(String.isNotBlank(unifiedChannelsConfig.RecordTypes__c)) {                                        
                        List<String> recordTypesNames = unifiedChannelsConfig.RecordTypes__c.split(SEPARADOR_UNIFICACAO);
                        if(recordTypesNames != null && recordTypesNames.size() > 0) {
                            unifiedChannel.recordTypeIds = new Set<String>();
                            for(String recordTypesName : recordTypesNames) {
                                Schema.RecordTypeInfo info = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypesName);
                                if(info != null) {
                                    unifiedChannel.recordTypeIds.add(info.getRecordTypeId());
                                }
                            }
                        }
                    }

                    unifiedChannel.specialQueue = unifiedChannelsConfig.SpecialQueue__c;

                    unifiedChannel.developerName = unifiedChannelsConfig.DeveloperName;

                    unifiedChannels.add(unifiedChannel);
                }
                UNIFIED_CHANNELS_CACHE = unifiedChannels;
                return unifiedChannels;
            }
            return null;
        }
    }

    /**
     * Obtem uma configuracao de unificacao de canal pelo caso
     */
    public static UnifiedChannel getUnifiedChannelByCase(Case caseItem) { 
        if(caseItem != null && String.isNotBlank(caseItem.Channel__c) && String.isNotBlank(caseItem.Grouping__c) && caseItem.RecordTypeId != null) {
            List<UnifiedChannel> unifiedChannels = getUnifiedChannels();
            if(unifiedChannels != null && unifiedChannels.size() > 0) {
                for(UnifiedChannel unifiedChannel : unifiedChannels) {
                    if(unifiedChannel.channels != null && unifiedChannel.channels.contains(caseItem.Channel__c) && 
                       unifiedChannel.groupings != null && unifiedChannel.groupings.contains(caseItem.Grouping__c) &&                       
                       unifiedChannel.recordTypeIds != null && unifiedChannel.recordTypeIds.contains(caseItem.RecordTypeId)) {
                          return unifiedChannel;
                    }
                }
            }
        }
        return null;
    }      

    /**
     * Obtem a lista de filas a partir de uma lista de nomes
     */
    public static Map<String, Id> getQueue(Set<String> queueNames) {
        if(queueNames != null && !queueNames.isEmpty()) {
            if(QUEUE_CACHE != null && !QUEUE_CACHE.isEmpty() && QUEUE_CACHE.keySet().containsAll(queueNames)) {
                return QUEUE_CACHE;
            } else {
                List<Group> queues = [Select Id, DeveloperName from Group where Type = 'Queue' and DeveloperName in :queueNames];
                if(queues != null && !queues.isEmpty()) {
                    QUEUE_CACHE = new Map<String, Id>();
                    for(Group queue : queues) {
                        QUEUE_CACHE.put(queue.DeveloperName, queue.Id);
                    }

                }
                return QUEUE_CACHE;
            }
        }
        return null;
    }

    /**
     * Ordena um Set
     */
    public static Set<String> sortSet(Set<String> values) {
        if(values != null &&  !values.isEmpty()) {
            List<String> newValues = new List<String>(values);
            newValues.sort();
            return new Set<String>(newValues);
        }
        return values;
    }
}