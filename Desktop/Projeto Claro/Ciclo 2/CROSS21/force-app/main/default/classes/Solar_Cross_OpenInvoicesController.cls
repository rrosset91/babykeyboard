/**
 * @description       : 
 * @author            : Lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 12-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-14-2020   Lucas.soldi@ibm.com   Initial Version
**/
public class Solar_Cross_OpenInvoicesController {
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
	 * @description: Método para retornar para o componente as faturas em aberto por periodo
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesByPeriod(Case objCase, Integer period, String recordId, Boolean isMobile) {
		System.debug('getOpenInvoicesByPeriod::');

		if(period != null)
			recordId = null;
    
        String contractId = objCase.ContractBillingAccount__r.ContractReferenceNumber__c;
        String operatorId = objCase.ContractBillingAccount__r.CityCode__c;
		Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
		System.debug('getOpenInvoices:: startDate ==>'+ startDate);
		System.debug('getOpenInvoices:: endDate ==>'+ endDate);

        if(isMobile){
            return Solar_CrossInvoices_MobileIntegration.getOpenInvoicesByPeriod(objCase, period, recordId);
        }else{
            return getInvoices(contractId, operatorId, startDate, endDate, recordId);
		}
	}

	private static Map<String, Object> getInvoices(String contractId, String operatorId, Date startDate, Date endDate, String recordId) {
		System.debug('getInvoices');

		if (checkOpenCase(recordId) != null)
			startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-60));

		Map<String, Object> data = new Map<String, Object>();
	//	try {
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
			Map<String, String> calloutResponse = new Map<String,String>();
			if(!Test.isRunningTest()){
				calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'Invoices');
			}else{
				HTTPRequest request = new HTTPRequest();
				request.setEndpoint('/Invoices');
				request.setMethod('GET');
				request.setTimeout(120000);
				HTTP http = new HTTP();
				HttpResponse response = http.send(request);
				calloutResponse.put('statusCode',String.valueOf(response.getStatusCode()));
				calloutResponse.put('response',response.getBody());
			}
			System.debug('calloutResponse: ' + calloutResponse);
			System.debug('calloutResponse status: ' + calloutResponse.get('statusCode'));
			//success
			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400)  {
				Map<String, List<Solar_Cross_InvoiceEvents.Event>> mapInvoiceEvents = Solar_Cross_InvoiceEvents.getEvents(operatorId,contractId,startDateText,endDateText);
				List<InvoicesWrapper> wpp = new List<InvoicesWrapper>();
				wpp = processInvoices(calloutResponse.get('response'), mapInvoiceEvents);
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
				data.put('invoicesEvents',mapInvoiceEvents);
			} else {
				data.put('success', false);
				data.put('message', setErrorMessage(calloutResponse.get('response')));
			}
	//	} catch (Exception e) {
			//throw new AuraHandledException(e.getMessage());
	//	}
		return data;
	}

	/*
	 * @description: Método para processar as informações e agrupar no wrapper
	 */
	private static List<InvoicesWrapper> processInvoices(String jsonString, Map<String,List<Solar_Cross_InvoiceEvents.Event>> mapInvoices) {
		System.debug('processInvoices' + jsonString);
		List<InvoicesWrapper> invoices = new List<InvoicesWrapper>();
		//JSONInvoices response = (JSONInvoices)JSON.deserialize(jsonString, JSONInvoices.class);
		Map<String, Object> genericResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

		JSONInvoices.Invoices data;
		List<JSONInvoices.Invoices> dataList;
		System.debug('data 00: ' + genericResponse.get('data'));
		if (genericResponse.get('data') == null)
			return invoices;

		String newJson = JSON.serialize(genericResponse.get('data'));
		Map<String, Object> untypedInvoices = (Map<String, Object>) JSON.deserializeUntyped(newJson);

		if (untypedInvoices.get('invoices') == null)
			return invoices;

		String serializedObject = JSON.serialize(untypedInvoices.get('invoices'));
		try {
			System.debug('data:: ');
			data = (JSONInvoices.Invoices) JSON.deserialize(serializedObject, JSONInvoices.Invoices.class);
		} catch (Exception e) {
			System.debug('DAta 2');
			dataList = (List<JSONInvoices.Invoices>) JSON.deserialize(serializedObject, List<JSONInvoices.Invoices>.class);
		}

		if (data != null) {
			System.debug('data: ' + data);
			invoices.add(getWrapper(data,mapInvoices));
		} else if (dataList != null) {
			for (JSONInvoices.Invoices invoice : dataList) {
				invoices.add(getWrapper(invoice,mapInvoices));
			}
		}

		System.debug('processInvoices' + jsonString);
		return invoices;
	}
	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	public static Map<String, String> setParams(String companyId, String contractId, String operatorId, String startDate, String endDate) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(companyId) || String.isEmpty(contractId) || String.isEmpty(operatorId) || String.isEmpty(startDate) || String.isEmpty(endDate)) {
			String emptyFields = (String.isEmpty(companyId)) ? 'companyId' : '';
			emptyFields += (String.isEmpty(contractId)) ? ', contractId' : '';
			emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
			emptyFields += (String.isEmpty(startDate)) ? ', startDate' : '';
			emptyFields += (String.isEmpty(endDate)) ? ', endDate' : '';
			if(!Test.isRunningTest())
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
	private static InvoicesWrapper getWrapper(JSONInvoices.Invoices invoice, Map<String,List<Solar_Cross_InvoiceEvents.Event>> mapInvoices) {
		InvoicesWrapper invoiceWrp = new InvoicesWrapper();
		invoiceWrp.tipoFatura = 'Fatura';
		invoiceWrp.status = invoice.statusInvoiceDescription;
		invoiceWrp.cobranca = invoice.paymentForm;
		invoiceWrp.dataVencimento = (String.isNotEmpty(invoice.dueDate)) ? InvoicesUtils.setFormattedDate(invoice.dueDate) : '';
		invoiceWrp.valor = (invoice.invoiceAmount != null) ? 'R$' + invoice.invoiceAmount : 'R$0,00';
		invoiceWrp.idFatura = invoice.invoiceId;
		//confirmar o elemento
		List<Solar_Cross_InvoiceEvents.Event> lstEvent = mapInvoices.get(invoice.invoiceId);
		// Integer lastIndex = lstEvent.size()-1;
		// invoiceWrp.statusFatura = mapInvoices.get(invoice.invoiceId)[lastIndex].invoiceStatusID;
		
		invoiceWrp.iconUsed = 'utility:success';
		invoicewrp.varianIcon =  'success';

		system.debug('invoice.paymentForm ' + invoice.paymentForm);
		system.debug('invoice.paymentForm.containsIgnoreCase ' + invoice.paymentForm.containsIgnoreCase('DebitoContaCorrente'));
		if(invoice.paymentForm != null && invoice.paymentForm.containsIgnoreCase('DebitoContaCorrente') && mapInvoices.containsKey(invoice.invoiceId)){
            system.debug('invoice.invoiceId -------------> ' + invoice.invoiceId);
			for(Solar_Cross_InvoiceEvents.Event event :mapInvoices.get(invoice.invoiceId)){
				if(event.criticalReasonID != null){
					invoiceWrp.iconUsed = 'utility:clear';
					invoicewrp.varianIcon = 'error';
					invoiceWrp.eventDescription = event.eventDescription;

					break;
				}
			}
		}
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
	public static Case getCase(Id strId) {
		List<Case> lstCase = [SELECT ContractBillingAccount__r.ContractReferenceNumber__c, ContractBillingAccount__r.Contractnumber__c,ContractBillingAccount__r.BusinessUnit__c, ContractBillingAccount__r.CityCode__c FROM CASE WHERE Id = :strId];
		if (lstCase.isEmpty())
			return null;
		return lstCase[0];
	}
}