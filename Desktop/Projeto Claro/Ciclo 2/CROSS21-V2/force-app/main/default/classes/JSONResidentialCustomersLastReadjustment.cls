public with sharing class JSONResidentialCustomersLastReadjustment {
    public class LastReadjustment{
        @AuraEnabled public String returnCode;
        @AuraEnabled public String productId;
        @AuraEnabled public String productDescription;
        @AuraEnabled public String readjustmentType;
        @AuraEnabled public String amount;
        @AuraEnabled public String readjustmentDate;
        @AuraEnabled public String previousPrice;
        @AuraEnabled public String readjustmentPrice;
        @AuraEnabled public String percentReadjustment;
        @AuraEnabled public Double realValue;
        @AuraEnabled public String formattedAmount;
        @AuraEnabled public String formattedPreviousPrice;
        @AuraEnabled public String formattedReadjustmentPrice;
        @AuraEnabled public String percentAdjusted;
        @AuraEnabled public decimal percentValue; //DFT 10317848 CALCULO DO REAJUSTE REVISADO PARA OS VALORES CORRETOS
    }
    
    public class Data{
        @AuraEnabled public List<LastReadjustment> lastReadjustments;
    }
    
    @AuraEnabled public String apiVersion;
    @AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
}