/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 30-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
public without sharing class FinancialMobileGeneralService {
	public static Set<String> RESIDENTIAL_UNIT = new Set<String>{ 'NET', 'EMBRATEL' };
	public static Set<String> MOBILE_UNIT = new Set<String>{ 'CLARO' };

	@AuraEnabled(cacheable=true)
	public static EntryPointWrapper getRecordProps(String recordId) {
		if (recordId == null || String.isEmpty(recordId))
			throw new AuraHandledException('Id de registro não enviado');

		EntryPointWrapper epw = new EntryPointWrapper();
		epw.recordId = recordId;
		epw.isCase = recordId.startsWith('500');
		epw.contractId = epw.isCase ? getContractFromCase(recordId) : getContractFromAccount(recordId);
		epw.operatorId = epw.isCase ? getOperatorFromCase(recordId) : getOperatorFromAccount(recordId);
		epw.contractAccountSalesforceId = getContractAccount(recordId);
		epw.customerAccountSalesforceId = getCustomerAccount(recordId);
		epw.isN2User = GeneralInvoicesController.isBackofficeN2();
		epw.isMobileContract = isMobileContract(epw.contractAccountSalesforceId);
		epw.isViewOnly = !epw.isCase;
		return epw;
	}

	private static String getContractFromAccount(String recordId) {
		List<Account> accsLst = [SELECT ContractReferenceNumber__c FROM Account WHERE Id = :recordId];

		if (accsLst.isEmpty())
			return null;

		return accsLst[0].ContractReferenceNumber__c;
	}

	private static String getOperatorFromAccount(String recordId) {
		List<Account> accsLst = [SELECT CityCode__c FROM Account WHERE Id = :recordId];

		if (accsLst.isEmpty())
			return null;

		return accsLst[0].CityCode__c;
	}

	private static String getContractFromCase(String recordId) {
		Account acc = InvoicesUtils.getAccountFromCaseId(recordId);

		return acc == null ? null : acc.ContractReferenceNumber__c;
	}

	private static String getOperatorFromCase(String recordId) {
		Account acc = InvoicesUtils.getAccountFromCaseId(recordId);

		return acc == null ? null : acc.CityCode__c;
	}

	private static String getContractAccount(String recordId) {
		if (recordId.startsWith('500')) {
			Account acc = InvoicesUtils.getAccountFromCaseId(recordId);
			return acc == null ? null : acc.Id;
		} else {
			Account acc = [SELECT RecordType.Name FROM Account WHERE Id = :recordId];
			return acc.RecordType.Name == 'Billing' ? acc.Id : getCustomerAccount(recordId);
		}
	}

	private static String getCustomerAccount(String recordId) {
		if (recordId.startsWith('500')) {
			Account acc = InvoicesUtils.getAccountFromCaseId(recordId);
			if (acc == null)
				return null;

			List<Account> accs = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND RecordType.Name = 'Consumer'];
			return accs.isEmpty() ? null : accs[0].Id;
		} else {
			Account acc = [SELECT ParentId, RecordType.Name FROM Account WHERE Id = :recordId];

			return acc.RecordType.Name == 'Consumer' ? acc.Id : acc.ParentId;
		}
	}

	private static Boolean isMobileContract(String contractAccountId) {
		System.debug('Contract Account -> ' + contractAccountId);

		if (contractAccountId == null)
			return false;

		Account acc = [SELECT Id, BusinessUnit__c FROM Account WHERE Id = :contractAccountId];

		if (acc.BusinessUnit__c == null)
			return false;

		if (RESIDENTIAL_UNIT.contains(acc.BusinessUnit__c.toUpperCase()))
			return false;

		if (MOBILE_UNIT.contains(acc.BusinessUnit__c.toUpperCase()))
			return true;

		return false;
	}

	public class EntryPointWrapper {
		//Id do registro que foi enviado para pegar as informacoes. Somente suporta ID de caso ou conta.
		@AuraEnabled
		public String recordId;
		//Flag que sinaliza se o id do registro em contexto é de caso ou nao
		@AuraEnabled
		public Boolean isCase;
		//Numero de id de contrato do cliente
		@AuraEnabled
		public String contractId;
		//Codigo de operadora do cliente
		@AuraEnabled
		public String operatorId;
		//Id do registro do contrato do cliente
		@AuraEnabled
		public String contractAccountSalesforceId;
		//Id do registro da conta de customer do cliente
		@AuraEnabled
		public String customerAccountSalesforceId;
		//Flag que especifica se é um usuario N2 ou nao
		@AuraEnabled
		public Boolean isN2User;
		//Id de nao sei oq, falta implementar isso
		@AuraEnabled
		public string msisdn;
		//Id de nao sei oq, falta implementar isso
		@AuraEnabled
		public string customerCrmId;
		//Indica se é um contrato mobile ou nao
		@AuraEnabled
		public Boolean isMobileContract;
		//Indica se é somente visualização
		@AuraEnabled
		public Boolean isViewOnly;
	}
}