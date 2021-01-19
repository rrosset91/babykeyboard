public class CEC_360_AdditionalInformationController {

	@AuraEnabled
	public static ResultWrapper getDataRecord(String recordId, string objectAPI) {
		ResultWrapper res = new ResultWrapper();
		if(objectAPI == 'Asset') {
			Asset varAsset = [SELECT Id, RecordType.Name, MSISDN__c FROM Asset where Id = :recordId];
			res.recordTypeName = varAsset.RecordType.Name;
			res.dataContract = String.isNotBlank(varAsset.MSISDN__c) ? varAsset.MSISDN__c :'';

		} else if(objectAPI == 'Account') {
			res.recordTypeName = '';
			res.dataContract = [Select ContractNumber__c FROM Account where Id = :recordId].ContractNumber__c;
		}
		return res;
	}


	@AuraEnabled
	public static List<Account> getAddress(String recordId, string objectAPI) {
		List<Asset> varAsset = null;
		string idContract = null;
		if(objectAPI == 'Asset') {
			varAsset = [SELECT Id, RecordType.Name, vlocity_cmt__BillingAccountId__c FROM Asset where Id = :recordId limit 1];
			if(!varAsset.isEmpty()) {
				idContract = varAsset [0].vlocity_cmt__BillingAccountId__c;
			}
		} else if(objectAPI == 'Account') {
			idContract = recordId;
		}

		if(idContract == null)
			return null;

		List<Account> result = [SELECT Id, InstalledPremises__c, InstalledPremises__r.vlocity_cmt__StreetAddress__c, InstalledPremises__r.Complement__c, vlocity_cmt__CalculatedAddress__c, 
					      InstalledPremises__r.vlocity_cmt__City__c, InstalledPremises__r.vlocity_cmt__State__c, InstalledPremises__r.vlocity_cmt__Country__c
					      FROM Account WHERE Id = :idContract];

        return result;
	}

	public class ResultWrapper {

		@AuraEnabled public string recordTypeName;
		@AuraEnabled public string dataContract;
	}

}