/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                               Modification 
 * 1.0   12-22-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Solar_Cross_IntegrationPromoDiscMovel {

    public static Map<String,Object> getPromotionsAndDiscounts(String recordId){
 
        Map<String,Object> data = new Map<String,Object>();
        Map<String,String> headers = new Map<String,String>();
        Map<String,String> params = new Map<String,String>();
        Case objCase = new Case();
        Account objAccount = new Account();
        List<Asset> lstAssets = new List<Asset>();

        if(recordId.startsWith('500')){
            objCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__c FROM CASE WHERE Id =: recordId LIMIT 1];
        }else{
            objAccount = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c, ContractNumber__c FROM Account WHERE id =: recordId LIMIT 1];
        }
        
        CEC_RestObjects.mobileSubscribers returnSubs = new CEC_RestObjects.mobileSubscribers();
        try{
            String contractNumber = objCase == null? objAccount.ContractReferenceNumber__c:objCase.ContractBillingAccount__r.ContractReferenceNumber__c;
            returnSubs = CEC_360_IntegrationsSubscriberHistory.getSubscriber(contractNumber);
        }catch(Exception e){
            System.debug('Falha na subscriber: ' + e.getMessage());
        }
        System.debug('returnSubs.type_Z'+returnSubs.type);
        System.debug('returnSubs.mobileSubscriberId'+returnSubs.mobileSubscriberId);
        ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('MobilePromotionsDiscounts');

        params.put('signaturetype',returnSubs.type);
        headers.put('x-client-auth',serviceParam.Token__c);
        headers.put('X-QueryString','mobileSubscriberId='+returnSubs.mobileSubscriberId+'&subscriberIndicator=true');

        
        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'MobilePromotionsDiscounts');
        List<WrapperListOffer> lstDiscounts = new List<WrapperListOffer>();
        List<WrapperListOffer> lstSVA = new List<WrapperListOffer>();
        List<WrapperListOffer> lstOthers = new List<WrapperListOffer>();
        JSONMobilePromotionDiscounts response = new JSONMobilePromotionDiscounts();

        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {

            String formattedResponse = calloutResponse.get('response').replaceAll('"NULL"','null');
            response = (JSONMobilePromotionDiscounts) JSON.deserialize(formattedResponse.remove('-03:00'),JSONMobilePromotionDiscounts.class);
            if(response.data.offers.size()> 0){
                for(JSONMobilePromotionDiscounts.offers objOffer : response.data.offers){
                    WrapperListOffer objWrapperOffer = new WrapperListOffer(objOffer);
                    if(objOffer.offerType == 'DESCONTO' && objOffer.name != response.data.name){
                        lstDiscounts.add(objWrapperOffer);
                    }else if(objOffer.offerType == 'OPCIONAL' && objOffer.mobileCategoryOfferId == 'SERVICO_VALOR_AGREGADO' && objOffer.name != response.data.name){
                        lstSVA.add(objWrapperOffer);
                    }else if(objOffer.offerType == 'OPCIONAL' && objOffer.mobileCategoryOfferId != 'SERVICO_VALOR_AGREGADO' && objOffer.name != response.data.name){
                        lstOthers.add(objWrapperOffer);
                    }
                }
                List<WrapperSums> lstWrapper = new List<WrapperSums>();
                WrapperSums objWrapper = new WrapperSums(response.data.name,response.data.valueDiscountLoyalty,response.data.valueDiscountSubscription, response.data.totalMonthlyValue);
                lstWrapper.add(objWrapper);
                
                WrapperOffer objWrp = new WrapperOffer(response.data);
                data.put('success',true);
                data.put('isMobile',true);
                data.put('planOffer',lstWrapper);
                data.put('offer',objWrp);
                data.put('discounts',lstDiscounts);
                data.put('svaOffers',lstSVA);
                data.put('others',lstOthers);
            }else{
                data.put('success',false);
                data.put('message', Label.Solar_Cross_IntegrationNoDataPromotions);
            }
        }else{
            data.put('success',false);
            data.put('message',Label.Solar_Cross_IntegrationErrorMessage + '\n'+'Código do Erro: ' + calloutResponse.get('statusCode') + ' | ' +  serviceParam.EndPoint__c.subStringAfter(':'));
        }

        return data;

    }

    public class WrapperSums{
        @AuraEnabled 
        public String typeProduct {get;set;}
        @AuraEnabled 
        public Decimal sumPromo {get;set;}
        @AuraEnabled 
        public Decimal sumDisc {get;set;}
        @AuraEnabled 
        public Decimal total {get;set;}

        WrapperSums(String typeProduct, Decimal sumPromo, Decimal sumDisc,Decimal total){
            this.typeProduct = typeProduct;
            this.sumPromo = sumPromo != null?sumPromo:0;
            this.sumDisc = sumDisc != null? sumDisc:0;
            this.total = total != null? total:0;
        }
    }


    public class WrapperOffer{

        @AuraEnabled public String name;
        @AuraEnabled public Datetime effectiveDate;
        @AuraEnabled public Datetime expirationDate;
        @AuraEnabled public Decimal signatureValue;
        @AuraEnabled public Decimal valueDiscountSubscription;
        @AuraEnabled public Decimal valueDiscountLoyalty;
        @AuraEnabled public Decimal totalMonthlyValue;
        @AuraEnabled public Decimal totalDiscount;
        @AuraEnabled public String type;
        @AuraEnabled public String level;
        @AuraEnabled public String situation;
        @AuraEnabled public String gracePeriod;
        @AuraEnabled public Datetime activationDate;
        @AuraEnabled public Datetime dateSituation;
        @AuraEnabled public Datetime needStartDate;

        WrapperOffer(JSONMobilePromotionDiscounts.data data){
            this.name = data.name;
            this.effectiveDate = data.effectiveDate;
            this.expirationDate = data.expirationDate;
            this.signatureValue = data.signatureValue != null? data.signatureValue:0;
            this.valueDiscountSubscription = data.valueDiscountSubscription != null? data.valueDiscountSubscription:0;
            this.valueDiscountLoyalty = data.valueDiscountLoyalty != null? data.valueDiscountLoyalty:0;
            this.totalMonthlyValue = data.totalMonthlyValue != null? data.totalMonthlyValue:0;
            this.totalDiscount = this.valueDiscountSubscription + this.valueDiscountLoyalty;
            this.type = data.Subscriber.signatureType;
            this.level = data.level;
            this.situation = data.Subscriber.situation;
            this.gracePeriod = data.gracePeriod != null ? data.gracePeriod + ' meses': 0 + ' meses';
            this.activationDate = data.Subscriber.activationDate;
            this.dateSituation = data.Subscriber.dateSituation;
            this.needStartDate = data.needStartDate;
        }
        
    }

    public class WrapperListOffer{
        @AuraEnabled public String name;
        @AuraEnabled public Datetime effectiveStartDate;
        @AuraEnabled public Datetime expiryDate;
        @AuraEnabled public String level;
        @AuraEnabled public String offerType;
        @AuraEnabled public Decimal offerValue;
        @AuraEnabled public Decimal monthlyDiscountValue;

        WrapperListOffer(JSONMobilePromotionDiscounts.Offers offer){
            this.name = offer.name;
            this.effectiveStartDate = offer.effectiveStartDate;
            this.expiryDate = offer.expiryDate;
            this.level = offer.level;
            this.offerType = offer.offerType;
            this.offerValue = offer.offerValue;
            this.monthlyDiscountValue = offer.monthlyDiscountValue;
        }
    }
}