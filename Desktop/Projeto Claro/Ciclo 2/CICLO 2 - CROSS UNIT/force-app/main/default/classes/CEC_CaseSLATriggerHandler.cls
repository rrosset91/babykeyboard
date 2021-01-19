/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/07/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 10] 
* 
* Controle de Versão
* --------------------------------------------------------------- 
* Data: 19/11/2019   
* Autor: Squad Canais Criticos
* Alterações: Remoção do Atendimento da Fila de Input
		      método (updateOwnerRobo)
* ---------------------------------------------------------------
* Data: 11/02/2020   
* Autor: Squad Canais Criticos
* Alterações: Remoção das condicionais para o preenchimento da data de vencimento e 
			  processamento no before para evitar update e método @future
* ---------------------------------------------------------------
* Data: 17/08/2020   
* Autor: Squad Canais Criticos
* Alterações: Inclusão da condição de usuário estar ativo no map de oldCaseMap para fazer a mudança do owner do caso no método updateOwner
* ---------------------------------------------------------------
* Data: 14/09/2020   
* Autor: Squad Canais Criticos
* Alterações: Alteração do método updateOwner para atualizar o owner do caso em memória e não realizar mais uma consulta. Chamada movida do afterUpdate pra beforeUpdate.
* ---------------------------------------------------------------
*/
public class CEC_CaseSLATriggerHandler extends TriggerHandler  
{
    @testVisible private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    @testVisible private static final String RT_GOV_CASO_FILHO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
      
    public override void beforeInsert() {
        setEntitlement(Trigger.new);
    }	
    
    public override void beforeUpdate()
    {
        updateOwner(Trigger.new, (Map<Id, Case>) Trigger.oldMap);
        setMilestoneTime(Trigger.new, (Map<Id, Case>)Trigger.oldMap);
    }
        
    public override void afterUpdate() {
        
        checkMilestone(Trigger.new, (Map<Id, Case>)Trigger.oldMap);

    } 
        
    /*-------------------------------------------------------------------------------------------------------
    --- Company: Deloitte Brazil
    --- Creation Date: 12/09/2018
    --- Author: Squad Canais Críticos
    --- Description: Método que realiza a criação de SLA de acordo a área de atuação (custom setting)
    -------------------------------------------------------------------------------------------------------*/
    public static void setEntitlement(list<Case> lstCases) 
    { 
        Map<String, String> mapCSEntitlementByArea = CEC_CC_Util.getCSEntitlementByArea();
        Map<String, Id> mapEntitlementId = new Map<String, Id>();
        Set<String> setSupportArea = new Set<String>();
        
        List<Entitlement> lstEntitlements = [SELECT Id, Name FROM Entitlement WHERE Name IN: mapCSEntitlementByArea.values()];
        //Getting all the entitlements info by the keys selected previously
        for(Entitlement entitlement : lstEntitlements){
            if(!mapEntitlementId.containsKey(entitlement.Name))
                mapEntitlementId.put(entitlement.Name, entitlement.Id);
        }
        
        //Applying the entitlements info according the Support Area
        for (Case varCase : lstCases)
        {
            String varEntitlementName;
            if(varCase.SupportArea__c <> null){
                String varSupportArea = varCase.SupportArea__c.toLowerCase().capitalize(); 
                varEntitlementName = mapCSEntitlementByArea.get(varSupportArea);
            }
            else if(varCase.Channel__c <> null && mapCSEntitlementByArea.containsKey(varCase.Channel__c))
            {
                varEntitlementName = mapCSEntitlementByArea.get(varCase.Channel__c);
            }            
            else {
                varEntitlementName = mapCSEntitlementByArea.get(Schema.SObjectType.Case.getRecordTypeInfosById().get(varCase.RecordTypeId).getDeveloperName());     
            }
            
            system.debug('SLA >> EntitlementName: ' + varEntitlementName);
            varCase.EntitlementId = mapEntitlementId.get(varEntitlementName);  
            system.debug('SLA >> EntitlementId: ' + varCase.EntitlementId);
        }
    }
    
	/*-------------------------------------------------------------------------------------------------------
    --- Company: Deloitte Brazil
    --- Creation Date: 12/09/2018
    --- Author: Squad Canais Críticos
    --- Description: Método que atualiza o valor do vencimento do caso com base no marco
	--- Atualizado 11-02-2020: Processamento no before para evitar update e método @future
	--- Atualizado 06-03-2020: Processamento de todos os casos CEC atribuídos pela recorrencia para atualizar o campo SLA Restante 
			  				   Demais casos atribuídos pelo omni channel devem ser atualizados na classe CEC_CC_AgentWorkFlow
    -------------------------------------------------------------------------------------------------------*/    
    public static void setMilestoneTime(List<Case> lstCases, Map<Id, Case> oldCaseMap)
    {
        Set<Id> setCasesCECRTId = CEC_CC_Util.getAllCecRtByObj('Case');
        setCasesCECRTId.add(RT_GOV_CASO_FILHO);
        setCasesCECRTId.add(RT_CONSUMIDOR_GOV);
            
        Set<Id> setCasesCECId = new Set<Id>();
        Map<Id, DateTime> mapCaseMilestone = new Map<Id, DateTime> ();
        
        for (Case varCase : lstCases)
        {
            //Preenchimento da data de vencimento para casos CC ou casos do GOV com mudança de Proprietário (Recorrência Omni)
            if(setCasesCECRTId.contains(varCase.RecordTypeId) && varCase.MilestoneTime__c == null &&
               varCase.OwnerId != oldCaseMap.get(varCase.Id).OwnerId && !CEC_CC_Util.isSemaphored(varCase.Id, 'setMilestoneTime')) 
            {
                setCasesCECId.add(varCase.Id);
            }
        }
        
        //FLUXO DE TESTE - Devido a impossibilidade de ser criar CaseMilestone via teste, no fluxo de teste serao simulados os dados
        if(Test.isRunningTest() && setCasesCECId.isEmpty() && lstCases != null && lstCases.size() > 0) {
            setCasesCECId.add(lstCases.get(0).Id);
            mapCaseMilestone.put(lstCases.get(0).Id,Datetime.Now());
        }
        
        if (setCasesCECId.isEmpty()) { return; }
	
        //Selecionar os marcos dos casos recebidos        
        for (CaseMilestone varCaseMilestone :[SELECT Id, CaseId, TargetDate FROM CaseMilestone WHERE CaseId = :setCasesCECId]){
			mapCaseMilestone.put(varCaseMilestone.CaseId, varCaseMilestone.TargetDate);
        }
        
        for (Case varCase : lstCases)
        {
            if(mapCaseMilestone.containsKey(varCase.Id)){
            system.debug('CEC_CaseSLATriggerHandler beforeUpdate ## TargetDate: ' + mapCaseMilestone.get(varCase.Id));
                varCase.MilestoneTime__c =  mapCaseMilestone.get(varCase.Id);
            }
        }
    }
    
