/**
 * @description       : Classe responsável por orquestrar as chamadas de api da tela de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro - Eventos
 * @last modified on  : 27-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialMobileEventsRequestsBuilder {

    /**
    * @description Retorna o Map de parametros necessários de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param String requesterAccordion 
    * @return Map<String, String> 
    **/
    public static Map<String,String> requestParams(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion, FinancialMobileGeneralService.EntryPointWrapper baseAttributes, FinancialMobileFiltersWrapper.filterValues filterParams) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.getParams(requesterAccordion, baseAttributes, filterParams);
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.getParams(requesterAccordion, baseAttributes, filterParams);
            }
            when else {
                return null;
            }
        }
    }

    /**
    * @description Retorna o Map de headers necessários de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param String requesterAccordion 
    * @return Map<String, String> 
    **/
    public static Map<String,String> requestHeaders(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.getHeaders(requesterAccordion);
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.getHeaders(requesterAccordion);
            }
            when else {
                return null;
            }
        }
    }

    /**
    * @description Retorna o Body (String) de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param String requesterAccordion 
    * @return String
    **/
    public static String requestBody(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.getBody(requesterAccordion);
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.getBody(requesterAccordion);
            }
            when else {
                return null;
            }
        }
    }
}