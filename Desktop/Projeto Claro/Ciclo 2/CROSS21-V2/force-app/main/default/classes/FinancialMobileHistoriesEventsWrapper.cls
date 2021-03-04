public with sharing class FinancialMobileHistoriesEventsWrapper {
	public class Accountevent {
		@AuraEnabled
		public List<Contract> contract;
		@AuraEnabled
		public List<Subscriber> subscriber;
	}

	@AuraEnabled
	public String apiVersion;
	@AuraEnabled
	public String transactionId;
	@AuraEnabled
	public Data data;

	public class Subscriber {
		@AuraEnabled
		public String msisdn;
		@AuraEnabled
		public String subscriberNumber;
		@AuraEnabled
		public List<Offers> offers;
	}

	public class Data {
		public List<Accountevent> accountevent;
		public List<Offers> offerList;
	}

	public class Offers {
		@AuraEnabled
		public String offerlId;
		@AuraEnabled
		public String offerDescription;
		@AuraEnabled
		public String serviceplanlevel;
		@AuraEnabled
		public String accessionDate;
		@AuraEnabled
		public Date realAccessionDate;
		@AuraEnabled
		public String formattedAccessionDate;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String expirationDate;
		@AuraEnabled
		public Date realExpirationDate;
		@AuraEnabled
		public String formattedExpirationDate;
	}

	public class Contract {
		@AuraEnabled
		public String contractNumber;
		@AuraEnabled
		public List<Offers> offers;
	}
}