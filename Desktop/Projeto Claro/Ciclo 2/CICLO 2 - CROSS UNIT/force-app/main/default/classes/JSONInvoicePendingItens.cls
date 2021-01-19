/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: Classe com objetivo de converter o JSON retornado do serviço "InvoicePendingItens" (Lançamentos futuros)
*/
public class JSONInvoicePendingItens {
	public String apiVersion;
	public String transactionId;
	public Data data;
	public Error error;
    
	public class Charges {
		public String partnerName;
		public String partnerId;
		public String segmentationId;
		public String titleNumber;
		public String generationDate;
		public String amount;
	}

	public class Data {
		public Boolean hasHistoricRenegotiation;
		public String termRenegotiationId;
		public String cityId;
		public String contractNumber;
		public String functionalityRuleId;
		public String checkUseItemRenegotiation;
		public String enableFirstInstallmentSeparateDebts;
		public String migratedCityMessage;
		public String businessMessage;
		public List<Bills> bills;
	}

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

	public class Link {
		public String rel;
		public String href;
	}

	public class Bills {
		public Boolean isMandatory;
		public Boolean isEnabled;
		public Boolean isOutOfTime;
		public String dueDate;
		public String status;
		public String paymentMethod;
		public String amount;
		public List<Charges> charges;
		public List<Statements> statements;
	}
    
    public class Error {
		public String httpCode;
		public String errorCode;
		public String message;
		public String detailedMessage;
		public Link link;
	}
}