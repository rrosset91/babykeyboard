/*
* Data: 17/08/2020   
* Autor: Squad Canais Criticos
* Alterações: Inclusão da condição de usuário estar ativo no metodo checkIfRedirectToAnotherOwner
* ---------------------------------------------------------------
* Data: 14/09/2020   
* Autor: Squad Canais Criticos
* Alterações: Alteração do método checkIfRedirectToAnotherOwner para ser acionado por Process Builder. A chamada direta desse metodo pela trigger do Case dava erro caso o perfil corrente não tiver permissão de transferir casos.
* O erro acontecia somente por ser um fluxo de insert do casto, os demais que fazer esse fluxo no update ou até mesmo no process builder funcionam mesmo sem o perfil ter a permisao
* ---------------------------------------------------------------
*/
public class CEC_CaseTriggerController {
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();

    public static void checkIfIsAllowedToCreateANewCase(List<Case> lstCases){        
        Set<String> caseContractId = new Set<String>();
        Set<String> caseLineNumber = new Set<String>();
        for(Case currentCase: lstCases){
            if(currentCase.recordTypeId == CEC_CC_Ouvidoria){
                caseContractId.add(currentCase.ContractBillingAccount__c);
                caseLineNumber.add(currentCase.LineNumber__c);
            }
        }

        List<Case> openedCases = [
            SELECT
                Id, AccountId, RecordTypeId, ContractBillingAccount__c, LineNumber__c
            FROM
                Case
            WHERE
                RecordTypeId = :CEC_CC_Ouvidoria AND
                ContractBillingAccount__c IN :caseContractId AND
                LineNumber__c IN :caseLineNumber AND
                IsClosed = false
        ];

        if(openedCases.size() > 0){
            Map<String, List<Case>> AccountCases = new Map<String, List<Case>>();
            Map<String, List<Case>> LineCases = new Map<String, List<Case>>();
    
            for(Case currentCase: openedCases){
                if(!AccountCases.containsKey(currentCase.ContractBillingAccount__c)){
                    AccountCases.put(currentCase.ContractBillingAccount__c, new List<Case>());
                }
    
                if(!LineCases.containsKey(currentCase.LineNumber__c)){
                    LineCases.put(currentCase.LineNumber__c, new List<Case>());
                }
    
                AccountCases.get(currentCase.ContractBillingAccount__c).add(currentCase);
                LineCases.get(currentCase.LineNumber__c).add(currentCase);
            }
    
            for(Case currentCase: lstCases){
                if((!String.isBlank(currentCase.ContractBillingAccount__c) && AccountCases.containsKey(currentCase.ContractBillingAccount__c) && AccountCases.get(currentCase.ContractBillingAccount__c).size() > 0) ||
                    (!String.isBlank(currentCase.LineNumber__c) && LineCases.containsKey(currentCase.LineNumber__c) && LineCases.get(currentCase.LineNumber__c).size() > 0)){
                    currentCase.addError('Não é possível criar um novo caso de ouvidoria, pois o contrato do cliente possui um em aberto. Adicione uma ação interna ao caso aberto.');
                }
            }
        }
    }

    /**
     * Acionado no Process Builder - SkillsOuvidoria
     */
    @InvocableMethod
    public static void checkIfRedirectToAnotherOwner(List<String> casesIds){
        Map<String, List<Case>> identificadorCasos = new Map<String, List<Case>>();
        List<Case> casosFechadosCliente = NULL;
    
        List<Case> lstCases =        [SELECT Id, 
                                             ContractBillingAccount__c,
                                             LineNumber__c,
                                             OwnerId,
                                             RecordTypeId
                                             FROM Case 
                                             WHERE Id IN : casesIds];

        for(Case currentCase: lstCases){
            if(currentCase.recordTypeId == CEC_CC_Ouvidoria){
                String identificador = currentCase.ContractBillingAccount__c != NULL && currentCase.LineNumber__c == NULL ? String.valueOf(currentCase.ContractBillingAccount__c) : currentCase.ContractBillingAccount__c == NULL && currentCase.LineNumber__c != NULL ? String.ValueOf(currentCase.LineNumber__c) : '';                
                
                if(!String.isBlank(identificador) && !identificadorCasos.containsKey(identificador)){
                    identificadorCasos.put(identificador, new List<Case>());
                }
            }
        }
        
        if(identificadorCasos.keySet().size() > 0){
            casosFechadosCliente = [
                SELECT
                    Id, OwnerId, AccountId, ContractBillingAccount__c, LineNumber__c
                FROM
                    Case
                WHERE
                    (ContractBillingAccount__c IN :identificadorCasos.keySet() OR
                    LineNumber__c IN :identificadorCasos.keySet()) AND
                    IsClosed = true AND
                    ClosedDate = LAST_N_DAYS:45 AND
                    RecordTypeId = :CEC_CC_Ouvidoria AND
                    Owner.IsActive = true AND
                    OwnerId IN (
                        SELECT
                            RelatedRecordId
                        FROM
                            ServiceResource
                        WHERE
                            Quantidade_de_Habilidades__c > 0 AND
                            IsActive = true AND
                            RelatedRecord.isActive = true
                    )
                ORDER BY
                    ClosedDate DESC
            ];
        }
    
        if(casosFechadosCliente != NULL && casosFechadosCliente.size() > 0){
            for(Case currentClosedCase: casosFechadosCliente){
                String identificador = currentClosedCase.ContractBillingAccount__c != NULL && currentClosedCase.LineNumber__c == NULL ? currentClosedCase.ContractBillingAccount__c : currentClosedCase.ContractBillingAccount__c == NULL && currentClosedCase.LineNumber__c != NULL ? currentClosedCase.LineNumber__c : '';
                if(!String.isBlank(identificador)){
                    identificadorCasos.get(identificador).add(currentClosedCase);
                }
            }

            List<Case> casosRecorrencia = new List<Case>();
    
            for(Case currentCase: lstCases){
                String identificador = currentCase.ContractBillingAccount__c != NULL && currentCase.LineNumber__c == NULL ? String.valueOf(currentCase.ContractBillingAccount__c) : currentCase.ContractBillingAccount__c == NULL && currentCase.LineNumber__c != NULL ? String.ValueOf(currentCase.LineNumber__c) : '';
                
                if(!String.isBlank(identificador) && identificadorCasos.containsKey(identificador) && identificadorCasos.get(identificador).size() > 0){
                    currentCase.OwnerId = identificadorCasos.get(identificador)[0].OwnerId;
                    casosRecorrencia.add(currentCase);
                }
            }

            if(!casosRecorrencia.isEmpty()) {
                Database.update(casosRecorrencia);
            }
            
        }
    }
}