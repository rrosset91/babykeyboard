/**
 * @description       :
 * @author            : Diogo Domingos
 * @group             :
 * @last modified on  : 01-20-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   01-19-2021   Diogo Domingos                      Initial Version
 **/
public with sharing class FinancialNegotiationInadimplente {
	/*
	 * @description: Método que faz a chamada para retornar ao componente as faturas
	 */
	@AuraEnabled
	public static Map<String, Object> getInvoicesPending(String operatorCode, String contractNumber) {
		Map<String, Object> data = new Map<String, Object>();
		try {
			Map<String, String> params = setParams(operatorCode, contractNumber);
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoicesPendingItems');

			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				List<BillsWrapper> wppBills = new List<BillsWrapper>();
				List<StatementsWrapper> wppStatements = new List<StatementsWrapper>();
				wppBills = processBills(calloutResponse.get('response'));
				wppStatements = processStatements(calloutResponse.get('response'));
				data.put('success', true);
				data.put('bills', wppBills);
				data.put('statements', wppStatements);
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
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	@TestVisible
	private static Map<String, String> setParams(String operatorCode, String contractNumber) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(operatorCode) || String.isEmpty(contractNumber)) {
			String emptyFields = (String.isEmpty(operatorCode)) ? 'operatorCode' : '';
			emptyFields += (String.isEmpty(contractNumber)) ? ', contractNumber' : '';

			system.debug('OPERATOR CODE: ' + operatorCode);
			system.debug('CONTRACT NUMBER: ' + contractNumber);
			throw new InvoicesControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('operatorCode', operatorCode);
			params.put('contractNumber', contractNumber);
		}
		return params;
	}

	/*
	 * @description: Método para processar as informações e agrupar no wrapper
	 */
	public static List<BillsWrapper> processBills(String jsonString) {
		NegotiationInvoicesJSON negotitationJSON = (NegotiationInvoicesJSON) JSON.deserialize(jsonString, NegotiationInvoicesJSON.class);
		List<BillsWrapper> lstItemBills = new List<BillsWrapper>();

		for (NegotiationInvoicesJSON.InvoicesItems item : negotitationJSON.data.invoicesItems) {
			for (NegotiationInvoicesJSON.Bills itemBills : item.bills) {
				BillsWrapper itemWrapper = new BillsWrapper();
				itemWrapper.dueDate = itemBills.dueDate;
				itemWrapper.valueInvoice = itemBills.amount;
				itemWrapper.isMandatory = itemBills.isMandatory;

				lstItemBills.add(itemWrapper);
			}
		}
		return lstItemBills;
	}

	/*
	 * @description: Método para processar as informações e agrupar no wrapper
	 */
	public static List<StatementsWrapper> processStatements(String jsonString) {
		NegotiationInvoicesJSON negotitationJSON = (NegotiationInvoicesJSON) JSON.deserialize(jsonString, NegotiationInvoicesJSON.class);
		List<StatementsWrapper> lstItemStatements = new List<StatementsWrapper>();

		for (NegotiationInvoicesJSON.InvoicesItems item : negotitationJSON.data.invoicesItems) {
			for (NegotiationInvoicesJSON.Statements itemStatements : item.statements) {
				StatementsWrapper itemWrapper = new StatementsWrapper();
				itemWrapper.dueDate = itemStatements.dueDate;
				itemWrapper.valueInvoice = itemStatements.amount;
				itemWrapper.isMandatory = itemStatements.isMandatory;

				if (itemWrapper.isMandatory) {
					lstItemStatements.add(itemWrapper);
				}
			}
		}
		return lstItemStatements;
	}

	/*
	 * @description: Método para gerar a a mensagem de erro quando necessário
	 */
	@TestVisible
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

	public class InvoicesControllerException extends Exception {
	}

	public class BillsWrapper {
		@AuraEnabled
		public String invoiceId;
		@AuraEnabled
		public String tipo = 'Fatura';
		@AuraEnabled
		public String dueDate;
		@AuraEnabled
		public String valueInvoice;
		@AuraEnabled
		public String isMandatory;
	}

	public class StatementsWrapper {
		@AuraEnabled
		public String invoiceId;
		@AuraEnabled
		public String tipo = 'Fatura';
		@AuraEnabled
		public String dueDate;
		@AuraEnabled
		public String valueInvoice;
		@AuraEnabled
		public Boolean isMandatory;
	}
}
