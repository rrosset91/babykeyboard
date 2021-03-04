/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 11-18-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-14-2020   lucas.soldi@ibm.com   Initial Version
**/
public class Solar_CrossInvoices_MobileIntegration {

	/*
	 * @description: Método para retornar para o componente as faturas em aberto por periodo
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesByPeriod(Case objCase, Integer period, String recordId) {
		System.debug('getOpenInvoicesByPeriod::');

		if(period != null)
			recordId = null;
    
		String billingAccountId = objCase.ContractBillingAccount__r.ContractReferenceNumber__c;
		//Date startDate = InvoicesUtils.toStartOfMonth(Date.newInstance(2000,03,25));
		//Date endDate = InvoicesUtils.toEndOfMonth(Date.newInstance(2020,03,25));
		Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
		System.debug('getOpenInvoices:: startDate ==>'+ startDate);
		System.debug('getOpenInvoices:: endDate ==>'+ endDate);

        
		return getInvoices(billingAccountId, startDate, endDate, recordId);
	}

	private static Map<String, Object> getInvoices(String billingAccountId, Date startDate, Date endDate, String recordId) {
		System.debug('getInvoices');

		Map<String, Object> data = new Map<String, Object>();
		try {
			String companyId = 'MOVEL';
			String startDateText = InvoicesUtils.formatDateToIntegration(startDate, true);
			String endDateText = InvoicesUtils.formatDateToIntegration(endDate, true);
			System.debug('getOpenInvoices:: startDate ==>'+ startDate);
			System.debug('getOpenInvoices:: endDate ==>'+ endDate);
			//parâmetros para a URL
			Map<String, String> params = setParams(companyId, billingAccountId, startDateText, endDateText);
			System.debug('params: ' + params);
            //header
            ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('Invoices');
			Map<String, String> headers = setHeaders(metaParameter.token__c);
			//instância e realização do callout
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers,'Invoices');
			System.debug('calloutResponse: ' + calloutResponse);
			//success
			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				List<InvoicesWrapper> wpp = new List<InvoicesWrapper>();
				wpp = processInvoices(calloutResponse.get('response'));
				System.debug('getInvoices wpp' + wpp);
				data.put('success', true);
				data.put('invoices', wpp);
			} else {
				data.put('success', false);
				data.put('message', setErrorMessage(calloutResponse.get('response')));
			}
		} catch (Exception e) {
			System.debug('Deu erro::' );
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
		Map<String, Object> genericResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

		JSONInvoices.Invoices data;
		List<JSONInvoices.Invoices> dataList;

		if (genericResponse.get('data') == null)
			return invoices;

		String newJson = JSON.serialize(genericResponse.get('data'));
		Map<String, Object> untypedInvoices = (Map<String, Object>) JSON.deserializeUntyped(newJson);
		System.debug('new Json: '+ newJson);
		if (untypedInvoices.get('invoices') == null)
			return invoices;

		String serializedObject = JSON.serialize(untypedInvoices.get('invoices'));
		System.debug('serializedObject: '+ serializedObject);
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
	private static Map<String, String> setParams(String companyId,String billingAccountId, String startDate, String endDate) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(companyId) || String.isEmpty(startDate) || String.isEmpty(endDate) || String.isEmpty(billingAccountId)) {
			String emptyFields = (String.isEmpty(companyId)) ? 'companyId' : '';
			emptyFields += (String.isEmpty(billingAccountId)) ? ', billingAccountId' : '';
			emptyFields += (String.isEmpty(startDate)) ? ', startDate' : '';
			emptyFields += (String.isEmpty(endDate)) ? ', endDate' : '';
			throw new InvoicesControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('companyId', companyId);
			params.put('billingAccountId', billingAccountId);
			params.put('startDate', startDate);
			params.put('endDate', endDate);
		}
		return params;
	}
	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	private static Map<String, String> setHeaders(String token) {
		Map<String, String> params = new Map<String, String>();
		params.put('Authorization', token);
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
		invoiceWrp.status = Boolean.valueOf(invoice.indicatorInvoiceNotPaid) == true? 'Em Aberto' : 'Pago';
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

}