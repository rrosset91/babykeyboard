/*
* Autor: Danilo Fucuhara (Deloitte)
* Data: 12/02/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360] Classe de conexão com a API de promoções.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 12-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Criado o método getPromotions() e generateMock().
* ---------------------------------------------------------------
* Data: 11-06-2019  
* Autor: Letícia Freitas
* Alterações: Adicionado métodos para busca de histórico de promoções.
* --------------------------------------------------------------------
* Data: 17-07-2019.
* Autor: Letícia Freitas.
* Alterações: Alterando métodos para credencial nomeada. 
*/

public class CEC_360_IntegrationPromotions {
    
    public static CEC_RestObjects.PromotionsMain getPromotions(String phoneLineNumber) { 
        CEC_RestObjects.PromotionsMain promotions = new CEC_RestObjects.PromotionsMain();
         String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('Promotions');
        }else{
            service = '/promotions';
        }
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service +
                                '?phoneLineNumber=' + phoneLineNumber );
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('REQUEST: ' + request);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            promotions = (CEC_RestObjects.PromotionsMain)JSON.deserialize(responseBody, CEC_RestObjects.PromotionsMain.class);
            promotions = formatPromotions(promotions);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return promotions;
    }
    
    public static CEC_RestObjects.PromotionsMain formatPromotions(CEC_RestObjects.PromotionsMain promotions) {
        if(promotions.data != null) {
            for(CEC_RestObjects.Promotions p : promotions.data.promotions) {
                if(p.statusContractedPromotion != null) {
                    if(p.statusContractedPromotion == 'FINALIZADO')
                        p.statusContractedPromotion = 'Finalizado';
                    
                    if(p.statusContractedPromotion == 'NEGOCIADO')
                        p.statusContractedPromotion = 'Negociado';
                    
                    if(p.statusContractedPromotion == 'PARTICIPANTE')
                        p.statusContractedPromotion = 'Participante-Ativo';
                    
                    if(p.statusContractedPromotion == 'SUSPENSO')
                        p.statusContractedPromotion = 'Suspenso por Regras';
                    
                    if(p.statusContractedPromotion == 'EXCLUIDO_ATENDENTE')
                        p.statusContractedPromotion = 'Cancelamento Manual';
                    
                    if(p.statusContractedPromotion == 'EXCLUIDO_RESTRICAO')
                        p.statusContractedPromotion = 'Cancelado por Regras';
                    
                    if(p.statusContractedPromotion == 'SUSPENSO_VOLUNTARIAMENTE')
                        p.statusContractedPromotion = 'Suspenso Voluntariamente';
                    
                    if(p.statusContractedPromotion == 'CONTRATO_CANCELADO')
                        p.statusContractedPromotion = 'Número Cancelado na Op.';
                    
                    if(p.statusContractedPromotion == 'EXCLUIDO_REPASSE')
                        p.statusContractedPromotion = 'Troca';
                    
                    if(p.statusContractedPromotion == 'EXCLUIDO_REQUEST')
                        p.statusContractedPromotion = 'Cancel. Troca Promoção';
                    
                    if(p.statusContractedPromotion == 'SUSPENSO_PRORROGACAO')
                        p.statusContractedPromotion = 'Suspenso Involuntariamente';
                    
                    if(p.statusContractedPromotion == 'SUSPENSO_QUALIFICACAO')
                        p.statusContractedPromotion = 'Aguardando cump. Regra';
                }
                
                Datetime dt = (DateTime)JSON.deserialize('"' + p.effectiveDate + '"', DateTime.class);
                String dateFormated = dt.format('dd/MM/yyyy HH:mm', 'America/Sao_Paulo');
                p.effectiveDate = String.valueOf(dateFormated);
            }
        }
        return promotions;
    }
    
    
    
    public static CEC_RestObjects.PromotionsMain generateMock() {
        
        CEC_RestObjects.PromotionsMain promotions = new CEC_RestObjects.PromotionsMain();
        promotions.apiVersion = '1';
        promotions.transactionId = 'String';
        promotions.data = new CEC_RestObjects.DataPromotion();
        promotions.data.promotions = new List<CEC_RestObjects.Promotions>();
        
        for(Integer i = 0; i < 100; i++){
            CEC_RestObjects.Promotions promotion = new CEC_RestObjects.Promotions();
            promotion.promotionIdNGP = 1164 + i;
            promotion.promotionVersionNGP = 2 + i;
            promotion.sequentialIdNGP = 1 + i;
            promotion.promotionName = 'PROMOCAO DIA DAS MAES 201' + i;
            promotion.promotionDescription = 'PROMOCAO FALE MUITO GASTE POUCO';
            promotion.valueAccession = 12.3 + i;
            promotion.numberInstallments = 10 + i;
            promotion.effectiveDate = '2009-01-12T12:10:30-03:00';
            promotion.expirationDate = '2009-01-12T12:10:30-03:00';
            promotion.channelName = 'URA';
            promotion.statusContractedPromotion = 'SUSPENSO_PRORROGACAO';
            promotions.data.promotions.add(promotion);
        }
        
        return promotions;
    }
    
    public static CEC_RestObjects.promotionsHistoryResponse getPromotionsHistory(String phoneLineNumber, string startDate, string endDate){
        CEC_RestObjects.promotionsHistoryResponse promotionsHistoryObj = new CEC_RestObjects.promotionsHistoryResponse();
          String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('PromotionsHistory');
        }else{
            service = '/promotionsHistory';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service +
                                '?msisdn='+phoneLineNumber+
                                +'&startDate='+startDate+'&endDate='+endDate);
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('REQUEST: ' + request);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            promotionsHistoryObj = (CEC_RestObjects.promotionsHistoryResponse)JSON.deserialize(responseBody, CEC_RestObjects.promotionsHistoryResponse.class);
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        if (promotionsHistoryObj.data != null){
            promotionsHistoryObj.data.promotionsHistory = formatDate(promotionsHistoryObj.data.promotionsHistory);
            promotionsHistoryObj.data.promotionsHistory = formatValue(promotionsHistoryObj.data.promotionsHistory);
            promotionsHistoryObj.data.promotionsHistory = formatCategoryType(promotionsHistoryObj.data.promotionsHistory);
          }
            return promotionsHistoryObj;
       
 }
    public static List<CEC_RestObjects.PromotionsHistory> formatCategoryType (List<CEC_RestObjects.PromotionsHistory> lstProm){
        
        for(CEC_RestObjects.PromotionsHistory prom: lstProm){
            
            prom.categoryName = prom.promotionsCategoryType.categories.promotionCategoryName; 
            system.debug('CategoryNameReal:'+prom.promotionsCategoryType.categories.promotionCategoryName);
        }
       
        return lstProm;
    }
    public static List<CEC_RestObjects.PromotionsHistory> formatDate (List<CEC_RestObjects.PromotionsHistory> lstProm){
        
        for(CEC_RestObjects.PromotionsHistory prom: lstProm){
            
            prom.effectiveDate = prom.effectiveDate.substring(8,10) + '/' + prom.effectiveDate.substring(5,7) + '/' + 
                prom.effectiveDate.substring(0,4)+' as '+ prom.effectiveDate.substring(11,19);
            
            prom.effectiveEndDate =prom.effectiveEndDate.substring(8,10) + '/' + prom.effectiveEndDate.substring(5,7) + '/'+ 
                prom.effectiveEndDate.substring(0,4)+ +' as ' + prom.effectiveEndDate.substring(11,19);
        }
        
        return lstProm;
    }
    
    public static List<CEC_RestObjects.PromotionsHistory> formatValue (List<CEC_RestObjects.PromotionsHistory> lstProm){
        for(CEC_RestObjects.PromotionsHistory prom: lstProm){
            prom.valueAccession = 'R$' + prom.valueAccession.replace('.',',');
             system.debug('Prom'+prom.promotionsCategoryType);
          }
        return lstProm;
    }
    
   
  public static CEC_RestObjects.promotionsHistoryResponse generateMockHistory() {
        CEC_RestObjects.promotionsHistoryResponse mainResponse = new CEC_RestObjects.promotionsHistoryResponse();
        mainResponse.apiVersion = '1';
        mainResponse.transactionId = '123';
        CEC_RestObjects.DataPromo dataPromo = new CEC_RestObjects.DataPromo ();
        
        List<CEC_RestObjects.promotionsHistory> promotionsList = new List <CEC_RestObjects.promotionsHistory>();
       
        CEC_RestObjects.PromotionsCategoryType CategoryType = new CEC_RestObjects.PromotionsCategoryType();
        CEC_RestObjects.Categories categories = new CEC_RestObjects.Categories();
        categories.promotionCategoryId = '123556ID';
        categories.promotionCategoryName = 'Categoria A';
       
        CategoryType.categories = categories;
        
        for (integer i=0;i < 20;i++){
            CEC_RestObjects.promotionsHistory obj = new CEC_RestObjects.promotionsHistory();
            obj.promotionId = '12345'+i;
            obj.promotionName = 'Promoção'+'['+i+']';
            obj.promotionsCategoryType =  CategoryType;
            obj.effectiveDate = '2019-05-02T15:08:17.000-03:00';
            obj.effectiveEndDate = '2019-05-02T15:08:17.000-03:00';
            obj.valueAccession = '0.0';
            obj.promotionStatusHired ='Inativo';
            obj.ngpPromotionId ='12345';
            obj.ngpPromotionVersion = '1';
            obj.ngpSequentialId = '12';            
            promotionsList.add(obj);
        }
        
       dataPromo.promotionsHistory = promotionsList;
       mainResponse.data = dataPromo;
        
        return mainResponse;
    }
    
}