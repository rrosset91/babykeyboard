/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-07-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-08-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Solar_Cross_PromotionDiscountController {

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getPromotionsAndDiscounts(String recordId){

        Map<String,Object> data = new Map<String,Object>();
        Case objCase = new Case();
        Account objAccount = new Account();
        List<Asset> lstAssets = new List<Asset>();
        List<String> lstMobileContracts = Label.Solar_Cross_MobileContract.split(';');
        List<String> residentialContracts = Label.Solar_Cross_ResidentialContract.split(';');
        if(recordId.startsWith('500')){
            objCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__c FROM CASE WHERE Id =: recordId LIMIT 1];

        }else{
            objAccount = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c, ContractNumber__c FROM Account WHERE id =: recordId LIMIT 1];
            //tirar oq estiver cancelado
        }

        if(recordId.startsWith('500')){
            if(lstMobileContracts.contains(objCase.ContractBillingAccount__r.BusinessUnit__c)){
                data.put('success',true);
                data.put('isMobile',true);
                return Solar_Cross_IntegrationPromoDiscMovel.getPromotionsAndDiscounts(recordId);
            }else{
                return Solar_Cross_IntegrationPromotionDiscount.getPromotionsAndDiscounts(recordId);
            }
        }else{
            if(lstMobileContracts.contains(objAccount.BusinessUnit__c)){
                data.put('success',true);
                data.put('isMobile',true);
                return Solar_Cross_IntegrationPromoDiscMovel.getPromotionsAndDiscounts(recordId);
            }else{
                return Solar_Cross_IntegrationPromotionDiscount.getPromotionsAndDiscounts(recordId);

            }
        }
    }
}