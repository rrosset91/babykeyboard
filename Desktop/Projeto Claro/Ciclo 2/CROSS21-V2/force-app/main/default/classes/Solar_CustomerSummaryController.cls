public class Solar_CustomerSummaryController {
    @AuraEnabled
    public static Map<String, Object> loadData(String recordId, String sObjectName) {
        try{
            Map<String, Object> data = new Map<String, Object>();
            String accountId = '';
            if(sObjectName == 'Case'){
                accountId = [SELECT AccountId FROM Case WHERE Id =: recordId].AccountId;
            }else if(sObjectName == 'Account'){
                accountId = recordId;
            }
            Account customerData = [SELECT FormattedDocument__c, Name, Phone, vlocity_cmt__CustomerValue__c,
                                    CellPhone__c, vlocity_cmt__BillingEmailAddress__c, Id 
                                    FROM Account 
                                    WHERE Id =: accountId];
            data.put('customerData', customerData);
            data.put('customerUrl', URL.getOrgDomainUrl().toExternalForm() + '/' + accountId);
            return data;
        }catch(Exception e){throw new AuraHandledException('Erro - ' + e.getMessage());} 
    }   
}