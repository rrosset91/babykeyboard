global class CEC_PME_BatchLimiteExpOpp implements Database.Batchable<sObject>{
	//construtor
    global CEC_PME_BatchLimiteExpOpp(){}
    
    //preparar dados para o batch
    global Database.QueryLocator start(Database.BatchableContext bc){
        String recType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_PME').getRecordTypeId();
        Set<String> setStatus = CEC_PME_UtilsLimiteExpiracao.getLimiteStatus('Simulação');
        Date expDate = Date.today();
        
        return Database.getQueryLocator([SELECT StageName, CreatorProfile__c, CommercialSegment2__c,
                                         SimulationCreationDate__c
                                         FROM Opportunity
                                         WHERE RecordTypeId =: recType
                                         AND (Expiration_Date__c <= :expDate)
                                         AND StageName NOT IN: setStatus]);
    }
                                        
    //processamento do batch
    global void execute(Database.BatchableContext bc, List<Opportunity> lstOppt) {       
        //Status do pedido
        final String NEW_OPPT_STATUS = 'Expirada';
        
        //lista para atualização
        List<Opportunity> lstOpptUpd = new List<Opportunity>();
        for(Opportunity oppt: lstOppt) {
            oppt.StageName = NEW_OPPT_STATUS;
            lstOpptUpd.add(oppt);
        }

        update lstOpptUpd;   
    }
    
    //ação pós processamento
    global void finish(Database.BatchableContext bc) {}
}