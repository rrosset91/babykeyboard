public with sharing class JSONWorkOrders {
    public String apiVersion;
	public String transactionId;
	public Data data;

	public class WorkOrders {
		public String cityId;
		public String operatorCode;
		public String contractNumber;
		public Integer requestID;
		public String workOrderID;
		public Integer workorderTypeID;
		public String workorderTypeDescription;
		public String status;
		public String statusDescription;
		public String note;
		public String terminationDate;
		public String attendanceDate;
		public Boolean isExempt;
		public String eventDate;
		public String closeUser;
	}

	public class Data {
		public List<WorkOrders> workorders;
	}
}