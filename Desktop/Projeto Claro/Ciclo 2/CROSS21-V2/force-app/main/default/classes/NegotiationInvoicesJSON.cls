/**
 * @description       :
 * @author            : Diogo Domingos
 * @group             :
 * @last modified on  : 27-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   01-19-2021   Diogo Domingos                      Initial Version
 **/
public with sharing class NegotiationInvoicesJSON {
	public String apiVersion;
	public String transactionId;
	public Data data;

	public class Charges {
		@AuraEnabled
		public String partnerName;
		@AuraEnabled
		public Integer partnerId;
		@AuraEnabled
		public String segmentationId;
		@AuraEnabled
		public String titleNumber;
		@AuraEnabled
		public String generationDate;
		@AuraEnabled
		public String amount;
	}

	public class Data {
		@AuraEnabled
		public List<InvoicesItems> invoicesItems;
	}

	//mostrar todos!  Se nao for mandatorio nao precisa exibir
	public class Statements {
		@AuraEnabled
		public Boolean isMandatory;
		@AuraEnabled
		public Boolean isSelectable;
		@AuraEnabled
		public Boolean isRenegItem;
		@AuraEnabled
		public Boolean isDue;
		@AuraEnabled
		public String dueDate;
		@AuraEnabled
		public String paymentMethod;
		@AuraEnabled
		public String description;
		@AuraEnabled
		public String amount;
		@AuraEnabled
		public String statementId;
		@AuraEnabled
		public String partnerName;
		@AuraEnabled
		public String serviceType;
		@AuraEnabled
		public String valueInvoice;
		@AuraEnabled
		public String type = 'Fatura';
	}

	public class InvoicesItems {
		@AuraEnabled
		public Boolean hasHistoricRenegotiation;
		@AuraEnabled
		public String termRenegotiationId;
		@AuraEnabled
		public String cityId;
		@AuraEnabled
		public String contractNumber;
		@AuraEnabled
		public String functionalityRuleId;
		@AuraEnabled
		public String checkUseItemRenegotiation;
		@AuraEnabled
		public String enableFirstInstallmentSeparateDebts;
		@AuraEnabled
		public String migratedCityMessage;
		@AuraEnabled
		public String businessMessage;
		@AuraEnabled
		public String billsValue;
		@AuraEnabled
		public List<Bills> bills;
		@AuraEnabled
		public List<Statements> statements;
	}

	public class Bills {
		@AuraEnabled
		public Boolean isMandatory;
		@AuraEnabled
		public String isEnabled;
		@AuraEnabled
		public String isOutOfTime;
		@AuraEnabled
		public String dueDate;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String paymentMethod;
		@AuraEnabled
		public String amount;
		@AuraEnabled
		public String valueInvoice;
		@AuraEnabled
		public String billId;
		@AuraEnabled
		public String type = 'Fatura';
		@AuraEnabled
		public List<Charges> charges;
	}
}