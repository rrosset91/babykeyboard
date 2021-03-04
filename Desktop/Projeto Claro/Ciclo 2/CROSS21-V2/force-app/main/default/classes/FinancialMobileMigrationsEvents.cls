/**
 * @description       : 
 * @author            : Roger Rosset
 * @group             : Events mobile
 * @last modified on  : 19-11-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   12-11-2020   Roger Rosset   Initial Version
 * 
**/
public without sharing class FinancialMobileMigrationsEvents {
	/**
	 * --------------------------------- @MÉTODOS DE REQUEST  --------------------------------
	 **/
  
	/**
	 * @description Recebe o wrapper do accordion e retorna os parametros necessários para chamadas de api
	 * @author Roger Rosset | 23-10-2020
	 * @param FinancialMobileEventsWrapper.EventRequestAttributes baseAttributes
	 * @return Map<String, String>
	 **/
	public static Map<String, String> getParams(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion,FinancialMobileGeneralService.EntryPointWrapper baseAttributes,FinancialMobileFiltersWrapper.filterValues filterParams) {
		Map<String, String> params = new Map<String, String>();
		Integer period = filterParams.periodFilter;
		params.put('mobileBan', baseAttributes.contractId);
		params.put('memoLevel', 'TODOS');
		if (period != null) {
		  Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		  String startDateText = InvoicesUtils.formatDateToIntegration(startDate,false);
		  Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
		  String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
			params.put('startDate', startDateText);
			params.put('endDate', endDateText);
		} else if (
		  filterParams.startDateFilter != null &&
		  filterParams.endDateFilter != null
		) {
		  String startDateText = InvoicesUtils.formatDateToIntegration(filterParams.startDateFilter,false);
		  String endDateText = InvoicesUtils.formatDateToIntegration(filterParams.endDateFilter,false);
		  	params.put('startDate', startDateText);
			params.put('endDate', endDateText);
		}
		return params;
	  }
	
	  /**
	   * @description Recebe o wrapper do accordion e retorna os headers necessários para chamadas de api
	   * @author Roger Rosset | 23-10-2020
	   * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	   * @return Map<String, String>
	   **/
	  public static Map<String, String> getHeaders(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		Map<String, String> headers = new Map<String, String>();
		String token = FinancialMobileUtils.getAuth('GetMigrations');
		headers.put('Authorization', token);
		return headers;
	  }
	
	  /**
	   * @description Recebe o wrapper do accordion e retorna o body necessário para chamadas de api
	   * @author Roger Rosset | 23-10-2020
	   * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
	   * @return String
	   **/
	  public static String getBody(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		String body = '';
		return body;
	  }
	
	  /**
		* --------------------------------- @MÉTODOS DE RESPONSE  --------------------------------
		/**
		* @description Retorna uma lista tratada para o map
		* @author Roger Rosset | 23-10-2020 
		* @param String responseJSON 
		* @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion 
		* @return Object 
		**/

	  public static Object processJSON(String responseJSON, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
		system.debug('@@ACCORDION ---->' + requesterAccordion);
		List<JSONMigrationsEventsWrapper.memoObj> memoObjList = new List<JSONMigrationsEventsWrapper.memoObj>();
		JSONMigrationsEventsWrapper response = (JSONMigrationsEventsWrapper) JSON.deserialize(responseJSON,JSONMigrationsEventsWrapper.class);
		Boolean hasMultipleGroups = requesterAccordion.hasMultipleGroups;
		String groupBy = requesterAccordion.groupBy;
		if(response.data != null){
			for (JSONMigrationsEventsWrapper.memoObj item : response.data.memoObj) {
			if (item.memoDate != null) {
				item.memoDate = FinancialMobileUtils.formatResponseDate(item.memoDate,true);
				String stringDate = item.memoDate.split('-')[0];
				stringDate = stringDate.replace(' ', '');

				String stringTime = item.memoDate.split('-')[1];
				stringTime = stringTime.replace(' ', '');
		
				item.realMemoDate = FinancialMobileUtils.getRealDateTimeInstance(stringDate,stringTime);
				item.formattedMemoTime = stringTime;
				item.formattedMemoDate = stringDate;
				item.formattedMemoDateTime = stringDate+ ' - ' +stringTime;
			}
			item.relatedAccordion = requesterAccordion.accordionId;
				if(item.memoCategoryDesc == 'Cancelar assinante'){
					memoObjList.add(item);
				}
			}
		}
		system.debug(
		  '@@Response Tratado -->' + JSON.serializePretty(memoObjList)
		);
		return JSON.serializePretty(memoObjList);
	  }
	
	  /**
	   * @description Retorna um JSON com as colunas do Datatable
	   * @author Roger Rosset | 23-10-2020
	   * @return Object
	   **/

	  public static Object getColumns() {
		List<FinancialDataTableUtils.Columns> columnsData = new List<FinancialDataTableUtils.Columns>();
		//Definindo as colunas e adicionando à listagem
		FinancialDataTableUtils.Columns column1 = new FinancialDataTableUtils.Columns();
		column1.label = 'Tipo';
		column1.fieldName = 'memoCategoryDesc';
		column1.sortable = true;
		column1.type = 'text';
		columnsData.add(column1);
		FinancialDataTableUtils.Columns column2 = new FinancialDataTableUtils.Columns();
		column2.label = 'ID do Usuário';
		column2.fieldName = 'memoUserId';
		column2.sortable = true;
		column2.type = 'text';
		columnsData.add(column2);
		FinancialDataTableUtils.Columns column3 = new FinancialDataTableUtils.Columns();
		column3.label = 'Data';
		column3.fieldName = 'formattedMemoDate'; 
		column3.sortable = true;
		column3.type = 'text';
		columnsData.add(column3);

		system.debug('@@Colunas -->' + JSON.serializePretty(columnsData));
		return JSON.serializePretty(columnsData);
	  }
}