public with sharing class MobileInvoiceWrapper {
	@AuraEnabled
	public String type;
	@AuraEnabled
	public String product;
	@AuraEnabled
	public String status;
	@AuraEnabled
	public String dueDate;
	@AuraEnabled
	public String contested;
	@AuraEnabled
	public String value;
	@AuraEnabled
	public String billId;
	@AuraEnabled
	public Decimal rawValue;
	@AuraEnabled
	public String payDate;
}