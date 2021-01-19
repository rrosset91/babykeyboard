/**
 * @description       :
 * @author            : Caio Cesar
 * @group             :
 * @last modified on  : 17-12-2020
 * @last modified by  : Caio Cesar
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   17-12-2020   Caio Cesar   		Initial version
 **/

public with sharing class FinancialMobileInvoiceDetailsWrapper {
    public class Invoice {
		@AuraEnabled public Integer monthReference;
		@AuraEnabled public String startDate;
		@AuraEnabled public String endDate;
		@AuraEnabled public String issuanceDate;
		@AuraEnabled public DocumentBank documentBank;
		@AuraEnabled public Integer documentNumber;
		@AuraEnabled public String invoiceNumber;
		@AuraEnabled public String dueDate;
		@AuraEnabled public Situation situation;
		@AuraEnabled public Double valueToPay;
		@AuraEnabled public String paymentDate;
		@AuraEnabled public Double paymentAmount;
		@AuraEnabled public Double valueAdjustment;
		@AuraEnabled public Double previousValue;
		@AuraEnabled public Double laterValue;
		@AuraEnabled public Double creditPrevious;
		@AuraEnabled public Double creditLater;
		@AuraEnabled public String onlineAccountCreationDate;
		@AuraEnabled public String dateLastUpdateOnlineAccount;
	}
		
	@AuraEnabled public String apiVersion;
	@AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public Integer apiResponse;

	public class DocumentBank {
		@AuraEnabled public String bankId;
	}

	public class Invoices {
		@AuraEnabled public Invoice invoice;
	}

	public class Data {
		@AuraEnabled public Invoices invoices;
	}

	public class Situation {
		@AuraEnabled public String situationId;
		@AuraEnabled public String description;
	}

	public class ResponsePaymentHistories {
		public String apiVersion;
		public String transactionId;
		public Data data;
	}

}