/*
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: do tipo wrapper para reunir as informações dos métodos de envio de 2a via
*/
public class InvoicesDuplicateWrapper {
    @AuraEnabled public List<sendMethods> availableSendMethods;
    @AuraEnabled public List<Object> availableReasons;
    @AuraEnabled public String userHasAccess;
    @AuraEnabled public String billAllowsSending;
    @AuraEnabled public String billExtend;
    @AuraEnabled public String contractNumber;
    @AuraEnabled public String name;
    @AuraEnabled public String email;
    @AuraEnabled public String phoneNumber;
    @AuraEnabled public String note;
    
    public class sendMethods{
        @AuraEnabled public String sendMethodId;
        @AuraEnabled public String sendMethodDescription;
        @AuraEnabled public String isExtended;
    }
    
    public class reasons{
        @AuraEnabled public Integer reasonId;
        @AuraEnabled public String descriptionReason;
        @AuraEnabled public String isExtended;
    }
}