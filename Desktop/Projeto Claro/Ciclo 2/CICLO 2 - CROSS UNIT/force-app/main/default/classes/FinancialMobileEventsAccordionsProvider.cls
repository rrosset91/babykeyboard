/**
 * @description       : Classe responsável por adicionar e gerenciar os accordions na aba de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos

 * @last modified on  : 03-11-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   26-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialMobileEventsAccordionsProvider {
    @AuraEnabled 
    public static List<FinancialMobileEventsWrapper.EventGroup> getAccordionsList(){
        List<FinancialMobileEventsWrapper.EventGroup> accordionsList = new List<FinancialMobileEventsWrapper.EventGroup>();
            

            FinancialMobileEventsWrapper.EventGroup accordionCompras = accordionSectionAdder('Compras e Movimentações', 'OAGClaro', '', false, null, true, true, false, false, false, null, false);
            accordionsList.add(accordionCompras);

            FinancialMobileEventsWrapper.EventGroup accordionReajustes = accordionSectionAdder('Reajustes', 'OAGClaro', '', false, null, true, true, false, false, false, null, false);
            accordionsList.add(accordionReajustes);

            FinancialMobileEventsWrapper.EventGroup accordionMigracoes = accordionSectionAdder('Migrações e Cancelamentos', 'OAGClaro', '', false, null, false, true, false, false, false, null, false);
            accordionsList.add(accordionMigracoes);

            FinancialMobileEventsWrapper.EventGroup accordionAgregadores = accordionSectionAdder('Agregadores', 'OAGClaro', 'GetSubscriberVas', false, null, false, true, true, false, false, null, true);
            accordionsList.add(accordionAgregadores);
            
            FinancialMobileEventsWrapper.EventGroup accordionRegistrosFinanceiro = accordionSectionAdder('Registros de Atendimento - Financeiro', 'OAGClaro', 'GetInteractions', true, 'financeiro', true, true, false, true, true, 'GetInteractionsProtocol', true);
            accordionsList.add(accordionRegistrosFinanceiro);
            
            FinancialMobileEventsWrapper.EventGroup accordionRegistrosCancelamento = accordionSectionAdder('Registros de Atendimento - Cancelamento', 'OAGClaro', 'GetInteractions', true, 'cancelamento', true, true, false, true, true, 'GetInteractionsProtocol', true);
            accordionsList.add(accordionRegistrosCancelamento);

            FinancialMobileEventsWrapper.EventGroup accordionTerminoOfertas = accordionSectionAdder('Término de Ofertas', 'OAGClaro', '', false, null, false, true, false, false, false, null, false);
            accordionsList.add(accordionTerminoOfertas);

            FinancialMobileEventsWrapper.EventGroup accordionPortabilidade = accordionSectionAdder('Portabilidade', 'OAGClaro', '', false, null, false, true, false, false, false, null, false);

            accordionsList.add(accordionPortabilidade);

        return accordionsList;
    }


    private static FinancialMobileEventsWrapper.EventGroup accordionSectionAdder(String accordionTitle, String namedCredential, String customSetting, Boolean hasMultipleGroups, String groupBy, Boolean hasModal, Boolean isActive, Boolean msisdn, Boolean crmCustomerId, Boolean callApiOnRowActions, String apiToCallOnRowAction, Boolean implemented){

        FinancialMobileEventsWrapper.EventGroup accordionSection = new FinancialMobileEventsWrapper.EventGroup();
        FinancialMobileEventsWrapper.EventRequestAttributes accordionAttributes = new FinancialMobileEventsWrapper.EventRequestAttributes();
        //Instanciando os atributos do accordion
        accordionAttributes.namedCredential = namedCredential;

        accordionAttributes.implemented = implemented;
        accordionAttributes.customSetting = customSetting;
        accordionAttributes.hasMultipleGroups = hasMultipleGroups;
        accordionAttributes.groupBy = groupBy;
        accordionAttributes.accordionId = accordionTitle.replace(' ','');
        accordionAttributes.accordionId = accordionAttributes.accordionId.replace('-','');
        accordionAttributes.callApiOnRowAction = callApiOnRowActions;
        accordionAttributes.apiToCallOnRowAction = apiToCallOnRowAction;
        //Instanciando os parametros do accordion
        accordionSection.accordionTitle = accordionTitle;
        accordionSection.requireMsisdn = msisdn;
        accordionSection.requireCrmCustomerId = crmCustomerId;
        accordionSection.accordionId = accordionTitle.replace(' ','');
        accordionSection.accordionId = accordionSection.accordionId.replace('-','');
        accordionSection.attributes = accordionAttributes;
        accordionSection.hasModal = hasModal;
        accordionSection.active = isActive;


        return accordionSection;
    }
}