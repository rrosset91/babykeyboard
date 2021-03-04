/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 15/01/2020
* Descrição: Atribuição automática de sub status 'em tratamento' para casos do Representante Gov
* 
* Controle de Versão
* --------------------------------------------------------------- 
* Data: 06/03/2020   
* Autor: Squad Canais Criticos
* Alterações: Processamento de todos os casos CEC atribuídos pelo omni para atualizar o campo SLA Restante 
			  Demais casos tratados pela recorrencia devem ser atualizados na classe CEC_CaseSLATriggerHandler
* ---------------------------------------------------------------
*/
public class CEC_CC_AgentWorkFlow {
    
    @testVisible private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    @testVisible private static final String RT_ChildrenCases = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
   
    @InvocableMethod
    public static void setCaseUp(List<Agente> agents)
    {
        system.debug('CEC_CC_AgentWorkFlow ## setCaseUp : Lista de Agentes para processar: ' + agents);
        
        //Selecionar perfis permitidos para validaçao de casos do GOV
        Set<String> setAllowdProfiles = new Set<String>{'ZSF_CANAIS_CRITICOS_RPA','RPA Canais Criticos','Administrador do sistema','System Administrator'};
        
        //Selecionar todos os tipos de registros de casos de Canais Críticos
        Set<Id> setCasesCECRTId = CEC_CC_Util.getAllCecRtByObj('Case');
        setCasesCECRTId.add(RT_ChildrenCases);
        setCasesCECRTId.add(RT_CONSUMIDOR_GOV);
        
        List<Case> lstCasesToUpdate = new List<Case>();
        Set<Id> setAgentsId = new Set<Id>();
        Set<Id> setCasesId  = new Set<Id>();
        
        for(Agente agente : agents)
        {
            setAgentsId.add(agente.UserId);
            setCasesId.add(agente.WorkItemId);
        }
        
        Map<Id, User> mapUsersInfo = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :setAgentsId]);
        Map<Id, Case> mapCaseInfo = new Map<Id, Case>([SELECT Id, CreatedBy.UserName, CreatedBy.Profile.Name, 
                                                       SubStatus__c, Milestonetime__c, RecordTypeId FROM Case WHERE Id IN :setCasesId]);
        
        //Selecionar os marcos dos casos recebidos
        Map<Id, DateTime> mapCaseMilestone = new Map<Id, DateTime> ();
        for (CaseMilestone varCaseMilestone :[SELECT Id, CaseId, TargetDate FROM CaseMilestone WHERE CaseId IN: mapCaseInfo.keySet()]){
			mapCaseMilestone.put(varCaseMilestone.CaseId, varCaseMilestone.TargetDate);
        }
        
        for(Agente agente : agents)
        {
            User userInfo = mapUsersInfo.get(agente.userId);             
            Case caseInfo = mapCaseInfo.get(agente.WorkItemId);
            
            //Atualizar o caso do GOV para 'Em tratamento'
            if((setAllowdProfiles.contains(caseInfo.CreatedBy.Profile.Name) || caseInfo.CreatedBy.UserName.contains('rpacc@claro.com.br')) && 
               userInfo.Profile.Name == 'Representantes Gov')
            {
                caseInfo.SubStatus__c = 'Em tratamento';
                lstCasesToUpdate.add(caseInfo);
            }
            
            //Atualizar o campo de SLA restante para todos os casos do CEC
            if(setCasesCECRTId.contains(caseInfo.RecordTypeId) && mapCaseMilestone.containsKey(caseInfo.Id)){
                system.debug('CEC_CC_AgentWorkFlow  ## TargetDate: ' + mapCaseMilestone.get(caseInfo.Id));
                caseInfo.MilestoneTime__c =  mapCaseMilestone.get(caseInfo.Id);
                if(!lstCasesToUpdate.contains(caseInfo))
                	lstCasesToUpdate.add(caseInfo);
            }
        }
        system.debug('CEC_CC_AgentWorkFlow ## setCaseUp : Casos para reprocessar: ' + lstCasesToUpdate.size());
        if(lstCasesToUpdate.size() > 0) {
            CEC_CaseTriggerHandler.byPassValidation = true;
            update lstCasesToUpdate;
        }
    }
    
    public class Agente
    {
        @InvocableVariable public string Id;
        @InvocableVariable public Datetime AcceptDateTime;
        @InvocableVariable public String UserId;
        @InvocableVariable public String WorkItemId;        
    }
}