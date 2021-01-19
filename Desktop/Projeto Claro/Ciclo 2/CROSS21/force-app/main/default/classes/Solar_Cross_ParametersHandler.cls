/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Parameters__c Trigger Handler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-22      Jean Sganzerla          class created 
**************************************************************************************************************/
public class Solar_Cross_ParametersHandler {

    private static final Id ATTENDENCE_TREE_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AttendanceTree').getRecordTypeId();

    //Desabilita a trigger caso haja um registro com o nome do objeto marcado com Active__c false no custom setting Solar_Cross_TriggerConfiguration__c
    public static Boolean isActive(String aObjName) {
        Solar_Cross_TriggerConfiguration__c lConf = Solar_Cross_TriggerConfiguration__c.getValues(aObjName);
        Boolean isActive = lConf == null || lConf.Active__c ? true : false;
        return isActive;         
    }

    //Método que impede que um registro de Parâmetro, do tipo "Árvore de Atendimento" seja criado em duplicidade;
    //Foi descartado o uso de regra de duplicata, pois estão sendo utilizados campos picklist para fazer a correspondência;
    public static void validateDuplicatedAttendenceTree(Map<Id,Parameters__c> aOldMap, List<Parameters__c> aNewLst){
        
        List<Parameters__c> lRecordsToValidateLst = new List<Parameters__c>();
        //valida se o registro é do tipo 'Árvore de atendimento E (se é novo OU se os campos chave foram alterados)'
        for(Parameters__c lParam :aNewLst){
            if(lParam.RecordTypeId == ATTENDENCE_TREE_RECTYPE && ((aOldMap == null || !aOldMap.containsKey(lParam.Id) || 
            (aOldMap.get(lParam.Id).Channel__c != lParam.Channel__c || aOldMap.get(lParam.Id).Business_Unit__c != lParam.Business_Unit__c || aOldMap.get(lParam.Id).FirstCallResolution__c != lParam.FirstCallResolution__c)))){
                lRecordsToValidateLst.add(lParam);
            }
        }
        system.debug('lRecordsToValidateLst ' + lRecordsToValidateLst);
        if(lRecordsToValidateLst.isEmpty()) return;

        Map<String,String> lExistingRecordsMap = new Map<String,String>();
        for(Parameters__c lParam :[SELECT Id, Channel__c, Business_Unit__c, FirstCallResolution__c FROM Parameters__c WHERE RecordTypeId =: ATTENDENCE_TREE_RECTYPE]){
            lExistingRecordsMap.put(lParam.Channel__c + ';' + lParam.Business_Unit__c + ';' + lParam.FirstCallResolution__c, lParam.Id);
        }

        for(Parameters__c lParam :lRecordsToValidateLst){
            String lInvalid = lParam.Channel__c + ';' + lParam.Business_Unit__c + ';' + lParam.FirstCallResolution__c;
            if(lExistingRecordsMap.containsKey(lInvalid)){
                lParam.addError(Label.Solar_Cross_ParametersDuplicatedError + ' Registro existente: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Parameters__c/' +  lExistingRecordsMap.get(lInvalid) + '/view');
            }
        }
    }
}