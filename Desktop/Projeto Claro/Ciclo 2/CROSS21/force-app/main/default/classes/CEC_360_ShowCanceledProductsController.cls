public class CEC_360_ShowCanceledProductsController {

	@AuraEnabled
	public static List<AssetWrapper> getAssets(string id) {

        List<Asset> subProducts = [Select Id, recordtype.name, 
							     Name, Status, msisdn__c, 
							     AccountId, 
							     SpotId__c, 
							     businessUnit__c, LastModifiedDate
                                 from Asset where Status = 'Cancelado'
                                 AND vlocity_cmt__BillingAccountId__c =: id];

         System.debug('subProducts ' + subProducts);


		return formatSubWrapper(subProducts);
        
        

	}

	@AuraEnabled
	public static List<AssetWrapper> formatSubWrapper(List<Asset> subProducts) {
		Integer cont = 0;
		List<AssetWrapper> lstTree = new List<AssetWrapper>();

		for (Asset ast :subProducts) {
            AssetWrapper objNode = new AssetWrapper();
			objNode.Id = ast.id;
			objNode.Product = ast.RecordType.Name;
			objNode.AccountId = ast.AccountId;
			objNode.bu = ast.businessUnit__c;
			objNode.Name = ast.Name;
			objNode.status = ast.status;
			objNode.msisdn = ast.msisdn__c;
			objNode.endDate = ast.LastModifiedDate;
			objNode.spotid = ast.SpotId__c;
			objNode.isExpandable = false;
			objNode.line = cont;
			cont++;
			lstTree.add(objNode);
		}
        System.debug('lstTree ' + lstTree);
		return lstTree;
	}

	public class AssetWrapper {
        
		@AuraEnabled public String Id;
        @AuraEnabled public String Product;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String city;
        @AuraEnabled public String complement;
        @AuraEnabled public String street;
        @AuraEnabled public String Name;
        @AuraEnabled public String msisdn;
        @AuraEnabled public String spotid;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime endDate;
        @AuraEnabled public String bu;
        @AuraEnabled public String addres;
        @AuraEnabled public String dateMod;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String record;
        @AuraEnabled public Boolean isExpandable;
        @AuraEnabled public Integer line;
	}
}