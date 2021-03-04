/*
* Autor:
* Data: 
* Descrição: Criação do metodo futuro para tratativa dos casos que estão sem o milestoneTime__c preenchido 
* e com o status de 'Em Tratamento'. Metodo updateMilestoneTime
*
* Controle de Versão
* --------------------------------------------------------------- 
* Data: 
* Autor: 
* Alterações:
* ---------------------------------------------------------------*/
public class CEC_CC_CheckMilestoneTime {

   /*
    * Autor:
    * Data: 
    * Descrição: Metodo futuro para tratativa dos casos que estão sem o milestoneTime__c preenchido 
	* e com o status de 'Em Tratamento'
    */ 
    @InvocableMethod
    public static void checkMilestoneTimeCase(List<String> cases) {  
        Set<Id> casesToUpdateMilestone = new Set<Id>();
        
        for(String caseItem : cases){
    		casesToUpdateMilestone.add(caseItem);
        }
        
        if(casesToUpdateMilestone.size() > 0){
        	updateMilestoneTime(casesToUpdateMilestone);
        }
    }
    
    /*
    * Autor: André Salgado
    * Data: 30/04/11/2019 
    * Descrição: Metodo futuro para tratativa dos casos que estão sem o milestoneTime__c preenchido 
	* e com o status de 'Em Tratamento'
    */  
	@future
    public static void updateMilestoneTime(Set<Id> cases) {
		Map<Id, DateTime> mapCaseMilestone = new Map<Id, DateTime>();		
		List<Case> lstCasesToUpdate = new List<Case>();

		//## seleciona todos os casos que estão sem milestoneTime preenchido que sejam consumidor.gov  e que estejam em tratamento
		//ATUALIZACAO - 02/09/2020 - retirada do sub status e owner id da consulta para evitar da informacao atualizar de volta no Case por esse metodo rodar de forma async. Erros de carga via RPA//
		List<Case> lstCasesToMilestone = [SELECT Id, 
												  Grouping__c, 
												  Channel__c, 
												  Account.DocumentNumber__c,
												  RecordTypeId,
                                          		  RecordType.DeveloperName,
                                          		  MilestoneStatus,
                                          		  MilestoneTime__c,
												  Skill__c
										  FROM Case WHERE Id IN : cases
										  AND  MilestoneTime__c = null];
                
        System.debug('# tamanho casos ' + lstCasesToMilestone.size() );
        
        List<CaseMilestone> lstCaseMilestone = [SELECT Id, CaseId, TargetDate FROM CaseMilestone WHERE CaseId in :lstCasesToMilestone];
		
        System.debug('# tamanho milestone ' + lstCaseMilestone.size() );
        
		//## lista todos os milestones para os cases criados		
		for (CaseMilestone varCaseMilestone : lstCaseMilestone){
            mapCaseMilestone.put(varCaseMilestone.CaseId, varCaseMilestone.TargetDate);
            
            System.debug('# Encontrou o milestone para o caso: ' + varCaseMilestone);
        }
		
		//## Percorre a relação de cases para atribuir os milestones
		for (Case varCase : lstCasesToMilestone){
            System.debug('# ID ' + varCase.Id + ' MilestoneTime__c ' + varCase.MilestoneTime__c + ' MilestoneStatus ' + varCase.MilestoneStatus );
            
            //## Verifica se existe os milestones para os casos e seta o target caso exista
			if(mapCaseMilestone.containsKey(varCase.Id)){
				varCase.MilestoneTime__c = mapCaseMilestone.get(varCase.Id);
				lstCasesToUpdate.add(varCase);
                
                System.debug('# Caso a ser alterado: ' + varCase);
			}
		}

		//## verifica se tem algum caso para atualizar e atualiza os casos com o milestoneTime 
        if (!lstCasesToUpdate.isEmpty()) { 
            Database.update(lstCasesToUpdate); 
        }							  
	} 
}