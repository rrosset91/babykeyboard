/**
 * @author: Rafael de Campos
 * @company: IBM - Bluewolf
 * @description: Classe do tipo controller do componente "Faturas em Aberto"
 */
public class InvoicesController {
	/*
	 * @description: Método para retornar o detalhe de uma fatura em especifico
	 */
	@AuraEnabled
	public static string checkOpenCase(String caseId) {
		System.debug('Valor atual -> ' + caseId);

		AggregateResult[] countId = [SELECT count(Id) sets FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN ('CEC_Backoffice', 'Supervisor_Backoffice')];
		Integer countNumber = 0;

		if (caseId == null)
			return null;

		System.debug('VALOR - >' + JSON.serializePretty(countId));

		for (AggregateResult ar : countId)
			countNumber = Integer.valueOf(ar.get('sets'));

		if (countNumber <= 0)
			return null;

		List<Case> cs = [SELECT Id, Invoice__c FROM Case WHERE IsClosed = FALSE AND RecordType.DeveloperName = 'Financial' AND Id = :caseId];

		return !cs.isEmpty() ? cs[0].Invoice__c : null;
	}
	/*
	 * @description: Método para retornar o detalhe de uma fatura em especifico
	 */
	@AuraEnabled
	public static Map<String, Object> getInvoiceDetails(String contractNumber, String invoiceId, String operatorCode, String infoDetailLevel, String recordId, String contestId) {
		return InvoiceDetailsController.getInvoiceDetails(contractNumber, invoiceId, operatorCode, infoDetailLevel, recordId, contestId);
	}
	/*
	 * @description: Método para retornar os detalhe de envio de segunda via
	 */
	@AuraEnabled
	public static Map<String, Object> getDuplicateInfo(String billId, String operatorCode) {
		return InvoicesSendDuplicate.getDuplicateInvoice(billId, operatorCode);
	}

	/*
	 * @description: Método para enviar a segunda via
	 */
	@AuraEnabled
	public static Object postDuplicate(
		string operatorCode,
		string contractNumber,
		string userName,
		string billId,
		string name,
		string phoneNumber,
		string email,
		string sendMethod,
		string billExtend,
		string descriptionReason,
		string caseId
	) {
		system.debug(
			'@@@postDuplicate-Envio invoicesControler: ' +
			' ' +
			operatorCode +
			' ' +
			contractNumber +
			' ' +
			userName +
			' ' +
			billId +
			' ' +
			name +
			' ' +
			phoneNumber +
			' ' +
			email +
			' ' +
			sendMethod +
			' ' +
			billExtend +
			' ' +
			descriptionReason +
			' ' +
			caseId
		);
		return InvoicesSendDuplicate.postDuplicateInvoice(operatorCode, contractNumber, userName, billId, name, phoneNumber, email, sendMethod, billExtend, descriptionReason, caseId);
	}

