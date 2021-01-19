/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/07/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 10] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 24/07/2019  
* Autor: Squad Canais Criticos
* Alterações: Utilização de TriggerHandler e segregação da lógica de SLA
* ---------------------------------------------------------------
* Data: 14/09/2020   
* Autor: Squad Canais Criticos
* Alterações: Retitada do before insert da chamada do CEC_CaseTriggerController.checkIfRedirectToAnotherOwner devido a erro de 'insufficient access rights on cross-reference id'
* ---------------------------------------------------------------
*/
trigger CEC_CaseTrigger on Case(before insert, before update, after insert, after update) 
{
    new CEC_CaseTriggerHandler().run();
    new CEC_CaseSLATriggerHandler().run();
    
    new NBA_CaseTriggerHandler().run();

    if (trigger.isBefore) {
        if (trigger.isInsert){
            CEC_CaseTriggerController.checkIfIsAllowedToCreateANewCase(trigger.new);

            //Retirado para ser chamado dentro do process builder - SkillsOuvidoria. Na trigger esse fluxo dá erro caso o perfil corrente não tenha a permissão de transfer cases - CEC_CaseTriggerController.checkIfRedirectToAnotherOwner(trigger.new);
        }
            
        if (trigger.IsUpdate) {
            //Valida alteracoes na descricao do caso, considerando caracteres especiais. Somente continua a proxima execucao se nao forem retornados casos invalidos na lista
            CEC_CaseValidationHelper.validateChangeDescription(Trigger.old, Trigger.new);
            
            //Regras de validacao específicas para evitar o limite de 15 lookups
            CEC_CC_ValidationRuleCase.validationRules(Trigger.new);  
        }
    }
}