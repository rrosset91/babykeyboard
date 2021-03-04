/**
 * @description       :
 * @author            : Joao Neves
 * @group             :

 * @last modified on  : 18-12-2020
 * @last modified by  : Diego Almeida

 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Joao Neves   		Initial version
 * 2.0   11-11-2020   Diego Almeida   	Adicionada dados referentes as US104496

 * 3.0   09-12-2020   Ricardo Alves   	Adicionada dados referente à US100153
 * 4.0   17-12-2020   Caio Cesar   		Adicionada dados referente à US104496

 **/
public without sharing class FinancialMobileInvoices {
	/*
	 * @description: Método para retornar para o componente as faturas em aberto em range de data
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesManualPeriod(String billingAccountId, Date startDate, Date endDate) {
		startDate = InvoicesUtils.toStartOfMonth(startDate);
		endDate = InvoicesUtils.toEndOfMonth(endDate);
		return getInvoices(billingAccountId, startDate, endDate);
	}

	/*
	 * @description: Método para retornar para o componente as faturas em aberto por periodo
	 */
	@AuraEnabled
	public static Map<String, Object> getOpenInvoicesByPeriod(String billingAccountId, Integer period) {
		Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());

		return getInvoices(billingAccountId, startDate, endDate);
	}


	//@TestVisible

	private static Map<String, Object> getInvoices(String billingAccountId, Date startDate, Date endDate) {
		Map<String, Object> data = new Map<String, Object>();
		try {
			String companyId = 'MOVEL';
			String startDateText = InvoicesUtils.formatDateToIntegration(startDate, true);
			String endDateText = InvoicesUtils.formatDateToIntegration(endDate, true);

			//parâmetros para a URL
			Map<String, String> params = setParams(companyId, billingAccountId, startDateText, endDateText);
			//instância e realização do callout
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'Invoices');
			//success
			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {

				List<MobileInvoicesWrapper> wpp = new List<MobileInvoicesWrapper>();

				wpp = processInvoices(calloutResponse.get('response'));
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
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */

	//@TestVisible

	private static Map<String, String> setParams(String companyId, String billingAccountId, String startDate, String endDate) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(companyId) || String.isEmpty(billingAccountId) || String.isEmpty(startDate) || String.isEmpty(endDate)) {
			String emptyFields = (String.isEmpty(companyId)) ? 'companyId' : '';
			emptyFields += (String.isEmpty(billingAccountId)) ? ', billingAccountId' : '';
			emptyFields += (String.isEmpty(startDate)) ? ', startDate' : '';
			emptyFields += (String.isEmpty(endDate)) ? ', endDate' : '';
			throw new InvoicesControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('companyId', companyId);
			params.put('billingAccountId', billingAccountId);
			params.put('channelAttendanceId', '3');
			params.put('startDate', startDate);
			params.put('endDate', endDate);
		}
		return params;
	}

	/*
	 * @description: Método para processar as informações e agrupar no wrapper
	 */

	//@TestVisible
	private static List<MobileInvoicesWrapper> processInvoices(String jsonString) {
		List<MobileInvoicesWrapper> invoices = new List<MobileInvoicesWrapper>();

		Map<String, Object> genericResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

		MobileInvoiceJson.Invoice data;
		List<MobileInvoiceJson.Invoice> dataList;

		if (genericResponse.get('data') == null)
			return invoices;

		String newJson = JSON.serialize(genericResponse.get('data'));
		Map<String, Object> untypedInvoices = (Map<String, Object>) JSON.deserializeUntyped(newJson);

		if (untypedInvoices.get('invoices') == null)
			return invoices;

		String serializedObject = JSON.serialize(untypedInvoices.get('invoices'));
		try {
			data = (MobileInvoiceJson.Invoice) JSON.deserialize(serializedObject, MobileInvoiceJson.Invoice.class);
		} catch (Exception e) {
			dataList = (List<MobileInvoiceJson.Invoice>) JSON.deserialize(serializedObject, List<MobileInvoiceJson.Invoice>.class);
		}

		if (data != null) {
			invoices.add(getWrapper(data));
		} else if (dataList != null) {
			for (MobileInvoiceJson.Invoice invoice : dataList) {
				invoices.add(getWrapper(invoice));
			}
		}

		return invoices;
	}

	/*
	 * @description: Gera o wrapper com base no objeto de invoice
	 */

	//@TestVisible
	private static MobileInvoicesWrapper getWrapper(MobileInvoiceJson.Invoice invoice) {
		MobileInvoicesWrapper invoiceWrp = new MobileInvoicesWrapper();

		MobileInvoiceJson.TypedInvoice typedInvoice = invoice.getTypedInvoice();
		invoiceWrp.billDate = typedInvoice.issuanceDate.parsedDate;
		invoiceWrp.noteFiscalNumber = typedInvoice.noteFiscalNumber;
		invoiceWrp.rawDueDate = typedInvoice.dueDate.parsedDate;
		invoiceWrp.formatDueDate = typedInvoice.dueDate.parsedDate.format();
		invoiceWrp.isInvoiceNotPaid = typedInvoice.indicatorInvoiceNotPaid;
		invoiceWrp.rawAmount = typedInvoice.amountPrincipal;
		invoiceWrp.formatAmount = (typedInvoice.amountPrincipal != null) ? 'R$ ' + typedInvoice.amountPrincipal : 'R$ 0,00';
		return invoiceWrp;
	}

	/*
	 * @description: Método para gerar a a mensagem de erro quando necessário
	 */

	//@TestVisible

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
	 * @description: Método para buscar o valor e  data depagamento da fatura
	*/
	@AuraEnabled
	public static MobileInvoiceWrapper.ResponsePaymentWrapper getInvoiceDetail(String billingAccountId, String selectedInvoiceString) {
		System.debug('billingAccountId: ' + billingAccountId);
		System.debug('selectedInvoiceString: ' + selectedInvoiceString);

		MobileInvoiceWrapper.ResponseInvoice selectedInvoice = (MobileInvoiceWrapper.ResponseInvoice) JSON.deserialize(selectedInvoiceString, MobileInvoiceWrapper.ResponseInvoice.class);
		System.debug('selectedInvoice: ' + selectedInvoice);

		MobileInvoiceWrapper.ResponsePaymentWrapper response = new MobileInvoiceWrapper.ResponsePaymentWrapper();

		Map<String, String> params = new Map<String, String>();
		Date dataVencimento = FinancialMobileUtils.getRealDateInstance(selectedInvoice.formatDueDate);
		System.debug('dataVencimento: ' + dataVencimento);

		String startDate = String.valueOf(dataVencimento.addDays(-2)).Split(' ')[0];
		//params.put('startDate', '2019-01-30');
		//params.put('endDate', '2019-02-01');
		params.put('startDate', startDate);
		params.put('endDate', String.valueOf(dataVencimento));
		System.debug('getInvoiceDetail params: ' + params);

		Map<String, String> headers = new Map<String, String>();
		String authToken = getAuth('MobileInvoicesPaymentHistories');
		headers.put('X-Client-Auth', authToken);
		headers.put('X-QueryString', 'mobileBan=' + billingAccountId);
		//headers.put('X-QueryString', 'mobileBan=108680617');
		System.debug('getInvoiceDetail headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'MobileInvoicesPaymentHistories');
		//Map<String, String> calloutResponse = new Map<String, String>();
		//BEGIN MOCK
		//calloutResponse.put('response', '{"apiVersion":"1;2020-10-14","transactionId":"b639f781-b00c-42e4-8e96-733a605de1db","data":{"invoices":{"invoice":[{"monthReference":"11","startDate":"2009-10-13","endDate":"2009-11-13","issuanceDate":"2009-11-14","documentBank":[{"bankId":"422"}],"documentNumber":"123456789","invoiceNumber":"2342494","dueDate":"2009-11-15","situation":[{"situationId":"A_PAGAR","description":"À Pagar"}],"valueToPay":"25.00","paymentDate":"2009-11-17","paymentAmount":"20.00","valueAdjustment":"5.00","previousValue":"0.00","creditPrevious":"10.00","creditLater":"0.00","account":[{"mobile-ban":"654321","billingCycle":[{"code":"115"}],"client":[{"mobileClientId":"115"}]}],"onlineAccountCreationDate":"2009-11-14","dateLastUpdateOnlineAccount":"2009-11-17"}]}}}');
		//calloutResponse.put('statusCode', '200');
		//END MOCK

		System.debug('callout Reponse: ' + calloutResponse.get('response'));
		Integer responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
		String stringResponse = String.valueOf(calloutResponse.get('response'));
		System.debug('responseCode: ' + responseCode);
		System.debug('stringResponse: ' + stringResponse);
		if (responseCode == 200 && stringResponse.contains('"data":"NULL"')) {
			FinancialMobileUtils.processResponseCode(999);
		} else if (responseCode < 400) {
			System.debug('getInvoiceDetail Response < 400: ' + stringResponse);
			FinancialMobileInvoiceDetailsWrapper.ResponsePaymentHistories responseObject = (FinancialMobileInvoiceDetailsWrapper.ResponsePaymentHistories) JSON.deserialize(calloutResponse.get('response'), FinancialMobileInvoiceDetailsWrapper.ResponsePaymentHistories.class);
			System.debug('getInvoiceDetail responseObject: ' + responseObject.data.invoices);
			response.responseData = searchInvoice(responseObject, selectedInvoice);
		} else {
			FinancialMobileUtils.processResponseCode(response.apiResponse);
			response.errorMessage = calloutResponse.get('response');
			System.debug('getInvoiceDetail response.errorMessage: ' + response.errorMessage);
		}

		System.debug('getInvoiceDetail Response: ' + response);
		return response;
	}

	/**
	 * @description Retorna o token de autorizacao cadastrado no ServiceParameter
	 * @author Diego Almeida | 11-11-2020
	 * @param customSetting
	 * @return String
	 **/
	//@TestVisible
	private static String getAuth(String customSetting) {
		ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
		String token = setting.Token__c;
		return token;
	}

	/**
	* @description Completa os dados de pagamento de acordo com a resposta da api US104496
	*
	@author Caio Cesar | 17-12-2020
	* @param response
	* @param responseData
	* @return MobileInvoiceWrapper
	**/
	//@TestVisible
	private static MobileInvoiceWrapper.ResponseInvoice searchInvoice(FinancialMobileInvoiceDetailsWrapper.ResponsePaymentHistories responseObject, MobileInvoiceWrapper.ResponseInvoice responseData) {
			System.debug('searchInvoice: ' + responseObject.data.invoices.invoice.invoiceNumber + ' == billId: ' + responseData.noteFiscalNumber);
			if (responseObject.data.invoices.invoice.invoiceNumber == responseData.noteFiscalNumber) {
				responseData.payDate = formattedResponseDate(responseObject.data.invoices.invoice.paymentDate);
				responseData.paymentValue = responseObject.data.invoices.invoice.paymentAmount;
			}
		return responseData;
	}

	//@TestVisible
	private static String formattedResponseDate(String inputDate){
		String formattedYear = inputDate.split('-')[0];
		String formattedMonth = inputDate.split('-')[1];
		String formattedDay = inputDate.split('-')[2];
		String formattedDateOutput = formattedDay+'/'+formattedMonth+'/'+formattedYear;
		return formattedDateOutput;
	}

	public class MobileInvoicesWrapper {

		@AuraEnabled
		public Date billDate;
		@AuraEnabled
		public Long noteFiscalNumber = 0;
		@AuraEnabled
		public Date rawDueDate;
		@AuraEnabled
		public String formatDueDate;
		@AuraEnabled
		public Boolean isInvoiceNotPaid = true;
		@AuraEnabled
		public String status {
			get {
				return this.isInvoiceNotPaid ? 'Em Aberto' : 'Pago';
			}
			set {
			}
		}
		@AuraEnabled
		public Decimal rawAmount;
		@AuraEnabled
		public String formatAmount;
		@AuraEnabled
		public String type = 'Não definido';
		@AuraEnabled
		public String product = 'Não definido';
		@AuraEnabled
		public Boolean rawIsContested = false;
		@AuraEnabled
		public String formatIsContested {
			get {
				return this.rawIsContested ? 'Contestado' : 'Não Contestado';
			}
			set {
			}
		}
	}


	public class InvoicesControllerException extends Exception {
	}

}