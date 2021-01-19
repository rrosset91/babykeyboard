public without sharing class GeneralInvoicesController {
	@AuraEnabled
	public static string getOperatorId(String recordId) {
		Account acc = InvoicesUtils.getAccountFromCaseId(recordId);

		return acc == null ? null : acc.CityCode__c;
	}

	@AuraEnabled
	public static List<Case> getInvoicesStatus(String recordId) {
		System.debug('GeneralInvoicesController-getInvoicesStatus ' + recordId);
		List<Case> invoicesStatus = [SELECT Invoice__c, status FROM Case WHERE id = :recordId LIMIT 1];
		System.debug('GeneralInvoicesController-getInvoicesStatus ' + invoicesStatus);

		return invoicesStatus;
	}

	// BUGPRD Verifica se é N1 ou BackofficeN2 (True = N2)
	@AuraEnabled
	public static Boolean isBackofficeN2() {
		AggregateResult[] countId = [
			SELECT count(Id) sets
			FROM PermissionSetAssignment
			WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN ('CEC_Backoffice', 'Supervisor_Backoffice')
		];
		Integer countNumber = 0;
		for (AggregateResult ar : countId)
			countNumber = Integer.valueOf(ar.get('sets'));
		if (countNumber > 0) {
			System.debug('GeneralInvoicesController-isBackofficeN2 ' + 'true');
			return true;
		}
		System.debug('GeneralInvoicesController-isBackofficeN2 ' + 'false');
		return false;
	}

	@AuraEnabled
	public static string getContractId(String recordId) {
		Account acc = InvoicesUtils.getAccountFromCaseId(recordId);

		return acc == null ? null : acc.ContractReferenceNumber__c;
	}

	@AuraEnabled
	public static List<ContestedInvoice> getCaseDetails(List<String> billIds) {
		System.debug('getCaseDetails' + billIds);
		List<Case> relatedCases = [
			SELECT
				Id,
				toLabel(ReturnStrategy__c),
				ContractBillingAccount__c,
				RefundObject__c,
				ContractNumber__c,
				OperatorCode__c,
				vlocity_cmt__ServiceId__c,
				Reason,
				Subreason__c,
				Category__c,
				Channel__c,
				Origin,
				CallReason__c,
				ProtocolNumber__c,
				RecordTypeId,
				Invoice__c
			FROM Case
			WHERE Invoice__c IN :billIds AND IsClosed = FALSE
		];
		System.debug('Bug DadosTela:: relatedCases ==>' + relatedCases);
		if (relatedCases.isEmpty())
			return new List<ContestedInvoice>();

		List<ContestedInvoice> invCases = new List<ContestedInvoice>();

		for (Case caseInstance : relatedCases) {
			ContestedInvoice inv = new ContestedInvoice();
			inv.caseId = caseInstance.Id;
			inv.idCliente = caseInstance.ContractBillingAccount__c;
			inv.contractNumber = caseInstance.ContractNumber__c;
			inv.operatorCode = caseInstance.OperatorCode__c;
			inv.servico = caseInstance.vlocity_cmt__ServiceId__c;
			inv.motivo = caseInstance.Reason;
			inv.subMotivo = caseInstance.Subreason__c;
			inv.categoria = caseInstance.Category__c;
			inv.canal = caseInstance.Channel__c;
			inv.origem = caseInstance.Origin;
			inv.motivoContato = caseInstance.CallReason__c;
			inv.protocolo = caseInstance.ProtocolNumber__c;
			inv.invoiceId = caseInstance.Invoice__c;
			inv.returnStrategy = caseInstance.ReturnStrategy__c;
			inv.reembolso = caseInstance.RefundObject__c;
			invCases.add(inv);
		}
		System.debug('Bug DadosTela:: invCases ==>' + invCases);

		List<vlocity_cmt__PaymentAdjustment__c> paymentsAdjustments = [
			SELECT
				Id,
				vlocity_cmt__AccountId__c,
				vlocity_cmt__Amount__c,
				//Bug Preenchimento tela
				// vlocity_cmt__InstallmentAmount__c,
				ContestedAmount__c,
				Reason__c,
				vlocity_cmt__Notes__c,
				vlocity_cmt__Status__c,
				vlocity_cmt__DisputeId__c,
				idExtractItem__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE vlocity_cmt__DisputeId__c IN :relatedCases
		];
		System.debug('Bug DadosTela:: paymentsAdjustments ==>' + paymentsAdjustments);

		for (ContestedInvoice caseInst : invCases) {
			List<ContestItem> constItems = new List<ContestItem>();

			for (vlocity_cmt__PaymentAdjustment__c instPay : paymentsAdjustments) {
				if (instPay.vlocity_cmt__DisputeId__c != caseInst.caseId)
					continue;
				ContestItem itm = new ContestItem();
				itm.idInvoiceItem = instPay.idExtractItem__c;
				itm.accountId = instPay.vlocity_cmt__AccountId__c;
				itm.originalValue = instPay.vlocity_cmt__Amount__c;
				//Bug Preenchimento tela
				// itm.wishedValue = instPay.vlocity_cmt__InstallmentAmount__c;
				itm.wishedValue = instPay.ContestedAmount__c;
				itm.status = instPay.vlocity_cmt__Status__c;
				itm.note = instPay.vlocity_cmt__Notes__c;
				itm.reason = instPay.Reason__c;
				constItems.add(itm);
			}

			caseInst.items = constItems;
		}

		System.debug('getCaseDetails' + invCases);
		return invCases;
	}

	@AuraEnabled
	public static boolean canDispute(String recordId, String caseId) {
		if (recordId == null)
			return true;

		List<Case> csList = [SELECT EntryReason__c FROM Case WHERE Id = :recordId];
		if (csList.isEmpty())
			return true;
		Case cs = csList[0];

		System.debug('Case -> ' + cs);
		System.debug('recordId -> ' + recordId);
		System.debug('caseId -> ' + caseId);
		System.debug('recordId == -> ' + recordId == caseId);

		AggregateResult[] countId = [
			SELECT count(Id) sets
			FROM PermissionSetAssignment
			WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN ('CEC_Backoffice', 'Supervisor_Backoffice')
		];
		Integer countNumber = 0;

		for (AggregateResult ar : countId)
			countNumber = Integer.valueOf(ar.get('sets'));

		if (countNumber <= 0)
			return true;

		if (cs.EntryReason__c == 'Validação de Contestação de Valores') {
			if (caseId == null)
				return true;

			return recordId == caseId;
		}

		return true;
	}

	@AuraEnabled
	public static String switchCaseType(String caseId) {
		List<Case> cs = [SELECT Id, Invoice__c FROM Case WHERE Id = :caseId AND EntryReason__c = 'Validação de Contestação de Valores'];
		if (cs.IsEmpty())
			return 'Bill';

		return cs[0].Invoice__c == null ? 'FutureRelease' : 'Bill';
	}

	public class ContestedInvoice {
		@AuraEnabled
		public string caseId;
		@AuraEnabled
		public string idCliente;
		@AuraEnabled
		public string contractNumber;
		@AuraEnabled
		public string operatorCode;
		@AuraEnabled
		public string servico;
		@AuraEnabled
		public string motivo;
		@AuraEnabled
		public string subMotivo;
		@AuraEnabled
		public string categoria;
		@AuraEnabled
		public string canal;
		@AuraEnabled
		public string origem;
		@AuraEnabled
		public string motivoContato;
		@AuraEnabled
		public string protocolo;
		@AuraEnabled
		public string invoiceId;
		@AuraEnabled
		public string returnStrategy;
		@AuraEnabled
		public string reembolso;
		@AuraEnabled
		public List<ContestItem> items;
	}

	public class ContestItem {
		@AuraEnabled
		public string idInvoiceItem;
		@AuraEnabled
		public string accountId;
		@AuraEnabled
		public decimal originalValue;
		@AuraEnabled
		public decimal wishedValue;
		@AuraEnabled
		public string status;
		@AuraEnabled
		public string reason;
		@AuraEnabled
		public string note;
	}
}