public with sharing class ConfigurationsWrapper {
	@AuraEnabled
	public String type {get;set;}
	@AuraEnabled
	public String executionDate {get;set;}
	@AuraEnabled
	public String productDescription {get;set;}
	@AuraEnabled
    public Integer id {get;set;}
}