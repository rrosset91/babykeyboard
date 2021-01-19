/**************************************************************************************************************
* IBM - Bluewolf
* @author           Lucas Soldi (lucas.soldi@ibm.com)
* Project:          Solar
* Description:      Controlador dos Aura Components Solar_Cross_ProtocolHistory e Solar_Cross_ProtocolHistoryDetail
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-04      Lucas Soldi          	class created 
**************************************************************************************************************/
public class Solar_Cross_SelectJourneyController {


    public static String getRecordType(String RTDeveloperName){
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RTDeveloperName).getRecordTypeId();
    }
    
    @AuraEnabled
    public static List<metadataSolarJourney> getMetadata(Id caseId){
        List<metadataSolarJourney> lstReturn = new List<metadataSolarJourney>();
        

        Map<String,Schema.RecordTypeInfo> mapRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        List<String> lstAvaialable = new List<String>();

        //filtra o rt por acesso
        for(RecordTypeInfo rt : mapRecordTypes.values()){
            if(rt.isAvailable()){
                lstAvaialable.add(rt.getDeveloperName());
            }
        }
        //Adiciona o agrupador
        lstAvaialable.add('Canais_Criticos');

        
        List<Case> lstCases = [Select Id, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        Solar_Control_Journey__mdt[] lstMetadataSolarControlJourney = [SELECT Label,DeveloperName,Agrupador__c FROM Solar_Control_Journey__mdt WHERE DeveloperName !=:lstCases[0].RecordType.DeveloperName AND Ativo__c = true AND DeveloperName IN :lstAvaialable ORDER BY Label];
        if(!lstMetadataSolarControlJourney.isEmpty()){
        	for(Solar_Control_Journey__mdt objMetadata : lstMetadataSolarControlJourney){
            	metadataSolarJourney objMet = new metadataSolarJourney();
                objMet.label = objMetadata.Label;
                objMet.value = objMetadata.DeveloperName;
                objMet.agrupador = objMetadata.Agrupador__c;
                lstReturn.add(objMet);
        	}            
        }
        return lstReturn;
    }
    
    @AuraEnabled
    public static String changeRecordType(String id,  String RecordType){
        
        List<Case> lstCases = [Select Id, RecordTypeId FROM Case WHERE Id = :id];
        String newRecordTypeId = getRecordType(RecordType);
        
        if(!lstCases.isEmpty()){
            if(lstCases[0].RecordTypeId != newRecordTypeId){
                lstCases[0].RecordTypeId = newRecordTypeId;
                update lstCases[0];
                return 'Ok';
            }else{
                return 'Error';
            }  
        }
        return null;
        
    }
    

    
    public class metadataSolarJourney{

        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String agrupador {get;set;}

        public metadataSolarJourney(){
            this.label = '';
            this.value = '';
            this.agrupador = '';
        }        
    }
}