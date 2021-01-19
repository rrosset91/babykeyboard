/*
* Autor: Squad Canais Criticos
* Data: 18/11/2020 
* Descrição: Habilitar as regras de atribuição dos casos de ouvidoria
*/
public class CEC_CC_CaseAssignmentRules {
    
    //Controle para evitar processamento recorrente
    private static boolean run = true;
    
    /**
     * Habilita a regra de atribuicao para casos que tenham sub area
     */
    public static void enableCaseAssignmentRulesSubArea(List<Case> cases) {

        if(run) {
            List<Case> casesToAssign = new List<Case>();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;            
            for(Case caseToAssign : [Select id from Case where id in :cases and ServiceSubArea__c != null]) {
            	caseToAssign.setOptions(dmo);    
                casesToAssign.add(caseToAssign);
            }         
            if(!casesToAssign.isEmpty()) {
                System.debug('Regra de atribuicao para os Casos: ');
                System.debug(casesToAssign);
                update casesToAssign;
            }            
            run = false;
        } else {
            System.debug('enableCaseAssignmentRulesSubArea nao executado');
        }   
    }
}