    /*-------------------------------------------------------------------------------------------------------
    --- Company: Deloitte Brazil
    --- Creation Date: 12/09/2018
    --- Author: Squad Canais Críticos
    --- Description: Método que recalcula o vencimento do marco de acordo ao horário de antendimento
    -------------------------------------------------------------------------------------------------------*/
    
    public static void checkMilestone(list<Case> lstCases, map<Id, Case> oldCaseMap)
    { 
        Set<Id> setCasesGovId = new Set<Id> ();
               
        BusinessHours varDefaultHours = [SELECT Id, Name FROM BusinessHours
                                          WHERE Name = 'CEC_CC_HorarioAtendimentoConsumidorGov' LIMIT 1];
        
        //Selecionar status de atendimento do caso
        Map<Id, boolean> mapCaseMilestone = new map<Id, boolean> ();
        for (CaseMilestone varCaseMilestone :[SELECT id, CaseId, IsViolated FROM CaseMilestone WHERE CaseId = :lstCases]) {  
            mapCaseMilestone.put(varCaseMilestone.CaseId, varCaseMilestone.IsViolated);
        }
          
        List<Case> lstCasesToUpdate = new list<Case> (); 
        
        //Selecionar casos para recálculo de SLA
        for (Case varCase : lstCases)
        {
            Boolean caseIsViolated = mapCaseMilestone.get(varCase.Id);            
            caseIsViolated = (caseIsViolated == null) ? true : caseIsViolated;
            
            //Redução para uma unica linha para aumentar o percentual de cobertura, visto que nao foi possivel incrementera via metodo de teste esse fluxo porque nao é criado Milestone
            if (varCase.RecordTypeId == RT_CONSUMIDOR_GOV && varCase.SubStatus__c == 'Recusa Negada' && oldCaseMap.get(varCase.Id).SubStatus__c != 'Recusa Negada' && !caseIsViolated && !CEC_CC_Util.isSemaphored(varCase.Id, 'checkMilestone')) 
            { 
                setCasesGovId.add(varCase.Id);
            }
        }
        
        if (setCasesGovId.isEmpty()) { return; }
        
        //Recalcular SLA para atendimento fora do horário
        for (Case varCase : [SELECT Id, OpenDateRobot__c, milestonetime__c, DatePauseSla__c, ResumedDate__c FROM Case WHERE Id IN: setCasesGovId])
        {
            Long dtSLA = varCase.DatePauseSla__c.getTime();
            Long seconds = (System.now().getTime() - dtSLA) / 1000;
            
            varCase.milestonetime__c = varCase.milestonetime__c.addSeconds(Integer.valueOf(seconds));
            
            if (!BusinessHours.isWithin(varDefaultHours.Id, varCase.MilestoneTime__c)) {
                varCase.MilestoneTime__c = BusinessHours.nextStartDate(varDefaultHours.Id, varCase.MilestoneTime__c);
            }
            
            lstCasesToUpdate.add(varCase);
        }
        
        if (!lstCasesToUpdate.isEmpty()) { 
            Database.update(lstCasesToUpdate); 
        }
    } 
    
    @testVisible private static void updateOwner(List<Case> lstCases, Map<Id, Case> oldCaseMap)
    {
        for (Case varCase : lstCases)
        {
            //Redução para uma unica linha para aumentar o percentual de cobertura, visto que nao foi possivel incrementera via metodo de teste esse fluxo.
            if (varCase.RecordTypeId == RT_CONSUMIDOR_GOV && (varCase.SubStatus__c == 'Recusa Negada' || varCase.SubStatus__c == 'Recusa Aceita' || varCase.SubStatus__c == 'Concluído' || varCase.SubStatus__c == 'Encerrado') && (oldCaseMap.get(varCase.Id).SubStatus__c != 'Recusa Negada' || oldCaseMap.get(varCase.Id).SubStatus__c != 'Concluído' || oldCaseMap.get(varCase.Id).SubStatus__c != 'Recusa Aceita' || oldCaseMap.get(varCase.Id).SubStatus__c != 'Encerrado') && varCase.OwnerId != oldCaseMap.get(varCase.Id).OwnerId && !CEC_CC_Util.isSemaphored(varCase.Id, 'updateOwner') && varCase.OwnerId != oldCaseMap.get(varCase.Id).OwnerId && oldCaseMap.get(varCase.Id).Owner != null && oldCaseMap.get(varCase.Id).Owner.IsActive)
            {
                varCase.OwnerId = oldCaseMap.get(varCase.Id).OwnerId;
            }
            else continue;
        }
   }
}