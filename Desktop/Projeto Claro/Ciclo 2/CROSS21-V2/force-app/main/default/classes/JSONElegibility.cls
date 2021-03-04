public with sharing class JSONElegibility {
	public String apiVersion;
	public String transactionId;
	public Data data;

	public class Installments {
		public Long idExtractItem;
		public Long idDetExtractItem;
		public Long idPartnerStatement;
		public String itemOrder;
		public Boolean allowContestation;
		public String itemDescription;
		public String itemGrouper;
		public String dueDate;
		public List<ContestationTypes> contestationTypes;
	}

	public class ContestationTypes{
		public Integer idReasonDisputes;
		public String descriptionDisputed;
	}

	public class Charges {
		public String partnerId;
		public Double amountCharge;
		public Double amountAgainstDeparture;
		public List<Installments> installments;
	}

	public class Data {
		public boolean allowOnlyRecalculate;
		public String billId;
		public Double billValue;
		public String cityId;
		public String contractId;
		public String statusBill;
		public String paymentMethod;
		public List<Charges> charges;
	}

	public static JSONElegibility parse(String json) {
		return (JSONElegibility) System.JSON.deserialize(json, JSONElegibility.class);
	}

}