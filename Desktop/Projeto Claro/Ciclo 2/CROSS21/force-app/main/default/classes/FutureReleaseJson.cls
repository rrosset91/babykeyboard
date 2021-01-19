public class FutureReleaseJson {
	public Data data;

	public class Installments {
		public Long idExtractItem;
		public String descriptionExtractItem;
		public Integer idExtractItemType;
		public String itemDescriptionType;
		public Boolean allowContestation;
		public Integer idInvoiceGroupDemo;
		public Object idItemExtractComboSva;
		public String releaseDate;
		public String dueDate;
		public Decimal value;
		public Decimal sourceValue;
		public List<ContestationReasonTypes> contestationReasonTypes;
		public String descriptionInvoiceGroupDemo;
	}

	public class ContestationReasonTypes {
		@AuraEnabled
		public Integer contestationReasonId;
		@AuraEnabled
		public String contestationDescription;
	}

	public class Data {
		public Integer totalCount;
		public String operatorCode;
		public String contractNumber;
		public String userName;
		public List<Installments> installments;
	}
}