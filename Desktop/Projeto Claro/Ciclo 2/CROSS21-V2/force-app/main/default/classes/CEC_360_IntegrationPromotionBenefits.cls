/* Autor: Danilo Fucuhara - Deloitte 
   Criação: 22/03/2019
   Descrição:Classe de conexão com a API Beneficios da promoção. 
   Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

public class CEC_360_IntegrationPromotionBenefits {
    
    public static CEC_RestObjects.PromotionBenefitsMain getPromotionBenefits(String phoneLineNumber, String promotionIdNGP, String promotionVersionNGP, String sequentialIdNGP) { 
        CEC_RestObjects.PromotionBenefitsMain benefits = new CEC_RestObjects.PromotionBenefitsMain();
        String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('PromotionsBenefits');
        }else{
            service = '/promotionsHistory';
        }
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service +
                                '?phoneLineNumber=' + phoneLineNumber + 
                                '&promotionIdNGP=' + promotionIdNGP + 
                                '&promotionVersionNGP=' + promotionVersionNGP + 
                                '&sequentialIdNGP=' + sequentialIdNGP);
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('REQUEST: ' + request);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            benefits = (CEC_RestObjects.PromotionBenefitsMain)JSON.deserialize(responseBody, CEC_RestObjects.PromotionBenefitsMain.class);
            benefits = formatPromotionsBenefits(benefits);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return benefits;
    }
    
    public static CEC_RestObjects.PromotionBenefitsMain formatPromotionsBenefits(CEC_RestObjects.PromotionBenefitsMain benefits) {
        if(benefits.data.promotion != null) {
            for(CEC_RestObjects.Benefit b : benefits.data.promotion.benefitsReceived) {
                if(b.benefitValue == null){
                    b.benefitValue = 'R$0,00';
                }else{
                    b.benefitValue = b.unitMeasure + b.benefitValue.replace('.',',') + '0';
                }
                
                if(b.minimumLimit == null)
                    b.minimumLimit = '0.0';
                
                if(b.maximumLimit == null)
                    b.maximumLimit = '0.0';
                
                if(b.numberInstallments == null)
                    b.numberInstallments = 0;
            }
        }
        return benefits;
    }
    
    public static CEC_RestObjects.PromotionBenefitsMain generateMock() {
        CEC_RestObjects.PromotionBenefitsMain benefits = new CEC_RestObjects.PromotionBenefitsMain();
        benefits.apiVersion = '1';
        benefits.transactionId = 'String';
        benefits.data = new CEC_RestObjects.DataPromotionBenefits();
        benefits.data.promotion = new CEC_RestObjects.Promotion();
        benefits.data.promotion.qualifications = new List<CEC_RestObjects.Qualification>();
        benefits.data.promotion.benefitsReceived = new List<CEC_RestObjects.Benefit>();
        
        CEC_RestObjects.Qualification qualification = new CEC_RestObjects.Qualification();
        qualification.qualificationId = 123456789;
        qualification.qualificationDescription = 'Descrição qualificação';
        qualification.qualificationTypeId = 123456789;
        qualification.qualificationTypeDescription = 'Descrição tipo qualificação';
        qualification.unitMeasure = 'Unidade medida';
        benefits.data.promotion.qualifications.add(qualification);
        
        for(Integer i = 0; i < 100; i++){
            CEC_RestObjects.Benefit benefit = new CEC_RestObjects.Benefit();
            benefit.benefitIdNGP = 123456789;
            benefit.benefitDescription = 'Descrição do benefício ' + i;
            benefit.benefitValue = String.valueOf(20 + i);
            benefit.unitMeasure = 'Moeda';
            benefit.minimumLimit = String.valueOf(10.5 + i);
            benefit.maximumLimit = String.valueOf(20.3 + i);
            benefit.concessionInterval = 3 + i;
            benefit.numberInstallments = 3 + i;
            benefit.waitingPeriod = 2 + i;
            //benefit.indicatorBalanceTransfer = true;
            benefit.expirationDays = 30 + i;
            benefit.multiplyingFactor= 1.2 + i;
            benefit.percentageDiscount = 10 + i;
            benefit.qualifyingGroup = 'Grupo B';
            benefits.data.promotion.benefitsReceived.add(benefit);
        }
        
        return benefits;
    }
    
}