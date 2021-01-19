public class CEC_360_showProductsController {

	static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

	@AuraEnabled
	public static List<CEC_RestObjects.treeProducts> getBillingAccount(string parentId) {
		List<Account> lstBillingAcc = [SELECT Id, Name, ContractNumber__c, 
									   vlocity_cmt__PremisesId__r.Complement__c, 
									   vlocity_cmt__PremisesId__r.Number__c, 
									   vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c
									   FROM Account
									   WHERE ParentId = :parentId
									   and RecordTypeId = :recTypeBillingAccount
									   and vlocity_cmt__Status__c <> 'Cancelado'];
		system.debug('getBillingAccount: ' + lstBillingAcc);
		system.debug('getBillingAccount1: ' + formatToWrapper(lstBillingAcc));
		return formatToWrapper(lstBillingAcc);
	}

	@AuraEnabled
	public static List<Asset> getPreAssets(string id, string recordType) {
		Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
		List<Asset> lstAst = [Select Id, Msisdn__c, Name, status from Asset where AccountId = :id
						      And RecordTypeId = :recordTypeAsset
						      And (Status = 'Ativo' Or Status = 'Pendente' Or Status = 'Suspenso')];

		system.debug('Pre Assets:' + lstAst);
		return lstAst;
	}


	public static List<CEC_RestObjects.treeProducts> formatToWrapper(List<Account> lstBillingAcc) {
		List<CEC_RestObjects.treeProducts> lstTree = new List<CEC_RestObjects.treeProducts>();


		for(Account acc :lstBillingAcc) {
			CEC_RestObjects.treeProducts obj = new CEC_RestObjects.treeProducts();
			obj.Id = acc.Id;
			obj.name = acc.name;
			obj.contractNumber = acc.ContractNumber__c;
			obj.complement = acc.vlocity_cmt__PremisesId__r.Complement__c;
			obj.numberAd = acc.vlocity_cmt__PremisesId__r.Number__c;
			obj.street = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c;
			obj.isExpandable = false;
			lstTree.add(obj);
		}
		return lstTree;
	}

	@AuraEnabled
	public static List<CEC_RestObjects.subTreeProduct> getAssetsByListRecordType(string id, List<string> recordType) {
		List<Id> recordTypeAsset = new List<Id>();
		for(string rt :recordType) {
			recordTypeAsset.add(Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId());
		}

		List<Asset> listAsset = [SELECT ID, 
							     Name, 
							     Status, 
							     Msisdn__c, 
							     AccountId, 
							     SpotId__c, 
							     businessUnit__c
							     FROM Asset WHERE(Status = 'Ativo' Or Status = 'Pendente' Or Status = 'Suspenso') AND((businessUnit__c = 'NET' and SpotType__c in('Principal', 'Adicional')) OR(businessUnit__c != 'NET' AND SpotType__c in('PLANO_PRECO'))) AND vlocity_cmt__BillingAccountId__c = :id
							     AND RecordTypeId in :recordTypeAsset];

		return formatSubWrapper(listAsset);
	}

	@AuraEnabled
	public static List<String> getRecordType(string recordId) {
		List<Asset> ass = [SELECT Id, Name, RecordType.developerName FROM Asset WHERE
						   accountId = :recordId and RecordType.developerName LIKE '%Movel%'];

		List<String> lstRecordsTypeName = new List<string>();
		for(Asset ast :ass) {
			lstRecordsTypeName.add(ast.RecordType.DeveloperName);
		}
		system.debug('recordType: ' + lstRecordsTypeName);
		return lstRecordsTypeName;
	}

	@AuraEnabled
	public static List<CEC_RestObjects.subTreeProduct> getAssets(string id, list<String> recordType) {


		List<Asset> listAsset = [SELECT ID, 
							     Name, 
							     Status, 
							     Msisdn__c, 
							     AccountId,
							     SpotId__c, PriceDec__c,
							     businessUnit__c
							     FROM Asset WHERE(Status = 'Ativo' Or Status = 'Pendente' Or Status = 'Suspenso') AND((businessUnit__c = 'NET' and SpotType__c in('Principal', 'Adicional')) OR(businessUnit__c != 'NET' AND SpotType__c in('PLANO_PRECO'))) AND vlocity_cmt__BillingAccountId__c = :id
							     AND RecordType.developerName IN :recordType];
		system.debug('listAsset: ' + formatSubWrapper(listAsset));
		return formatSubWrapper(listAsset);
	}

	@AuraEnabled
	public static List<CEC_RestObjects.subTreeProduct> getCaAssets(string id, string dataIn, string dataFim, string dataHoje, 
																   string contractNumber) {
		String date1aux = dataIn + ' 00:00:00';
		String date2aux = datafim + ' 23:00:00';

		dateTime dt1 = Datetime.valueOf(date1aux);
		dateTime dt2 = Datetime.valueOf(date2aux);
		dt1 = dt1.addDays(0);
		dt2 = dt2.addDays(0);
		system.debug('dt1' + dt1);
		system.debug('dt2' + dt2);


		List<Asset> listAsset = new List<Asset>();


		if(contractNumber == 'Ver Todos') {
				listAsset = [SELECT ID, 
						     Name, 
						     Msisdn__c, 
						     RecordType.Name, PriceDec__c,
						     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Complement__c, 
						     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Number__c, 
						     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, 
						     vlocity_cmt__BillingAccountId__r.Name, 
						     LastModifiedDate
						     FROM Asset WHERE(Status = 'Cancelado') And AccountId = :id
						     And LastModifiedDate >= :dt1
						     And LastModifiedDate <= :dt2];
			system.debug('listAsset1: ' + listAsset.size());
		} else {
			Account contractId = [Select Id from Account where ContractNumber__c = :contractNumber
				      and RecordTypeId = :recTypeBillingAccount LIMIT 1];
				listAsset = [SELECT ID, 
					     Name, 
					     Msisdn__c, 
					     RecordType.Name, PriceDec__c,
					     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Complement__c, 
					     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Number__c, 
					     vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, 
					     vlocity_cmt__BillingAccountId__r.Name, 
					     LastModifiedDate
					     FROM Asset WHERE(Status = 'Cancelado') And(vlocity_cmt__BillingAccountId__c = :contractId.Id
					     And LastModifiedDate >= :dt1
					     And LastModifiedDate <= :dt2)];


		system.debug('listAsset2: ' + listAsset.size());
	}
	return formatSubWrapperCancel(listAsset);
}

@AuraEnabled
public static List<CEC_RestObjects.subTreeProduct> formatSubWrapperCancel(List<Asset> lstAsset) {


	List<Cec_RestObjects.subTreeProduct> lstTree = new List<CEC_RestObjects.subTreeProduct>();
	for (Asset ast :lstAsset) {

		CEC_RestObjects.subTreeProduct objNode = new CEC_RestObjects.subTreeProduct();
		String auxStreet = ast.vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c;
		String auxNum = ast.vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Number__c;
		String auxCom = ast.vlocity_cmt__BillingAccountId__r.vlocity_cmt__PremisesId__r.Complement__c;
		objNode.Id = ast.id;
		objNode.Name = ast.Name;
		objNode.msisdn = ast.MSISDN__c;

		objNode.contractNumber = ast.vlocity_cmt__BillingAccountId__r.Name;
		if(String.isBlank(auxStreet) || auxStreet.contains('null')) {
			auxStreet = '--';
		}
		if(String.isBlank(auxNum) || auxNum.contains('null')) {
			auxNum = '--';
		}
		if(String.isBlank(auxCom) || auxCom.contains('null')) {
			auxCom = '--';
		}
		objNode.addres = auxStreet + '  ' + auxNum + ' ' + auxCom;

		String dtAux = String.valueOf(ast.LastModifiedDate);
		objNode.dateMod = dtAux.substring(8, 10) + '/' + dtAux.substring(5, 7) + '/' + dtAux.substring(0, 4);
		objNode.record = ast.RecordType.Name;

		lstTree.add(objNode);
	}

	return lstTree;
}



@AuraEnabled
public static List<CEC_RestObjects.subTreeProduct> formatSubWrapper(List<Asset> lstAsset) {
	Integer cont = 0;
	List<Cec_RestObjects.subTreeProduct> lstTree = new List<CEC_RestObjects.subTreeProduct>();
	for (Asset ast :lstAsset) {
		CEC_RestObjects.subTreeProduct objNode = new CEC_RestObjects.subTreeProduct();
		objNode.Id = ast.id;
		objNode.AccountId = ast.AccountId;
		objNode.bu = ast.businessUnit__c;
		objNode.Name = ast.Name;
		objNode.status = ast.status;
		objNode.msisdn = ast.Msisdn__c;
		objNode.Preco = ast.PriceDec__c;
		objNode.spotid = ast.SpotId__c;
		objNode.isExpandable = false;
		objNode.line = cont;
		cont++;
		lstTree.add(objNode);
	}

	return lstTree;
}

@AuraEnabled
public static List<Asset> getSubAssetsRes(string AccountId, String SpotId) {
	List<Asset> listAsset = [Select ID, 
							     Name, 
								 PriceDec__c,
							     Status
							     from asset where AccountId = :AccountId
							     and SpotId__c = :SpotId
							     and SpotId__c != null
							     And SpotType__c != 'ADICIONAL'
							     And SpotType__c != 'PRINCIPAL'
								 And SpotType__c != null
							     And Status != 'Cancelado'
								/* And (NOT Name LIKE 'COMODATO')
								 And (NOT Name LIKE 'COMODATO DIGITAL')*/];

	return listAsset;

}

@AuraEnabled
public static List<Asset> getSubAssetsMov(String msisdn) {
	List<Asset> listAsset = [Select ID, 
							     Name, 
								 PriceDec__C,
							     Status
							     from Asset
							     where Msisdn__c = :msisdn
							     and ServiceType__c LIKE 'Assinante'
							     And (NOT SpotType__c LIKE 'Plano Pre')
								  /*And (NOT Name LIKE 'COMODATO')*/];

	return listAsset;
}

@AuraEnabled
public static List<String> fillContracts(string parentId) {
	List<Account> lstBillingAcc = [SELECT Id, ContractNumber__c FROM Account
									   WHERE ParentId = :parentId
									   and RecordTypeId = :recTypeBillingAccount];
	return formatAccount(lstBillingAcc);
}

public static List<String> formatAccount(List<Account> acc) {
	List<String> accTList = new List<String>();
	accTList.add('Ver Todos');
	for(integer i = 0; i < acc.size(); i ++) {
		String contract = acc [i].ContractNumber__c;
		accTList.add(contract);
	}
	return accTList;
}
}