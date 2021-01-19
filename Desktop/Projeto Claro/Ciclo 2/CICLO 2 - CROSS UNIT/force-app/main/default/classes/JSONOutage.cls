public class JSONOutage {

	public class Installments {
		@AuraEnabled public String returnCode;
		@AuraEnabled public String OutageNumber;
		@AuraEnabled public List<Products> products;
	}

	public class Products {
		@AuraEnabled public String productType;
		@AuraEnabled public String affectedServices;
		@AuraEnabled public String symptom;
		@AuraEnabled public String coverage;
		@AuraEnabled public String nature;
		@AuraEnabled public String startDate;
		@AuraEnabled public String previsionDate;
		@AuraEnabled public String endDate;
		@AuraEnabled public String status;
		@AuraEnabled public String responsible;
	}

	@AuraEnabled public Data data;

	public class Data {
		@AuraEnabled public List<Installments> installments;
	}
}