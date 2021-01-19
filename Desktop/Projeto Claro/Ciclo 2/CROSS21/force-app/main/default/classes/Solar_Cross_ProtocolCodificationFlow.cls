/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Auxiliar Class to make a complex logic for ProtocolCodification Flow
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-25      Jean Sganzerla          class created 
* @version   1.1    2020-10-22      Jean Sganzerla          methods changed to support multipicklist 
**************************************************************************************************************/
public class Solar_Cross_ProtocolCodificationFlow {

    @AuraEnabled
    public static Case getContextRecord(String aCaseId){
        return [SELECT Id, Status, IsClosed, ContractBillingAccount__c, ContractBusinessUnit__c, RecordType.DeveloperName, Channel__c, Category__c, Product__c, Modalidade__c, EntryReason__c, Solar_Cross_forwardingReason__c FROM Case WHERE Id = :aCaseId];
    }

    @AuraEnabled
    public static void updaContextRecord(String aCaseId, String aResolution, String aLeavingReason, String aCategory, /*String aProductValue,*/ String aModality, String aEntry, String aDescription){
        Case lCase = [SELECT Id, Status, Resolution__c, Solar_Cross_forwardingReason__c, LeavingReason__c, Category__c, Product__c, Modalidade__c, EntryReason__c, Description FROM Case WHERE Id = :aCaseId];
        // system.debug('aResolution ' + aResolution);
        lCase.Resolution__c = aResolution != null ? aResolution : lCase.Resolution__c;
        lCase.LeavingReason__c = aResolution != null ? aLeavingReason : lCase.LeavingReason__c; //verifica se o aResolution é diferente de null porque, o caso pode estar indo para o BKO, fazendo com que esse campo não tenha que ser atualizado   
        lCase.Category__c = aCategory != null ? aCategory : lCase.Category__c;
        lCase.Modalidade__c = aModality != null ? aModality :lCase.Modalidade__c;
        lCase.EntryReason__c = aEntry != null ? aEntry : lCase.EntryReason__c;
        lCase.Description = aDescription != null ? aDescription : lCase.Description;
        lCase.Status = aResolution != null ? 'Closed' : lCase.Status; //verifica se o aResolution é diferente de null porque, o caso pode estar indo para o BKO, fazendo com que esse campo não tenha que ser atualizado          
        lCase.Solar_Cross_forwardingReason__c = aResolution == null ? 'Codificação da árvore de atendimento' : lCase.Solar_Cross_forwardingReason__c; //verifica se o aResolution é diferente de null porque, o caso pode estar indo para o BKO, fazendo com que esse campo não tenha que ser atualizado          

        try{
            update lCase;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static List<PicklistWrapper> getPicklistOptions(List<String> aValuesLst){
        system.debug('aValuesLst ' + aValuesLst);
        String lField;
        String lFCR = 'FirstCallResolution__c';
        String lDynamicConditions = '';
        
        switch on aValuesLst.size(){
            when 3 { // Primeira chamada
                lField = 'TypeService__c';
            }
            when 4 { // Segunda chamada
                lField = 'Solar_Cross_ServiceModality__c';
                lDynamicConditions = ' AND TypeService__c INCLUDES(' + '\'' + aValuesLst[3] + '\'' + ')';
            }
            when 5 { // Terceira chamada
                lField = 'EntryReason__c';
                lDynamicConditions = ' AND TypeService__c INCLUDES(' + '\'' + aValuesLst[3] + '\'' + ')';
                lDynamicConditions = ' AND Solar_Cross_ServiceModality__c INCLUDES(' + '\'' + aValuesLst[4] + '\'' + ')';
            }
            when 6 { // Quarta chamada
                lField = 'LeavingReason__c';
                lDynamicConditions = ' AND TypeService__c INCLUDES(' + '\'' + aValuesLst[3] + '\'' + ')';
                lDynamicConditions = ' AND Solar_Cross_ServiceModality__c INCLUDES(' + '\'' + aValuesLst[4] + '\'' + ')';
                lDynamicConditions = ' AND EntryReason__c INCLUDES(' + '\'' + aValuesLst[5] + '\'' + ')';
            }
        }
        
        String lRecordType = '\'' + 'AttendanceTree' + '\'';
        
        String lQuery = 'SELECT FirstCallResolution__c, ' + lField;
        lQuery += ' FROM Parameters__c WHERE Active__c = TRUE AND RecordType.DeveloperName = ' + lRecordType;
        lQuery += ' AND Journey__c INCLUDES(' + '\'' + aValuesLst[0] + '\'' + ') AND Business_Unit__c = '  + '\'' + aValuesLst[1] + '\'' +  ' AND Channel__c = ' + '\'' + aValuesLst[2] + '\'';
        lQuery += lDynamicConditions;
        system.debug('lQuery ' + lQuery);
        List<SObject> lParametersLst = Database.query(lQuery);
        system.debug('lParametersLst ' + lParametersLst);

        List<String> lSplitedValuesFCRTrueLst = new List<String>(); // Lista de registros FCR true
        List<String> lSplitedValuesFCRFalseLst = new List<String>(); // Lista de registros FCR false
        for(SObject lParamter :lParametersLst){
            // system.debug(lParamter.get(lField));
            if(Boolean.ValueOf(lParamter.get(lFCR)) && String.ValueOf(lParamter.get(lField)) != null){
                lSplitedValuesFCRTrueLst.addAll(String.ValueOf(lParamter.get(lField)).split(';'));
            }
            else if(!Boolean.ValueOf(lParamter.get(lFCR)) && String.ValueOf(lParamter.get(lField)) != null){                
                lSplitedValuesFCRFalseLst.addAll(String.ValueOf(lParamter.get(lField)).split(';'));
            }
        }
        // system.debug('lSplitedValuesFCRTrueLst ' + lSplitedValuesFCRTrueLst);
        // system.debug('lSplitedValuesFCRFalseLst ' + lSplitedValuesFCRFalseLst);

        List<PicklistWrapper> lReturnLst = new List<PicklistWrapper>();
        Map<String,PicklistWrapper> lFilteredValuesMap = new Map<String,PicklistWrapper>();
        if(!lSplitedValuesFCRTrueLst.isEmpty()){
            for(String lSplitedValue :lSplitedValuesFCRTrueLst){
                PicklistWrapper lValues = new PicklistWrapper();
                lValues.label = lSplitedValue;
                lValues.value = lSplitedValue;
                lValues.fcr = true;

                lFilteredValuesMap.put(lValues.label, lValues);
            }
        }
        // system.debug('!lSplitedValuesFCRFalseLst.isEmpty() ' + !lSplitedValuesFCRFalseLst.isEmpty());

        if(!lSplitedValuesFCRFalseLst.isEmpty()){
            for(String lSplitedValue :lSplitedValuesFCRFalseLst){
                system.debug('false ' + lSplitedValue);
                PicklistWrapper lValues = new PicklistWrapper();
                lValues.label = lSplitedValue;
                lValues.value = lSplitedValue;
                lValues.fcr = false;

                lFilteredValuesMap.put(lValues.label, lValues);
            }
        }
        lReturnLst.addAll(lFilteredValuesMap.values()); 
        
        system.debug('lReturnLst ' + lReturnLst);
        return lReturnLst;
    }

    @AuraEnabled
    public static Boolean isBKOUser(){
        List<GroupMember> lGroupMemberLst = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'BackOffice_Financeiro' AND UserOrGroupId = :UserInfo.getUserId()];
        if(!lGroupMemberLst.isEmpty()){
            system.debug('grupo');
            return true;
        }
        
        List<Profile> lProfileLst = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System administrator'];
        if(lProfileLst[0].Id == userinfo.getProfileId()){
            system.debug('perfil');
            return true;
        }
        system.debug('nenhum');
        return false;
    }

    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean fcr;
    }  
}