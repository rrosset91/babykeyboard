public without sharing class FinancialCaseManagement 
{
	// public static final String FINANCEIRO_RT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Financeiro' LIMIT 1].Id;
	public static final String FINANCEIRO_RT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Financial' LIMIT 1].Id;

	public static SolarCaseResponseWrapper createSolarCase(SolarCaseRequestWrapper reqSolarCase){

		Case cs = new Case();

		cs.ContractBillingAccount__c			= reqSolarCase.idCliente;
		cs.Contract__c   					    = reqSolarCase.contractNumber;
		cs.OperatorCode__c 						= reqSolarCase.operatorCode;
		cs.EntryReason__c 						= reqSolarCase.motivoEntrada;
		cs.LeavingReason__c 					= reqSolarCase.motivoSaida;
        cs.Solar_Cross_forwardingReason__c		= reqSolarCase.motivoEncaminhamento;
		cs.vlocity_cmt__ServiceId__c 			= reqSolarCase.servico; 				
		cs.Reason 								= reqSolarCase.motivo;
		cs.Subreason__c 						= reqSolarCase.subMotivo;
		cs.Category__c 							= reqSolarCase.categoria;
		cs.Channel__c 							= reqSolarCase.canal;
		cs.Origin 								= reqSolarCase.origem;
		cs.CallReason__c 						= reqSolarCase.motivoContato;
		cs.ProtocolNumber__c					= reqSolarCase.protocolo;
		cs.RecordTypeId = FINANCEIRO_RT;
		cs.Invoice__c = reqSolarCase.idFatura;
		cs.RequestSupport__c = reqSolarCase.descricaoSolicitacao;
		cs.Status = reqSolarCase.status;

		System.debug('Campos com mock ainda falta definir');

		insert cs;

		return SolarCaseResponseWrapper.SolarCaseResponse(cs);
	}

	public static List<vlocity_cmt__PaymentAdjustment__c> createPaymentItems(CEC_DisputeInvoice.DisputeInvoiceRequest invoice, Id caseId, Id accountId, String recordType){
		List<vlocity_cmt__PaymentAdjustment__c> retList = new List<vlocity_cmt__PaymentAdjustment__c>();
		Id recordTypeId = 
		Schema.getGlobalDescribe().get('vlocity_cmt__PaymentAdjustment__c')
		.getDescribe()
		.getRecordTypeInfosByDeveloperName()
		.get(recordType)
		.getRecordTypeId();	

		if(invoice.invoiceItems == null || invoice.invoiceItems.isEmpty())
			return retList;

		for(CEC_DisputeInvoice.InvoiceItem item : invoice.invoiceItems){
			vlocity_cmt__PaymentAdjustment__c adjustment = new vlocity_cmt__PaymentAdjustment__c();
			
			adjustment.RecordTypeId = recordTypeId;
			adjustment.idExtractItem__c = item.idInvoiceItem;
            adjustment.vlocity_cmt__AccountId__c = accountId;
			adjustment.vlocity_cmt__Amount__c = item.originalValue;
			adjustment.vlocity_cmt__Date__c = Date.today();
			adjustment.vlocity_cmt__DisputeId__c = caseId;
			adjustment.ContestedAmount__c = item.wishedValue;
			adjustment.vlocity_cmt__Status__c = item.approvationHash != null ? 'Approved' : 'Pending';
			adjustment.Reason__c = item.reason;
			adjustment.vlocity_cmt__Notes__c = item.notes;
			item.status = adjustment.vlocity_cmt__Status__c;
			retList.add(adjustment);
		}

		insert retList;
		return retList;
	}

	public static Case updateCaseContestation(CEC_DisputeInvoice.DisputeInvoiceRequest req, Id caseId, Id accountId, String recalculationReturn, Boolean hasAuth){
		Case cs = new Case(Id = caseId);
		cs.RequestSupport__c = req.descricaoSolicitacao;
		cs.Invoice__c = req.idInvoice;

		if(hasAuth){
			cs.EntryReason__c = 'Validação de Contestação de Valores';
			cs.LeavingReason__c = 'Contestação Realizada';
			cs.Authorization__c = InvoiceDetailsController.authorityParam;
            cs.Status = 'Closed';
             
		}else{
			cs.EntryReason__c = 'Validação de Contestação de Valores';
			cs.Solar_Cross_forwardingReason__c = 'Fora da alçada';
		}

		update cs;
		return null;
	}

	// @note 92819 Fechamento do Caso de Contestação em caso de falha de API - updateCaseAPIErrorContestation
	public static String updateCaseAPIErrorContestation(CEC_DisputeInvoice.DisputeInvoiceRequest Invoice){
		System.debug('92819:: Invoice ==>'+ Invoice);
		Case cs = new Case(Id = Invoice.caseId);

		System.debug('92819:: Caso pre updade ==>'+ cs);
		String msgReturn = '[500]Claro API Erro: ';
		if(isBackofficeN2()){
			cs.LeavingReason__c = 'Contestação Negada';
			msgReturn  += 'Erro ao enviar Contestação';
		}else{
			cs.EntryReason__c = 'Validação de Contestação de Valores';
			cs.LeavingReason__c = 'Contestação Negada';
			cs.Status = 'Closed';
			msgReturn  += 'Erro de Contestação, caso finalizado';
		}

		update cs;
		System.debug('92819:: Caso pos updade ==>'+ cs);

		return msgReturn;
	}

	// @note 92819 Fechamento do Caso de Contestação em caso de falha de API - isBackofficeN2
	public static Boolean isBackofficeN2(){
		AggregateResult[] countId = [SELECT count(Id) sets FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN ('CEC_Backoffice', 'Supervisor_Backoffice')];
        Integer countNumber = 0;
        for (AggregateResult ar : countId)
            countNumber = Integer.valueOf(ar.get('sets'));
        if (countNumber > 0)
            return true;
		return false;
	}
}