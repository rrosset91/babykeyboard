/**
 * @description       :
 * @author            : Joao Neves
 * @group             :

 * @last modified on  : 03-03-2021
 * @last modified by  : Felipe Ducheiko

 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-10-2020   Joao Neves   Initial Version
 **/
public without sharing class FinancialMobileGeneralService {
	public static Set<String> RESIDENTIAL_UNIT = new Set<String>{ 'NET', 'EMBRATEL', 'CLARO DTH' };
	public static Set<String> MOBILE_UNIT = new Set<String>{ 'CLARO - PRÉ', 'CLARO - PÓS', 'CLARO', 'MOVEL' };

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
		epw.isProfileFinancial = isProfileFinancial();
		epw.isFinancialPermissionSet = isFinancialPermissionSet();
		epw.isMobileContract = isMobileContract(epw.contractAccountSalesforceId);
		epw.isViewOnly = !epw.isCase;

		if (epw.isCase) {
			Case dadosCaso = getDataFromCase(recordId);

			epw.invoiceCase = dadosCaso.Invoice__c;
			epw.statusCase = dadosCaso.Status;
			epw.numeroCase = dadosCaso.CaseNumber;
			epw.typeCase = dadosCaso.RecordType.Name;
			epw.businessUnit = dadosCaso.ContractBillingAccount__r != null ? dadosCaso.ContractBillingAccount__r.BusinessUnit__c : null;
			epw.customerValue = dadosCaso.ContractBillingAccount__r != null ? dadosCaso.ContractBillingAccount__r.vlocity_cmt__CustomerValue__c : null;
			epw.documentNumber = dadosCaso.Account != null ? dadosCaso.Account.DocumentNumber__c : null;
		}

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

	private static Case getDataFromCase(String recordId) {
		return [
			SELECT
				ContractBillingAccount__r.BusinessUnit__c,
				ContractBillingAccount__r.ContractReferenceNumber__c,
				ContractBillingAccount__r.CityCode__c,
				ContractBillingAccount__r.vlocity_cmt__CustomerValue__c,
				Account.DocumentNumber__c,
				Invoice__c,
				Status,
				CaseNumber,
				RecordType.Name
			FROM Case
			WHERE Id = :recordId
		];
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

	//Vinicius Damasceno TU98 - CRM CROSS 03.12.2020
	@AuraEnabled(cacheable=true)
	public static Boolean hasPermissionSet(Id caseId) {
		Case objCase = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c FROM CASE WHERE Id = :caseId];

		Boolean permissionMobile = false;
		Boolean permissionResidential = false;

		for (PermissionSetAssignment permission : [
			SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId() AND (PermissionSet.Name = 'Solar_Cross_MobileBusinessUnit' OR PermissionSet.Name = 'Solar_Cross_ResidentialBusinessUnit')
		]) {
			permissionMobile = permission.PermissionSet.Name == 'Solar_Cross_MobileBusinessUnit' ? true : permissionMobile;
			permissionResidential = permission.PermissionSet.Name == 'Solar_Cross_ResidentialBusinessUnit' ? true : permissionResidential;
		}

		if (objCase.ContractBillingAccount__r.BusinessUnit__c.toUpperCase() == 'CLARO - PRÉ') {
			return false;
		}

		if (
			(RESIDENTIAL_UNIT.contains(objCase.ContractBillingAccount__r.BusinessUnit__c.toUpperCase()) && (permissionResidential)) ||
			(MOBILE_UNIT.contains(objCase.ContractBillingAccount__r.BusinessUnit__c.toUpperCase()) && (permissionMobile)) ||
			(!permissionMobile && !permissionResidential)
		) {
			if (permissionResidential && permissionMobile) {
				system.debug('User with 2 permissions cannot access!');
				return false;
			} else {
				system.debug('hasPermission returned true');
				return true;
			}
		} else {
			system.debug('hasPermission returned false');
			return false;
		}
	}

	/*Método que define a visibilidade do botão PU28(Cross), devido a regras de negócios, decidiu-se retirar

	@AuraEnabled
	public static Boolean getButtonVisibility(String caseId){
		Case objCase = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.ContractReferenceNumber__c FROM CASE WHERE Id = :caseId];
		Map<String, String> params = new Map<String,String>();
		try {
			String userName = InvoicesUtils.getCalloutUser('InvoicesPendingItems');
			params.put('operatorCode', objCase.ContractBillingAccount__r.CityCode__c);
			params.put('contractNumber', objCase.ContractBillingAccount__r.ContractReferenceNumber__c);
			params.put('userName', userName);
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoicesPendingItems');
			if(Integer.valueOf(calloutResponse.get('statusCode')) == 422){
				return false;
			}
		}catch(Exception e){
            System.debug('Exception: ' + e);
			return false;
		}

		return true;
	}
	*/

	public static Boolean isProfileFinancial() {
		String profileName = InvoicesUtils.getProfileName(UserInfo.getProfileId());
		
		Set<String> financialProfiles = new Set<String>{'Administrador do sistema', 'Suporte claro', 'IN_REPORT', 'SF_HOT_INTEGRACAO', 'SF_SUPORTE_NEGOCIO', 'Atendimento Call Center', 'Representante GOV', 'Representante Canais Críticos', 'CRN_Atendimento_Me_Cec', 'CRN_Master_Me_CEC', 'System Administrator'};

		if (financialProfiles.contains(profileName)) return true;
		
		return false;
	}

	public static Boolean isFinancialPermissionSet() {
		Set<String> permissionSets = new Set<String>{'CEC_Supervisor', 'Supervisor_Backoffice', 'CEC_Operador', 'CEC_Backoffice', 'SF_PS_DAC_AF_SUPERVISOR_CRC', 'SF_PS_DAC_AF_OPERADOR_CRC', 'SF_Authority', 'SF_PS_Area_de_Procedimentos', 'SF_PS_FINANCEIRO_PILOTO'};
		
		return InvoicesUtils.isPermissionSet(permissionSets);
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
		//Flag que especifica se é um usuario com perfil Financeiro ou nao
		@AuraEnabled
		public Boolean isProfileFinancial;
		//Flag que especifica se é um usuario com Permission Set Financeiro ou nao
		@AuraEnabled
		public Boolean isFinancialPermissionSet;
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
		//Indica a fatura de tratamento no caso(quando null sera o primeiro atendimento)
		@AuraEnabled
		public String invoiceCase;
		//Indica o Status do caso
		@AuraEnabled
		public String statusCase;
		//Numero do caso
		@AuraEnabled
		public String numeroCase;
		//Tipo do caso
		@AuraEnabled
		public String typeCase;
		//Business Unit do contrato
		@AuraEnabled
		public String businessUnit;
		//Atributo customer value do contrato
		@AuraEnabled
		public String customerValue;
		//Numero do documento do contrato
		@AuraEnabled
		public String documentNumber;
	}
}