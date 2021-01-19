public with sharing class JSONPaginationModalData {
        @AuraEnabled public List<Data> data;
        @AuraEnabled public Integer page;
        
    public class Data{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
    }
}