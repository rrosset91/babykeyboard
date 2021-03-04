/**************************************************************************************************************
* IBM - Bluewolf
* @author           Lucas Soldi (lucas.soldi@ibm.com)
* Project:          Solar
* Description:     
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-04      Lucas Soldi          	class created 
* @version   2.0    2020-11-10      Jean Sganzerla          returning to component, fields to populate 
                                                            Solar_Cross_UraExperience component
**************************************************************************************************************/
public class Solar_Cross_SelectJourneyController {


    public static String getRecordType(String RTDeveloperName){
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RTDeveloperName).getRecordTypeId();
    }
    
    @AuraEnabled
    public static DataWrapper getMetadata(Id caseId){
        System.debug('Entrou na classe selectJourney ');
        DataWrapper lReturn = new DataWrapper();
        

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
       System.debug('lstAvaialable: ' + lstAvaialable);
        List<Case> lstCases = [Select Id, LastAccessedSystem__c, SystemResponse__c, Channel__c, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        if(lstCases[0].Channel__c == 'URA'){
            lReturn.lCaseFields.lLastAccessedSystem = lstCases[0].LastAccessedSystem__c;
            lReturn.lCaseFields.lSystemResponse = lstCases[0].SystemResponse__c;
        }
        system.debug('lCaseFields to return - Journey ------------------> ' + lReturn.lCaseFields);

        Solar_Control_Journey__mdt[] lstMetadataSolarControlJourney = [SELECT Label,DeveloperName,Agrupador__c FROM Solar_Control_Journey__mdt WHERE DeveloperName !=:lstCases[0].RecordType.DeveloperName AND Ativo__c = true AND DeveloperName IN :lstAvaialable ORDER BY Label];
        System.debug('lstMetadataSolarControlJourney: ' + lstMetadataSolarControlJourney);
        if(!lstMetadataSolarControlJourney.isEmpty()){
        	for(Solar_Control_Journey__mdt objMetadata : lstMetadataSolarControlJourney){
            	metadataSolarJourney objMet = new metadataSolarJourney();
                objMet.label = objMetadata.Label;
                objMet.value = objMetadata.DeveloperName;
                objMet.agrupador = objMetadata.Agrupador__c;
                lReturn.lJourneyLst.add(objMet);
        	}            
        }
        System.debug('lReturn: ' + lReturn);
        return lReturn;
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

    public class DataWrapper{
        @AuraEnabled public List<metadataSolarJourney> lJourneyLst;
        @AuraEnabled public CaseFields lCaseFields;

        public DataWrapper(){
            this.lJourneyLst = new List<metadataSolarJourney>();
            this.lCaseFields = new CaseFields();
        }
    }    

    public class CaseFields{
        @AuraEnabled public String lLastAccessedSystem;
        @AuraEnabled public String lSystemResponse;
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