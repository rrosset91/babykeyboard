public class CEC_ME_CaseButtonsController {
	@AuraEnabled
    public static Case getCase(String caseId){
        List<Case> lstCase = [SELECT Status FROM Case WHERE Id =:caseId];
        if(!lstCase.isEmpty()){
            return lstCase[0];
        }else{
            return null;
        }
    }
}