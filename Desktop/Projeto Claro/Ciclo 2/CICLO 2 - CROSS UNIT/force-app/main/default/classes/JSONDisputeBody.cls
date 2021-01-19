public with sharing class JSONDisputeBody {
	
	public Data data;

	public class ContestationStatements {
		public Long idExtractItem;
		public Long idPartnerStatement;
		public Long idDetExtractItem;
		public Integer partnerid;
		public Double amont;
		public Integer contestationreasonid;
		public String note;
		public String hashAuthority;
	}

	public class Data {
		public String operatorCode;
		public String contractNumber;
		public String userName;
		public String billId;
		public String name;
		public String ddd;
		public String phoneNumber;
		public String email;
		public Integer contestactionOrigin;
		public String contestactionType;
		public String sendMethod;
		public String numberIp = '';
		public String valueHash = '';
		public String callId = '';
		public String protocolNumber = '';
		public List<ContestationStatements> contestationStatements;
	}

	public static JSONDisputeBody parse(String json) {
		return (JSONDisputeBody) System.JSON.deserialize(json, JSONDisputeBody.class);
	}

}