/**
 * @description       :
 * @author            : Diogo Domingos
 * @group             :
 * @last modified on  : 01-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   01-19-2021   Diogo Domingos                      Initial Version
 **/
public with sharing class NegotiationInvoicesJSON {
	public String apiVersion;
	public String transactionId;
	public Data data;

	public class Charges {
		public String partnerName;
		public Integer partnerId;
		public String segmentationId;
		public String titleNumber;
		public String generationDate;
		public String amount;
	}

	public class Data {
		public List<InvoicesItems> invoicesItems;
	}

	//mostrar todos!  Se nao for mandatorio nao precisa exibir
	public class Statements {
		public Boolean isMandatory;
		public Boolean isSelectable;
		public Boolean isRenegItem;
		public Boolean isDue;
		public String dueDate;
		public String paymentMethod;
		public String description;
		public String amount;
		public String partnerName;
		public String serviceType;
	}

	public class InvoicesItems {
		public Boolean hasHistoricRenegotiation;
		public Integer termRenegotiationId;
		public Integer cityId;
		public Integer contractNumber;
		public Integer functionalityRuleId;
		public String checkUseItemRenegotiation;
		public Integer enableFirstInstallmentSeparateDebts;
		public String migratedCityMessage;
		public String businessMessage;
		public List<Bills> bills;
		public List<Statements> statements;
	}

	public class Bills {
		public String isMandatory;
		public String isEnabled;
		public String isOutOfTime;
		public String dueDate;
		public String status;
		public String paymentMethod;
		public String amount;
		public List<Charges> charges;
	}
}
