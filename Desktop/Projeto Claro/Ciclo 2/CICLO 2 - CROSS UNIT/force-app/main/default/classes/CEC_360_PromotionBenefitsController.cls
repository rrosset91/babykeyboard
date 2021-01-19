/* Autor: Danilo Fucuhara - Deloitte 
   Criação: 22/03/2019
   Descrição:Classe para interfacear a busca via integração dos beneficios de controle. 
   Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

public class CEC_360_PromotionBenefitsController {
    @AuraEnabled
    public static CEC_RestObjects.PromotionBenefitsMain getPromotionBenefits(String recordId, String promotionIdNGP, String promotionVersionNGP, String sequentialIdNGP) {
        CEC_RestObjects.PromotionBenefitsMain benefits = new CEC_RestObjects.PromotionBenefitsMain();
        Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
        if(record.MSISDN__c != null) {
            benefits = CEC_360_IntegrationPromotionBenefits.getPromotionBenefits(record.MSISDN__c, promotionIdNGP, promotionVersionNGP, sequentialIdNGP);
           	//benefits = CEC_360_IntegrationPromotionBenefits.generateMock();
        }
        return benefits;
    }
}