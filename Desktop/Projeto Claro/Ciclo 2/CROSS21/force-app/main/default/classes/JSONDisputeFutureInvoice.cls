public class JSONDisputeFutureInvoice {
	public Data data;

	public class Data {
		public String operatorCode;
		public String contractNumber;
		public String userName;
		public String phoneNumber;
		public String name;
		public Integer contestationOrigin;
		public List<ContestationFutureItem> installments;
	}

	public class ContestationFutureItem {
		public Long idExtractItem;
		public Decimal value;
		public Integer contestationReasonId;
		public String note;
		public String hashAuthority;
	}
}