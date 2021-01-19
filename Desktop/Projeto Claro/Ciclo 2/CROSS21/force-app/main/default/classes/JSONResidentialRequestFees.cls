public with sharing class JSONResidentialRequestFees {
    public class RequestFee{
        @AuraEnabled public String returnCode;
        @AuraEnabled public String productId;
        @AuraEnabled public String productDescription;
        @AuraEnabled public String requestTypeId;
        @AuraEnabled public String requestTypeDescription;
        @AuraEnabled public String releaseDate;
        @AuraEnabled public String extractItemTypeId;
        @AuraEnabled public String extractItemTypeDescription;
        @AuraEnabled public String itemExtractRegistrationUser;
        @AuraEnabled public String requestRegistrationUser;
        @AuraEnabled public String amount;
        @AuraEnabled public string formattedAmount;
        @AuraEnabled public String paymentPlanId;
        @AuraEnabled public String paymentPlanName;
        @AuraEnabled public String installmentNumber;

    }
    
    public class Data{

        @AuraEnabled public List <RequestFee> technicalRequestFees;

    }
    
    @AuraEnabled public String apiVersion;
    @AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
}