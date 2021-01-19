/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Solar_Cross_IntegrationPromotionDiscount {

    public static sumDiscPromoWrapper objSums = new sumDiscPromoWrapper(); 

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getPromotionsAndDiscounts(String recordId){
        Map<String,Object> data = new Map<String,Object>();
        Map<String,String> headers = new Map<String,String>();
        Map<String,String> params = new Map<String,String>();
        Case objCase = new Case();
        Account objAccount = new Account();
        List<Asset> lstAssets = new List<Asset>();
        List<String> lstMobileContracts = Label.Solar_Cross_MobileContract.split(';');
        List<String> residentialContracts = Label.Solar_Cross_ResidentialContract.split(';');

        Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addDays(-1).addMonths(-60));
        String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
        
        if(recordId.startsWith('500')){
            objCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__c FROM CASE WHERE Id =: recordId LIMIT 1];
            lstAssets = [SELECT Id, RecordType.Name, CodigoProdutoLegado__c  FROM Asset WHERE vlocity_cmt__BillingAccountId__c =: objCase.ContractBillingAccount__c AND Status = 'Ativo'];
            params.put('operatorCode', objCase.ContractBillingAccount__r.CityCode__c);
            params.put('contractNumber', objCase.ContractBillingAccount__r.ContractReferenceNumber__c);

        }else{
            objAccount = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c, ContractNumber__c FROM Account WHERE id =: recordId LIMIT 1];
            //tirar oq estiver cancelado
            lstAssets = [SELECT Id, RecordType.Name, CodigoProdutoLegado__c  FROM Asset WHERE vlocity_cmt__BillingAccountId__c =: objAccount.Id AND Status = 'Ativo'];
            params.put('operatorCode', objAccount.CityCode__c);
            params.put('contractNumber', objAccount.ContractReferenceNumber__c);
        }
        params.put('startDate',startDateText);
        //numero id x nome produto
        Map<String,String> mapProdIdAsset = getMapProdAsset(lstAssets);
        System.debug('mapProdIdAsset: ' + mapProdIdAsset);
        ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('ResidentialPromotionsDiscounts');
        headers.put('X-Client-Auth',serviceParam.Token__c);

        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'ResidentialPromotionsDiscounts');

        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {

            PromotionDiscounts releaseJson = (PromotionDiscounts) JSON.deserialize(calloutResponse.get('response'), PromotionDiscounts.class);
            List<DiscountsWrapper> lstDiscountsReturn = getDiscounts(releaseJson,mapProdIdAsset);
            List<PromotionsWrapper> lstPromotionsReturn = getPromotions(releaseJson,mapProdIdAsset);
            List<WrapperSums> lstWrapperSums = new List<WrapperSums>();
            for(String nameProduct : mapProdIdAsset.values()){
                WrapperSums Ret = new WrapperSums();
                Ret.typeProduct = nameProduct;
                Ret.sumPromo = objSums.sumPromotions.get(nameProduct) == null? 0: objSums.sumPromotions.get(nameProduct);
                Ret.sumDisc  = objSums.sumDiscounts.get(nameProduct)  == null? 0: objSums.sumDiscounts.get(nameProduct);
                lstWrapperSums.add(Ret);
            }
            if(!lstDiscountsReturn.isEmpty() || !lstPromotionsReturn.isEmpty()){
                data.put('success', true);
                data.put('isMobile',false);
                data.put('completeListDiscounts',lstDiscountsReturn);
                data.put('completeListPromotions',lstPromotionsReturn);
                data.put('sumsList',lstWrapperSums);
            }else{
                data.put('success',false);
                data.put('message', Label.Solar_Cross_IntegrationNoDataPromotions);
            } 
        }else{
            data.put('success',false);
            data.put('message',Label.Solar_Cross_IntegrationErrorMessage + '\n'+'Código do Erro: ' + calloutResponse.get('statusCode') + ' | ' +  serviceParam.EndPoint__c.subStringAfter(':'));
        }   

        System.debug('data'+data);
        return data;

    }



    public static Map<String,String> getMapProdAsset(List<Asset> lstAssets){
        Map<String,String> mapReturn = new Map<String,String>();
        for(Asset objAsset: lstAssets){
            mapReturn.put(objAsset.CodigoProdutoLegado__c,objAsset.recordType.Name);
        }

        return mapReturn;
    }

    public static List<DiscountsWrapper> getDiscounts(PromotionDiscounts Discounts, Map<String,String> mapAsset){
        List<DiscountsWrapper> lstDiscounts = new List<DiscountsWrapper>();
        Decimal sumDisc = 0;
        for(Discounts objDisc : Discounts.Data.Discounts){
            DiscountsWrapper objDiscWrapper = new DiscountsWrapper();
            if(mapAsset.get(String.valueof(objDisc.productId)) == null){
                continue;
            }
            objDiscWrapper.startDate = convertDate(objDisc.startDate);
            objDiscWrapper.endDate = convertDate(objDisc.endDate);
            objDiscWrapper.months = Date.Today().monthsBetween(objDiscWrapper.endDate) > 0 ? Date.Today().monthsBetween(objDiscWrapper.endDate) : 0;
            if(objDiscWrapper.months == 0 && Date.Today().monthsBetween(objDiscWrapper.endDate) < -1){
                continue;
            }
            objDiscWrapper.type = mapAsset.get(String.valueof(objDisc.productId));
            objDiscWrapper.description = objDisc.productDescription;
            objDiscWrapper.value   = objDisc.discountValue;
            if(objSums.sumDiscounts.get(objDiscWrapper.type) != null && objDisc.descriptionDiscount != 'PORCENTAGEM' && Date.Today().monthsBetween(objDiscWrapper.endDate) > 0){
                sumDisc = objSums.sumDiscounts.get(objDiscWrapper.type) + objDiscWrapper.value;
                objSums.sumDiscounts.put(objDiscWrapper.type,sumDisc);
            }else if(objSums.sumDiscounts.get(objDiscWrapper.type) == null && objDisc.descriptionDiscount != 'PORCENTAGEM' && Date.Today().monthsBetween(objDiscWrapper.endDate) > 0){
                objSums.sumDiscounts.put(objDiscWrapper.type, objDiscWrapper.value);
            }
            objDiscWrapper.treatedValue = convertValue(objDisc.descriptionDiscount, objDiscWrapper.value);
            lstDiscounts.add(objDiscWrapper);
        }
        System.debug('lstDiscount: ' + lstDiscounts);
        return lstDiscounts;
    }
    //string tipoNome x objeto

    public static List<PromotionsWrapper> getPromotions(PromotionDiscounts Promotions, Map<String,String> mapAsset){
        List<PromotionsWrapper> lstPromotions = new List<PromotionsWrapper>();
        Decimal sumPromo = 0;
        for(Promotions objPromo : Promotions.Data.Promotions){
            PromotionsWrapper objPromoWrapper = new PromotionsWrapper();
            if(mapAsset.get(String.valueof(objPromo.productId)) == null){
                continue;
            }
            objPromoWrapper.startDate = convertDate(objPromo.startDate);
            objPromoWrapper.endDate = convertDate(objPromo.endDate);
            objPromoWrapper.months = Date.Today().monthsBetween(objPromoWrapper.endDate) > 0 ? Date.Today().monthsBetween(objPromoWrapper.endDate) : 0;
            if(objPromoWrapper.months == 0 && Date.Today().monthsBetween(objPromoWrapper.endDate) < -1){
                continue;
            }
            objPromoWrapper.type = mapAsset.get(String.valueof(objPromo.productId));
            objPromoWrapper.description = objPromo.productDescription;
            
            objPromoWrapper.value = objPromo.promotionValue;
            if(objSums.sumPromotions.get(objPromoWrapper.type) != null && Date.Today().monthsBetween(objPromoWrapper.endDate) > 0){
                sumPromo = objSums.sumPromotions.get(objPromoWrapper.type) + objPromoWrapper.value;
                objSums.sumPromotions.put(objPromoWrapper.type,sumPromo);
            }else if(objSums.sumPromotions.get(objPromoWrapper.type) == null && Date.Today().monthsBetween(objPromoWrapper.endDate) > 0){
                objSums.sumPromotions.put(objPromoWrapper.type, objPromoWrapper.value);
            }
            
            objPromoWrapper.treatedValue  = convertValue('', objPromoWrapper.value);
            lstPromotions.add(objPromoWrapper);
        }
        System.debug('lstPromotion: ' + lstPromotions);
        return lstPromotions;

    }

    public static String convertValue(String type, Decimal value){
        String newValue = value.format().contains(',')?value.format():(value.format()+',00');
        return type == 'PORCENTAGEM'? newValue +'%':'R$ ' + newValue; 
    }

    public static Date convertDate(String strDate){
        List<String> dateAndHour = strDate.split('T');
        List<String> yearMonthDay = dateAndHour[0].split('-');

        Date returnDate = Date.newInstance(Integer.valueof(yearMonthDay[0]),Integer.valueof(yearMonthDay[1]),Integer.valueof(yearMonthDay[2]));
        return returnDate;
    }


    public class PromotionDiscounts{
        public String apiVersion;
        public String transactionId;
        public Data data;
    }

    public class Data{
        public String operatorCode;
        public String contractNumber;
        public Decimal bonusAmount;
        public List<Promotions> promotions;
        public List<Discounts> discounts;

    }

    public class Promotions{
        public String promotionName;
        public Integer pointId;
        public String pointType;
        public Decimal promotionValue;
        public Integer totalMonthsDiscount;
        public Integer productId;
        public String productDescription;
        public String startDate;
        public String endDate;

    }

    public class Discounts{
        public Integer discountType;
        public String descriptionDiscount;
        public Decimal discountValue;
        public Integer pointId;
        public String pointType;
        public Integer productId;
        public String productDescription;
        public String startDate;
        public String endDate;
    }

    public class WrapperSums{
        @AuraEnabled 
        public String typeProduct {get;set;}
        @AuraEnabled 
        public Decimal sumPromo {get;set;}
        @AuraEnabled 
        public Decimal sumDisc {get;set;}
    }

    public class sumDiscPromoWrapper{
        public Map<String,Decimal> sumDiscounts = new Map<String,Decimal>();
        public Map<String,Decimal> sumPromotions = new Map<String,Decimal>();

    }

    public class PromotionsWrapper{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public Integer months;
        @AuraEnabled
        public Decimal value;
        @AuraEnabled
        public String treatedValue;
    }

    public class DiscountsWrapper{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public Integer months;
        @AuraEnabled
        public Decimal value;
        @AuraEnabled
        public String treatedValue;
    }
}