/**
 * @description       :
 * @author            : Joao Neves
 * @group             :

 * @last modified on  : 09-12-2020
 * @last modified by  : Joao Neves

 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Joao Neves   		Initial version
 * 2.0   11-11-2020   Diego Almeida   	Adicionada dados referentes as US104496
**/
public without sharing class MobileInvoiceWrapper {
	//Response Wrappers

	//Response Wrapper for Invoices
	public class ResponseInvoiceWrapper{

		@AuraEnabled
		public Integer apiResponse;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public List<ResponseInvoice> responseData;

	}

	//Response Wrapper for PaymentHistories
	public class ResponsePaymentWrapper{

		@AuraEnabled
		public Integer apiResponse;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public ResponseInvoice responseData;
	}

	public class ResponseInvoice {
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
		@AuraEnabled
		public Decimal paymentValue;
		@AuraEnabled
		public String contractId;
		@AuraEnabled
		public String formatDueDate;
		@AuraEnabled
		public String noteFiscalNumber;

	}

	//JsonApi Wrapper Invoices



	public class ResponseInvoices{
		public String apiVersion;
		public String transactionId;
		public Data data;
		// public Pagination pagination;
	}



	// public class Pagination{
	// 	public String start;
	// 	// public String limit;
	// 	public String xTotalCount;
	// }



	public class Data{
		public List<Invoice> invoices;
	}

	public class Invoice{
		public String billAmount;
		public String paymentDueDate;
		public String status;
		public String billCode;
		public String name;
		public String partyIdentificationNumber;
		public String customerAccountId;
		public String telephoneNumber;
		public Secondary secondary;
		public String paymentMethod;
		public String company;
		public String origin;
		public String isCombomulti;
	}



	public class Secondary{
		public List<String> telephoneNumbers;
	}



	//JsonApi Wrapper MobileInvoicesPaymentHistories
	public class DocumentBank{
		public String bankId;
	}

	public class Situation{
		public String situationId;
		public String description;
	}

	public class BillingCycle{
		public String code;
	}

	public class Client{
		public String mobileClientId;
	}

	public class Account{
		public String mobileBan;
		public List<BillingCycle> billingCycle;
		public List<Client> client;
	}

	public class InvoicePayment{

		public Integer monthReference;

		public String startDate;
		public String endDate;
		public String issuanceDate;
		public List<DocumentBank> documentBank;

		public Integer documentNumber;
		public String invoiceNumber;
		public String dueDate;
		public List<Situation> situation;
		public Decimal valueToPay;
		public String paymentDate;
		public Decimal paymentAmount;
		public Decimal valueAdjustment;
		public Decimal previousValue;
		public Decimal creditPrevious;
		public Decimal creditLater;

		public List<Account> account;
		public String onlineAccountCreationDate;
		public String dateLastUpdateOnlineAccount;
	}

	public class InvoicesPayment{
		public List<InvoicePayment> invoice;
	}

	public class DataPayment{
		public InvoicesPayment invoices;
	}

	public class ResponsePaymentHistories{
		public String apiVersion;
		public String transactionId;
		public DataPayment data;
	}


	//-------------------------------------------------------US104496
	// public class Invoice2 {
	// 	public Integer monthReference;
	// 	public String startDate;
	// 	public String endDate;
	// 	public String issuanceDate;
	// 	public DocumentBank2 documentBank;
	// 	public Integer documentNumber;
	// 	public String invoiceNumber;
	// 	public String dueDate;
	// 	public Situation2 situation;
	// 	public Double valueToPay;
	// 	public String paymentDate;
	// 	public Double paymentAmount;
	// 	public Double valueAdjustment;
	// 	public Double previousValue;
	// 	public Double laterValue;
	// 	public Double creditPrevious;
	// 	public Double creditLater;
	// 	public String onlineAccountCreationDate;
	// 	public String dateLastUpdateOnlineAccount;
	// }

	// public class ResponsePaymentHistories2 {
	// 	public String apiVersion;
	// 	public String transactionId;
	// 	public Data2 data;
	// }

	// public class DocumentBank2 {
	// 	public String bankId;
	// }

	// public class Invoices2 {
	// 	public Invoice2 invoice;
	// }

	// public class Data2 {
	// 	public List<Invoices2> invoices;
	// }

	// public class Situation2 {
	// 	public String situationId;
	// 	public String description;
	// }
	@AuraEnabled public String apiVersion;
	@AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public Integer apiResponse;


}