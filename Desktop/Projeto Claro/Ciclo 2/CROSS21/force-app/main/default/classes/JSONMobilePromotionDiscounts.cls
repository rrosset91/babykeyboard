/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-07-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-21-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class JSONMobilePromotionDiscounts {

    String apiVersion;
    String transactionId;
    public Data data;

    public class Data{
        public String mobileOfferId;
        public String waPlanPriceId;
        public String wppPricePlanId;
        public String name;
        public Datetime effectiveDate;
        public DateTime expirationDate;
        public Datetime effectiveDateSale;
        public Datetime expirationSaleDate;
        public String flatType;
        public String level;
        public Decimal dependentMinimumQty;
        public Decimal dependentMaxQty;
        public Decimal minimumMobilePhoneQty;
        public Decimal maxMobilePhoneQty;
        public Decimal maxfixedPhoneQty;
        public Decimal minimumfixedPhoneQty;
        public Decimal minimumBroadbandQty;
        public Decimal maxBroadbandQty;
        public Decimal valueSignatureTable;
        public Decimal signatureValue;
        public Decimal minimumSignatureValue;
        public Decimal valueDiscountSubscription;
        public Decimal valuePercentageDiscountSubscription;
        public Decimal valueDiscountLoyalty;
        public Decimal valuePercentageDiscountLoyalty;
        public Decimal totalMonthlyValue;
        public Decimal franchise;
        public String measuredUnit;
        public Decimal franchiseMinutesVc1;
        public Decimal franchiseMinutesVc1Go;
        public Decimal franchiseMinutesVc1Fx;
        public Decimal franchiseMinutesVc1Mm;
        public Decimal franchiseMinutesVc2;
        public Decimal torpedoFranchise;
        public Decimal franchiseData;
        public Decimal limitControl;
        public Date needStartDate;
        public Decimal gracePeriod;
        public List<Offers> offers;
        public Subscriber subscriber;
        //public ComponentGroups componentGroups;
       // public List<BonusPricePlan> bonusPricePlan;
    }

    public class Offers{
        public String mobileOfferId;
        public String wppOfferId;
        public String name;
        public String offerType;
        public String mobileCategoryOfferId;
        public String level;
        public Date effectiveStartDate;
        public Date expiryDate;
        public Boolean compositionIndicatorPricePlan;
        public Boolean mandatoryIndicator;
        public Boolean indicatorDistribution;
        public Boolean indicatorDistributedSubscriber;
        public Boolean recurrentIndicator;
        public String franchise;
        public List<Franchise> listFranchises;
        public Decimal offerValue;
        public Decimal monthlyFee;
        public Decimal monthlyDiscountValue;
        //public List<RelatedOffers> listRelatedOffers;

    }

    public class Franchise{
        public String category;
        public String unitQuantity;
        public Decimal amount;
        public String measuredUnit;
    }

    public class RelatedOffers{
        public CorrelatedOffer correlatedOffer;
    }

    public class CorrelatedOffer{
        public String mobileOfferId;
    }

    public class ComponentGroups{
        public String nome;
        public String serviceType;
        public Decimal minimumQuantity;
        public Decimal valueSignatureTable;
        public Decimal signatureValue;
        public Decimal minimumSignatureValue;
        public Decimal maximumSignatureValue;
        public Decimal valueDiscountSubscription;
        public Decimal valuePercentageDiscountSubscription;
        public Decimal valueDiscountLoyalty;
        public Decimal valuePercentageDiscountLoyalty;
        public List<Offers> offers;
        public List<components> components;


    }

    public class Components{
        public String mobileComponentId;
        public String name;

    }

    public class ComponentType{
        public String typeId;
        public String name;
        public Decimal amount;
        public String measuredUnit;
        public Decimal valueSignatureTable;
        public Decimal signatureValue;
        public Decimal valueDiscountSubscription;
        public Decimal valuePercentageDiscountSubscription;

    }

    public class BonusPricePlan{
        public String mobileBonusId;
        public String name;
        public String bonusCategory;
        public Decimal amount;
        public String measuredUnit;
        public Decimal value;
        public Date dueate;
        public List<Offers> offers;
    }

    public class Subscriber{
        public String signatureType;
        public Datetime activationDate;
        public Datetime dateSituation;
        public String situation;
    }
}