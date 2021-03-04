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

    public static List<WrapperOffer> lstoffers = new List<WrapperOffer>();
    public static List<WrapperSums> lstWrapper = new List<WrapperSums>();
    public static Map<String,Object> data = new Map<String,Object>{'success'=> false};


    public static Map<String,Object> getPromotionsAndDiscounts(String recordId){
 
        Case objCase = new Case();
        Account objAccount = new Account();
        List<Asset> lstAssets = new List<Asset>();
        Map<String, String> calloutResponse = new Map<String,String>();
        ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('MobilePromotionsDiscounts');

        if(recordId.startsWith('500')){
            objCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__c FROM CASE WHERE Id =: recordId LIMIT 1];
        }else{
            objAccount = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c, ContractNumber__c FROM Account WHERE id =: recordId LIMIT 1];
        }
        String idAccount = objCase == null? objAccount.Id:objCase.ContractBillingAccount__c;
        Set<String> lMSISDNSet = new Set<String>();
                //coloca os MSISDN's relacionados ao contrato dentro de um SET, pois o LAKE pode inserir registros duplicados
        for(Asset lAsset :[SELECT Id, MSISDN__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c = :idAccount AND Status = 'Ativo' AND MSISDN__c != null]){
                lMSISDNSet.add(lAsset.MSISDN__c);
        } 
        for(String msisdn : lMSISDNSet){
            makeCallout(msisdn);
        }

        CEC_RestObjects.mobileSubscribers returnSubs = new CEC_RestObjects.mobileSubscribers();

        if(lstWrapper.isEmpty() && data.get('message') == null){
            data.put('success',false);
            data.put('isMobile',true);
            data.put('message', Label.Solar_Cross_IntegrationNoDataPromotions);
        }

        return data;

    }


    public static void makeCallout(String msisdn){
        Map<String,String> headers = new Map<String,String>();
        Map<String,String> params = new Map<String,String>();
        Map<String, String> calloutResponse = new Map<String,String>();
        CEC_RestObjects.mobileSubscribers returnSubs = new CEC_RestObjects.mobileSubscribers();
        ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('MobilePromotionsDiscounts');
        List<WrapperListOffer> lstDiscounts = new List<WrapperListOffer>();
        List<WrapperListOffer> lstSVA = new List<WrapperListOffer>();
        List<WrapperListOffer> lstOthers = new List<WrapperListOffer>();
        try{
            if(!Test.isRunningTest()){
                headers.put('x-client-auth',serviceParam.Token__c);
                returnSubs = CEC_360_IntegrationsSubscriberHistory.getSubscriber(msisdn);
            }else{
                HTTPRequest request = new HTTPRequest();
				request.setEndpoint('/Subscriber');
				request.setMethod('GET');
				request.setTimeout(120000);
				HTTP http = new HTTP();
				HttpResponse response = http.send(request);
				calloutResponse.put('statusCode',String.valueOf(response.getStatusCode()));
                calloutResponse.put('response',response.getBody());
                returnSubs = (CEC_RestObjects.mobileSubscribers) JSON.deserialize(response.getBody(),  CEC_RestObjects.mobileSubscribers.class);
            }
        }
        catch(Exception e){
            return;
        }
        headers.put('X-QueryString','mobileSubscriberId='+returnSubs.mobileSubscriberId+'&subscriberIndicator=true');
        params.put('signaturetype',returnSubs.type);

        System.debug('calloutResponse: ' + calloutResponse);
        JSONMobilePromotionDiscounts response = new JSONMobilePromotionDiscounts();
        if(!Test.isRunningTest()){
            calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'MobilePromotionsDiscounts');

        }else{
            HTTPRequest request = new HTTPRequest();
			request.setEndpoint('/MobilePromotion');
			request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HttpResponse response1 = http.send(request);
            calloutResponse.put('statusCode',String.valueOf(response1.getStatusCode()));
            calloutResponse.put('response',response1.getBody());            
        }
        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {

            String formattedResponse = calloutResponse.get('response').replaceAll('"NULL"','null');
            response = (JSONMobilePromotionDiscounts) JSON.deserialize(formattedResponse.remove('-03:00'),JSONMobilePromotionDiscounts.class);

            if(response.data.offers != null){
                response.data.offers.sort();
                for(JSONMobilePromotionDiscounts.offers objOffer : response.data.offers){
                    WrapperListOffer objWrapperOffer = new WrapperListOffer(objOffer, msisdn);
                    if(objOffer.offerType == 'DESCONTO' && objOffer.name != response.data.name){
                        lstDiscounts.add(objWrapperOffer);
                    }else if(objOffer.offerType == 'OPCIONAL' && objOffer.mobileCategoryOfferId == 'SERVICO_VALOR_AGREGADO' && objOffer.name != response.data.name){
                        lstSVA.add(objWrapperOffer);
                    }else if(objOffer.offerType == 'OPCIONAL' && objOffer.mobileCategoryOfferId != 'SERVICO_VALOR_AGREGADO' && objOffer.name != response.data.name){
                        lstOthers.add(objWrapperOffer);
                    }
                }

                //somatórias da tela inicial
                WrapperSums objWrapper = new WrapperSums(response.data.name + ' - '+msisdn ,response.data.valueDiscountLoyalty,response.data.valueDiscountSubscription, response.data.totalMonthlyValue);
                lstWrapper.add(objWrapper);
                
                //header do modal
                WrapperOffer objWrp = new WrapperOffer(response.data,msisdn);
                objWrp.discounts = lstDiscounts;
                objWrp.svas = lstSVA;
                objWrp.others = lstOthers;
                lstoffers.add(objWrp);
                
                data.put('success',true);
                data.put('isMobile',true);
                data.put('planOffer',lstWrapper);
                data.put('offer',lstoffers);
               // data.put('discounts',lstDiscounts);
               // data.put('svaOffers',lstSVA);
               // data.put('others',lstOthers);
            }
        }else{
            data.put('isMobile',true);
            data.put('message', Label.Solar_Cross_IntegrationErrorMessage + '\n'+'Código do Erro: ' + calloutResponse.get('statusCode') + ' | ' +  serviceParam.EndPoint__c.subStringAfter(':'));
        }

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
        @AuraEnabled public List<WrapperListOffer> discounts {get;set;}
        @AuraEnabled public List<WrapperListOffer> svas {get;set;}
        @AuraEnabled public List<WrapperListOffer> others {get;set;}

        WrapperOffer(JSONMobilePromotionDiscounts.data data,String msisdn){
            this.name = data.name + ' - '+msisdn;
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
        @AuraEnabled public String msisdn;

        WrapperListOffer(JSONMobilePromotionDiscounts.Offers offer, String msisdn){
            this.name = offer.name;
            this.effectiveStartDate = offer.effectiveStartDate;
            this.expiryDate = offer.expiryDate;
            this.level = offer.level;
            this.offerType = offer.offerType;
            this.offerValue = offer.offerValue;
            this.monthlyDiscountValue = offer.monthlyDiscountValue;
            this.msisdn = msisdn;
        }
    }
}