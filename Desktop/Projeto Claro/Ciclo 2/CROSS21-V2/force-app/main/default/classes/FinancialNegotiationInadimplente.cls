/**
 * @description       :
 * @author            : Diogo Domingos
 * @group             :
 * @last modified on  : 22-01-2021
 * @last modified by  : Roger Rosset
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
			String userName = InvoicesUtils.getCalloutUser('InvoicesPendingItems');
			Map<String, String> params = setParams(operatorCode, contractNumber, userName);
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoicesPendingItems');

			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				List<NegotiationInvoicesJSON.InvoicesItems> wppInvoiceItems = new List<NegotiationInvoicesJSON.InvoicesItems>();
				wppInvoiceItems = processInvoiceItems(calloutResponse.get('response'));
				data.put('success', true);
				data.put('invoiceItems', wppInvoiceItems);
			} else {
				throw new InvoicesControllerException(setErrorMessage(calloutResponse.get('response')));
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
	private static Map<String, String> setParams(String operatorCode, String contractNumber, String userName) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(operatorCode) || String.isEmpty(contractNumber) || String.isEmpty(userName)) {
			String emptyFields = (String.isEmpty(operatorCode)) ? 'operatorCode' : '';
			emptyFields += (String.isEmpty(contractNumber)) ? ', contractNumber' : '';
			emptyFields += (String.isEmpty(userName)) ? ', userName' : '';
			system.debug('OPERATOR CODE: ' + operatorCode);
			system.debug('CONTRACT NUMBER: ' + contractNumber);
			system.debug('USER NAME: ' + userName);
			throw new InvoicesControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('operatorCode', operatorCode);
			params.put('contractNumber', contractNumber);
			params.put('userName', userName);
		}
		return params;
	}

	/*
	 * @description: Método para processar as informações adicionais
	 */
	private static List<NegotiationInvoicesJSON.InvoicesItems> processInvoiceItems(String jsonString) {
		NegotiationInvoicesJSON negotitationJSON = (NegotiationInvoicesJSON) JSON.deserialize(jsonString, NegotiationInvoicesJSON.class);
		List<NegotiationInvoicesJSON.InvoicesItems> lstInvoiceItems = new List<NegotiationInvoicesJSON.InvoicesItems>();

		for (NegotiationInvoicesJSON.InvoicesItems item : negotitationJSON.data.invoicesItems) {
			NegotiationInvoicesJSON.InvoicesItems invoice = new NegotiationInvoicesJSON.InvoicesItems();
			invoice.hasHistoricRenegotiation = item.hasHistoricRenegotiation;
			invoice.termRenegotiationId = item.termRenegotiationId;
			invoice.cityId = item.cityId;
			invoice.contractNumber = item.contractNumber;
			invoice.functionalityRuleId = item.functionalityRuleId;
			invoice.checkUseItemRenegotiation = item.checkUseItemRenegotiation;
			invoice.enableFirstInstallmentSeparateDebts = item.enableFirstInstallmentSeparateDebts;
			invoice.migratedCityMessage = item.migratedCityMessage;
			invoice.businessMessage = item.businessMessage;
			invoice.billsValue = item.billsValue;
			invoice.bills = new List<NegotiationInvoicesJSON.Bills>();
			invoice.statements = new List<NegotiationInvoicesJSON.Statements>();

			for (NegotiationInvoicesJSON.Statements itemStatements : item.statements) {
				NegotiationInvoicesJSON.Statements itemWrapper = new NegotiationInvoicesJSON.Statements();
				itemWrapper.dueDate = itemStatements.dueDate;
				itemWrapper.valueInvoice = itemStatements.amount;
				itemWrapper.isMandatory = itemStatements.isMandatory;
				itemWrapper.statementId = itemStatements.statementId;
				invoice.statements.add(itemWrapper);
			}

			for (NegotiationInvoicesJSON.Bills itemBills : item.bills) {
				NegotiationInvoicesJSON.Bills itemWrapper = new NegotiationInvoicesJSON.Bills();
				itemWrapper.dueDate = itemBills.dueDate;
				itemWrapper.valueInvoice = itemBills.amount;
				itemWrapper.isMandatory = itemBills.isMandatory;
				itemWrapper.billId = itemBills.billId;
				invoice.bills.add(itemWrapper);
			}
			lstInvoiceItems.add(invoice);
		}
		return lstInvoiceItems;
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
}