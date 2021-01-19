public class ContestationResult {
	public Data data;

	public class ContestationBillItems {
		public Long billId;
		public String status;
	}

	public class Data {
		public String returnCode;
		public String returnMessage;
		public String dccMessage;
		public String batchGenerationMessage;
		public List<ContestationBillItems> contestationBillItems;
	}
}