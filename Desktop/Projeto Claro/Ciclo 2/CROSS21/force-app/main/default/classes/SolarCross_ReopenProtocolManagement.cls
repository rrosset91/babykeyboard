/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Class used by a trigger to validate reopened cases
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2021-01-04      Jean Sganzerla          class created 
**************************************************************************************************************/
public class SolarCross_ReopenProtocolManagement {

    private static final Id REOPEN_PROTOCOL_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('SolarCross_ReopenCasesManagement').getRecordTypeId();
    
    //Método que valida se um caso que foi criado pela API de composite pode ser reaberto ou não.
    public static void reopenProtocol (List<Case> aCaseNewLst) {
        
        Map<Id,RecordType> lJourneyNameMap = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case']);
        
        Set<String> lJourneySet = new Set<String>();
        Set<String> lEntryReasonSet = new Set<String>();
        Set<String> lLeavingReasonSet = new Set<String>();
        Set<String> lProductSet = new Set<String>();
        Set<String> lContractBillingAccountSet = new Set<String>();
        Set<String> lParentIdSet = new Set<String>();

        List<Case> lReopenCasesLst = new List<Case>();        

        for(Case lCase :aCaseNewLst){
            if(lCase.Solar_Cross_IsReopen__c == true && lCase.Channel__c == 'Digital' && lCase.Origin == 'Portal'){
                lReopenCasesLst.add(lCase);

                lJourneySet.add(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName);
                lEntryReasonSet.add(lCase.EntryReason__c);
                lLeavingReasonSet.add(lCase.LeavingReason__c);
                lProductSet.add(lCase.Product__c);
                // lContractBillingAccountSet.add(lCase.ContractBillingAccount__c);
                lContractBillingAccountSet.add(lCase.ContractBillingAccount__c);
                lParentIdSet.add(lCase.ParentId);
                //não é possível pegar o BusinessUnit__c, pois essas informações estão no contrato (registro relacionado)
            }
        }        
        system.debug('lReopenCasesLst ---------> ' + lReopenCasesLst);
        if(lReopenCasesLst.isEmpty()) return;

        //Monta map passando o ParentId como chave. Como valor um Wrapper que armazena a quantidade de casos filhos na base e data de fechamento do caso Pai
        Map<Id,CaseInfoWrapper> lCaseInfoMap = new Map<Id,CaseInfoWrapper>();
        for(Case lCase :[SELECT Id, ParentId, ClosedDate FROM Case WHERE Id IN :lParentIdSet OR ParentId IN :lParentIdSet]){
            if(lParentIdSet.contains(lCase.Id)){ // significa que é um caso pai
                CaseInfoWrapper lInfo = lCaseInfoMap.get(lCase.Id);
                if(lInfo == null){
                    lInfo = new CaseInfoWrapper();
                    lCaseInfoMap.put(lCase.Id, lInfo);
                }
                lInfo.lClosedDate = Date.ValueOf(lCase.ClosedDate);
            }
            else{// entra nesse else quando for um caso filho
                CaseInfoWrapper lInfo = lCaseInfoMap.get(lCase.ParentId);
                if(lInfo == null){
                    lInfo = new CaseInfoWrapper();
                    lCaseInfoMap.put(lCase.ParentId, lInfo);
                }
                lInfo.lChieldCasesAmount ++;
            }
        }
        system.debug('lCaseInfoMap ---------> ' + lCaseInfoMap);
        
        // Monta Map de unidade de negócio de todos os casos, através da unidade de negócio do contrato
        Map<Id,String> lBusinessUnitMap = new Map<Id,String>();
        Set<String> lBusinessUnitSet = new Set<String>();
        for(Account lAccount :[SELECT Id, BusinessUnit__c FROM Account WHERE Id IN :lContractBillingAccountSet]){
            lBusinessUnitMap.put(lAccount.Id, lAccount.BusinessUnit__c);
            lBusinessUnitSet.add(lAccount.BusinessUnit__c); // Utilizando um SET, pois a Query Dinâmica não aceita map.values();
        }

        String lStringJourneys;        
        for(String lJourney :lJourneySet){
            lStringJourneys = String.isNotBlank(lStringJourneys) ? lStringJourneys + ',' + '\'' + lJourney + '\'' : '\'' + lJourney + '\'';
        }
        system.debug('lStringJourneys ---------> ' + lStringJourneys);

        String lStringEntryReasons;
        for(String lEntryReason :lEntryReasonSet){
            lStringEntryReasons = String.isNotBlank(lStringEntryReasons) ? lStringEntryReasons + ',' + '\'' + lEntryReason + '\'' : '\'' + lEntryReason + '\'';
        }
        system.debug('lStringEntryReasons ---------> ' + lStringEntryReasons);

        String lStringLeavingReasons;
        for(String lLeavingReason :lLeavingReasonSet){
            lStringLeavingReasons = String.isNotBlank(lStringLeavingReasons) ? lStringLeavingReasons + ',' + '\'' + lLeavingReason + '\'' : '\'' + lLeavingReason + '\'';
        }
        system.debug('lStringLeavingReasons ---------> ' + lStringLeavingReasons);

        String lQuery = 'SELECT Id, Active__c, Journey__c, EntryReason__c, LeavingReason__c, Business_Unit__c, Product__c, Solar_Cross_ReopenPriority__c, SolarCross_QuantityTime__c, SolarCross_QuantityDays__c '; 
        lQuery += 'FROM Parameters__c ';
        lQuery += 'WHERE Active__c = true AND ';
        lQuery += 'RecordTypeId = :REOPEN_PROTOCOL_RECTYPE AND ';
        lQuery += '(Journey__c INCLUDES (' + lStringJourneys + ') OR Journey__c = null) AND ';
        lQuery += '(EntryReason__c INCLUDES (' + lStringEntryReasons + ') OR EntryReason__c = null) AND ';
        lQuery += '(LeavingReason__c INCLUDES (' + lStringLeavingReasons + ') OR LeavingReason__c = null) AND ';
        lQuery += '(Business_Unit__c IN :lBusinessUnitSet OR Business_Unit__c = null) AND ';
        lQuery += '(Product__c IN :lProductSet OR Product__c = null) '; 
        lQuery += 'ORDER BY Solar_Cross_ReopenPriority__c DESC'; 
        system.debug('lQuery ---------> ' + lQuery);

        List<Parameters__c> lParametersLst = Database.query(lQuery);
        system.debug('lParametersLst ---------> ' + lParametersLst);
        
        for(Case lCase :lReopenCasesLst){
            for(Parameters__c lParameter :lParametersLst){  
                CaseInfoWrapper lCaseInfo = lCaseInfoMap.get(lCase.ParentId);
                Boolean lRefuseCase = false;

                switch on Integer.ValueOf(lParameter.Solar_Cross_ReopenPriority__c) {
                    when 5 {
                        if(lParameter.Journey__c.contains(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName) && lParameter.EntryReason__c.contains(lCase.EntryReason__c)
                        && lParameter.LeavingReason__c.contains(lCase.LeavingReason__c) && lParameter.Business_Unit__c == lBusinessUnitMap.get(lCase.ContractBillingAccount__c)
                        && lParameter.Product__c == lCase.Product__c){
                            lRefuseCase = true;
                        }
                    }	
                    when 4 {
                        if(lParameter.Journey__c.contains(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName) && lParameter.EntryReason__c.contains(lCase.EntryReason__c)
                        && lParameter.LeavingReason__c.contains(lCase.LeavingReason__c) && lParameter.Business_Unit__c == lBusinessUnitMap.get(lCase.ContractBillingAccount__c)){
                            lRefuseCase = true;
                        }
                    }
                    when 3 {
                        if(lParameter.Journey__c.contains(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName) && lParameter.EntryReason__c.contains(lCase.EntryReason__c)
                        && lParameter.LeavingReason__c.contains(lCase.LeavingReason__c)){
                            lRefuseCase = true;
                        }
                    }
                    when 2 {
                        if(lParameter.Journey__c.contains(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName) && lParameter.EntryReason__c.contains(lCase.EntryReason__c)){
                            lRefuseCase = true;
                        }
                    }
                    when 1 {
                        if(lParameter.Journey__c.contains(lJourneyNameMap.get(lCase.RecordTypeId).DeveloperName)){
                            lRefuseCase = true;
                        }
                    }
                    when 0 {
                        lRefuseCase = true;
                    }
                }
                //Caso Exista Testa se a quantidade de casos filho abertos ultrapassa a quantidade definida no registro de Parâmetros, 
                //ou se a quantidade de dias entre o fechamento do caso pai e a data de hoje ultrapassa a quantidade definida no registro de Parâmetros
                //Em seguida dá um Break na iteração aninhada, pois significa que já encontrado um registro de Parameters__c correspondente à esse Case
                if(lRefuseCase){
                    if(lCaseInfo.lClosedDate == null){
                        String lError = 'Não é possível reabrir um Caso que não esteja encerrado';
                        system.debug('lError ---------> ' + lError);
                        lCase.addError(lError);
                    }
                    Integer lDaysBetweenClosedDate = lCaseInfo.lClosedDate.daysBetween(system.today());
                    if(Test.isRunningTest()){
                        lDaysBetweenClosedDate = lCaseInfo.lClosedDate.daysBetween(system.today().addDays(100));
                    }
                    if(lCaseInfo.lChieldCasesAmount >= Integer.ValueOf(lParameter.SolarCross_QuantityTime__c)){
                        String lError = Label.SolarCross_ReopenCasesDeniedMessage + ' -- ' + 'Quantidade máxima de reabertura para esse caso: ' + lParameter.SolarCross_QuantityTime__c + ' -- ' + 'Quantidade de vezes já reabertas: ' + lCaseInfo.lChieldCasesAmount;
                        system.debug('lError ---------> ' + lError);
                        lCase.addError(Label.SolarCross_ReopenCasesDeniedMessage + ' -- ' + 'Quantidade máxima de reabertura para esse caso: ' + lParameter.SolarCross_QuantityTime__c + ' -- ' + 'Quantidade de vezes já reabertas: ' + lCaseInfo.lChieldCasesAmount);
                    }
                    else if(lDaysBetweenClosedDate > Integer.ValueOf(lParameter.SolarCross_QuantityDays__c)){
                        String lError = Label.SolarCross_ReopenCasesDeniedMessage + ' -- ' + 'Quantidade máxima de dias para reabertura desse caso: ' + lParameter.SolarCross_QuantityDays__c + ' -- ' + 'Quantidade de dias passados após fechamento deste caso: ' + lCaseInfo.lClosedDate.daysBetween(system.today());
                        system.debug('lError ---------> ' + lError);
                        lCase.addError(lError);
                    }
                    break;
                }
            }
        }
    }

    public class CaseInfoWrapper{
        public Integer lChieldCasesAmount;
        public Date lClosedDate;

        public CaseInfoWrapper(){
            lChieldCasesAmount = 0;
        }
    }
}