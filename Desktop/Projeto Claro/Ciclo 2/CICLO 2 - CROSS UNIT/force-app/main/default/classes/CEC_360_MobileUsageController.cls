/*
* Autor:Letícia Freitas.
* Data: 26/06/2019
* [Claro Visão 360] [Time: SQUAD 360]
* Descrição: [USS 202 - Sprint 8] - Classe test para o componente CEC_360_MobileUsage - referente a consumo móvel.
* 
*/

public class CEC_360_MobileUsageController {
    
    @AuraEnabled 
    public static  CEC_RestObjects.mobileUsage getMobileUsage (string recordId){
        Long total, consumed;
        
        Asset ast = [SELECT Msisdn__c from Asset where id =: recordId];
        CEC_RestObjects.mobileUsage objMobileUsage = CEC_360_IntegrationsMobileUsage.getMobileUsage(ast.msisdn__c);
        //CEC_RestObjects.mobileUsage objMobileUsage = CEC_360_IntegrationsMobileUsage.generateMock();
        if(objMobileUsage != null){
            objMobileUsage.data.usages = calculatePercentage(objmobileUsage.data.usages);
             objMobileUsage.data.usages = formatDate(objmobileUsage.data.usages);
            system.debug(objmobileUsage.data.usages[0].franchiseAmountGB);
            return objMobileUsage;
        }else{
            return null;
        }
   }
    
    public static List <CEC_RestObjects.usageDetail> calculatePercentage (List<CEC_RestObjects.usageDetail> lstUsageDetail)
    {
        for(CEC_RestObjects.usageDetail usg :lstUsageDetail){
            Decimal gbyte = 1073741824;
            Decimal franchiseAmountGB = Double.valueOf(usg.franchiseAmount)/gbyte ;
            Decimal consumedAmountGB =  Double.valueOf(usg.consumedAmount)/gbyte  ;
            usg.consumedAmountGB = String.valueOf(consumedAmountGB.setScale(2));
            system.debug('usg.consumedAmountGB'+ usg.consumedAmountGB);
            usg.franchiseAmountGB = String.valueOf(franchiseAmountGB.setScale(2));
            usg.percentage = (consumedAmountGB * 100)/franchiseAmountGB;
            usg.percentage = usg.percentage.setScale(2);
        }
        
        return lstUsageDetail;
    }
    
     public static List <CEC_RestObjects.usageDetail> formatDate (List<CEC_RestObjects.usageDetail> lstUsageDetail)
    {
        for(CEC_RestObjects.usageDetail usg :lstUsageDetail){
            usg.usageDateStart = usg.usageDateStart.substring(8,10) +  '/' +
                usg.usageDateStart.substring(5,7) +  '/' + usg.usageDateStart.substring(0,4);
            usg.usageDateEnd= usg.usageDateEnd.substring(8,10) +  '/' +
                usg.usageDateEnd.substring(5,7) +  '/' + usg.usageDateEnd.substring(0,4);
        }
        
        return lstUsageDetail;
    }
    
    
    
    
 
    
}