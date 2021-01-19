/**
* @author: Gustavo Rodrigues
* @company: IBM - Bluewolf
* @description: Classe do tipo controller do componente "ConsumoMobileCross"
*/

public class CROSS_MobileUsageController {
    @AuraEnabled
    public static CEC_RestObjects.mobileUsage getMobileUsage (string recordId){
        try{
            Long total, consumed;
            Case cs = [SELECT ContractBillingAccount__c FROM Case WHERE Id =: recordId];
            String ctrBillAccId = cs.ContractBillingAccount__c;
            List<Asset> assets = [SELECT msisdn__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c =: ctrBillAccId AND msisdn__c != null AND Status != 'Cancelado'];
            Asset firstAsset = assets.get(0);
            CEC_RestObjects.mobileUsage objMobileUsage = CEC_360_IntegrationsMobileUsage.getMobileUsage(firstAsset.msisdn__c);
            if(objMobileUsage != null){
                objMobileUsage.data.usages = calculatePercentage(objmobileUsage.data.usages);
                objMobileUsage.data.usages = formatDate(objmobileUsage.data.usages);
                return objMobileUsage;
            }else{
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
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