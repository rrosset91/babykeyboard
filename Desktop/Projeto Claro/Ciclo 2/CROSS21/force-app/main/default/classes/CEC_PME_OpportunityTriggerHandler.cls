/*  	
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto oportunidade, contextualizado com a tipo de registro.
*/
public class CEC_PME_OpportunityTriggerHandler extends TriggerHandler {
    private final String RECORD_TYPE_PME = 'Opportunity_PME';
    List<Opportunity> triggerNewPME;
    List<Opportunity> triggerOldPME;
    Map<Id, Opportunity> triggerOldMapPME;
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Construtor, pega os registros contextualizados
    */ 
    public CEC_PME_OpportunityTriggerHandler() {
        triggerNewPME = (List<Opportunity>) getTriggerNewByRecordTypeDeveloperName(RECORD_TYPE_PME);
        triggerOldPME = (List<Opportunity>) getTriggerOldByRecordTypeDeveloperName(RECORD_TYPE_PME);
        triggerOldMapPME = new Map<Id, Opportunity>();
        triggerOldMapPME.putAll(triggerOldPME);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterInsert() {
        if(!triggerNewPME.isEmpty()) {
            new CEC_PME_SharerRecord().sharingRecordOpportunity(triggerNewPME);
        	CEC_PME_OpportunityExpirationDate.getExpirationDate(Trigger.newMap.keySet());
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void beforeUpdate() {
        if(!triggerNewPME.isEmpty()) {
            
            List<Opportunity> listOnChangeStatus = getListOnChangeStatus();
            
            if(!listOnChangeStatus.isEmpty()) {
                CEC_PME_OpportunityExpirationDate.updExpirationDate(listOnChangeStatus);               
            }        
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Lista os registros que tiveram o status atualizados
    */ 
    private List<Opportunity> getListOnChangeStatus() {
        List<Opportunity> listOnChangeStatus = new List<Opportunity>();
        for(Opportunity opportunity : triggerNewPME) {
            String stageName = triggerOldMapPME.get(opportunity.Id).StageName;
            
            if (stageName != opportunity.StageName) {
                listOnChangeStatus.add(opportunity);                   
            }
        }
        
        return listOnChangeStatus;
    }
}