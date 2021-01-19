public with sharing class JSONMobileInteractionsProtocol {

	@AuraEnabled public String apiVersion;
	@AuraEnabled public String transactionId;
	@AuraEnabled public Data data;

	public class Attendances {
		@AuraEnabled public String interactionSequenceId;
		@AuraEnabled public String solicitationDateOpening;
		@AuraEnabled public String interactionModificationDate;
		@AuraEnabled public String protocolNumber;
		@AuraEnabled public String contactName;
		@AuraEnabled public String msisdn;
		@AuraEnabled public String channelRequestId;
		@AuraEnabled public String situation;
		@AuraEnabled public String slaIndicatorExceeded;
		@AuraEnabled public String synthesisRanking;
		@AuraEnabled public String reasonDescription1;
		@AuraEnabled public String reasonDescription2;
		@AuraEnabled public String reasonCode3;
		@AuraEnabled public String reasonDescription3;
		@AuraEnabled public String reasonCode4;
		@AuraEnabled public String reasonDescription4;
		@AuraEnabled public String description;
		@AuraEnabled public String closedSituationIndicator;
		@AuraEnabled public String memo;
		@AuraEnabled public String contactReturnType;
		@AuraEnabled public String contactTelephoneNumber;
		@AuraEnabled public String name;
		@AuraEnabled public List<UpdateInteraction> updateInteraction;
		@AuraEnabled public Object address;
	}

	public class UpdateInteraction {
		@AuraEnabled public String updateResume;
		@AuraEnabled public String updateDetail;
		@AuraEnabled public String label;
		@AuraEnabled public String fieldName;
		@AuraEnabled public List<String> updateDate;
	}

	public class Data {
		@AuraEnabled public List<Attendances> attendances;
	}
}