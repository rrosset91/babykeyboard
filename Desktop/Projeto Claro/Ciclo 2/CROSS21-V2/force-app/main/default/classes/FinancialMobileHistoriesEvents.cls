public with sharing class FinancialMobileHistoriesEvents {
	/**
	 * --------------------------------- @MÉTODOS DE REQUEST  --------------------------------
	 **/

	/**
	 * @description Retorna os parametros necessários para chamadas de API
	 * @author Roger Rosset | 30-12-2020
	 * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	 * @param FinancialMobileGeneralService.EntryPointWrapper baseAttributes
	 * @param FinancialMobileFiltersWrapper.filterValues filterParams
	 * @return Map<String, String>
	 **/
	public static Map<String, String> getParams(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion, FinancialMobileGeneralService.EntryPointWrapper baseAttributes, FinancialMobileFiltersWrapper.filterValues filterParams) {
		Map<String, String> params = new Map<String, String>();
		Integer period = filterParams.periodFilter;
		params.put('ban', baseAttributes.contractId);
		if (period != null) {
			Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
			String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
			Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
			String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
			params.put('startDate', startDateText);
			params.put('endDate', endDateText);
		} else if (filterParams.startDateFilter != null && filterParams.endDateFilter != null) {
			String startDateText = InvoicesUtils.formatDateToIntegration(filterParams.startDateFilter, false);
			String endDateText = InvoicesUtils.formatDateToIntegration(filterParams.endDateFilter, false);
			params.put('startDate', startDateText);
			params.put('endDate', endDateText);
		}
		return params;
	}

	/**
	 * @description Retorna os headers para chamadas de API
	 * @author Roger Rosset | 30-12-2020
	 * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	 * @return Map<String, String>
	 **/
	public static Map<String, String> getHeaders(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		Map<String, String> headers = new Map<String, String>();
		return headers;
	}

	/**
	 * @description Retorna o body necessário para chamadas de api
	 * @author Roger Rosset | 30-12-2020
	 * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	 * @return String
	 **/
	public static String getBody(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		String body = '';
		return body;
	}

	/**
	 * --------------------------------- @MÉTODOS DE RESPONSE  --------------------------------
	 **/

	/**
	 * @description  MÉtodo responsável por tratar o JSON de response retornado da API.
	 * @author Roger Rosset | 30-12-2020
	 * @param String responseJSON
	 * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	 * @return Object
	 **/
	public static Object processJSON(String responseJSON, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		FinancialMobileHistoriesEventsWrapper response = (FinancialMobileHistoriesEventsWrapper) JSON.deserialize(responseJSON, FinancialMobileHistoriesEventsWrapper.class);
		List<FinancialMobileHistoriesEventsWrapper.Offers> offersList = new List<FinancialMobileHistoriesEventsWrapper.Offers>();
		if (response.data != null) {
			for (FinancialMobileHistoriesEventsWrapper.Accountevent item : response.data.Accountevent) {
				for (FinancialMobileHistoriesEventsWrapper.Contract contract : item.contract) {
					system.debug('OFFERS--->' + contract.offers);
					for (FinancialMobileHistoriesEventsWrapper.Offers offer : contract.offers) {
						system.debug('CURRENT OFFER ---->' + offer);
						offer.formattedAccessionDate = FinancialMobileUtils.formatResponseDate(offer.accessionDate, false);
						offer.formattedExpirationDate = FinancialMobileUtils.formatResponseDate(offer.expirationDate, false);
						offer.realAccessionDate = FinancialMobileUtils.getRealDateInstance(offer.accessionDate);
						offer.realExpirationDate = FinancialMobileUtils.getRealDateInstance(offer.expirationDate);
						offersList.add(offer);
					}
				}
			}
		}
		system.debug('@@Response Tratado -->' + JSON.serializePretty(offersList));
		return JSON.serializePretty(offersList);
	}

	/**
	 * @description Retorna as colunas para serem exibidas no front-end
	 * @author Roger Rosset | 30-12-2020
	 * @return Object
	 **/
	public static Object getColumns() {
		List<FinancialDataTableUtils.Columns> columnsData = new List<FinancialDataTableUtils.Columns>();
		FinancialDataTableUtils.Columns column1 = new FinancialDataTableUtils.Columns();
		column1.label = 'Nome';
		column1.fieldName = 'offerDescription';
		column1.sortable = true;
		column1.type = 'text';
		columnsData.add(column1);
		FinancialDataTableUtils.Columns column2 = new FinancialDataTableUtils.Columns();
		column2.label = 'Data Adesão';
		column2.fieldName = 'formattedAccessionDate';
		column2.sortable = true;
		column2.type = 'text';
		columnsData.add(column2);
		FinancialDataTableUtils.Columns column3 = new FinancialDataTableUtils.Columns();
		column3.label = 'Data Expiração';
		column3.fieldName = 'formattedExpirationDate';
		column3.sortable = true;
		column3.type = 'text';
		columnsData.add(column3);
		FinancialDataTableUtils.Columns column4 = new FinancialDataTableUtils.Columns();
		column4.label = 'Status';
		column4.fieldName = 'status';
		column4.sortable = true;
		column4.type = 'text';
		columnsData.add(column4);

		system.debug('@@Colunas -->' + JSON.serializePretty(columnsData));
		return JSON.serializePretty(columnsData);
	}

	/**
	 * @description Retorna os campos para serem exibidos em eventuais modais
	 * @author Roger Rosset | 30-12-2020
	 * @return Object
	 **/
	public static Object getModalFields() {
		return null;
	}
}