public with sharing class JSONResidentialCustomersNewProducts {
    public class NewProduct{
        @AuraEnabled public String returnCode;
        @AuraEnabled public String productId;
        @AuraEnabled public String productDescription;
        @AuraEnabled public String effectiveDate;
        @AuraEnabled public String amount;
        @AuraEnabled public String formattedAmount;
    }
    
    public class Data{
        @AuraEnabled public List<NewProduct> newProducts;
    }
    
    @AuraEnabled public String apiVersion;
    @AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
}