	/*
	 * @description: Método para retornar para o componente as faturas em aberto em range de data
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoices(String contractId, String operatorId, Date startDate, Date endDate, String recordId) {
		System.debug('getOpenInvoices::');

		if(startDate != null || endDate != null)
			recordId = null;
		startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-6));

		// startDate = InvoicesUtils.toStartOfMonth(startDate);
		endDate = InvoicesUtils.toEndOfMonth(endDate);
		return getInvoices(contractId, operatorId, startDate, endDate, recordId);
	}
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesManualPeriod(String contractId, String operatorId, Date startDate, Date endDate, String recordId) {
		System.debug('getOpenInvoices::');

		if(startDate != null || endDate != null)
			recordId = null;
		
		startDate = InvoicesUtils.toStartOfMonth(startDate);
		endDate = InvoicesUtils.toEndOfMonth(endDate);
		return getInvoices(contractId, operatorId, startDate, endDate, recordId);
	}

	/*
	 * @description: Método para retornar para o componente as faturas em aberto por periodo
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesByPeriod(String contractId, String operatorId, Integer period, String recordId) {
		System.debug('getOpenInvoicesByPeriod::');

		if(period != null)
			recordId = null;
	
		Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
		System.debug('getOpenInvoices:: startDate ==>'+ startDate);
		System.debug('getOpenInvoices:: endDate ==>'+ endDate);

		return getInvoices(contractId, operatorId, startDate, endDate, recordId);
	}

	private static Map<String, Object> getInvoices(String contractId, String operatorId, Date startDate, Date endDate, String recordId) {
		System.debug('getInvoices');

		if (checkOpenCase(recordId) != null)
			startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-60));

		Map<String, Object> data = new Map<String, Object>();
		try {
			String companyId = 'RESIDENCIAL';
			String startDateText = InvoicesUtils.formatDateToIntegration(startDate, true);
			String endDateText = InvoicesUtils.formatDateToIntegration(endDate, true);
			System.debug('getOpenInvoices:: startDate ==>'+ startDate);
			System.debug('getOpenInvoices:: endDate ==>'+ endDate);
			//parâmetros para a URL
			Map<String, String> params = setParams(companyId, contractId, operatorId, startDateText, endDateText);
			System.debug('params: ' + params);
			//header
			Map<String, String> headers = setHeaders();
			//instância e realização do callout
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'Invoices');
			System.debug('calloutResponse: ' + calloutResponse);
			//success
			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				List<InvoicesWrapper> wpp = new List<InvoicesWrapper>();
				wpp = processInvoices(calloutResponse.get('response'));
				System.debug('getInvoices wpp' + wpp);
				List<string> idBills = new List<string>();
				for (InvoicesWrapper invWrp : wpp)
					idBills.add(invWrp.idFatura);
				System.debug('getInvoices:relatedCases');
				List<GeneralInvoicesController.ContestedInvoice> relatedCases = GeneralInvoicesController.getCaseDetails(idBills);
				System.debug('Task:: getInvoices ==>' + relatedCases);

				if (!relatedCases.isEmpty()){
					Map<String, GeneralInvoicesController.ContestedInvoice> mapRelatedCases = new Map<String, GeneralInvoicesController.ContestedInvoice>();
					for (GeneralInvoicesController.ContestedInvoice constInv : relatedCases){
						mapRelatedCases.put(constInv.invoiceId, constInv);
					}
					for (InvoicesWrapper invWrp : wpp){
						// System.debug('Task:: invWrp ==>'+ invWrp);
						if(mapRelatedCases.containsKey(invWrp.idFatura)){
							invWrp.contestation = mapRelatedCases.get(invWrp.idFatura);
							System.debug('Task:: invWrp ==>'+ invWrp);

						}
						//refactoring
						// for (GeneralInvoicesController.ContestedInvoice constInv : relatedCases){
						// 	System.debug('Task:: constInv ==>'+ constInv);
						// 	if (constInv.invoiceId == invWrp.idFatura){
						// 		System.debug('Task:: invWrp.idFatura ==>'+ invWrp.idFatura);
						// 		invWrp.contestation = constInv;
						// 	}
						// }
					}
				}

				data.put('success', true);
				data.put('invoices', wpp);
			} else {
				data.put('success', false);
				data.put('message', setErrorMessage(calloutResponse.get('response')));
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return data;
	}

	/*
	 * @description: Método para processar as informações e agrupar no wrapper
	 */
	private static List<InvoicesWrapper> processInvoices(String jsonString) {
		System.debug('processInvoices' + jsonString);
		List<InvoicesWrapper> invoices = new List<InvoicesWrapper>();
		//JSONInvoices response = (JSONInvoices)JSON.deserialize(jsonString, JSONInvoices.class);
		Map<String, Object> genericResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

		JSONInvoices.Invoices data;
		List<JSONInvoices.Invoices> dataList;

		if (genericResponse.get('data') == null)
			return invoices;

		String newJson = JSON.serialize(genericResponse.get('data'));
		Map<String, Object> untypedInvoices = (Map<String, Object>) JSON.deserializeUntyped(newJson);

		if (untypedInvoices.get('invoices') == null)
			return invoices;

		String serializedObject = JSON.serialize(untypedInvoices.get('invoices'));
		try {
			data = (JSONInvoices.Invoices) JSON.deserialize(serializedObject, JSONInvoices.Invoices.class);
		} catch (Exception e) {
			dataList = (List<JSONInvoices.Invoices>) JSON.deserialize(serializedObject, List<JSONInvoices.Invoices>.class);
		}

		if (data != null) {
			invoices.add(getWrapper(data));
		} else if (dataList != null) {
			for (JSONInvoices.Invoices invoice : dataList) {
				invoices.add(getWrapper(invoice));
			}
		}

		System.debug('processInvoices' + jsonString);
		return invoices;
	}
	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	private static Map<String, String> setParams(String companyId, String contractId, String operatorId, String startDate, String endDate) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(companyId) || String.isEmpty(contractId) || String.isEmpty(operatorId) || String.isEmpty(startDate) || String.isEmpty(endDate)) {
			String emptyFields = (String.isEmpty(companyId)) ? 'companyId' : '';
			emptyFields += (String.isEmpty(contractId)) ? ', contractId' : '';
			emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
			emptyFields += (String.isEmpty(startDate)) ? ', startDate' : '';
			emptyFields += (String.isEmpty(endDate)) ? ', endDate' : '';
			throw new InvoicesControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('companyId', companyId);
			params.put('contractId', contractId);
			params.put('operatorId', operatorId);
			params.put('channelAttendanceId', '3');
			params.put('startDate', startDate);
			params.put('endDate', endDate);
		}
		return params;
	}
	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	private static Map<String, String> setHeaders() {
		Map<String, String> params = new Map<String, String>();
		//params.put('', '');
		return params;
	}

	/*
	 * @description: Método para gerar a a mensagem de erro quando necessário
	 */
	private static String setErrorMessage(String jsonString) {
		String errorMessage = '';
		JSONInvoices errorResponse = (JSONInvoices) JSON.deserialize(jsonString, JSONInvoices.class);
		if (errorResponse != null) {
			if (errorResponse.error != null) {
				errorMessage = errorResponse.error.errorCode + ' - ' + errorResponse.error.detailedMessage;
			} else {
				errorMessage = 'Unknown error';
			}
		} else {
			errorMessage = 'Unknown error';
		}
		return errorMessage;
	}

	/*
	 * @description: Gera o wrapper com base no objeto de invoice
	 */
	private static InvoicesWrapper getWrapper(JSONInvoices.Invoices invoice) {
		InvoicesWrapper invoiceWrp = new InvoicesWrapper();
		invoiceWrp.tipoFatura = 'Fatura';
		invoiceWrp.status = invoice.statusInvoiceDescription;
		invoiceWrp.cobranca = invoice.paymentForm;
		invoiceWrp.dataVencimento = (String.isNotEmpty(invoice.dueDate)) ? InvoicesUtils.setFormattedDate(invoice.dueDate) : '';
		invoiceWrp.valor = (invoice.invoiceAmount != null) ? 'R$' + invoice.invoiceAmount : 'R$0,00';
		invoiceWrp.idFatura = invoice.invoiceId;
		return invoiceWrp;
	}

	/*
	 * @description: Sub-classe para exceções customizadas
	 */
	public class InvoicesControllerException extends Exception {
	}

	/*
	 * @description: Sub-classe para busca de parâmetros do componente Solar_Cross_OpenInvoices a partir do caso (Tela Única)
	 */
	@AuraEnabled
	public static String getInvoiceParams(Id strId) {
		List<Case> lstCase = [SELECT ContractBillingAccount__r.ContractReferenceNumber__c, ContractBillingAccount__r.Contractnumber__c FROM CASE WHERE Id = :strId];
		if (lstCase.isEmpty())
			return null;
		
		
			return lstCase[0].ContractBillingAccount__r.Contractnumber__c;
	}

	/*
	 * @description: Método para verificar se os critérios para envio de 2via estão de acordo
	 */
	@AuraEnabled
	public static Boolean verifyDuplicatePermission(String csId) {
		System.debug('verifyDuplicate segment: ' + csId);

		account acc = InvoicesUtils.getAccountFromCaseId(csId);

		//Busca recodType do Controle de funcionalidades
		String recordTypeId = Schema.Sobjecttype.Parameters__c.getRecordTypeInfosByDeveloperName().get('FunctionalityControl').getRecordTypeId();
		System.debug('verifyDuplicate recordTypeId: ' + recordTypeId);
		
		//Busca segmento
		account accountId = [SELECT vlocity_cmt__CustomerValue__c FROM Account WHERE id =: acc.Id LIMIT 1];
		System.debug('verifyDuplicate AccountId: ' + accountId);

		//Busca Perfil/Area
		List<PermissionSetAssignment> permissionSetAssignmenList = [SELECT PermissionSet.Name FROM PermissionSetAssignment	WHERE Assignee.Id = : Userinfo.getUserId()];
		List<String> PermissionSetNameList = new List<String>();
		for (PermissionSetAssignment permission : permissionSetAssignmenList) {
			PermissionSetNameList.add(permission.PermissionSet.Name);
		}
		System.debug('verifyDuplicate PermissionSetAssignment: ' + PermissionSetNameList);

		//Verifica permissao
		AggregateResult[] permission = [
			SELECT count(Id) sets
			FROM Parameters__c 
			WHERE Active__c = true AND
				RecordTypeId =: recordTypeId AND 							// Id do tipo de Registro Controle de Funcionalidades
				Process__c = 'Contestação' AND 
				Business_Division__c = 'Residencial' AND 
				Channel__c = 'Atendimento' AND 
				Segment__c =: accountId.vlocity_cmt__CustomerValue__c AND 	// Seguimento da conta utilizada(black e etc)
				Profile__c IN: PermissionSetNameList 						// Perfil do usuário utilizado
		];

		Integer countNumber = 0;
		for (AggregateResult ar : permission)
			countNumber = Integer.valueOf(ar.get('sets'));
			System.debug('verifyDuplicate countNumber: ' + countNumber);
		if (countNumber > 0) {
			System.debug('verifyDuplicate: ' + 'true');
			return true;
		}
		System.debug('verifyDuplicate: ' + 'false');
		return false;
	}
}