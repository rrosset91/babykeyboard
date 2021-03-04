/**
 * @description       : Classe responsável por iterar os dados do wrapper de eventos e retornar um agrupamento pronto para o component
 * @author            : Roger Rosset
 * @group             : Financeiro
 * @last modified on  : 19-11-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   10-20-2020   Roger Rosset   Initial Version
 **/

public with sharing class FinancialMobileEventsController {
  /**
   * @description
   * @author Roger Rosset | 10-20-2020
   * @return List<FinancialMobileEventsWrapper.EventGroup> - Retorna a lista de accordions para o componente
   **/
  @AuraEnabled(cacheable=true)
  public static List<FinancialMobileEventsWrapper.EventGroup> eventsAccordionsProvider() {
    List<FinancialMobileEventsWrapper.EventGroup> accordionsList = FinancialMobileEventsAccordionsProvider.getAccordionsList();
    system.debug('@@Accordions List -->' + accordionsList);
    return accordionsList;
  }
  /**
   * @description
   * @author Roger Rosset | 10-20-2020
   * @return Este método monta a request necessária de acordo com o tipo de serviço chamado no accordion (Custom Setting)
   **/

  @AuraEnabled
  public static Map<String, Object> accordionsRequestBuilder(String requesterAccordionText, String baseAttributesText, String filterParamsText) {
    //TRANSFORMAÇAO DOS STRINGS DE REQUEST NOS WRAPPER CORRESPONDENTES:
    FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = parseRequesterAccordion(requesterAccordionText);
    FinancialMobileGeneralService.EntryPointWrapper baseAttributes = parseRequestAttributes(baseAttributesText);
    FinancialMobileFiltersWrapper.filterValues filterParams = parseFilterParams(filterParamsText);
    //AJUSTE DOS PARAMETROS, HEADERS E BODY PARA AS REQUISIÇÕES
    Map<String, String> params = FinancialMobileEventsRequestsBuilder.requestParams(requesterAccordion, baseAttributes, filterParams);
    Map<String, String> headers = FinancialMobileEventsRequestsBuilder.requestHeaders(requesterAccordion);
    String body = FinancialMobileEventsRequestsBuilder.requestBody(requesterAccordion);
    system.debug('@@Custom Setting -->' + requesterAccordion);
    system.debug('@@Params -->' + params);
    system.debug('@@Headers -->' + headers);
    system.debug('@@Body -->' + body);
    return accordionsRequestPerfomer(body, params, headers, requesterAccordion);
  }
  /**
   * @description
   * @author Roger Rosset | 10-20-2020
   * @return Este método executa a request necessária usando os parametros recebidos
   **/
  @AuraEnabled
  public static Map<String, Object> accordionsRequestPerfomer(String body, Map<String, String> params, Map<String, String> headers, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion){
    Map<String, Object> data = new Map<String, Object>();
    String serviceParameter = requesterAccordion.customSetting;
    try {
      Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(body, params, headers, serviceParameter);
      String responseJSON = calloutResponse.get('response');
      Boolean validResponse = checkValidResponse(
        responseJSON,
        Integer.valueOf(calloutResponse.get('statusCode'))
      );
      Integer responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
      if (responseCode == 200) {
        data.put('success', true);
        data.put('columnsData', FinancialMobileEventsResponsesBuilder.getAccordionColumns(requesterAccordion));
        data.put('modalFieldsData', FinancialMobileEventsResponsesBuilder.getModalFields(requesterAccordion));
        data.put('accordionData', FinancialMobileEventsResponsesBuilder.processResponse(responseJSON, requesterAccordion));
      	}else {
		data.put('success', false);
		FinancialMobileUtils.processResponseCode(responseCode);
		}
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    system.debug('@@DADOS RETORNADOS :' + data);
    return data;
  }

  //MÉTODOS RESPONSÁVEIS POR INSTANCIAR O WRAPPER DE ACORDO COM O STRING JSON RECEBIDO DO COMPONENT
  private static FinancialMobileEventsWrapper.EventRequestAttributes parseRequesterAccordion(String stringData) {
    FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion = new FinancialMobileEventsWrapper.EventRequestAttributes();
    FinancialMobileEventsWrapper.EventRequestAttributes request = (FinancialMobileEventsWrapper.EventRequestAttributes) JSON.deserialize(stringData, FinancialMobileEventsWrapper.EventRequestAttributes.class);

    requesterAccordion.customSetting = request.customSetting;
    requesterAccordion.groupBy = request.groupBy;
    requesterAccordion.hasMultipleGroups = request.hasMultipleGroups;
    requesterAccordion.namedCredential = request.namedCredential;
    requesterAccordion.accordionId = request.accordionId;

    return requesterAccordion;
  }

  private static FinancialMobileGeneralService.EntryPointWrapper parseRequestAttributes(String stringData) {
    FinancialMobileGeneralService.EntryPointWrapper baseAttributes = new FinancialMobileGeneralService.EntryPointWrapper();
    FinancialMobileGeneralService.EntryPointWrapper request = (FinancialMobileGeneralService.EntryPointWrapper) JSON.deserialize(stringData, FinancialMobileGeneralService.EntryPointWrapper.class);
    baseAttributes.contractAccountSalesforceId = request.contractAccountSalesforceId;
    baseAttributes.contractId = request.contractId;
    baseAttributes.customerAccountSalesforceId = request.customerAccountSalesforceId;
    baseAttributes.customerCrmId = request.customerCrmId;
    baseAttributes.isCase = request.isCase;
    baseAttributes.isN2User = request.isN2User;
    baseAttributes.msisdn = request.msisdn;
    baseAttributes.operatorId = request.operatorId;
    baseAttributes.recordId = request.recordId;

    return baseAttributes;
  }

  private static FinancialMobileFiltersWrapper.filterValues parseFilterParams(String stringData) {
    FinancialMobileFiltersWrapper.filterValues filterParams = new FinancialMobileFiltersWrapper.filterValues();
    FinancialMobileFiltersWrapper.filterValues request = (FinancialMobileFiltersWrapper.filterValues) JSON.deserialize(stringData, FinancialMobileFiltersWrapper.filterValues.class);
    filterParams.periodFilter = request.periodFilter;
    filterParams.isCustomDateFilter = request.isCustomDateFilter;
    filterParams.startDateFilter = request.startDateFilter;
    filterParams.endDateFilter = request.endDateFilter;
    filterParams.liveSearchFilter = request.liveSearchFilter;
    filterParams.productFilter = request.productFilter;
    filterParams.statusFilter = request.statusFilter;

    return filterParams;
  }
  
  public static Boolean checkValidResponse(
    String jsonResponse,
    Integer statusCode
  ) {
    Boolean validReturn;
    if (jsonResponse.contains('"data" : null') && statusCode == 200) {
      system.debug('RESPONSE INVÁLIDO');
      validReturn = false;
    } else {
      system.debug('RESPONSE VÁLIDO');
      validReturn = true;
    }
    return validReturn;
  }

  public class FinancialMobileEventsException extends Exception {
  }
}