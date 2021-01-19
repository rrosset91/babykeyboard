public without sharing class CEC_PME_NavigateToOppController {
    
    @AuraEnabled
    public static String validate(String opportunityId) {
        final String STAGE_EXPIRADA = 'Expirada';
        final String MESSAGE_SUCCESS = 'Sucesso';
        final String MESSAGE_ERROR = 'Simulação Expirada';
        
        Opportunity varOpportunity = [SELECT Id, 
                                      StageName
                                      FROM Opportunity
                                      WHERE Id = :opportunityId];
        
        if(STAGE_EXPIRADA.equalsIgnoreCase(varOpportunity.StageName)) {
            return MESSAGE_ERROR;
        } else {
            return MESSAGE_SUCCESS;
        }
    }
}