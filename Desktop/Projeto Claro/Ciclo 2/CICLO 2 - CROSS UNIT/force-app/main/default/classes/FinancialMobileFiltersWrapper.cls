public with sharing class FinancialMobileFiltersWrapper {
    public class filterValues{
        @AuraEnabled public Integer periodFilter;
        @AuraEnabled public Date startDateFilter;
        @AuraEnabled public Date endDateFilter;
        @AuraEnabled public String productFilter;
        @AuraEnabled public String statusFilter;
        @AuraEnabled public String liveSearchFilter;
        @AuraEnabled public Boolean isCustomDateFilter;
    }
}