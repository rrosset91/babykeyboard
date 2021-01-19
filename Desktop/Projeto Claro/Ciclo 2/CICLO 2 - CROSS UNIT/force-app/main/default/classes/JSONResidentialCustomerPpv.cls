public with sharing class JSONResidentialCustomerPpv {
    public class Consumptions{
        @AuraEnabled public Long contractNumber;
        @AuraEnabled public String cityId;
        @AuraEnabled public Integer typeSaleId;
        @AuraEnabled public String typeSaleDescription;
        @AuraEnabled public String saleDate;
        @AuraEnabled public String salesChannelsDescription;
        @AuraEnabled public Integer salesStatusId;
        @AuraEnabled public String salesStatusDescription;
        @AuraEnabled public String eventId;
        @AuraEnabled public String eventDescription;
        @AuraEnabled public String eventName;
        @AuraEnabled public String eventDuration;
        @AuraEnabled public Decimal price;
        @AuraEnabled public String formattedPrice;
        @AuraEnabled public Integer categoryPPVId;
        @AuraEnabled public String categoryPPVDescription;
        @AuraEnabled public Integer typePPVId;
        @AuraEnabled public String typePPVDescription;
    }

    public class Link{
        @AuraEnabled public String rel;
        @AuraEnabled public String href;
    }

    public class Pages{
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public Integer page;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public List<Link> links;
    }
    
    public class Data{
        @AuraEnabled public List<Consumptions> consumption;
        @AuraEnabled public Pages pagination;
    }
    
    @AuraEnabled public String apiVersion;
    @AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
}