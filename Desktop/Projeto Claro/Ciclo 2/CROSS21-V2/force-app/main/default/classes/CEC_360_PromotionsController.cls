/*
* Autor: Danilo Fucuhara (Deloitte)
* Data: 12/02/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360] Classe controller do component CEC_360_Promotions.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 12-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Criado o método getPromotions().
*---------------------------------------------------------------
* Data: 05-06-2019
* Autor: Letícia Freitas
* Alterações: Inclusão do método Histórico de Promoções. 
*/

public class CEC_360_PromotionsController {
    @AuraEnabled
    public static CEC_RestObjects.PromotionsMain getPromotions(String recordId) {
        CEC_RestObjects.PromotionsMain promotions = new CEC_RestObjects.PromotionsMain();
        Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
        if(record.MSISDN__c != null) {
            promotions = CEC_360_IntegrationPromotions.getPromotions(record.MSISDN__c);
            //promotions = CEC_360_IntegrationPromotions.generateMock();
        }
        
        if(promotions == null) {
            return null;
        }
        
        return promotions;
    }
    
    @AuraEnabled 
    public static List<CEC_RestObjects.PromotionsHistory> getHistoryPromotion(String recordId,string startDate,string endDate ){
         Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
        CEC_RestObjects.promotionsHistoryResponse obj = new CEC_RestObjects.promotionsHistoryResponse();
        if(record.MSISDN__c != null){
          obj = CEC_360_IntegrationPromotions.getPromotionsHistory(record.msisdn__c, startDate, endDate);
          //obj = CEC_360_IntegrationPromotions.generateMockHistory();
        }
        
        if(obj.data != null){
           return obj.data.promotionsHistory;
        }else{
            return null;
        }
       
    }
    
    
    
}