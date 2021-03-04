public class JSONMigrationsEventsWrapper {
	public class MemoObj {
		@AuraEnabled public String mobileMemoId;
		@AuraEnabled public String mobileBan;
		@AuraEnabled public String msisdn;
		@AuraEnabled public String subscriberMobileId;
		@AuraEnabled public String mobileClientId;
		@AuraEnabled public String memoType;
		@AuraEnabled public String memoLevel;
		@AuraEnabled public String memoCategoryId;
		@AuraEnabled public String memoCategoryDesc;
		@AuraEnabled public String memoGenerationForm;
		@AuraEnabled public String memoDate;
		@AuraEnabled public String formattedMemoDate;
		@AuraEnabled public String formattedMemoTime;
		@AuraEnabled public String formattedMemoDateTime;
		@AuraEnabled public Datetime realMemoDate;
		@AuraEnabled public String memoUserId;
		@AuraEnabled public String memoText;
		@AuraEnabled public String relatedAccordion;
	}

	@AuraEnabled public String apiVersion;
	@AuraEnabled public String transactionId;
	@AuraEnabled public Data data;

	public class Data {
		@AuraEnabled public List<MemoObj> memoObj;
	}
}