/**
 * @description       : Classe responsável por orquestrar os retornos de api da tela de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos
 * @last modified on  : 23-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialMobileEventsResponsesBuilder {
    /**
    * @description Retorna o WRAPPER DO RESPONSE de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param Wrapper requesterAccordion , String responseJSON
    * @return Object 
    **/
    public static Object processResponse(String responseJSON , FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.processJSON(responseJSON, requesterAccordion);
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.processJSON(responseJSON, requesterAccordion);
            }
            when else {
                return null;
            }
        }
    }

    /**
    * @description Retorna o WRAPPER DAS COLUNAS  de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param Wrapper requesterAccordion
    * @return Object
    **/
    public static Object getAccordionColumns(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.getColumns();
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.getColumns();
            }
            when else {
                return null;
            }
        }
    }

    /**
    * @description Retorna o WRAPPER DOS CAMPOS DE MODAL  de acordo com o accordion solicitante
    * @author Roger Rosset | 20-10-2020 
    * @param Wrapper requesterAccordion
    * @return Object
    **/
    public static Object getModalFields(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String accordionService = requesterAccordion.customSetting;
        switch on accordionService {
            when 'GetSubscriberVas' {
                return FinancialMobileSubscribersEvents.getModalFields();
            }
            when 'GetInteractions' {
                return FinancialMobileInteractionsEvents.getModalFields();
            }
            when else {
                return null;
            }
        }
    }
}